# Feature Specification: Team Logo URL Support

**Feature Branch**: `033-team-logo-url-27`
**Created**: 2026-03-09
**Status**: Draft
**Input**: GitHub Issue #27 — [API Change] Change Handoff 013: Team Logo URL

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Team Logo in Skill Output (Priority: P1)

An rkit skill user who runs a command that displays team information (e.g., board, today, teams list) sees the team's logo URL included in the output when one has been set, so they know the team has a visual identity configured.

**Why this priority**: The logo URL is now returned by both team list and team detail endpoints. Skills must surface this data accurately to stay consistent with the live API.

**Independent Test**: Can be fully tested by running any skill that calls `GET /api/v2/teams` or `GET /api/v2/teams/:id` and verifying `logo_url` appears in the output when set and is absent (or shown as "none") when null.

**Acceptance Scenarios**:

1. **Given** a team has a logo configured, **When** a skill displays team info, **Then** the Filestack handle (last path segment of `logo_url`) is shown alongside the team name — not the full URL.
2. **Given** a team has no logo set, **When** a skill displays team info, **Then** no logo URL is shown (field is omitted or labeled "none").

---

### User Story 2 - Set Team Logo via Skill (Priority: P2)

An admin user asks rkit to set or update the logo URL for a team. The skill calls the logo endpoint with a Filestack CDN URL and confirms success.

**Why this priority**: The endpoint contract changed from multipart to JSON — any existing set-logo logic would be broken. Updating this ensures admin workflows are functional with the new API.

**Independent Test**: Can be tested by asking rkit to set a logo URL for a team (using a valid Filestack CDN URL), then checking the team detail to confirm the URL is stored.

**Acceptance Scenarios**:

1. **Given** the user is a team admin and provides a valid Filestack CDN URL, **When** they ask rkit to set the team logo, **Then** the logo is saved and the skill confirms the new URL.
2. **Given** the user provides a URL that is not a Filestack CDN URL, **When** they ask rkit to set the team logo, **Then** the skill reports the validation error clearly.
3. **Given** the user is not a team admin, **When** they ask rkit to set the team logo, **Then** the skill reports that admin access is required.

---

### User Story 3 - Remove Team Logo via Skill (Priority: P3)

An admin user asks rkit to remove the logo from a team. The skill calls the delete logo endpoint and confirms the logo has been cleared.

**Why this priority**: This is a new endpoint that enables logo removal — important for admin completeness but lower priority than setting a logo.

**Independent Test**: Can be tested by asking rkit to remove the logo from a team that has one, then verifying the team detail shows no logo.

**Acceptance Scenarios**:

1. **Given** a team has a logo set, **When** an admin asks rkit to remove it, **Then** the logo is deleted and the skill confirms `logo_url` is now null.
2. **Given** a team has no logo set, **When** an admin asks rkit to remove it, **Then** the skill still reports success (endpoint is idempotent).
3. **Given** the user is not a team admin, **When** they ask rkit to remove the logo, **Then** the skill reports that admin access is required.

---

### Edge Cases

- What happens when `logo_url` is `null` in the API response — skill must not display a broken or empty field.
- What happens when a non-Filestack URL is provided to the set-logo command — skill must surface the 422 validation error clearly.
- What happens when the user is not an admin and attempts to set/remove a logo — skill must relay the 403 response as a permissions message.
- What if the team ID is invalid or not found — skill must handle 404 gracefully.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `api-reference.md` MUST document `logo_url: string | null` as a field in the team object returned by `GET /api/v2/teams/{id}` and `GET /api/v2/teams`.
- **FR-002**: `api-reference.md` MUST document `POST /api/v2/teams/{id}/logo` accepting a JSON body `{ "logo_url": "..." }` with the Filestack CDN URL prefix requirement, upsert behavior, and admin-only authorization.
- **FR-003**: `api-reference.md` MUST document `DELETE /api/v2/teams/{id}/logo` as a new endpoint that removes the stored logo URL, noting idempotent behavior and admin-only authorization.
- **FR-004**: Any rkit skill that displays team information MUST show `logo_url` when present in the API response.
- **FR-005**: rkit MUST support setting a team logo via a natural language command, accepting a Filestack CDN URL and confirming success.
- **FR-006**: rkit MUST support removing a team logo via a natural language command and confirming success.
- **FR-007**: When the API returns 422 for an invalid `logo_url`, the skill MUST surface a clear error explaining the URL must be a Filestack CDN URL.
- **FR-008**: When the API returns 403, the skill MUST inform the user that admin permissions are required.

### Key Entities

- **Team**: Represents a ResultMaps team. Now includes `logo_url: string | null` — a Filestack CDN URL for the team's logo image, or `null` if no logo is set.
- **Team Logo**: A Filestack CDN URL stored server-side for a team. Set via the logo upload endpoint, removed via the logo delete endpoint. Both operations are admin-only.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All rkit skills that display team data show `logo_url` accurately — present when set, absent when null — with zero false positives or missing values.
- **SC-002**: An admin can set a team logo using a natural language command in a single interaction with no additional steps required.
- **SC-003**: An admin can remove a team logo using a natural language command in a single interaction.
- **SC-004**: When a non-Filestack URL is provided, 100% of attempts produce a clear, actionable error message without confusing the user.
- **SC-005**: `api-reference.md` reflects all four logo-related endpoint changes so future skills can be built from the reference without needing to inspect live API behavior.

## Assumptions

- The rkit skill suite does not currently implement a set-logo or remove-logo command — this feature adds both for the first time.
- `logo_url` display in skills is informational only; skills show the URL as text, not as a rendered image.
- Filestack URL validation is enforced server-side; the skill relays the API error without client-side pre-validation.
- Admin status is determined by the API (403 response); the skill does not need to pre-check permissions.
