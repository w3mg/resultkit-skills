# Feature Specification: Measure chart_type Field

**Feature Branch**: `036-measure-chart-type-31`
**Created**: 2026-03-13
**Status**: Draft
**Input**: User description: "GitHub Issue #31: [API Change] 016 — Measure chart_type Field"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Display chart_type in Measure Listings (Priority: P1)

A skill user asks to see scorecard measures for a team or seat. The skill displays each measure's name and, when present, its chart type so users know what visualization is configured.

**Why this priority**: The `chart_type` field is now included in all measure responses. Skills that display measures should surface this field — it's the most visible part of the change and requires no write access.

**Independent Test**: Run the scorecard or measures skill against a real team; verify that measures with a non-null `chart_type` show the value and measures with `null` show "none" or omit the field cleanly.

**Acceptance Scenarios**:

1. **Given** a measure has `chart_type: "progress_bar"`, **When** the skill lists measures, **Then** it displays "progress_bar" (or a human-friendly equivalent) alongside the measure name.
2. **Given** a measure has `chart_type: null`, **When** the skill lists measures, **Then** it omits the chart type or indicates none is set — no error or raw "null" printed.

---

### User Story 2 - Set chart_type When Creating a Measure (Priority: P2)

A skill user creates a new measure and optionally specifies a chart type. The skill passes `chart_type` in the create request and confirms the saved value in the response.

**Why this priority**: Creating measures with a chart type preference is a common setup task; skills should support it on creation so users don't need a separate update step.

**Independent Test**: Create a measure via the skill with a specific chart type and verify the response confirms the chart type was saved.

**Acceptance Scenarios**:

1. **Given** a user specifies a valid chart type during measure creation, **When** the skill creates the measure, **Then** the response includes the correct `chart_type` value.
2. **Given** a user does not specify a chart type, **When** the skill creates the measure, **Then** `chart_type` is omitted from the request and the measure is created successfully with `chart_type: null`.
3. **Given** a user specifies an invalid chart type, **When** the skill attempts to create the measure, **Then** the skill reports an error with valid options listed and does not call the API.

---

### User Story 3 - Update chart_type on an Existing Measure (Priority: P3)

A skill user updates a measure's chart type or clears it. The skill sends the correct update payload and confirms the result.

**Why this priority**: Changing visualization preference after initial creation is a secondary flow; useful but not blocking.

**Independent Test**: Update a measure's chart type via the skill and verify the response reflects the new value. Then clear it and verify.

**Acceptance Scenarios**:

1. **Given** an existing measure, **When** the user sets `chart_type` to a valid value via the skill, **Then** the measure is updated and the new chart type is confirmed.
2. **Given** an existing measure with a chart type, **When** the user clears the chart type, **Then** the measure's chart type is removed.
3. **Given** an existing measure, **When** the user updates only the name with no chart_type specified, **Then** the chart type is preserved unchanged.

---

### Edge Cases

- What happens when an invalid `chart_type` string is supplied? The skill should show the valid options and not call the API.
- What if the API returns an unexpected `chart_type` value not in the known enum? The skill should display the raw value rather than error.
- What if `chart_type` is absent from an API response (older data)? The skill must not crash — treat missing field as `null`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST display `chart_type` when listing or showing measures, rendering `null` gracefully (omit or label as "none").
- **FR-002**: The skill MUST accept an optional `chart_type` parameter when creating a measure and include it in the API request payload.
- **FR-003**: The skill MUST accept an optional `chart_type` parameter when updating a measure; omitting it MUST NOT send the key in the request body (preserves existing value).
- **FR-004**: The skill MUST support setting `chart_type` to `null` to clear the preference.
- **FR-005**: The skill MUST validate `chart_type` input against the known enum (`pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`) and show a helpful error for invalid values before calling the API.
- **FR-006**: The api-reference.md MUST document `chart_type` on the measure create and update endpoints, including valid values and null semantics.

### Key Entities

- **Measure**: A scorecard metric tracked over time. Now includes an optional `chart_type` field (string or absent) indicating the user's preferred visualization. Valid values: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`. Absent or null means no preference is set.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Skills that list measures display `chart_type` without errors for all measures regardless of whether the field is set.
- **SC-002**: A measure can be created with a chart type in one step — no follow-up update required.
- **SC-003**: A measure's chart type can be changed or cleared without affecting any other fields.
- **SC-004**: Invalid chart type values are caught before the API call, with valid options displayed to the user.
- **SC-005**: The API reference accurately documents `chart_type` for all four affected endpoints (GET team measures, GET seat measures, POST measure, PATCH measure).

## Assumptions

- The `chart_type` field is already live in the production API.
- Skills that display measures currently show name and other fields; adding `chart_type` display is additive and does not break existing output.
- The enum of valid values (`pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`) is stable.
- Client-side validation against the enum is a UX convenience; the API is the authoritative validator (returns 422 for invalid values).
