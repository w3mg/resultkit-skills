# Feature Specification: rkit:1on1

**Created**: 2026-02-23
**Status**: Draft
**Skill**: `/rkit:1on1`

## Overview

View and manage one-on-one meetings for a team. Shows meetings filtered by `type: one_on_one` and team. Detail view shows items grouped by column (next, done, issues/blocked). Follows the same patterns as `/rkit:weekly` — same column display, same move/add/remove flows, same confirm-before-write rules. Done column defaults to last 7 days, same as the team weekly.

## Clarifications

### Session 2026-02-23

- Q: What should the default (no args) behavior be? → A: List all one-on-ones for the default team.
- Q: Should this cover project meetings too? → A: No. One-on-ones only. Project meetings will get a separate `/rkit:meeting` skill later. They need different shortcuts because people conceptualize them differently.
- Q: How should done items be filtered? → A: Same rules as team weekly.
- Q: Should the skill support moving items between columns? → A: Yes. Same move flow as `/rkit:weekly` — move items between next, done, and blocked within a one-on-one.
- Q: Should users be able to add existing items from other contexts? → A: Yes. Attach existing items via `PUT /meetings/{id}/items/{item_id}`.

## User Scenarios

### US1 — List One-on-Ones (P1)

User wants to see their one-on-ones for a team.

**Flow**:
1. Read `default_team_id` from config (or `--team` override)
2. Call `GET /meetings`
3. Filter client-side to `type: one_on_one` scoped to team
4. Display table: ID, participant (the other person), date

**Invocation**: `/rkit:1on1` (no args)

**Acceptance**:
- **Given** user has one-on-ones, **When** invoked, **Then** all one-on-ones for the team listed
- **Given** no one-on-ones exist for team, **Then** "No one-on-ones found for team {team_id}."

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

**Flow (new item)**:
1. Describe action and confirm
2. Call `POST /meetings/{id}/items` with `{ "name": "<text>" }`
3. Show confirmation

**Flow (existing item from another context)**:
1. Describe action and confirm
2. Call `PUT /meetings/{id}/items/{item_id}`
3. Show confirmation

**Invocation**:
- `/rkit:1on1 {id} add "Discuss hiring plan"` — create new
- `/rkit:1on1 {id} attach {item_id}` — attach existing

**Acceptance**:
- **Given** valid meeting ID, **When** item added, **Then** item appears in meeting and confirmation shown

### US6 — Remove Item from One-on-One (P3)

**Flow**:
1. Describe action and confirm
2. Call `DELETE /meetings/{id}/items/{item_id}`
3. Confirm removal (item still exists, just detached from meeting)

**Invocation**: `/rkit:1on1 {id} remove {item_id}`

## Requirements

- **FR-001**: Default invocation MUST list one-on-ones filtered by type and team
- **FR-002**: Detail view MUST group items by next, done, blocked
- **FR-003**: Move MUST update item status (next, done, blocked)
- **FR-004**: MUST use `default_team_id` unless `--team` override provided
- **FR-005**: Adding MUST support both new creation and attaching existing items from other contexts
- **FR-006**: Display MUST show item ID, name, owner, due date per item
- **FR-007**: Done column MUST follow same time-window rules as team weekly
- **FR-008**: Confirm-before-write on all POST/PUT/PATCH/DELETE operations
- **FR-009**: Show IDs in all output so users can reference them

## Edge Cases

- No default team → "No default team configured. Run `/rkit:setup` first."
- Different team → `/rkit:1on1 --team 7` override
- No one-on-ones for team → "No one-on-ones found for team {team_id}."
- Meeting ID not found → 404 with guidance
- All columns empty → show all column headers with "(empty)"
- Item already in target column (move) → warn and skip
- User not a participant → 403 error explanation

## API Endpoints Used

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/meetings` | List meetings (filter client-side to one_on_one + team) |
| GET | `/meetings/{id}` | Meeting detail with next/done/issues arrays |
| GET | `/meetings/{id}/items/next` | Next items |
| GET | `/meetings/{id}/items/done` | Done items |
| GET | `/meetings/{id}/items/blocked` | Blocked/issues items |
| POST | `/meetings/{id}/items` | Create new item in meeting |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove item from meeting |
| PATCH | `/items/{id}` | Update item status (for moves) |
| GET | `/items/{id}` | Get item detail (for move status check) |
