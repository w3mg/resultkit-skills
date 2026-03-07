# Feature Specification: Fix Measure History Display in Scorecard

**Feature Branch**: `001-fix-measure-history`
**Created**: 2026-03-07
**Status**: Draft
**Input**: GitHub Issue #22 — [API Change] Change Handoff 010: Fix Measure History

## Background

The ResultMaps V2 API had a bug where weekly scorecard history values were always returned as `null`. This was fixed server-side (API branch `040-fix-measure-history`): the API now returns real `id` and `value` for weeks where data was previously recorded. Response shapes are unchanged — only the data is now non-null.

The `rkit:scorecard` skill fetches measure history via `GET /api/v2/teams/:id/measures` and records new values via `POST /api/v2/measures/:id/history`. This feature verifies and updates the skill to correctly display and handle non-null history values.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Weekly Scorecard History (Priority: P1)

A user runs `/rkit:scorecard` to review their team's scorecard. For weeks where values were previously recorded (via the legacy app or the skill), those values now appear instead of showing as blank or missing.

**Why this priority**: This is the core value — users can finally see historical scorecard data. Without this, the scorecard is effectively useless for tracking trends.

**Independent Test**: Run `/rkit:scorecard` for a team with historical measure data. Verify that weeks with recorded values show the actual value, and weeks with no data show as empty/unrecorded.

**Acceptance Scenarios**:

1. **Given** a team has measures with some weeks previously recorded, **When** a user views the scorecard, **Then** each recorded week shows its actual value (not blank or zero).
2. **Given** a team has measures with no history recorded, **When** a user views the scorecard, **Then** unrecorded weeks display as empty/unrecorded (not as an error).
3. **Given** a week's history entry has a non-null `id` and `value`, **When** the scorecard renders that week, **Then** the value is displayed correctly in the output.

---

### User Story 2 - Record a New Weekly Value (Priority: P2)

A user records a scorecard value for a specific measure and week. The newly recorded value is confirmed and reflected when the scorecard is viewed again.

**Why this priority**: Writing history is the other half of the scorecard workflow. If recording works but display is broken (or vice versa), users cannot complete the full loop.

**Independent Test**: Record a value for a measure for the current week, then view the scorecard. Verify the newly recorded value appears.

**Acceptance Scenarios**:

1. **Given** a user provides a measure and value for a specific week, **When** the record command is executed, **Then** the skill confirms the value was saved with the assigned ID.
2. **Given** a value is recorded successfully, **When** the scorecard is viewed afterward, **Then** the recorded value appears in the correct week slot.

---

### Edge Cases

- What happens when all history slots for a measure are null (no data ever recorded)? The skill should display the scorecard without errors, showing empty slots.
- What happens when a measure has a mix of recorded and unrecorded weeks? Each week should independently show its real value or empty state.
- What happens when the `id` field in a history slot is null but `value` is non-null (or vice versa)? Treat as unrecorded — only display a value when both are present.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The scorecard skill MUST display the actual `value` from each history slot when it is non-null.
- **FR-002**: The scorecard skill MUST display an empty/unrecorded indicator (`"—"`) for history slots where `value` is null.
- **FR-003**: The scorecard skill MUST NOT display `null` as a literal string in any output column.
- **FR-004**: When recording a new history value, the skill MUST confirm success using the `id` returned by the API.
- **FR-005**: The skill MUST handle a mix of recorded and unrecorded weeks in the same measure's history without errors.

### Key Entities

- **Measure**: A named scorecard metric belonging to a team. Has an ordered list of weekly history slots covering the selected year.
- **History Slot**: One week's entry for a measure. Has a `date` (Monday), `value` (string or null), and `id` (integer or null). A slot is "recorded" when both `id` and `value` are non-null.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: When viewing a scorecard for a team with historical data, 100% of recorded weeks display their actual value (no null passthrough).
- **SC-002**: Unrecorded weeks display a clear empty indicator in all scorecard views — no literal `null` or error text appears.
- **SC-003**: A newly recorded value appears in the scorecard on the next view without any additional action by the user.
- **SC-004**: The scorecard skill completes successfully (no crash or error output) for teams with zero history, partial history, or full history.

## Assumptions

- The API fix is already deployed. No API changes are required as part of this feature — only skill-side verification and rendering fixes.
- "Recorded" is defined as: both `id` and `value` are non-null in the history slot.
- Monday dates are always used when displaying week labels; the Sunday/Monday conversion is handled transparently by the API.
- The year displayed defaults to the current year unless the user specifies otherwise (existing behavior, unchanged).
