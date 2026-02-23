# Feature Specification: rkit:1on1

**Created**: 2026-02-23
**Status**: Draft
**Skill**: `/rkit:1on1`

## Overview

View and manage one-on-one meetings. Shows all one-on-ones filtered by `type: one_on_one`. Detail view shows items grouped by column (next, done, issues/blocked). Follows the same patterns as `/rkit:weekly` — same column display, same move/add/remove flows, same confirm-before-write rules. Done column defaults to last 7 days, same as the team weekly.

**Known limitation**: The meetings API has no team filter. All one-on-ones are returned regardless of team. A backlog item exists to add `team_id` filtering to `GET /meetings` (see ResultKit Lab Sprints backlog, ID 210978).

## Clarifications

### Session 2026-02-23

- Q: What should the default (no args) behavior be? → A: List all one-on-ones.
- Q: Should this cover project meetings too? → A: No. One-on-ones only. Project meetings will get a separate `/rkit:meeting` skill later. They need different shortcuts because people conceptualize them differently.
- Q: How should done items be filtered? → A: Same rules as team weekly.
- Q: Should the skill support moving items between columns? → A: Yes. Same move flow as `/rkit:weekly` — move items between next, done, and blocked within a one-on-one.
- Q: Should users be able to add existing items from other contexts? → A: Yes. Add existing items via `PUT /meetings/{id}/items/{item_id}`.
- Q: Should the list filter by team? → A: No. The meetings API has no team filter, and the meeting object has no team field. Filtering would require cross-referencing team membership — not worth inventing. Backlog item created to add team filtering to the API.
- Q: Should `add` and `remove` match weekly terminology? → A: Yes. Use `add` for both new and existing items (not `attach`). Use `remove` to detach.

## User Scenarios

### US1 — List One-on-Ones (P1)

User wants to see their one-on-ones.

**Flow**:
1. Call `GET /meetings`
2. Filter client-side to `type: one_on_one`
3. Display table: ID, participant (the other person), date

**Invocation**: `/rkit:1on1` (no args)

**Acceptance**:
- **Given** user has one-on-ones, **When** invoked, **Then** all one-on-ones listed
- **Given** no one-on-ones exist, **Then** "No one-on-ones found."

### US2 — View One-on-One Detail (P1)

User wants to see a specific one-on-one's items grouped by column.

**Flow**:
1. Call `GET /meetings/{id}`
2. Display meeting info (participants, date)
3. Show items grouped by: next, done, issues/blocked
4. Each item shows: ID, name, owner, due date
5. Empty columns show "(empty)"

**Invocation**: `/rkit:1on1 {id}` or `/rkit:1on1 show {id}`

**Acceptance**:
- **Given** meeting has items in all categories, **Then** items shown grouped by next/done/blocked
- **Given** a category is empty, **Then** shown as "(empty)"

### US3 — View Single Column (P2)

User wants to see just one column of a one-on-one.

**Flow**:
1. Call the appropriate endpoint:
   - `GET /meetings/{id}/items/next`
   - `GET /meetings/{id}/items/done`
   - `GET /meetings/{id}/items/blocked`
2. Display items with ID, name, owner, due date

**Invocation**:
- `/rkit:1on1 {id} next`
- `/rkit:1on1 {id} done`
- `/rkit:1on1 {id} issues`

### US4 — Move Item Between Columns (P2)

User wants to move an item to a different column within a one-on-one.

**Flow**:
1. Fetch item via `GET /items/{item_id}` to check current status
2. Map status to column: next→next, done→done, blocked→issues
3. If already in target column, warn and skip
4. Describe the move and confirm with user
5. Update item status via `PATCH /items/{item_id}` with new status
6. Show confirmation

**Invocation**: `/rkit:1on1 {meeting_id} move {item_id} done`

**Acceptance**:
- **Given** item is in next, **When** move to done, **Then** confirmation prompt, item status updated on confirm
- **Given** item already in target column, **Then** warn and skip

### US5 — Add Item to One-on-One (P2)

**Flow (new item)** — arg is a quoted string:
1. Describe action and confirm
2. Call `POST /meetings/{id}/items` with `{ "name": "<text>" }`
3. Show confirmation

**Flow (existing item)** — arg is a number:
1. Fetch item to confirm it exists
2. Describe action and confirm
3. Call `PUT /meetings/{id}/items/{item_id}`
4. Show confirmation

**Invocation**:
- `/rkit:1on1 {id} add "Discuss hiring plan"` — create new
- `/rkit:1on1 {id} add {item_id}` — add existing

**Acceptance**:
- **Given** valid meeting ID, **When** item added, **Then** item appears in meeting and confirmation shown

### US6 — Remove Item from One-on-One (P3)

**Flow**:
1. Describe action and confirm
2. Call `DELETE /meetings/{id}/items/{item_id}`
3. Confirm removal (item still exists, just detached from meeting)

**Invocation**: `/rkit:1on1 {id} remove {item_id}`

## Requirements

- **FR-001**: Default invocation MUST list all one-on-ones (no team filter — API limitation)
- **FR-002**: Detail view MUST group items by next, done, blocked
- **FR-003**: Move MUST update item status (next, done, blocked)
- **FR-004**: Adding MUST support both new creation and adding existing items using `add` for both
- **FR-005**: Display MUST show item ID, name, owner, due date per item
- **FR-006**: Done column MUST follow same time-window rules as team weekly
- **FR-007**: Confirm-before-write on all POST/PUT/PATCH/DELETE operations
- **FR-008**: Show IDs in all output so users can reference them
- **FR-009**: Use `add`/`remove` terminology consistent with `/rkit:weekly`

## Edge Cases

- No config → "Config not found. Run `/rkit:setup` first."
- No one-on-ones → "No one-on-ones found."
- Meeting ID not found → 404 with guidance
- All columns empty → show all column headers with "(empty)"
- Item already in target column (move) → warn and skip
- Item not found (add existing) → "Item {id} not found."
- User not a participant → 403 error explanation

## API Endpoints Used

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/meetings` | List meetings (filter client-side to one_on_one) |
| GET | `/meetings/{id}` | Meeting detail with next/done/issues arrays |
| GET | `/meetings/{id}/items/next` | Next items |
| GET | `/meetings/{id}/items/done` | Done items |
| GET | `/meetings/{id}/items/blocked` | Blocked/issues items |
| POST | `/meetings/{id}/items` | Create new item in meeting |
| PUT | `/meetings/{id}/items/{item_id}` | Add existing item |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove item from meeting |
| PATCH | `/items/{id}` | Update item status (for moves) |
| GET | `/items/{id}` | Get item detail (for move status check) |
