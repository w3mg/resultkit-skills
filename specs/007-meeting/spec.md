# Feature Specification: rkit:meeting

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:meeting`

## Overview

List meetings and view/prep meeting items organized by category (next, done, blocked). Supports both 1-on-1 and project meetings.

## User Scenarios

### US1 — List Meetings (P1)

**Flow**:
1. Call `GET /meetings`
2. Display table: ID, type (1-on-1 / project), participants, date

**Invocation**: `/rkit:meeting` or `/rkit:meeting list`

**Acceptance**:
- **Given** user has meetings, **When** invoked, **Then** all meetings listed with type and participants

### US2 — View Meeting Detail (P1)

**Flow**:
1. Call `GET /meetings/{id}`
2. Display meeting info + items grouped by category: next, done, issues/blocked

**Invocation**: `/rkit:meeting 15` or `/rkit:meeting show 15`

**Acceptance**:
- **Given** meeting 15 has items in all categories, **Then** items shown grouped by next/done/blocked
- **Given** meeting has no items in a category, **Then** category shown as "(empty)"

### US3 — Add Item to Meeting (P2)

**Flow (new item)**:
1. Call `POST /meetings/{id}/items` with `{ "name": "<text>" }`
2. Confirm creation

**Flow (existing item)**:
1. Call `PUT /meetings/{id}/items/{item_id}`
2. Confirm attachment

**Invocation**:
- `/rkit:meeting 15 add "Discuss hiring plan"`
- `/rkit:meeting 15 attach 42`

**Acceptance**:
- **Given** valid meeting ID, **When** item added, **Then** item appears in meeting and confirmation shown

### US4 — Remove Item from Meeting (P3)

**Flow**:
1. Call `DELETE /meetings/{id}/items/{item_id}`
2. Confirm removal (item still exists)

**Invocation**: `/rkit:meeting 15 remove 42`

## Requirements

- **FR-001**: List MUST show meeting type (one_on_one vs project)
- **FR-002**: Detail view MUST group items by next/done/blocked
- **FR-003**: Adding MUST support both new creation and existing attachment
- **FR-004**: Optional `owner_id` filter for viewing items by participant

## Edge Cases

- No meetings → "No meetings found"
- Meeting ID doesn't exist → 404 error with guidance
- User not a participant → 403 error explanation
