# Feature Specification: rkit:setup

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:setup`

## Overview

First-run configuration skill. Creates `~/.config/resultkit/config.json` with API token, default team, and API base URL. All other rkit skills depend on this config existing.

## User Scenarios

### US1 — First-Time Setup (P1)

User has never used rkit before. They invoke `/rkit:setup` and walk through initial configuration.

**Flow**:
1. Skill checks if `~/.config/resultkit/config.json` exists
2. If not, creates `~/.config/resultkit/` directory
3. Asks user for their API token (or reads from `$RESULTKIT_TOKEN` env var)
4. Calls `GET /users/me` to verify token
5. On success, displays user info (name, email)
6. Calls `GET /users/{id}/teams` to list user's teams
7. Displays teams in a numbered list
8. Asks user to pick a default team
9. Writes config file
10. Confirms setup complete

**Acceptance**:
- **Given** no config exists, **When** user runs `/rkit:setup`, **Then** config file is created with valid token and default_team_id
- **Given** invalid token provided, **When** API returns 401, **Then** skill reports error and asks for correct token
- **Given** user has multiple teams, **When** teams are listed, **Then** each shows ID, name, and framework

### US2 — Reconfigure Existing Setup (P2)

User already has config but wants to change token or default team.

**Flow**:
1. Skill detects existing config
2. Shows current config summary (token masked, team name, API base)
3. Asks what to update: token, default team, or API base
4. Performs the selected update
5. Re-verifies if token changed

**Acceptance**:
- **Given** config exists, **When** user runs `/rkit:setup`, **Then** current settings are displayed with token masked (e.g., `rm_...xxxx`)
- **Given** user changes token, **When** new token is saved, **Then** `GET /users/me` is called to verify before writing

### US3 — Environment Variable Fallback (P3)

User has `$RESULTKIT_TOKEN` env var set. Setup detects it automatically.

**Acceptance**:
- **Given** `$RESULTKIT_TOKEN` is set and no config exists, **When** user runs `/rkit:setup`, **Then** skill offers to use the env var token instead of asking for manual input

## Requirements

- **FR-001**: Config file location MUST be `~/.config/resultkit/config.json`
- **FR-002**: Config MUST contain: `api_token`, `default_team_id`, `api_base`
- **FR-003**: Token MUST be verified via `GET /users/me` before saving
- **FR-004**: Token MUST be stored in plaintext (same pattern as rm-api-v2's token storage)
- **FR-005**: API base MUST default to `https://api.resultmaps.com` if not specified
- **FR-006**: Setup MUST NOT overwrite existing config without user confirmation

## Shared Infrastructure

This spec also covers the shared `api.sh` script used by all rkit skills:

```
scripts/api.sh METHOD PATH [BODY]
```

- Reads token and api_base from `~/.config/resultkit/config.json`
- Executes curl with Bearer auth header
- Returns JSON: `{ "status": <int>, "body": <object> }` or `{ "status": 0, "error": "NO_CONFIG" }`

## Config Schema

```json
{
  "api_token": "string (required)",
  "default_team_id": "integer (required)",
  "api_base": "string (default: https://api.resultmaps.com)"
}
```

## Edge Cases

- What if user has no teams? → Display message, skip team selection, set `default_team_id` to `null`
- What if config directory can't be created? → Report filesystem error
- What if token works but teams endpoint fails? → Save token, warn about teams, allow retry
