# Feature Specification: rkit:teams

**Created**: 2026-02-23
**Status**: Draft
**Skill**: `/rkit:teams`

## Overview

List the authenticated user's visible (non-muted) teams and view team members. This is a read-only skill — no writes, no config changes. The existing `/rkit:team` skill (009) handles switching default team and showing team detail; this skill focuses on quick team listing and member lookup.

## API Endpoints

### GET /teams

Returns the authenticated user's teams as a flat JSON array (no `data`/`meta` wrapper — just a raw array).

| Param | Type | Description |
|-------|------|-------------|
| `include_muted` | string | `"true"` to include muted teams. Default behavior (omitted or `"false"`) excludes muted teams. |
| `q` | string | Filter by team name (min 2 chars, case-insensitive contains match) |

**Verified behavior** (2026-02-23):
- Default (no `include_muted` param): returns 62 teams, 0 muted — server-side filtering works.
- `include_muted=true`: returns 165 teams, 103 of which are muted.
- Response is a **flat array**, not paginated. No `meta` object. Every team object includes an `is_muted` field.
- Teams are ordered: default team first, then alphabetical.

**Response fields per team**: `id`, `name`, `description`, `framework`, `organization_name`, `organization_id`, `parent_name`, `parent_id`, `is_default`, `is_muted`, `creator` (UserSimple), `created_at`, `updated_at`.

### GET /teams/{id}/members

Returns paginated team members.

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `per_page` | integer | Results per page, 1–100 (default: 100) |
| `q` | string | Filter members by name |

**Verified behavior** (2026-02-23):
- Returns standard paginated response: `{ data: [...], meta: { page, per_page, total, total_pages } }`.
- Each member: `id` (membership ID), `team` (TeamSimple), `user` (UserSimple: `id`, `login`, `first_name`, `last_name`), `role` (`"member"` | `"admin"`).

### API Gaps

None identified. Both endpoints needed for this skill exist and work as documented.

## User Scenarios

### US1 — List My Teams (P1)

User wants to see their active, visible teams.

**Flow**:
1. Read config for token
2. Call `GET /teams` (default — excludes muted)
3. Display table grouped by organization: ID, Name, Framework, mark default team

**Invocation**:
- `/rkit:teams` — list active, non-muted teams

**Acceptance**:
- **Given** user has 62 visible teams across multiple orgs, **When** `/rkit:teams` is invoked with no args, **Then** all visible teams are displayed grouped by organization with the default team marked
- **Given** user's config has `default_team_id: 345`, **When** teams are listed, **Then** team 345 shows `(default)` marker
- **Given** user has muted teams, **When** `/rkit:teams` is invoked, **Then** muted teams are excluded

### US2 — Search Teams by Name (P2)

User wants to find a team by name.

**Flow**:
1. Read config for token
2. Call `GET /teams?q={search_term}`
3. Display matching teams

**Invocation**:
- `/rkit:teams q "leadership"` — search for teams with "leadership" in the name
- `/rkit:teams q "mender"` — search for teams matching "mender"

**Acceptance**:
- **Given** `/rkit:teams q "leadership"`, **When** multiple teams match, **Then** all matching teams are shown
- **Given** `/rkit:teams q "zz"`, **When** no teams match, **Then** "No teams matching 'zz'."
- **Given** search term is 1 character, **Then** warn "Search requires at least 2 characters."

### US3 — List Team Members (P1)

User wants to see who is on a specific team.

**Flow**:
1. Read config for token
2. Call `GET /teams/{id}/members?per_page=100`
3. Display table: Name, Role, User ID
4. If more than 1 page, fetch all pages

**Invocation**:
- `/rkit:teams members {team_id}` — list members for a specific team
- `/rkit:teams members` — list members for the default team

**Acceptance**:
- **Given** `/rkit:teams members 345`, **When** team has 5 members, **Then** all 5 members displayed with name and role
- **Given** `/rkit:teams members` with `default_team_id: 345`, **Then** shows members of team 345
- **Given** `/rkit:teams members 999`, **When** team not found, **Then** "Team 999 not found (404)."
- **Given** a member has empty first/last name, **Then** fall back to displaying login

### US4 — Include Muted Teams (P3)

User wants to see all teams, including muted ones.

**Flow**:
1. Read config for token
2. Call `GET /teams?include_muted=true`
3. Display table with muted teams marked

**Invocation**:
- `/rkit:teams all` — include muted teams in the listing

**Acceptance**:
- **Given** `/rkit:teams all`, **When** user has 103 muted teams, **Then** all 165 teams displayed with muted teams marked `(muted)`
- **Given** `/rkit:teams all q "leadership"`, **Then** search includes muted teams

## Requirements

- **FR-001**: MUST use `GET /teams` (no `include_muted`) by default to exclude muted teams — server-side filtering is confirmed working
- **FR-002**: MUST use `GET /teams/{id}/members` for member listing with standard pagination handling
- **FR-003**: MUST mark the current default team (from `default_team_id` in config) in list output
- **FR-004**: MUST group teams by `organization_name` in display
- **FR-005**: MUST show `framework` for each team (eos, okr, srt, etc.) or "—" if null
- **FR-006**: MUST handle members with empty names by falling back to `login`
- **FR-007**: MUST show member `role` (admin/member) in the members table
- **FR-008**: This is a **read-only** skill — no writes to config or API
- **FR-009**: MUST support `q` search param (min 2 chars) passed through to the API
- **FR-010**: MUST paginate through all pages for `/teams/{id}/members` if `total_pages > 1`

## Edge Cases

- No config exists → prompt to run `/rkit:setup`
- User has only one team → display it, no grouping header needed
- Team has no members (empty data array) → "No members found for team {id}."
- Member with empty first_name and last_name → display `login` instead
- `q` search term < 2 chars → "Search requires at least 2 characters."
- Team not found (404) on members request → "Team {id} not found (404)."
- No teams match search → "No teams matching '{term}'."
- Large team count (165+) → no pagination concerns since `/teams` returns a flat array, but consider output readability
