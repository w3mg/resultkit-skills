# Integration Test Pattern

Use this when starting step 3 of the loop — you have the fixture shape from step 2 and need to write the actual test file.

## Why integration, not unit

A unit test with mocked Prisma calls cannot reveal a bug whose nature is "the wrong rows were fetched" or "the JOIN missed rows in a sibling table." The mock returns whatever you tell it to. Legacy-data bugs almost always involve real schema interactions — nested-set walks, cross-table JOINs, default values, NULL semantics — and only an integration test against the real schema catches them.

If you find yourself reaching for `jest.mock('@/lib/prisma', ...)` to test this bug, stop. You're testing the wrong layer.

## Canonical template

The shipped example in resultmaps-api2 (commit `f32e46e2`):

```
tests/integration/v2/seats-org-tree.integration.test.ts
```

Read it before writing yours. The structure below mirrors it.

## Structure

```ts
/**
 * V2 Integration: <one-line summary of the endpoint and what symptom this covers>
 *
 * <Two-paragraph context block: what the customer reports, what the production
 * data actually looks like, and why this fixture demonstrates the bug.>
 */

import '../setup';                                  // boots the real test DB + seed
import { TOKENS, USERS, ACCOUNTS } from '../seed';  // existing auth/account anchors
import { v2 } from './helpers';                     // route invocation helper
import { prisma } from '../prisma-test-client';     // real Prisma client (NOT a mock)

const ROUTE = '<path-to-route-handler-relative-to-src/app/api/v2>';

// Fixture IDs — above existing seed range
const ROOT_GROUP_ID = 91050;
const SUB_GROUP_A_ID = 91051;
// ...

describe('<endpoint> — <bug shape> regression', () => {
  beforeAll(async () => {
    // Create groups + parent rows BEFORE child rows
    // Set group.user_id = an existing test user → isTeamAdmin returns true
    // Include lft/rgt if the code walks the group hierarchy
  }, 30000);

  afterAll(async () => {
    // Delete in REVERSE order: children first, then parents
  }, 30000);

  it('<asserts the quantified prod-data answer>', async () => {
    const { status, body } = await v2(
      'GET',
      `/api/v2/...`,
      ROUTE,
      TOKENS.a1_owner,
      { id: String(ROOT_GROUP_ID) }
    );

    expect(status).toBe(200);

    // Assert the shape that matches the prod-data observation
    // For depth bugs: walk the tree, compare to the prod-measured depth
  });
});
```

## Auth anchoring — use existing test users

Don't fabricate test users. The seed already has `USERS.a1_owner`, `USERS.a1_member`, etc., each with valid tokens in `TOKENS.*`. Pick one and re-use it.

To make permission checks pass without creating `GroupMembership` rows: set `group.user_id = USERS.a1_owner.id` on the groups you create. Most permission helpers (`isTeamAdmin`, `canViewGroup`, etc.) short-circuit to allow when the user is the creator. This saves you a whole class of fixture rows.

If the bug requires a non-creator viewer (e.g. testing what a regular member sees), then you do need a `GroupMembership` row. But for most legacy-data bugs, the question is "what does the API return," not "who can see what" — use the creator.

## Nested-set columns

If the code walks the group hierarchy via `lft`/`rgt` (look for `getGroupAncestorIds`, `getGroupDescendantIds`, or raw queries against `lft`/`rgt` in `groups`), your fixture **must** set valid nested-set coordinates. Otherwise the descendant walk returns empty and your test fails for the wrong reason.

Pattern for a 3-group fixture (root + 2 sub-teams):

```
root: lft=10050, rgt=10055
  sub-A: lft=10051, rgt=10052
  sub-B: lft=10053, rgt=10054
```

The rule: parent's range `[lft, rgt]` strictly contains each child's range. Adjacent sibling ranges don't overlap. Pick a window (e.g. 10050-10055) that's clearly yours and not used elsewhere.

## Cleanup order matters

In `afterAll`, delete in **reverse FK order**: children before parents. For the seat fixture:

```ts
afterAll(async () => {
  await prisma.seat.deleteMany({ where: { id: { in: [SEAT_L1, ..., SEAT_L7] } } });
  await prisma.group.deleteMany({ where: { id: { in: [SUB_GROUP_A_ID, SUB_GROUP_B_ID, ROOT_GROUP_ID] } } });
}, 30000);
```

Seats reference groups, so seats go first. If you flip the order, you get FK violation errors that mask the real test result.

If your fixture touches `object_metas`, `linked_urls`, `accountabilities`, or other sub-resource tables, delete those first too.

## Running the test

```bash
docker compose -f docker-compose.test.yml up -d                                # start MySQL once
npm run test:integration -- tests/integration/v2/<your-test-file>.integration.test.ts
```

If Prisma errors with "Unknown argument" or similar, run `npx prisma generate` first — the test DB schema may be ahead of the generated client.

Always pipe to `tee` so you don't lose the output to terminal truncation:

```bash
npm run test:integration -- tests/integration/v2/your-test.integration.test.ts 2>&1 | tee /tmp/test-results.txt | grep -E "PASS|FAIL|Tests:|✕|✓|Expected|Received"
```

## Regression-sweep after the fix

After the test goes green:

```bash
npm test -- --testPathPatterns="<feature-keyword>"    # run all adjacent unit/api tests
npm run type-check                                    # tsc --noEmit clean
```

If your fix changed a function signature, mock-based tests in adjacent files will fail with assertions like `Expected: 10, false  Received: [10], false, 10`. Update those assertions — don't delete the tests. The mock now expects the new shape.

## Worked example — the file shipped in #263

```ts
// tests/integration/v2/seats-org-tree.integration.test.ts (shipped as commit f32e46e2)

import '../setup';
import { TOKENS, USERS, ACCOUNTS } from '../seed';
import { v2 } from './helpers';
import { prisma } from '../prisma-test-client';

const ROUTE = 'teams/[id]/seats/route';

const ROOT_GROUP_ID = 91050;
const SUB_GROUP_A_ID = 91051;
const SUB_GROUP_B_ID = 91052;
const SEAT_L1 = 91100; // ... through SEAT_L7 = 91106

describe('GET /api/v2/teams/:id/seats?context=organization — Mender shape', () => {
  beforeAll(async () => {
    const now = new Date();
    await prisma.group.createMany({
      data: [
        { id: ROOT_GROUP_ID,  name: 'Mender (Org Root)',     account_id: ACCOUNTS.account1.id,
          user_id: USERS.a1_owner.id, public: false, parent_id: null,
          lft: 10050, rgt: 10055, created_at: now, updated_at: now },
        { id: SUB_GROUP_A_ID, name: 'Settlements',           account_id: ACCOUNTS.account1.id,
          user_id: USERS.a1_owner.id, public: false, parent_id: ROOT_GROUP_ID,
          lft: 10051, rgt: 10052, created_at: now, updated_at: now },
        { id: SUB_GROUP_B_ID, name: 'Production Operations', account_id: ACCOUNTS.account1.id,
          user_id: USERS.a1_owner.id, public: false, parent_id: ROOT_GROUP_ID,
          lft: 10053, rgt: 10054, created_at: now, updated_at: now },
      ],
    });
    await prisma.seat.createMany({ data: [ /* 7-seat chain */ ] });
  }, 30000);

  afterAll(async () => {
    await prisma.seat.deleteMany({ where: { id: { in: [/* L1..L7 */] } } });
    await prisma.group.deleteMany({ where: { id: { in: [SUB_GROUP_A_ID, SUB_GROUP_B_ID, ROOT_GROUP_ID] } } });
  }, 30000);

  it('returns the full 7-level org tree across sub-team groups', async () => {
    const { status, body } = await v2(
      'GET',
      `/api/v2/teams/${ROOT_GROUP_ID}/seats?context=organization`,
      ROUTE,
      TOKENS.a1_owner,
      { id: String(ROOT_GROUP_ID) }
    );
    expect(status).toBe(200);
    // ... walk tree, expect maxDepth === 7
  });
});
```

First run: `Expected: 7  Received: 4` ✕ — the production symptom, exactly.

## Stop conditions for step 3

Test file is ready to run when:
- All imports resolve (no `@/...` paths that don't exist in this repo).
- The fixture compiles (TypeScript clean).
- `beforeAll` creates everything in correct FK order; `afterAll` cleans up in reverse.
- The assertion encodes the prod-measured number from step 1.

Then run it. If it fails with the expected mismatch — proceed to step 5 (fix). If it errors out or fails for a different reason — go back to step 2 (your fixture isn't reproducing the bug).
