# Feature Specification: rkit:board

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:board`

## Overview

View and manage the team weekly board. The board has four columns: **next**, **done**, **issues**, **parked**. This skill shows the board state and moves items between columns.

## User Scenarios

### US1 — View Board (P1)

User wants to see their team's weekly board.

**Flow**:
1. Read `default_team_id` from config
2. Call `GET /teams/{id}/items/next`, `GET /teams/{id}/items/done`, `GET /teams/{id}/items/issues`, `GET /teams/{id}/items/parked` (in parallel if possible, or sequentially)
3. Display as four grouped sections with item name, owner, ID

**Invocation**: `/rkit:board` (no args)

**Acceptance**:
- **Given** team has items in next and issues columns, **When** `/rkit:board`, **Then** all columns shown with items grouped
- **Given** a column is empty, **Then** show column header with "(empty)"

### US2 — View Single Column (P2)

User wants to see just one column.

**Invocation**:
- `/rkit:board next`
- `/rkit:board done`
- `/rkit:board issues`
- `/rkit:board parked`

**Acceptance**:
- **Given** `/rkit:board issues`, **Then** only issues column items are shown

### US3 — Move Item Between Columns (P2)

User wants to move an item to a different column.

**Flow**:
1. Call `PUT /teams/{id}/items/{column}/{item_id}` where column is next/done/issues/parked
2. Confirm the move

**Invocation**:
- `/rkit:board move 42 done` → move item 42 to done
- `/rkit:board move 42 issues` → move item 42 to issues

**Acceptance**:
- **Given** item 42 is in next column, **When** `/rkit:board move 42 done`, **Then** item moves to done and confirmation shown
- **Given** item 42 is not on the board, **When** move attempted, **Then** appropriate error

### US4 — Add/Remove Item from Board (P3)

**Flow (add)**:
1. Call `PUT /teams/{id}/items/{item_id}` to add item to board
2. Confirm addition

**Flow (remove)**:
1. Call `DELETE /teams/{id}/items/{item_id}` to remove from weekly
2. Confirm removal (item still exists)

**Invocation**:
- `/rkit:board add 42`
- `/rkit:board remove 42`

## Requirements

- **FR-001**: Default invocation MUST show all four columns
- **FR-002**: Column names MUST map to API paths: next, done, issues, parked
- **FR-003**: Move MUST use PUT on the target column endpoint
- **FR-004**: MUST use `default_team_id` unless team is specified as argument
- **FR-005**: Framework terminology in output (see constitution principle V)

## Edge Cases

- No default team → list teams and ask
- Different team → `/rkit:board --team 7` override
- Board is completely empty → show all four column headers with "(empty)"
- Item not owned by user → still show it (board is team-level)
