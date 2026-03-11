# Feature Specification: Measure Data Source Fields

**Feature Branch**: `035-measure-data-source-30`
**Created**: 2026-03-10
**Status**: Draft
**Input**: User description: "GitHub Issue #30: [API Change] Change Handoff 015: Measure Data Source"

## Overview

The ResultMaps API now exposes `data_source_type` on all scorecard measures and supports a new roll-up measure type (`data_source_type=3`). Roll-up measures aggregate values from other measures on the same team via `roll_up_type` (sum or average) and a list of `roll_up_measure_ids`. The rkit skill suite must be updated to reflect these new fields in API reference docs and relevant skills.

## Scope

**In scope**:
- Update `api-reference.md` to document new fields on the measures endpoints (GET, POST, PATCH)
- Update scorecard skill (`/rkit:scorecard`) to display `data_source_type` where relevant
- Ensure measure creation/update flows accept and pass through `data_source_type`, `roll_up_type`, `roll_up_measure_ids`

**Out of scope**:
- UI for creating roll-up measures from scratch (no dedicated rkit measure-creation skill exists yet)
- Validating circular references client-side (server handles this)

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View scorecard with roll-up measures (Priority: P1)

A team admin views their scorecard and sees measures that are roll-ups. The skill should clearly indicate that these measures aggregate from other measures rather than accepting manual entries.

**Why this priority**: Roll-up measures appear alongside manual measures in scorecard output; displaying them correctly without confusing users is the core value.

**Independent Test**: Run `/rkit:scorecard` on a team that has at least one roll-up measure (`data_source_type=3`). The output should show the measure with its roll-up info (roll_up_type and source measure IDs), distinct from manual measures.

**Acceptance Scenarios**:

1. **Given** a team has a roll-up measure, **When** the user runs `/rkit:scorecard`, **Then** the measure is displayed with its `data_source_type` label (e.g., "roll-up") and `roll_up_type` (sum/average).
2. **Given** a team has only manual measures, **When** the user runs `/rkit:scorecard`, **Then** output is unchanged from prior behavior.

---

### User Story 2 — api-reference.md reflects new measure fields (Priority: P1)

A developer or skill maintainer reads `api-reference.md` and sees accurate documentation for `data_source_type`, `roll_up_type`, and `roll_up_measure_ids` on all three measures endpoints (GET, POST, PATCH).

**Why this priority**: The reference is the source of truth for all skill logic. Inaccurate reference leads to incorrect skill behavior.

**Independent Test**: Open `api-reference.md` and verify the measures section documents `data_source_type` (always present, values 0–3), and that POST/PATCH sections list `roll_up_type` and `roll_up_measure_ids` as optional fields.

**Acceptance Scenarios**:

1. **Given** the updated `api-reference.md`, **When** checking the `GET /api/v2/teams/{id}/measures` response docs, **Then** `data_source_type` is listed as always-present with values 0=manual, 1=google_sheets, 2=other_api, 3=roll_up.
2. **Given** the updated `api-reference.md`, **When** checking POST and PATCH request bodies, **Then** `data_source_type`, `roll_up_type`, and `roll_up_measure_ids` are listed as optional parameters with types and valid values.
3. **Given** the updated `api-reference.md`, **When** checking roll-up field visibility rules, **Then** it notes `roll_up_type` and `roll_up_measure_ids` are only present in responses when `data_source_type=3`.

---

### User Story 3 — Scorecard entry respects data_source_type (Priority: P2)

When a user attempts to enter a scorecard value for a roll-up measure, the skill should inform them that roll-up measures are auto-calculated and cannot accept manual entries.

**Why this priority**: Prevents user confusion — attempting to enter a value for a roll-up measure would either fail or produce misleading results.

**Independent Test**: Run the scorecard entry flow targeting a measure with `data_source_type=3`. The skill should detect this and inform the user instead of prompting for a value.

**Acceptance Scenarios**:

1. **Given** a user attempts to record a value for a roll-up measure, **When** the skill detects `data_source_type=3`, **Then** it informs the user that this measure is auto-calculated and skips the entry prompt.
2. **Given** a user records a value for a manual measure (`data_source_type=0`, `1`, or `2`), **When** the entry is submitted, **Then** behavior is unchanged from prior behavior.

---

### Edge Cases

- What happens when `roll_up_measure_ids` is an empty array? (Server likely rejects with 422; skill should surface the error clearly.)
- What if the API returns `data_source_type` values other than 0–3? (Skill should display the raw value rather than crash.)
- What if `roll_up_type` or `roll_up_measure_ids` appear on a non-roll-up measure? (Treat as unexpected; display what the API returns.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `api-reference.md` MUST document `data_source_type` as a field on all measure response objects, with values: `0`=manual, `1`=google_sheets, `2`=other_api, `3`=roll_up.
- **FR-002**: `api-reference.md` MUST document `roll_up_type` and `roll_up_measure_ids` as optional request parameters on `POST /api/v2/teams/{id}/measures` and `PATCH /api/v2/measures/{id}`.
- **FR-003**: `api-reference.md` MUST note that `roll_up_type` and `roll_up_measure_ids` appear in GET responses only when `data_source_type=3`.
- **FR-004**: `api-reference.md` MUST document validation constraints: cross-team IDs, self-reference, and circular references return 422.
- **FR-005**: The scorecard skill MUST display `data_source_type` context for measures — at minimum, distinguish roll-up measures from manual measures in output.
- **FR-006**: When a user attempts to enter a scorecard value for a roll-up measure, the skill MUST detect `data_source_type=3` and inform the user it is auto-calculated rather than accepting a value.
- **FR-007**: All updated `api-reference.md` content MUST be synced to all skill `references/api-reference.md` copies via `/sync-plugin`.

### Key Entities

- **Measure**: A scorecard metric tracked weekly/monthly. Now has `data_source_type` (always present), and conditionally `roll_up_type` + `roll_up_measure_ids` (when `data_source_type=3`).
- **Roll-up Measure**: A measure whose value is computed by summing or averaging other measures on the same team. Cannot accept manual value entries.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `api-reference.md` accurately documents all new measure fields — verifiable by reading the reference and comparing against the API Change Handoff.
- **SC-002**: Running `/rkit:scorecard` on a team with roll-up measures produces output that distinguishes roll-up measures from manual measures without errors.
- **SC-003**: Attempting to enter a value for a roll-up measure via scorecard entry produces a clear informational message rather than an API error or silent failure.
- **SC-004**: All skill copies of `api-reference.md` are in sync after `/sync-plugin` is run.

## Assumptions

- The rkit scorecard skill currently reads measure objects from the API; `data_source_type` is now always present in those responses so no extra API call is needed to get it.
- There is no dedicated measure-creation skill in rkit; only scorecard display and entry skills are affected.
- `data_source_type` values `1` (google_sheets) and `2` (other_api) also cannot accept manual entries, but this feature focuses on rolling out support for `3` (roll_up) per the API change handoff scope.
