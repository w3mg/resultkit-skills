# Feature Specification: rkit:today

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:today`

## Overview

View and manage today's day plan. The primary "start of day" skill — see what's on the plan, mark items complete, add or remove items.

## User Scenarios

### US1 — View Today's Plan (P1)

User wants to see what's on their plate today.

**Flow**:
1. Call `GET /day-plans/today/items`
2. Display items as a table: position, name, status, completed (checkbox), ID
3. Show summary: X items, Y completed, Z remaining

**Invocation**: `/rkit:today` (no args)

**Acceptance**:
- **Given** user has 5 items on today's plan, **When** `/rkit:today` is invoked, **Then** all 5 items shown with completion status
- **Given** today's plan is empty, **When** invoked, **Then** "No items on today's plan" message displayed

### US2 — Mark Item Complete/Incomplete (P2)

User wants to check off an item or uncheck it.

**Flow**:
1. Call `PATCH /day-plans/today/items/{item_id}` with `{ "completed": true/false }`
2. Confirm the change
3. Show updated plan

**Invocation**:
- `/rkit:today done 42` → mark item 42 complete
- `/rkit:today undo 42` → mark item 42 incomplete

**Acceptance**:
- **Given** item 42 is on today's plan and incomplete, **When** `/rkit:today done 42`, **Then** item is marked complete and confirmed
- **Given** item 42 is already complete, **When** `/rkit:today undo 42`, **Then** item is marked incomplete

### US3 — Add Item to Today (P3)

User wants to create a new item and put it on today's plan, or attach an existing item.

**Flow (new item)**:
1. Call `POST /day-plans/today/items` with `{ "name": "<text>" }`
2. Confirm creation and show the new item with its ID

**Flow (existing item)**:
1. Call `PUT /day-plans/today/items/{item_id}`
2. Confirm attachment

**Invocation**:
- `/rkit:today add "Fix the login bug"` → create new item on today
- `/rkit:today attach 42` → attach existing item 42 to today

**Acceptance**:
- **Given** user runs `/rkit:today add "Write tests"`, **Then** new item is created and appears on today's plan
- **Given** item 42 exists, **When** `/rkit:today attach 42`, **Then** item 42 appears on today's plan

### US4 — Remove Item from Today (P3)

**Flow**:
1. Call `DELETE /day-plans/today/items/{item_id}`
2. Confirm removal (item still exists, just removed from plan)

**Invocation**: `/rkit:today remove 42`

**Acceptance**:
- **Given** item 42 is on today's plan, **When** removed, **Then** item no longer on plan but still exists in system

## Requirements

- **FR-001**: Default invocation (no args) MUST show today's plan
- **FR-002**: Completion toggling MUST use PATCH with `completed` field
- **FR-003**: Adding items MUST support both creating new and attaching existing
- **FR-004**: Removing MUST only detach from plan, never archive the item

## Edge Cases

- No config → prompt `/rkit:setup`
- Item ID doesn't exist → show 404 error
- Item already on today's plan → PUT is idempotent, confirm it's already there
- View a different date → `/rkit:today 2026-02-13` could show that date's plan (stretch)
