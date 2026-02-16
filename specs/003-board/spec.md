# Feature Specification: rkit:board

**Created**: 2026-02-15
**Status**: Draft
**Skill**: `/rkit:board`

## Overview

View an item's immediate children as a board. Each child becomes a column header, and that child's children are the items listed under it. This gives a board-style view of any item's two-level hierarchy.

Example: Item 10 "Q1 Goals" has children "Engineering", "Sales", "Marketing". Running `/rkit:board 10` shows three columns — Engineering, Sales, Marketing — with each column listing its own children.

## Clarifications

### Session 2026-02-16

- Q: Should there be a max number of columns displayed? → A: Cap at 10 columns; show "(N more columns not shown)" if exceeded.
- Q: Does `/rkit:board` always require an explicit item ID? → A: Support `default_board_id` in config with an "ask to confirm" option. Always confirm before writes.
- Q: What if two children have the same name when filtering by column name? → A: List matching children with IDs and ask user to pick. If user is an editor, suggest renaming one to avoid future ambiguity.

## User Scenarios

### US1 — View Item as Board (P1)

User wants to see an item's children rendered as a board.

**Flow**:
1. Call `GET /items/{id}/children` to get the item's immediate children (these are the columns)
2. For each child, call `GET /items/{child_id}/children` to get that column's items
3. Display as columns: each child's name is the column header, its children are the items listed below

**Invocation**:
- `/rkit:board {id}` — explicit item ID
- `/rkit:board` — uses `default_board_id` from config, or prompts if not set

**Acceptance**:
- **Given** item 10 has children "Engineering", "Sales", "Marketing", each with their own children, **When** `/rkit:board 10`, **Then** three columns shown with items grouped under each
- **Given** a child has no children of its own, **Then** show column header with "(empty)"
- **Given** item has no children, **Then** show "No children found for item {id}."

### US2 — View Single Column (P2)

User wants to see just one column (one child and its children).

**Invocation**: `/rkit:board {id} {column_name_or_child_id}`

**Acceptance**:
- **Given** `/rkit:board 10 Engineering`, **Then** only the Engineering column is shown with its items
- **Given** `/rkit:board 10 42`, **Then** shows child item 42's children as a single column

### US3 — Move Item Between Columns (P2)

User wants to move an item from one column to another (re-parent it).

**Flow**:
1. Validate the item exists and the target column (parent) exists
2. Describe the move and confirm with user
3. Call `PUT /items/{item_id}/move` with `{ "parent_id": {new_parent_id} }` to re-parent
4. Show confirmation

**Invocation**: `/rkit:board move {item_id} {target_column_id}`

**Acceptance**:
- **Given** item 55 is under "Engineering" (child of item 10), **When** `/rkit:board move 55 43` (where 43 is "Sales"), **Then** item 55 moves under Sales
- **Given** item 55 is already under target column, **Then** warn and skip

### US4 — Add Item to Column (P3)

User wants to add a new item under a specific column.

**Flow**:
1. If column not specified, list the columns and prompt user to pick
2. Describe the action and confirm with user
3. Call `POST /items` with `{ "name": "...", "parent_id": {column_id} }` to create under that column
4. Show confirmation with new item ID

**Invocation**:
- `/rkit:board add {board_id} "item name"` → prompt for column
- `/rkit:board add {board_id} {column_id} "item name"` → add directly

**Acceptance**:
- **Given** `/rkit:board add 10 42 "New task"`, **Then** new item created under column 42, confirmation shown with ID

## Requirements

- **FR-001**: Board view MUST show item's children as columns and grandchildren as items
- **FR-002**: Each column header MUST show the child item's name and ID
- **FR-003**: Each item in a column MUST show name, ID, status, and due date
- **FR-004**: Move MUST use `PUT /items/{id}/move` with `parent_id`
- **FR-005**: MUST use config for auth (token from `~/.config/resultkit/config.json`)
- **FR-009**: MUST support `default_board_id` in config; if set to `"ask"`, prompt user to confirm/change before loading; if set to an integer, use that item ID as the default board
- **FR-010**: If no board ID provided and no default configured, prompt user for an item ID
- **FR-006**: Pagination MUST use `per_page=50` for children lists; show "(N more...)" if more exist
- **FR-007**: Adding without a column MUST prompt user to choose from available columns
- **FR-008**: Board MUST cap at 10 columns; if item has more children, show first 10 and "(N more columns not shown)"

## Edge Cases

- Item has no children → "No children found for item {id}."
- Column (child) has no children → show column header with "(empty)"
- Item not found → "Item {id} not found (404)."
- No config → prompt `/rkit:setup`
- Column has >50 items → show first 50 with "(N more...)" count
- Duplicate column names → list matches with IDs, ask user to pick; if user is an editor, suggest renaming one
