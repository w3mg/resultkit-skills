# Feature Specification: 1:1 Columns

**Feature Branch**: `019-1on1-columns`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #8: pull columns from a given 1:1 — provide list of 1:1s for a team, pull columns

## Clarifications

### Session 2026-03-01

- Q: Should the team filter match by participant membership or by team ID on the meeting? → A: Filter by team ID directly — meetings are associated with teams, so the skill filters `GET /meetings` results by the team's ID, showing all 1:1 meetings for that team.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - List 1:1s for a Team (Priority: P1)

A user runs `/rkit:1on1` (with no args or with a `--team` flag) and sees a list of one-on-one meetings associated with that team. Each row shows the meeting ID, the other participant's name, and the meeting date. The user can then pick a meeting to drill into.

**Why this priority**: Without a team-scoped list, users see all their 1:1s across every team — noisy when they only care about one team's meetings. This is the entry point for the column drill-down.

**Independent Test**: Can be fully tested by running `/rkit:1on1` with a configured default team and verifying only 1:1s for that team appear. Delivers value by reducing noise.

**Acceptance Scenarios**:

1. **Given** a user with a default team configured, **When** they run `/rkit:1on1`, **Then** they see only 1:1s associated with that team, displayed as a table with ID, partner name, and date.
2. **Given** a user specifying `--team 5`, **When** they run `/rkit:1on1 --team 5`, **Then** the list filters to 1:1s for team 5 (overriding any default).
3. **Given** no team configured and no `--team` flag, **When** they run `/rkit:1on1`, **Then** they see all their 1:1s (no team filter applied) with a hint to set a default team.
4. **Given** a team with no 1:1 meetings, **When** the user lists 1:1s for that team, **Then** they see "No one-on-ones found for {team_name}."

---

### User Story 2 - View Columns from a 1:1 (Priority: P2)

A user runs `/rkit:1on1 {meeting_id}` and sees the meeting's items grouped into columns: Next, Done, and Blocked. Each column shows a table of items with ID, name, creator, and due date. This is the "pull columns" functionality.

**Why this priority**: Viewing columns is the core use case from the issue. It depends on US1 for discovery (knowing which meeting ID to use), but can be tested independently with a known meeting ID.

**Independent Test**: Can be fully tested by running `/rkit:1on1 {known_meeting_id}` and verifying items appear in the correct column groupings.

**Acceptance Scenarios**:

1. **Given** a valid 1:1 meeting ID with items in multiple columns, **When** the user runs `/rkit:1on1 {meeting_id}`, **Then** they see a header with both participants' names and three column sections (Next, Done, Blocked) each with an item table showing ID, name, creator, and due date.
2. **Given** a 1:1 with all columns empty, **When** the user views it, **Then** all three column headers show "(empty)".
3. **Given** a 1:1 meeting ID that doesn't exist, **When** the user tries to view it, **Then** they see "Meeting {id} not found."
4. **Given** a meeting that is a project meeting (not a 1:1), **When** the user tries to view it, **Then** they see the meeting detail regardless (the skill handles both meeting types at the detail level).

---

### Edge Cases

- What happens when a participant has no first/last name? Fall back to `login` field.
- What happens when a 1:1 has more than 50 items in a column? Show first 50 with "Showing 50 of {total} — more items exist".
- What happens when the API returns a non-one_on_one meeting type? Filter it out in the list view (US1 only shows type=one_on_one).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST filter `GET /meetings` results by team ID, showing only meetings associated with the resolved team.
- **FR-002**: Skill MUST further filter results to only `type: "one_on_one"` meetings (exclude project meetings from the list view).
- **FR-003**: Skill MUST resolve team ID using the same precedence as other rkit skills: `--team {id}` flag > `default_team_id` from config > show all (no filter).
- **FR-004**: Skill MUST display 1:1 list as a table with columns: ID, With (other participant), Date.
- **FR-005**: Skill MUST display meeting detail with items grouped into Next, Done, and Blocked columns, each showing ID, name, creator, and due date.
- **FR-006**: Skill MUST show "(empty)" for columns with no items.
- **FR-007**: Skill MUST handle standard error responses (401, 404, 422, network errors) per the shared error handling pattern.
- **FR-008**: When no team is configured and no `--team` flag is provided, skill MUST list all 1:1s without team filtering (backward-compatible behavior).

### Key Entities

- **Meeting**: A one-on-one meeting with `id`, `type`, `date`, `person1`, `person2`, team association, and item arrays (`next`, `done`, `blocked`).
- **Meeting Item**: An item within a meeting column, with `id`, `name`, `creator`, `due`, and `status`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can see their team-scoped 1:1 list in a single command invocation (no multi-step navigation required).
- **SC-002**: Users can view all three columns (Next, Done, Blocked) of a specific 1:1 in a single command invocation.
- **SC-003**: The team filter correctly shows only 1:1s associated with the specified team — zero false positives.
- **SC-004**: All existing `/rkit:1on1` flows (move, add, remove) continue to work unchanged.

## Assumptions

- Meetings are associated with teams. The `GET /meetings` endpoint can be filtered by team ID to return only that team's meetings. The exact filtering mechanism (query param or client-side field match) will be verified against the live API during planning.
- Meeting participants are identified by `person1.id` and `person2.id` fields on the meeting object.
- The `GET /meetings` endpoint returns meeting type, allowing client-side filtering to `type: "one_on_one"` after the team filter is applied.
