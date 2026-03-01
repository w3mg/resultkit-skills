# Feature Specification: Teams Envelope Fix & Error Handling Update

**Feature Branch**: `022-teams-envelope-fix`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #11: [API Change] V2 Error Handling & Teams Envelope Fix — Handoff

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Teams Skill Handles Data Envelope (Priority: P1)

A user runs `/rkit:teams` to list their teams. The API now returns `{ "data": [...] }` instead of a bare array. The skill must parse the new envelope format and display teams correctly, with no change in user-facing behavior.

**Why this priority**: This is a breaking change. Without this fix, the teams skill will fail to display any teams — the most fundamental team operation.

**Independent Test**: Run `/rkit:teams` and verify teams are listed in a table with ID, name, framework, and default marker. Output should be identical to pre-change behavior.

**Acceptance Scenarios**:

1. **Given** a user with teams, **When** they run `/rkit:teams`, **Then** teams are displayed in a table (same format as before the API change).
2. **Given** a user with a default team, **When** they run `/rkit:teams`, **Then** the default team is marked and listed first.
3. **Given** a user with muted teams, **When** they run `/rkit:teams --include-muted`, **Then** muted teams are included.

---

### User Story 2 - Setup Skill Handles Data Envelope (Priority: P1)

A user runs `/rkit:setup` for first-time configuration. During team selection, the skill fetches `GET /teams` which now returns `{ "data": [...] }`. The skill must parse the new format and present the team list for selection.

**Why this priority**: Without this fix, new users cannot complete setup — they'll see no teams to select from.

**Independent Test**: Run `/rkit:setup` with a valid token. Verify the team selection step displays available teams correctly.

**Acceptance Scenarios**:

1. **Given** a user running setup, **When** the skill fetches teams, **Then** teams are listed for selection using the new envelope format.
2. **Given** a user with a default team, **When** teams are listed during setup, **Then** the default team is pre-selected or indicated.

---

### User Story 3 - API Reference Documents Envelope & Errors (Priority: P2)

The api-reference.md is updated to reflect that `GET /teams` returns a `data` envelope (matching all other list endpoints) and that a new `internal_error` (500) error code exists.

**Why this priority**: Documentation accuracy. Other skills and developers rely on api-reference.md as the source of truth.

**Independent Test**: Read api-reference.md and verify the Teams section documents the `data` envelope and the Error Responses section includes `internal_error`.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer reads the Teams section, **Then** it documents that `GET /teams` returns a standard `data` envelope with pagination meta.
2. **Given** the api-reference.md, **When** a developer reads the Error Responses section, **Then** `500 internal_error` is listed as a possible error.

---

### Edge Cases

- What happens if the API returns an empty teams array in the new envelope? The skill displays "No teams found." (same as before).
- What happens if the API returns a 500 `internal_error`? The skill shows the error message from the response body.
- What happens if a skill still receives a bare array (API rollback)? The skill should handle both formats gracefully during the transition period.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The teams skill MUST parse `GET /teams` response from the `data` envelope instead of as a bare array.
- **FR-002**: The setup skill MUST parse `GET /teams` response from the `data` envelope during team selection.
- **FR-003**: The api-reference.md MUST document that `GET /teams` returns a standard `{ "data": [...] }` envelope.
- **FR-004**: The api-reference.md MUST include `500 internal_error` in the Error Responses table.
- **FR-005**: Skills that handle errors MUST recognize the `internal_error` code and display a user-friendly message.

### Key Entities

- **Teams Response**: Previously a bare JSON array, now wrapped in the standard V2 data envelope `{ "data": [...] }`. No change to individual team object structure.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can list teams via `/rkit:teams` with identical output before and after the API change.
- **SC-002**: Users can complete `/rkit:setup` team selection without errors after the API change.
- **SC-003**: The api-reference.md accurately reflects the current API response format for all endpoints.
- **SC-004**: No skill produces a parsing error or empty result when the API returns a 500 `internal_error`.

## Assumptions

- The API change (`GET /teams` returning `data` envelope) is already deployed to production.
- All other `GET /teams/*` sub-endpoints (members, items, projects, headlines) already use the `data` envelope — only the top-level `GET /teams` was previously a bare array.
- The `internal_error` (500) error follows the same `{ "error": { "code", "message" } }` structure as other V2 errors.
- No other skills besides `rkit:teams` and `rkit:setup` directly parse the `GET /teams` list response as a bare array.
