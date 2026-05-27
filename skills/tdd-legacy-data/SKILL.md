---
name: rkit:tdd-legacy-data
description: >
  Run a tight TDD loop on bugs that only show up against real customer data in a
  legacy/production-data system. Use this skill whenever a user reports a customer-specific
  bug ("X is wrong for customer Y", "this account shows 4 but should be 7", "the chart is
  missing rows"), whenever a fix would otherwise be speculative without seeing the actual
  data shape, whenever the user says "validate with data" / "validate against the database" /
  "check the data first" before doing anything else, and whenever working on bugs in
  resultmaps-api2, resultmaps-web, or any other service backed by legacy production data.
  Especially trigger when DB query access is available (e.g. rm-db-query is in the skill set) —
  that combination is the whole point of this skill. Do not use for greenfield TDD (use
  test-driven-development), UI/visual bugs (use playwright), or bugs trivially reproducible
  with a hand-written fixture.
user-invocable: true
---

# TDD on Legacy Production Data

## Why this skill exists

The generic `test-driven-development` skill assumes you already know what to test. The unique value here is the **upstream step**: when a bug only shows up against real customer data, you must extract the failing data shape from production *before* you can write a meaningful test. Skip this and you'll either write a test that doesn't reproduce the bug, or you'll "fix" something that wasn't actually broken.

This skill exists because speculative fixes in legacy-data systems are expensive — they ship, they look right, they don't actually solve the customer's problem, and the bug comes back. The cost of 10 minutes querying production data is far less than the cost of a wrong fix.

## When to use this

Trigger when **all** of the following are true:
- A bug is reported against a system backed by real production data.
- You have read-only DB access (e.g. `rm-db-query` or equivalent).
- The bug's existence or shape is not obvious from the code alone.

Skip when:
- The bug is reproducible with a trivial fixture you already understand.
- The bug is UI-only (use playwright / visual loops instead).
- You're building something net-new (use `test-driven-development`).

## The five-step loop

### 1. Validate the bug exists in prod data
Query the real database to confirm the customer's claim and capture the exact data shape that triggers it. Don't move on until the prod query *quantifies* the bug (e.g. "tree is 7 levels deep, app shows 4").

→ See [references/validate-with-prod.md](references/validate-with-prod.md) for query patterns: finding a customer by name, walking parent_id chains, counting tree depth, finding orphaned cross-group references.

### 2. Extract the minimum reproducing data shape
Take the prod shape and scale it down to the smallest fixture that still reproduces the bug. The fixture must cross the *critical boundary* — the place where the production data does something the code doesn't handle. If you skip the boundary, the test passes against buggy code and proves nothing.

→ See [references/extract-fixture.md](references/extract-fixture.md) for the minimization heuristic, naming conventions, and ID-range rules.

### 3. Write a failing integration test that seeds that shape
Self-contained `beforeAll` / `afterAll` fixtures. Do not edit shared seed files — too much blast radius. Use the project's existing test users / accounts / tokens as the auth anchor so you don't have to fabricate identity machinery.

→ See [references/integration-test-pattern.md](references/integration-test-pattern.md) for the canonical template (resultmaps-api2 `tests/integration/v2/seats-org-tree.integration.test.ts`, shipped as commit `f32e46e2`).

### 4. Run it — confirm Expected vs Received matches the prod symptom
This is the gate. If the test fails with a different number than what production showed, your fixture doesn't reproduce the real bug — go back to step 2. Don't proceed to a fix on a test that fails for the wrong reason.

For the worked example: production walk showed Mender's tree was 7 levels deep; the chart showed 4; the failing test reported `Expected: 7  Received: 4`. The numbers matched — the fixture was a faithful mini-Mender.

### 5. Fix until green, then regression-sweep adjacent tests
Make the test pass with the smallest reasonable change. Then run every neighbouring test suite (e.g. `npm test -- --testPathPatterns="<feature>"`) and the type-checker. If your fix changes a function signature, the old mocks in nearby tests will break — update them, don't disable them.

## Worked example (cite throughout)

**Issue:** resultmaps-api2 #263 — Mender's accountability chart showed max 4 levels; customer reported 7.

1. **Validate:** Used `rm-db-query` to find `groups.name = 'Mender'` → group 2707, account 1921. Walked seats with cross-group `parent_id` chains: tree was 7 levels deep, but the API only returned 4 because `getTeamSeatTree` filtered by single `group_id` and sub-team seats lived in other groups.
2. **Extract:** Minimum repro was 3 groups (root + 2 sub-teams with nested-set `lft`/`rgt`) and a 7-seat chain that crossed `group_id` boundaries at L4→L5 and L5→L6 — the exact boundary the buggy code skipped.
3. **Test:** Created `tests/integration/v2/seats-org-tree.integration.test.ts` with self-contained `beforeAll` / `afterAll`. Used `USERS.a1_owner` as auth anchor by setting `group.user_id = 90001` so `isTeamAdmin` returned true without fabricating membership rows.
4. **Confirm:** First run failed with `Expected: 7  Received: 4` — exact match to the production symptom.
5. **Fix:** Added `getGroupDescendantIds` (nested-set query, mirror of the existing ancestor helper) + changed `getTeamSeatTree` to accept a `group_id` set. Test went green. 279 sibling tests still passed. `tsc --noEmit` clean. Shipped as commit `f32e46e2`.

Total cycle time: ~30 minutes. Cost of a speculative fix that "looked right" but missed the cross-group boundary: a re-open and another round of triage.

## Anti-patterns

- **Skipping step 1.** "I think I know what the bug is" — that's the trap. Even a 60-second prod query frequently reveals the real shape is not what you assumed.
- **Over-mocking.** A unit test with mocked Prisma calls cannot reveal a bug whose nature is "the wrong rows were fetched." Use an integration test against a real DB schema.
- **Fixtures that don't cross the boundary.** If your test fixture all lives in one `group_id`, you can't reproduce a cross-`group_id` bug. The fixture must contain the structural feature the production code mishandles.
- **Editing shared seed files.** Adds blast radius across the whole test suite. Use self-contained `beforeAll` / `afterAll` blocks.
- **Stopping at green.** Always run the adjacent test files and the type-checker. Signature changes almost always break a sibling mock somewhere.
