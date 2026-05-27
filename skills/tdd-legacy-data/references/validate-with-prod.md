# Validate with Production Data

Use this when starting step 1 of the loop — you need to confirm a bug exists in production data and capture its exact shape before writing a test.

## The goal

Turn the user's report ("the chart shows 4 levels but should show more") into a **quantified, queryable claim** ("for account 1921, the seats tree walked via `parent_id` is 7 levels deep; the API returns 4"). The quantified version is what becomes the assertion in your failing test.

## Tools

In the ResultMaps stack: `rm-db-query` (read-only, project-scoped). Other projects will have their own DB-access skill or a `mysql`/`psql` shell. The patterns below are SQL-shaped but the principle is universal.

`rm-db-query` rules to remember:
- Use backticks around reserved words: `` `groups` `` not `groups`.
- The wrapper blocks `WITH` (CTEs). Walk hierarchies with progressive `JOIN`s or pull rows in `--batch` mode and chase parent_ids in your head / a scratch script.
- Default `LIMIT 100` is auto-injected on `SELECT` without `LIMIT` — bump it explicitly when you need a full tree.

## Common queries

### Find the customer / account by name

```sql
SELECT id, name FROM `groups` WHERE name LIKE '%Mender%' LIMIT 20;
```

Watch for **multiple matches** (e.g. `Mender` and `mender` — different accounts). Always confirm `account_id` to pick the right one.

### Find all sub-groups under a customer

```sql
SELECT id, name, parent_id, account_id
FROM `groups`
WHERE id = :rootId OR parent_id = :rootId
ORDER BY id;
```

This reveals the customer's organizational structure. If the bug is about hierarchy or cross-team rollup, the count of sub-groups is usually the first surprise.

### Walk a parent_id chain to find tree depth

When you can't use a CTE, pull all rows and reconstruct in your head (or a 10-line script):

```sql
SELECT id, parent_id, name, group_id
FROM seats
WHERE group_id IN (:rootId, :sub1, :sub2, ...)
  AND archived_at IS NULL
ORDER BY parent_id, id;
```

Then trace: find rows with `parent_id IS NULL` (roots), then `parent_id IN (root_ids)`, etc. The depth at which you stop finding children is the actual tree depth.

### Find cross-reference / orphan rows

The "smoking gun" for a lot of legacy data bugs is a row whose `parent_id` points somewhere the code doesn't expect (different group, different account, archived row).

```sql
-- Seats whose parent lives in a different group_id
SELECT s.id, s.name, s.group_id AS child_group, p.group_id AS parent_group
FROM seats s
JOIN seats p ON p.id = s.parent_id
WHERE s.group_id != p.group_id
  AND s.archived_at IS NULL
  AND p.archived_at IS NULL;
```

### Confirm the API symptom

After you have the prod-data answer, hit the actual endpoint (curl, API skill, or check the UI) and write down what it returns. Test will assert against the prod-data answer; you've now proven the API disagrees.

## Worked example — Mender accountability chart (#263)

1. **Find the customer:**
   ```sql
   SELECT id, name FROM `groups` WHERE name LIKE '%Mender%';
   -- → 2707 Mender (account 1921), 2769 mender (account 1947 — empty)
   ```
2. **Count their seats and sub-groups:**
   ```sql
   SELECT COUNT(*) FROM seats WHERE group_id = 2707 AND archived_at IS NULL;
   -- → 25
   SELECT id, name FROM `groups` WHERE parent_id = 2707;
   -- → 13 sub-teams (Leadership Team, Production Operations, Settlements, IT, ...)
   ```
3. **Pull full seat set across the account:**
   ```sql
   SELECT s.id, s.parent_id, s.name, s.group_id, g.name AS group_name
   FROM seats s JOIN `groups` g ON g.id = s.group_id
   WHERE g.account_id = 1921 AND s.archived_at IS NULL
   ORDER BY s.parent_id, s.id LIMIT 200;
   ```
4. **Walk by hand:** L1 CEO (1280) → L2 COO (1281) → L3 VP Product Ops (1283) → L4 Production Manager (1366) → **L5 Test/QC Lead (1418, group 2725 — Settlements)** → **L6 Data Entry/Test Rack Jr (1425, group 2709 — Production Operations)** → **L7 Desktop Test Tech (1447)**. Bolded levels live in *sub-team* groups.
5. **Quantified claim:** "Tree is 7 levels deep when you follow `parent_id` across `group_id` boundaries. API currently returns 4 because it filters by single `group_id`."

That last sentence is the assertion you carry into step 2. The numbers (7 and 4) become `expect(maxDepth(tree)).toBe(7)` and the failure message `Received: 4`.

## Stop conditions for step 1

You're done validating when you can answer all three:
- **What** is the customer-observable symptom? (e.g. "chart shows 4")
- **What** does the data actually say? (e.g. "tree is 7 deep")
- **Where** is the boundary the code is missing? (e.g. "cross-group `parent_id` chains")

If you can't answer #3 yet, keep querying. The boundary is what your fixture has to contain in step 2.
