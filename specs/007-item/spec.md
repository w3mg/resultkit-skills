# Feature Specification: rkit:item

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:item`

## Overview

Deep dive on a single item — view details, children, comments, and assignees. Manage comments and assignees.

## User Scenarios

### US1 — View Item Detail (P1)

**Flow**:
1. Call `GET /items/{id}` (includes first-level children)
2. Display: name, description, status, due date, owner, assignees, child count, ID

**Invocation**: `/rkit:item 42`

**Acceptance**:
- **Given** item 42 exists, **When** invoked, **Then** full detail shown including children list
- **Given** item has no children, **Then** children section omitted or shows "(none)"

### US2 — View Comments (P2)

**Flow**:
1. Call `GET /items/{id}/comments`
2. Display chronologically: author, date, body

**Invocation**: `/rkit:item 42 comments`

**Acceptance**:
- **Given** item has 3 comments, **Then** all 3 shown in order with author and timestamp

### US3 — Add Comment (P2)

**Flow**:
1. Call `POST /items/{id}/comments` with `{ "body": "<text>" }`
2. Confirm comment added

**Invocation**: `/rkit:item 42 comment "Needs review by Friday"`

**Acceptance**:
- **Given** valid item ID and comment text, **Then** comment created and confirmation shown

### US4 — Manage Assignees (P3)

**Flow (add)**:
1. Call `PUT /items/{id}/assignees` with `{ "user_id": <int> }`

**Flow (remove)**:
1. Call `DELETE /items/{id}/assignees/{user_id}`

**Invocation**:
- `/rkit:item 42 assign 3` → assign user 3
- `/rkit:item 42 unassign 3` → remove user 3

### US5 — Update Item (P3)

**Flow**:
1. Call `PATCH /items/{id}` with provided fields

**Invocation**:
- `/rkit:item 42 status done`
- `/rkit:item 42 due 2026-02-20`
- `/rkit:item 42 rename "New name"`

## Requirements

- **FR-001**: Default invocation with just ID MUST show full detail
- **FR-002**: Comments MUST be shown chronologically
- **FR-003**: Adding comments MUST confirm before POST
- **FR-004**: Assignee operations MUST require user_id (show team members if ambiguous)
- **FR-005**: Update MUST confirm before PATCH

## Edge Cases

- Item doesn't exist → 404 with guidance
- No permission to view → 403 explanation
- Comment body empty → reject
- Assign user not in same account → 403 explanation
- Item has many children → paginate or show count with option to expand
