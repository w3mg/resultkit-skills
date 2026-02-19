# API Contracts: rkit:board

All calls go through `scripts/api.sh METHOD PATH [BODY]`.

## US1 — View Board

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Fetch columns | GET | `/items/{board_id}/children?per_page=50` | — | `{ data: [Item], meta: {...} }` |
| Fetch column items (×N) | GET | `/items/{column_id}/children?per_page=50` | — | `{ data: [Item], meta: {...} }` |

## US2 — View Single Column

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Fetch columns | GET | `/items/{board_id}/children?per_page=50` | — | Filter by name or ID |
| Fetch column items | GET | `/items/{column_id}/children?per_page=50` | — | `{ data: [Item], meta: {...} }` |

## US3 — Move Item

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Validate item | GET | `/items/{item_id}` | — | Item detail |
| Validate target | GET | `/items/{target_column_id}` | — | Item detail |
| Move | PUT | `/items/{item_id}/move` | `{"parent_id": {target_column_id}}` | Updated item |

## US4 — Add Item

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Fetch columns (if needed) | GET | `/items/{board_id}/children?per_page=50` | — | For column picker |
| Create item | POST | `/items` | `{"name": "...", "parent_id": {column_id}}` | New item with ID |

## US5 — Remove Item

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Validate item on board | GET | `/items/{item_id}` | — | Check parent is a column of board |
| Option A: Orphan | PUT | `/items/{item_id}/move` | `{"parent_id": null}` | Updated item |
| Option A+: Add to day plan | PUT | `/day-plans/today/items/{item_id}` | — | Attached |
| Option B/C: Re-parent | PUT | `/items/{item_id}/move` | `{"parent_id": {target_id}}` | Updated item |

## Shared: Board ID Resolution

| Condition | Action |
|-----------|--------|
| Explicit ID in args | Use directly |
| `default_board_id` is integer | Use that ID |
| `default_board_id` is `"ask"` | Show default, ask to confirm/change |
| `default_board_id` absent | Prompt user for item ID |
