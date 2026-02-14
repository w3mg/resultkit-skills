# Feature Specification: rkit:status

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:status`

## Overview

Aggregate standup-style summary across today's plan and the team board. Answers: "What did I do? What's blocked? What's next?"

## User Scenarios

### US1 — Full Status Report (P1)

User wants a quick standup summary.

**Flow**:
1. Read `default_team_id` from config
2. Fetch in parallel:
   - `GET /day-plans/today/items` → today's plan
   - `GET /teams/{id}/items/done` → done items
   - `GET /teams/{id}/items/issues` → blocked items
   - `GET /teams/{id}/items/next` → next items
3. Display formatted report:

```
## Done
- [42] Fixed login bug
- [43] Updated docs

## Issues / Blocked
- [44] Waiting on API credentials

## Next
- [45] Write integration tests
- [46] Review PR #123

## Today's Plan
- [x] Fixed login bug
- [ ] Write integration tests
- [ ] Review PR #123
```

**Invocation**: `/rkit:status`

**Acceptance**:
- **Given** user has items across board and plan, **When** `/rkit:status`, **Then** all four sections shown
- **Given** no blocked items, **Then** issues section shows "(none)"

### US2 — Status for Specific Team (P2)

**Invocation**: `/rkit:status --team 7`

**Acceptance**:
- **Given** team 7 specified, **Then** board data comes from team 7 instead of default

### US3 — Compact Mode (P3)

Shorter output for quick checks.

**Invocation**: `/rkit:status short`

**Output**: One-line summary like `Done: 3 | Blocked: 1 | Next: 4 | Today: 2/5 complete`

## Requirements

- **FR-001**: MUST aggregate from both day plan and team board
- **FR-002**: MUST show done, blocked, next sections from board
- **FR-003**: MUST show today's plan with completion status
- **FR-004**: MUST deduplicate items that appear in both board and today's plan

## Edge Cases

- No default team → show only today's plan, suggest setting a team
- Empty board and empty plan → "Nothing to report. Add items with /rkit:add"
- Pagination on large teams → fetch first page, note if more items exist
