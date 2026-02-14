# Feature Specification: rkit:add

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:add`

## Overview

Quick-capture skill for creating items with minimal friction. Optionally attach the new item to today's plan, a team board, or a meeting in one step.

## User Scenarios

### US1 — Quick Create (P1)

User wants to capture an item fast.

**Flow**:
1. Call `POST /items` with `{ "name": "<text>" }`
2. Show created item with ID
3. Optionally suggest: "Add to today's plan? Team board? Or leave standalone?"

**Invocation**: `/rkit:add "Fix the signup flow"`

**Acceptance**:
- **Given** user runs `/rkit:add "Fix signup"`, **Then** item is created and ID is shown
- **Given** creation succeeds, **Then** user is asked where to attach it (or skip)

### US2 — Create and Attach to Today (P2)

**Flow**:
1. Call `POST /day-plans/today/items` with `{ "name": "<text>" }`
2. Item is created and automatically on today's plan

**Invocation**: `/rkit:add "Fix signup" --today` or `/rkit:add "Fix signup" today`

**Acceptance**:
- **Given** `/rkit:add "Write docs" today`, **Then** item created and appears on today's plan

### US3 — Create and Add to Team Board (P2)

**Flow**:
1. Call `POST /teams/{default_team_id}/items` with `{ "name": "<text>" }`
2. Item is created on the team's weekly board

**Invocation**: `/rkit:add "Review PR" board` or `/rkit:add "Review PR" --board`

**Acceptance**:
- **Given** default team is set, **When** `/rkit:add "Review PR" board`, **Then** item created on team board

### US4 — Create with Details (P3)

User provides more than just a name.

**Invocation examples**:
- `/rkit:add "Fix signup" --due 2026-02-20`
- `/rkit:add "Fix signup" --status next`
- `/rkit:add "Fix signup" --parent 42`

**Acceptance**:
- **Given** user specifies due date, **When** item is created, **Then** `due` field is set correctly

## Requirements

- **FR-001**: MUST create item with at minimum a `name` field
- **FR-002**: MUST show created item ID in response
- **FR-003**: Attachment targets (today, board) MUST be optional — default is standalone
- **FR-004**: Board attachment MUST use `default_team_id` from config unless overridden

## Edge Cases

- Empty name → reject with error
- No config → prompt `/rkit:setup`
- No default team when `--board` used → list teams and ask
- Argument parsing ambiguity → item name is always the first quoted or unquoted string
