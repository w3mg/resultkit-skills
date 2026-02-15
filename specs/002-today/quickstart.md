# Quickstart: rkit:today

**Prerequisite**: `/rkit:setup` completed — config exists at
`~/.config/resultkit/config.json` with valid token.

## 1. View Today's Plan

```
/rkit:today
```

Expected output (items on plan):

```
Today's Plan (2026-02-15) — 3 items, 1 completed

| # | ID  | Name               | Status | Done |
|---|-----|--------------------|--------|------|
| 1 |  42 | Fix login bug      | next   | ✓    |
| 2 |  88 | Write API tests    | next   |      |
| 3 | 101 | Review PR #47      | next   |      |

2 remaining
```

Expected output (empty plan):

```
No items on today's plan. Use `/rkit:today add "task name"` to add one.
```

## 2. Mark Item Complete

```
/rkit:today done 88
```

Expected: Confirms action, marks item 88 as complete, shows updated plan.

## 3. Mark Item Incomplete

```
/rkit:today undo 42
```

Expected: Confirms action, marks item 42 as incomplete, shows updated plan.

## 4. Add New Item

```
/rkit:today add "Deploy hotfix to staging"
```

Expected: Confirms creation, shows new item with its ID, shows updated plan.

## 5. Attach Existing Item

```
/rkit:today attach 55
```

Expected: Confirms attachment, shows item 55 now on today's plan.

## 6. Remove Item from Plan

```
/rkit:today remove 88
```

Expected: Confirms removal. Item still exists in system, just not on
today's plan.

## 7. View Different Date (stretch)

```
/rkit:today 2026-02-13
```

Expected: Shows plan for Feb 13 if it exists. 404 message if no plan
for that date.

## Error Scenarios

- **No config**: "Config not found. Run `/rkit:setup` first."
- **Invalid item ID**: "Item 999 not found (404)."
- **Expired token**: "Unauthorized (401). Run `/rkit:setup` to update your token."
