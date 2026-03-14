# Feature Specification: Team Context Endpoint

**Feature Branch**: `037-team-context-endpoint-32`
**Created**: 2026-03-13
**Status**: Draft
**Input**: User description: "GitHub Issue #32: [API Change] 017 — Team Context Endpoint"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update API Reference with Team Context Endpoint (Priority: P1)

As a skill maintainer, I need the api-reference.md to document the new `PATCH /api/v2/users/me/team-context` endpoint and the corrected behavior of `current_team` in `GET /api/v2/users/me`, so that all skills have an accurate reference when making API calls.

**Why this priority**: The api-reference.md is the source of truth for all skill API usage. Without accurate documentation, skills may miss the new endpoint or misuse the now-functional `current_team` field.

**Independent Test**: Can be fully tested by reading the updated api-reference.md and confirming both the new PATCH endpoint and the updated GET /users/me `current_team` description are present and accurate.

**Acceptance Scenarios**:

1. **Given** the api-reference.md exists, **When** a developer reads the Users section, **Then** they find a documented entry for `PATCH /api/v2/users/me/team-context` with required parameter `team_id` (integer) and success/error response codes.
2. **Given** the api-reference.md exists, **When** a developer reads the `GET /api/v2/users/me` section, **Then** the `current_team` field is documented as now reflecting the team last set via the PATCH endpoint (no longer always null).

---

### User Story 2 - Skills Can Set Active Team via API (Priority: P2)

As a ResultMaps user running rkit skills, I want the skill to be able to set my active team on the server when I switch teams, so that subsequent API calls reflect my current team context without manual workarounds.

**Why this priority**: Team context drives which scorecard, board, and items are shown. If the server-side team context is stale, users see data from the wrong team.

**Independent Test**: Can be fully tested by running a team-switch action in a skill and verifying the API confirms the new active team in a subsequent `GET /api/v2/users/me` call.

**Acceptance Scenarios**:

1. **Given** a user is authenticated and belongs to multiple teams, **When** a skill calls the set-team-context action with a valid team ID, **Then** the API returns 200 with the team's `id` and `name` confirming the switch.
2. **Given** a user attempts to switch to a team they are not a member of, **When** the skill calls the set-team-context action, **Then** the skill surfaces a clear error indicating the team is unavailable.
3. **Given** a user sets their team context via the skill, **When** the skill subsequently fetches the current user, **Then** the active team field reflects the team just set.

---

### Edge Cases

- What happens when `team_id` is not an integer or is missing? → API returns 422; skill surfaces a user-friendly error.
- What happens when the user is not a member of the requested team? → API returns 422; skill surfaces a clear "not a member" message.
- What happens when the PATCH is called multiple times with the same team ID? → Idempotent — returns 200 each time; no side effects.
- What happens if the Bearer token is missing or invalid? → API returns 401; skill exits with an authentication error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The api-reference.md MUST document `PATCH /api/v2/users/me/team-context` with its request body (`team_id` integer), success response (200 with team id and name), and error codes (400, 401, 422).
- **FR-002**: The api-reference.md MUST update the `GET /api/v2/users/me` entry to note that `current_team` now reflects the value last set by `PATCH /api/v2/users/me/team-context` and is no longer always null.
- **FR-003**: The appropriate rkit skill MUST expose a way to call the set-team-context endpoint with a `team_id` to update the user's active team on the server.
- **FR-004**: The set-team-context action MUST display the confirmed team name on success and a clear, human-readable error message on failure (422 or 401).
- **FR-005**: All skill copies of api-reference.md MUST be updated via the sync-plugin workflow after the master is updated.

### Key Entities

- **Team Context**: The server-side record of which team is currently active for a user, represented by `{ id, name }` returned by the set-team-context endpoint and surfaced via the `current_team` field in the current-user response.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The api-reference.md contains a complete, accurate entry for `PATCH /api/v2/users/me/team-context` that a developer can use without consulting external documentation.
- **SC-002**: The `GET /api/v2/users/me` entry in api-reference.md explicitly documents that `current_team` is now populated after a successful set-team-context call.
- **SC-003**: A user can switch active teams via a skill command and receive confirmation of the new team name within a single interaction.
- **SC-004**: Error scenarios (invalid team, not a member, auth failure) result in human-readable messages rather than raw API error codes.

## Assumptions

- The api-reference.md master copy is at `api-reference.md` in the repo root and is synced to all skills via `/sync-plugin`.
- The appropriate home for the set-team-context action is within an existing skill (e.g., rkit:setup or rkit:board) rather than a new standalone skill, unless codebase exploration suggests otherwise.
- The `current_team` meta_key fix is already deployed to the production API — no changes are needed to the API itself.
- Skills that currently read `current_team` from `GET /api/v2/users/me` may have been silently receiving `null`; after this fix they will receive real data. Any skill with logic that assumed `current_team` is null should be reviewed.
