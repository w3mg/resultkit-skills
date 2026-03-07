# Feature Specification: Measure History Notes

**Feature Branch**: `001-measure-history-notes`
**Created**: 2026-03-07
**Status**: Draft
**Input**: GitHub Issue #23 — Per-Week Measure History Notes API Change Handoff

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record a note on a scorecard week (Priority: P1)

A scorecard user wants to annotate a specific week's result with context — for example, "Holiday week — results skewed" — so that teammates reviewing the scorecard understand why numbers look unusual.

**Why this priority**: Core new capability; delivers value independently as soon as notes can be recorded.

**Independent Test**: User can add a note to a specific week's measure slot and see it reflected when the scorecard is displayed.

**Acceptance Scenarios**:

1. **Given** a valid measure ID and a Monday date, **When** the user records a note for that week, **Then** the note is saved and subsequent scorecard fetches include the note on that week's history slot.
2. **Given** an existing note on a week, **When** the user records a new note for the same date, **Then** the previous note is replaced (upsert semantics).
3. **Given** a valid measure ID and date, **When** the user records a note exceeding 255 characters, **Then** the action is rejected with a validation error.
4. **Given** a valid measure ID and date, **When** the user provides a non-string value as the note, **Then** the action is rejected with a validation error.
5. **Given** a valid measure ID, **When** the user provides an invalid or unparseable date, **Then** the action is rejected with a validation error.

---

### User Story 2 - Clear a note from a scorecard week (Priority: P2)

A scorecard user wants to remove an existing note from a week's history slot — either because it was entered in error or is no longer relevant.

**Why this priority**: Clearing is the inverse of recording and required for full note lifecycle management.

**Independent Test**: User can clear an existing note and subsequent scorecard fetches show `null` for that week's note.

**Acceptance Scenarios**:

1. **Given** a week with an existing note, **When** the user clears the note (sends `null` or empty string), **Then** the note is removed and the history slot shows `note: null`.
2. **Given** a week with no note, **When** the user clears the note, **Then** the action succeeds as a no-op.

---

### User Story 3 - View notes when reading a scorecard (Priority: P3)

A scorecard viewer browsing a team's scorecard sees per-week notes alongside values, giving context without needing to leave the scorecard view.

**Why this priority**: Display depends on P1 producing notes; read-only and lower risk.

**Independent Test**: Fetch team measures and verify each history slot includes a `note` field.

**Acceptance Scenarios**:

1. **Given** a team with scorecard measures, **When** the team's measures are fetched, **Then** every history slot includes a `note` field (`string` or `null`).
2. **Given** a week with no note recorded, **When** the team's measures are fetched, **Then** that slot's `note` is `null`.
3. **Given** a week with a note recorded, **When** the team's measures are fetched, **Then** that slot's `note` matches the recorded text.

---

### Edge Cases

- What happens when a note is recorded for a week that has no value entry? Note is independent of value — should succeed.
- What happens when clearing a note that never existed? Should be a silent no-op (success, no error).
- What happens when the date sent is not a Monday? The API normalizes to the ISO week — behavior consistent with existing value recording convention.
- What happens when a note of exactly 255 characters is submitted? Should be accepted (at-boundary case).
- What happens when a note of 256 characters is submitted? Should be rejected with a validation error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST support recording a text note for a specific measure and week date via the measure history note endpoint.
- **FR-002**: The skill MUST support clearing a note for a specific measure and week by sending `null` or an empty string as the note value.
- **FR-003**: If a date is not provided, the skill MUST default to the current week's Monday. The skill MUST reject requests where a date is explicitly provided but is invalid or unparseable.
- **FR-004**: The skill MUST surface validation errors to the user when note text exceeds 255 characters or is a non-string value.
- **FR-005**: When displaying scorecard history, the skill MUST surface each slot's `note` field (string or null) alongside its value.
- **FR-006**: Note recording MUST use upsert semantics — recording a note for an already-noted week replaces the previous note.
- **FR-007**: Note recording and value recording MUST be independent — recording a note MUST NOT modify the week's value, and recording a value MUST NOT modify the week's note.
- **FR-008**: The `api-reference.md` MUST be updated to document the note POST endpoint and the `note` field on history slots returned by the team measures endpoint.

### Key Entities

- **History Slot**: A weekly entry on a scorecard measure. Carries `id`, `date`, `value`, `target_value`, and `note` (string | null). A slot can have a note without a value and vice versa.
- **Note Entry**: The result of a successful note POST. Carries `id` (null when cleared), `measure_id`, `date`, and `note`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can record a note for any measure week they have edit access to in a single command, with the note visible on subsequent scorecard fetches.
- **SC-002**: A user can clear a note in a single command; cleared slots show `null` for the note field on the next scorecard fetch.
- **SC-003**: All scorecard history fetches include the `note` field on every slot — no slots are missing the field regardless of whether a note was ever recorded.
- **SC-004**: Attempts to record invalid notes (wrong type, too long, missing date) are rejected with a clear error message before any change is made.
- **SC-005**: The API reference accurately documents the new note endpoint and the updated history slot shape so other skills can rely on it without re-discovering the API.

## Assumptions

- The `rkit:scorecard` skill is the primary consumer of these changes; both its `SKILL.md` and shared `api-reference.md` need updating.
- Monday dates are the correct week key convention, consistent with existing value recording in the scorecard skill.
- Notes are free-form user-visible text; no minimum length or format is enforced.
- Authentication and team/group edit permissions are enforced by the API — the skill passes the user's token and does not duplicate permission checks.
