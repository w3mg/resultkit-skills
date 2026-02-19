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
- Q: What if two children have the same name when filtering by column name? → A: List matching children with IDs and ask user to pick. Suggest renaming one to avoid future ambiguity.
- Q: Should `/rkit:board` support removing/archiving items from a column? → A: Support remove (option B). Board gets `/rkit:board remove {item_id}` calling the API directly (same pattern as move). Archive is out of scope — deferred to future `rkit:archive` skill.
- Q: What should remove do with the item? → A: Prompt the user with options: (1) Remove from all projects (orphan via API), and if so, offer to add to their day plan; (2) Move to another project; (3) Move to a one-on-one or other source. The orphan mechanic is hidden behind the API — user sees "remove from all projects", not "orphan".

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

### US5 — Remove Item from Column (P2)

User wants to remove an item from a board column.

**Flow**:
1. Resolve board ID via Board ID Resolution (default_board_id, "ask", or prompt). Validate the item exists and its parent is a column on the resolved board
2. Prompt user with options:
   - **Remove from all projects** — orphan the item (remove parent). If chosen, ask if they want it added to their day plan.
   - **Move to another project** — prompt for target project/parent ID
   - **Move to a one-on-one or other source** — prompt for target parent ID
3. Confirm the action with the user
4. Execute: orphan via API (`PUT /items/{id}/move` with no parent) or re-parent to chosen target
5. Show confirmation

**Invocation**: `/rkit:board remove {item_id}` (board context resolved via Board ID Resolution — default_board_id or prompt)

**Acceptance**:
- **Given** `/rkit:board remove 55`, **Then** user is prompted with removal options
- **Given** user picks "remove from all projects", **Then** item is orphaned and user is asked if they want it on their day plan
- **Given** user picks "move to another project", **Then** prompted for target, item is re-parented
- **Given** item is not under any column on the current board, **Then** warn "Item {id} is not on this board."

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
- **FR-011**: Remove MUST prompt user with options: remove from all projects (orphan), move to another project, or move to a one-on-one/other source
- **FR-012**: If user orphans an item, MUST offer to add it to their day plan
- **FR-013**: Orphan mechanic MUST be hidden from user — present as "remove from all projects", not "orphan"

## Edge Cases

- Item has no children → "No children found for item {id}."
- Column (child) has no children → show column header with "(empty)"
- Item not found → "Item {id} not found (404)."
- No config → prompt `/rkit:setup`
- Column has >50 items → show first 50 with "(N more...)" count
- Column name/ID not found → "No column matching '{input}' on board {id}." with list of available columns
- Duplicate column names → list matches with IDs, ask user to pick; suggest renaming one to avoid future ambiguity
