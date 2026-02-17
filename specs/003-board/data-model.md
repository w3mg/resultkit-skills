# Data Model: rkit:board

**Date**: 2026-02-16

## Entities

Board is a virtual concept — no dedicated API entity. It's an item viewed through its two-level hierarchy.

### Board (virtual)

An item whose children are treated as columns and grandchildren as column items.

| Field | Source | Notes |
|-------|--------|-------|
| id | Item ID | The board root item |
| name | Item name | Displayed as board title |
| columns | `GET /items/{id}/children` | First-level children = column headers |

### Column (virtual)

A child of the board item, rendered as a column header.

| Field | Source | Notes |
|-------|--------|-------|
| id | Item ID | Shown in header per FR-002 |
| name | Item name | Column header text |
| items | `GET /items/{id}/children` | Second-level children = column items |
| item_count | meta.total from children response | For "(N more...)" display |

### Column Item

A grandchild of the board item, listed under a column.

| Field | Source | Notes |
|-------|--------|-------|
| id | Item ID | Shown per FR-003 |
| name | Item name | Shown per FR-003 |
| status | Item status | Shown per FR-003 |
| due | Item due date | Shown per FR-003 |

### Config Extension

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| default_board_id | integer \| "ask" \| absent | absent | Per FR-009/FR-010 |

## State Transitions

### Remove Flow (US5)

```
Item in column
  ├── "Remove from all projects" → orphan (parent_id: null)
  │     └── "Add to day plan?" → attach to today
  ├── "Move to another project" → re-parent (parent_id: target)
  └── "Move to one-on-one/other" → re-parent (parent_id: target)
```

## Relationships

```
Board Item (root)
  ├── Column A (child)
  │   ├── Item 1 (grandchild)
  │   ├── Item 2 (grandchild)
  │   └── ...
  ├── Column B (child)
  │   └── ...
  └── ... (max 10 displayed)
```
