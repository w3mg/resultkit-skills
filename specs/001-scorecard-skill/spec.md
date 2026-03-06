# Feature Specification: Scorecard Skill (rkit:scorecard)

**Feature Branch**: `001-scorecard-skill`
**Created**: 2026-03-05
**Status**: Draft
**Input**: User description: "GitHub Issue #21: Team Scorecard Measures — weekly history, create, update, archive, record values via 5 new API endpoints"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Team Scorecard (Priority: P1)

A user runs `/rkit:scorecard` to see the current year's KPI measures for their default team, with recent weekly history values displayed in a readable format.

**Why this priority**: Core read operation — the most common use case, needed before any other action is useful.

**Independent Test**: Run `/rkit:scorecard` with a configured team; measures and their recent weekly values are displayed. Delivers value as a standalone read-only dashboard.

**Acceptance Scenarios**:

1. **Given** the user has a default team configured, **When** they run `/rkit:scorecard`, **Then** all non-archived measures are listed with name, unit, direction, target, owner, and the last 4 weeks of history values.
2. **Given** the team has no measures, **When** the user runs `/rkit:scorecard`, **Then** a friendly "no measures" message is shown.
3. **Given** the user specifies a year (e.g., `year=2025`), **When** the command runs, **Then** history for that year is shown.
4. **Given** the user passes `--include-archived`, **When** the command runs, **Then** archived measures are included in output (visually marked).

---

### User Story 2 - Record a Weekly Value (Priority: P2)

A user records an actual value for a specific measure for the current (or a specified) week.

**Why this priority**: The most frequent write operation — users fill in weekly KPI actuals on a regular cadence.

**Independent Test**: User records a value for one measure; the API persists it and the updated value appears on the next scorecard view.

**Acceptance Scenarios**:

1. **Given** a measure exists, **When** the user runs `/rkit:scorecard record "Weekly Signups" 42`, **Then** the value is saved for the current Monday's date and a confirmation is shown.
2. **Given** a value already exists for that week, **When** the user records a new value for the same measure and date, **Then** it is updated (upsert), not duplicated.
3. **Given** the user specifies a date (e.g., `date=2026-01-05`), **When** recording, **Then** the value is saved against that specific week.
4. **Given** the user enters a non-numeric value, **When** recording, **Then** a clear error is shown and nothing is saved.

---

### User Story 3 - Create a Measure (Priority: P3)

A user creates a new KPI measure on their team's scorecard.

**Why this priority**: Infrequent setup operation, but needed for teams getting started or adding new KPIs.

**Independent Test**: User creates a measure by name; it appears in the next scorecard view.

**Acceptance Scenarios**:

1. **Given** a team is configured, **When** the user runs `/rkit:scorecard add "Revenue" unit="$" direction=higher target=50000`, **Then** the measure is created and confirmed.
2. **Given** the user provides only a name, **When** creating, **Then** defaults apply (unit: none, direction: higher, no target, no owner).
3. **Given** the user omits a name, **When** creating, **Then** a clear error is shown.

---

### User Story 4 - Update or Archive a Measure (Priority: P4)

A user edits an existing measure's name, unit, direction, or target — or archives it to remove it from the active scorecard.

**Why this priority**: Maintenance operation; less frequent than recording values.

**Independent Test**: User updates a measure's target value; the change is reflected on the next scorecard view. User archives a measure; it no longer appears in the default scorecard view.

**Acceptance Scenarios**:

1. **Given** a measure exists, **When** the user runs `/rkit:scorecard update "Weekly Signups" target=100`, **Then** the target is updated and confirmed.
2. **Given** a measure exists, **When** the user runs `/rkit:scorecard archive "Weekly Signups"`, **Then** it is soft-deleted and no longer shown by default.
3. **Given** a user archives an already-archived measure, **When** the command runs, **Then** it succeeds idempotently.
4. **Given** the user provides an unrecognized measure name, **When** updating or archiving, **Then** a clear error is shown.

---

### Edge Cases

- What happens when the team has no measures at all? Show a friendly empty state.
- What happens when a measure name matches multiple measures? Show a disambiguation list before acting.
- What if the API returns a 422 for an invalid value when recording? Surface the API error message clearly.
- What if the user's token lacks edit permissions? Show a permissions error without crashing.
- What if `year` is far in the past with no recorded data? Show measure rows with all history slots empty.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST list all non-archived measures for the user's default team when invoked with no subcommand, showing name, unit, direction, target, owner, and recent weekly values.
- **FR-002**: The skill MUST support a `record <measure-name> <value>` subcommand to upsert a weekly value for the current Monday by default.
- **FR-003**: The skill MUST support an optional `date=YYYY-MM-DD` parameter on `record` to target a specific week.
- **FR-004**: The skill MUST support an `add <name>` subcommand to create a new measure, with optional `unit`, `direction`, and `target` parameters.
- **FR-005**: The skill MUST support an `update <measure-name>` subcommand to edit one or more fields (name, unit, direction, target) of an existing measure.
- **FR-006**: The skill MUST support an `archive <measure-name>` subcommand to soft-delete a measure.
- **FR-007**: The skill MUST support a `--year YYYY` flag on the list view to display history for a different year (default: current year).
- **FR-008**: The skill MUST support a `--include-archived` flag to show archived measures in the list view.
- **FR-009**: The skill MUST display history values in a readable tabular format showing at minimum the last 4 weeks of data for each measure.
- **FR-010**: The skill MUST validate that `record` values are numeric before calling the API, showing a user-friendly error if not.
- **FR-011**: The skill MUST surface API error messages (e.g., 422) clearly without a raw stack trace or opaque failure.
- **FR-012**: The skill MUST resolve measure names case-insensitively; if multiple measures match, present a disambiguation list before proceeding.

### Key Entities

- **Measure**: A KPI tracked weekly on a team scorecard. Fields: id, name, unit, direction (higher/lower), target_value, owner, is_archived, histories.
- **MeasureHistory**: A weekly value entry for a measure. Fields: id, measure_id, date (Monday), value, target_value. Slots with no recorded entry have null id and value.
- **Team**: The organizational group owning the scorecard. Identified by `default_team_id` in user config.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can view their team's full scorecard (all measures + recent history) in a single command with no additional steps.
- **SC-002**: A user can record a weekly value in one command, with confirmation returned in under 3 seconds under normal network conditions.
- **SC-003**: A user can create, update, or archive a measure in one command without needing to look up measure IDs manually.
- **SC-004**: All five API operations (list, create, update, archive, record history) are accessible from the skill with clear, consistent syntax.
- **SC-005**: Error messages for invalid input (non-numeric value, missing name, unknown measure) are human-readable and actionable without requiring the user to consult documentation.

## Assumptions

- The user's `~/.config/resultkit/config.json` has a valid `default_team_id` and API token; the skill will error clearly if not configured.
- Measure name resolution uses case-insensitive exact match first, falling back to substring match, against the list returned by the API.
- "Current Monday" for `record` is computed from today's date at skill runtime.
- The list view shows the last 4 weeks of history by default (truncated from the full 52-slot year) to keep output concise.
- Owner assignment on create/update is out of scope for v1; `owner_id` will not be exposed in the CLI interface initially.
