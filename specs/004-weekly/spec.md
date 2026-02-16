# Feature Specification: rkit:weekly

**Created**: 2026-02-14
**Revised**: 2026-02-15
**Status**: Draft
**Skill**: `/rkit:weekly` (synonym: `/rkit:level10`)

## Overview

View and manage the team weekly. The team weekly has four columns: **next**, **done**, **issues**, **parked**. This skill shows the weekly state and lets users move items between columns, add items, and remove items. Column headers MUST use framework-specific terminology based on the team's `framework` field.

## Clarifications

### Session 2026-02-15

- Q: When adding an item with `/rkit:weekly add 42` (no column specified), which column should it land in? → A: Prompt the user interactively with the four column choices and let them pick.
- Q: Should columns handle pagination? → A: Fetch first page with `per_page=50`; if more pages exist, show "(N more...)" indicator.
- Q: What fields should be displayed per item? → A: Default: name, owner, ID, due date. Before rendering, ask user if they want truncated descriptions included.
- Q: How should framework terminology apply to the display? → A: Framework terms MUST replace column headers where applicable (e.g., "To-Do" instead of "Next" for EOS). Non-negotiable.
- Q: When moving an item to the column it's already in, what should happen? → A: Detect and warn "Item {id} is already in {column}" — skip the API call.
- Q: Adding an item already on the weekly? → A: Warn "Item {id} is already on the weekly in {column}" and ask if user wants to move it.

## User Scenarios

### US1 — View Team Weekly (P1)

User wants to see their team's weekly.

**Flow**:
1. Read `default_team_id` from config
2. Fetch team detail (`GET /teams/{id}`) to obtain the `framework` field for column header terminology
3. Call `GET /teams/{id}/items/next?per_page=50`, `GET /teams/{id}/items/done?per_page=50`, `GET /teams/{id}/items/issues?per_page=50`, `GET /teams/{id}/items/parked?per_page=50` (in parallel if possible, or sequentially)
4. Ask user if they want truncated descriptions included
5. Display as four grouped sections with framework-appropriate column headers; each item shows name, owner, ID, due date (and truncated description if requested)
6. If a column has more than 50 items, append "(N more...)" after the listed items

**Invocation**: `/rkit:weekly` (no args)

**Acceptance**:
- **Given** team has items in next and issues columns, **When** `/rkit:weekly`, **Then** all columns shown with items grouped
- **Given** a column is empty, **Then** show column header with "(empty)"
- **Given** team framework is EOS, **Then** column headers use EOS terminology
- **Given** a column has more than 50 items, **Then** first 50 shown with "(N more...)" indicator

### US2 — View Single Column (P2)

User wants to see just one column.

**Invocation**:
- `/rkit:weekly next`
- `/rkit:weekly done`
- `/rkit:weekly issues`
- `/rkit:weekly parked`

**Acceptance**:
- **Given** `/rkit:weekly issues`, **Then** only issues column items are shown with framework-appropriate header
- **Given** column has more than 50 items, **Then** first 50 shown with "(N more...)" indicator

### US3 — Move Item Between Columns (P2)

User wants to move an item to a different column.

**Flow**:
1. Check if item is already in the target column
2. If already there, warn "Item {id} is already in {column}" and skip
3. Describe the move and confirm with user
4. Call `PUT /teams/{id}/items/{column}/{item_id}` where column is next/done/issues/parked
5. Show confirmation

**Invocation**:
- `/rkit:weekly move 42 done` → move item 42 to done
- `/rkit:weekly move 42 issues` → move item 42 to issues

**Acceptance**:
- **Given** item 42 is in next column, **When** `/rkit:weekly move 42 done`, **Then** confirmation prompt shown, item moves to done on confirm
- **Given** item 42 is already in done, **When** `/rkit:weekly move 42 done`, **Then** warn and skip
- **Given** item 42 is not on the weekly, **When** move attempted, **Then** appropriate error

### US4 — Add/Remove Item from Weekly (P3)

**Flow (add)**:
1. Check if item is already on the weekly; if so, warn and ask if user wants to move it
2. If no column specified, prompt user interactively with the four column choices (next, done, issues, parked) and let them pick
3. Describe the action and confirm with user
4. Call `PUT /teams/{id}/items/{column}/{item_id}` to add item to weekly in the chosen column
5. Show confirmation with column placement

**Flow (remove)**:
1. Describe the action and confirm with user
2. Call `DELETE /teams/{id}/items/{item_id}` to remove from weekly
3. Confirm removal (item still exists)

**Invocation**:
- `/rkit:weekly add 42` → prompt for column choice
- `/rkit:weekly add 42 next` → add directly to next column
- `/rkit:weekly remove 42`

## Requirements

- **FR-001**: Default invocation MUST show all four columns
- **FR-002**: Column names MUST map to API paths: next, done, issues, parked
- **FR-003**: Move MUST use PUT on the target column endpoint
- **FR-004**: MUST use `default_team_id` unless team is specified as argument
- **FR-005**: Column headers MUST use framework-specific terminology based on team's `framework` field (non-negotiable)
- **FR-006**: Display MUST show item name, owner, ID, and due date per item
- **FR-007**: Pagination MUST use `per_page=50`; if more items exist, show "(N more...)" indicator
- **FR-008**: Adding an item without a column argument MUST prompt user to choose a column interactively
- **FR-009**: Moving an item to its current column MUST warn and skip the API call
- **FR-010**: Adding an item already on the weekly MUST warn and ask if user wants to move it

## Edge Cases

- No default team → list teams and ask
- Different team → `/rkit:weekly --team 7` override
- All columns empty → show all four column headers with "(empty)"
- Item not owned by user → still show it (weekly is team-level)
- Item already in target column → warn and skip move
- Item already on weekly (add) → warn and offer to move
- Column has >50 items → show first 50 with "(N more...)" count
