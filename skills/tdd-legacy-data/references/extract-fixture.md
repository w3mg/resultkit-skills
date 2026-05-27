# Extract the Minimum Reproducing Fixture

Use this when starting step 2 of the loop — you have a quantified prod-data claim from step 1 and need to design a self-contained test fixture that reproduces the same shape.

## The goal

Translate the production data shape into the **smallest possible fixture that still crosses the bug-triggering boundary**. The fixture must contain the structural feature the production code mishandles. If it doesn't, your test will pass against buggy code and prove nothing.

This is the hardest step to get right and the one most often skipped.

## The minimization heuristic

Production data has noise — hundreds of seats, dozens of teams, archived rows, irrelevant attributes. Most of it doesn't matter to the bug. Strip it down by asking:

1. **What is the structural feature the bug depends on?** (e.g. a parent_id chain that crosses group_id boundaries; a row in account A referencing account B; a deeply-nested tree)
2. **What is the minimum number of rows that exhibits that feature?** (e.g. for cross-group chain: 2 groups + 2 seats. For *demonstrating depth across the cross-group boundary*: at least 1 seat on each side of the boundary, plus enough depth above and below to make the depth measurement meaningful.)
3. **Can I drop any attribute without changing the answer?** (e.g. owners, archived rows, names — usually yes. Foreign-key relationships that the code reads — no.)

The fixture you ship is the answer to #2 plus any attributes from #3 that are required (not_null columns, FKs the code dereferences).

## The "cross the boundary" rule

This is where most failing tests fail to actually demonstrate the bug.

**If your fixture is entirely inside one `group_id` / one account / one tenant, you cannot reproduce a cross-`group_id` / cross-account / cross-tenant bug.**

For the Mender case (#263), the bug was that `getTeamSeatTree` filtered by single `group_id` and missed sub-team seats whose `parent_id` chained back into the root team. The fixture had to:

- Have at least 3 groups (root + 2 sub-teams) so the descendant-walk had something to walk.
- Have a `parent_id` chain that **crossed `group_id`** at least twice (root→sub-A and sub-A→sub-B) so the test caught both the "first jump" bug and the "subsequent jump" bug.
- Be deep enough (7 levels) so the wrong answer (4) was distinguishable from the right answer (7).

A fixture with all 7 seats in one group_id would have passed against the buggy code (the bug had nothing to do with depth-within-a-group). Useless.

## Naming conventions

**Use realistic role names from the production data.** When the test fails, you want the failure message to read like the customer's actual org chart, not `seat_A`/`seat_B`/`seat_C`. This pays off in two ways:

- The failure makes intuitive sense to anyone reading the test later (including future-you).
- When the customer asks "is this the same bug we reported?" you can point at the fixture and they'll recognize it.

For Mender we used: `CEO & Visionary`, `COO & Integrator`, `VP Product Operations`, `Production Manager`, `Test/QC Lead`, `Data Entry/Test Rack Jr`, `Desktop Test Tech` — lifted directly from prod.

## ID-range conventions

Pick test fixture IDs **above the existing seed range** so they can't collide.

In resultmaps-api2 the existing test seed uses IDs in the 90000s. New self-contained fixtures should use 91000+ (or higher if 91000s are taken). For Mender we used:

- Groups: 91050 (root), 91051 (sub-A), 91052 (sub-B)
- Seats: 91100 (L1) through 91106 (L7)

The contiguous block (91100-91106) makes the chain visually obvious in the fixture code. The 91050s and 91100s are far enough apart that no future fixture will accidentally overlap.

For nested-set `lft`/`rgt` values, use a range nobody else is using — we picked 10050-10055. Same principle: pick a window that's obviously yours.

## Required attributes (don't skip these)

Easy to forget; will cause `PrismaClientValidationError` or fail-without-message bugs:

- **`account_id`** on groups — required by most multi-tenant code paths.
- **`user_id`** on groups — set to an existing test user (e.g. `USERS.a1_owner.id`) so `isTeamAdmin` returns true via the creator-override path. Saves you fabricating a `GroupMembership` row.
- **`lft` / `rgt`** on groups when the code walks the group hierarchy via nested-set queries (descendant or ancestor lookups). Without these, the descendant query returns empty and your test fails for the wrong reason.
- **`created_at` / `updated_at`** — often required (NOT NULL).
- **`parent_id`** on the seats / nodes — the whole point of the chain. Easy to forget on row L1 (must be `null`, not omitted, depending on Prisma version).

## Drop these (usually)

- **Sub-resources** the bug doesn't touch (measures, goals, links, comments). Leaving them empty is fine.
- **Archived rows** unless the bug is about archival.
- **Optional metadata** the code doesn't read.

The fixture file should be readable in one screen. If it's not, you're including stuff that doesn't matter.

## Worked example fixture (Mender, #263)

```ts
// IDs picked to be above existing seed range; nested-set window 10050..10055
const ROOT_GROUP_ID = 91050;
const SUB_GROUP_A_ID = 91051;
const SUB_GROUP_B_ID = 91052;

const SEAT_L1 = 91100; // CEO
const SEAT_L2 = 91101; // COO
const SEAT_L3 = 91102; // VP Ops
const SEAT_L4 = 91103; // Mgr — boundary; last seat in root group
const SEAT_L5 = 91104; // Lead — sub-group A (parent crosses into root group)
const SEAT_L6 = 91105; // Jr  — sub-group B (parent crosses sub-A → sub-B)
const SEAT_L7 = 91106; // IC  — sub-group B
```

The fixture is 3 groups + 7 seats. It crosses the boundary twice (L4→L5 and L5→L6). Anything smaller (e.g. 2 groups + 4 seats) wouldn't demonstrate that the fix works for chains that recurse across multiple sub-teams.

## Stop conditions for step 2

You're done designing the fixture when:
- You can sketch the chain on paper and point to the row where the bug triggers.
- You've counted the minimum rows and you're not carrying extras.
- All required FK / NOT NULL columns are accounted for.
- You can name what your fixture's `expect()` assertion will be (e.g. `expect(maxDepth(root)).toBe(7)`).

Then proceed to step 3 ([references/integration-test-pattern.md](integration-test-pattern.md)).
