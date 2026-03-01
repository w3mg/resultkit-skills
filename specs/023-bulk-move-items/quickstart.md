# Quickstart: Bulk Move Items

**Branch**: `023-bulk-move-items` | **Date**: 2026-03-01

## Verification Scenarios

### US1: Bulk Move Items Under a Parent

**Scenario 1**: Successful bulk move (all items)
```
User: /rkit:board bulk-move 1,2,3 100
Expected: Confirm prompt → "Move 3 items under #100? (Items will be removed from all weekly boards.)" → Yes → "Moved 3 items under #100. 0 failed."
```

**Scenario 2**: Partial failure
```
User: /rkit:board bulk-move 1,2,3 100 (item 3 is forbidden)
Expected: Confirm → "Moved 2 items under #100. 1 failed."
  | Item ID | Reason    |
  |---------|-----------|
  | 3       | forbidden |
```

**Scenario 3**: No item IDs provided
```
User: /rkit:board bulk-move
Expected: "Usage: `/rkit:board bulk-move {item_ids} {parent_id}`
  Example: `/rkit:board bulk-move 1,2,3 100`"
```

**Scenario 4**: Target parent not found
```
User: /rkit:board bulk-move 1,2,3 99999
Expected: 404 → "Parent item not found (404)."
```

**Scenario 5**: No access to target parent
```
User: /rkit:board bulk-move 1,2,3 100 (no access)
Expected: 403 → "Access denied to parent item (403)."
```

**Scenario 6**: All items fail
```
User: /rkit:board bulk-move 1,2,3 100 (all forbidden)
Expected: "Moved 0 items under #100. 3 failed."
  | Item ID | Reason    |
  |---------|-----------|
  | 1       | forbidden |
  | 2       | forbidden |
  | 3       | forbidden |
```

**Scenario 7**: Self-reference (parent in item list)
```
User: /rkit:board bulk-move 1,2,100 100
Expected: "Moved 2 items under #100. 1 failed."
  | Item ID | Reason         |
  |---------|----------------|
  | 100     | self_reference |
```

### US2: API Reference Updated

**Scenario 8**: Documentation check
```
Read api-reference.md → Verify:
- Items section includes PATCH /items/bulk-move
- Body params: item_ids (integer[]), parent_id (integer)
- Response: moved, failed, errors
- User phrases present in glossary
```
