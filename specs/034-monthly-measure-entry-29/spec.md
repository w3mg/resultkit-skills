# Feature Specification: Monthly Measure Entry

**Feature Branch**: `034-monthly-measure-entry-29`
**Created**: 2026-03-10
**Status**: Draft
**Input**: GitHub Issue #29 — [API Change] Change Handoff 014: Monthly Measure Entry

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record a Monthly Scorecard Value (Priority: P1)

A team admin asks rkit to record a scorecard value for a specific month (e.g., "record 87 for Revenue in March 2026"). The skill records the value as a monthly entry and confirms success.

**Why this priority**: Monthly measurement is a first-class use case for teams that review performance on a monthly cadence. Without this, admins must use the web UI or raw API to enter monthly values — a significant friction point.

**Independent Test**: Can be fully tested by asking rkit to record a value for a measure with a month-only date (e.g., "March 2026") and verifying the skill confirms the recorded value and month.

**Acceptance Scenarios**:

1. **Given** a team admin provides a measure name/ID, a numeric value, and a month reference, **When** they ask rkit to record the value, **Then** the value is saved as a monthly entry and the skill confirms the recorded value and month.
2. **Given** a team admin records a value for a month that already has an entry, **When** they submit again, **Then** the previous value is replaced and the skill confirms the updated value.
3. **Given** a non-admin user attempts to record a monthly value, **When** they submit the command, **Then** the skill reports that admin access is required.

---

### User Story 2 - Clear Feedback on Invalid Monthly Entries (Priority: P2)

When an admin provides an invalid value or unrecognizable date for a monthly entry, the skill reports the specific validation error so the user can correct and retry in a single follow-up.

**Why this priority**: Validation errors during scorecard data entry are disruptive. Clear messages reduce friction. Lower priority than the core recording flow but important for usability.

**Independent Test**: Can be tested by submitting a non-numeric value or a malformed date and verifying the skill returns a clear, actionable error without recording anything.

**Acceptance Scenarios**:

1. **Given** an admin provides a non-numeric value (e.g., "n/a"), **When** they submit a monthly entry, **Then** the skill reports that the value must be numeric.
2. **Given** an admin provides an unrecognizable date format, **When** they submit a monthly entry, **Then** the skill reports the expected format clearly.

---

### Edge Cases

- What if the user specifies a full date (e.g., "2026-03-15") when they mean a monthly entry — skill should ask whether to record weekly or monthly.
- What if the measure ID or name is not found — skill must handle the not-found case gracefully.
- What if `period` is omitted in an existing weekly command — weekly entry behaviour must be unchanged (no regression).
- What if a monthly date is given in natural language without a year ("March") — skill should resolve to current year or ask for clarification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `api-reference.md` MUST document the optional `period` field (`"week"` or `"month"`) on `POST /measures/{id}/history`, including that omitting `period` defaults to weekly behaviour (backward-compatible).
- **FR-002**: `api-reference.md` MUST document that monthly `date` accepts `YYYY-MM` or `YYYY-MM-01` as input and that the API response always normalises `date` to `YYYY-MM-01`.
- **FR-003**: rkit MUST support recording a monthly measure value via a natural language command, accepting a month reference and a numeric value.
- **FR-004**: When a monthly entry is saved successfully, the skill MUST confirm the recorded value and the normalised month date returned by the API.
- **FR-005**: When the API returns 422 (invalid value or date format), the skill MUST surface a clear, actionable error message.
- **FR-006**: When the API returns 403, the skill MUST inform the user that admin access is required.
- **FR-007**: All existing weekly scorecard entry commands MUST continue to work without modification — no regressions.

### Key Entities

- **Measure History Entry**: A recorded value for a measure at a specific time interval. Now supports two period types: weekly (default, existing) and monthly (new). Monthly entries use `YYYY-MM-01` as their canonical date.
- **Period**: The interval type for an entry — `"week"` (default, existing) or `"month"` (new). Determines how the `date` field is interpreted and stored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A team admin can record a monthly scorecard value via a natural language command in a single interaction with no additional steps.
- **SC-002**: When a monthly entry is saved, 100% of confirmations show the correct month and value as returned by the API.
- **SC-003**: All existing weekly entry commands continue to work without change — zero regressions.
- **SC-004**: `api-reference.md` fully documents the `period` field extension so future skill changes can be made from the reference without inspecting live API behaviour.
- **SC-005**: When a validation error occurs, 100% of error responses include a clear, user-readable message explaining what needs to be corrected.

## Assumptions

- The rkit scorecard skill already supports recording weekly measure values; this feature adds monthly as a new period type on the same command.
- Month resolution from natural language (e.g., "March 2026") is best-effort; the skill may prompt when the year is ambiguous.
- Validation of `period` and `date` format is enforced server-side; the skill relays API errors without client-side pre-validation.
- Admin status is determined by the API (403 response); the skill does not need to pre-check permissions.
- The read path (displaying monthly entries in scorecard output) is not in scope — only the write path (recording values) is affected by this change.
