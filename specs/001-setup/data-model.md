# Data Model: rkit:setup

**Phase**: 1 — Design & Contracts
**Date**: 2026-02-14

## Entities

### Config

Persisted to `~/.config/resultkit/config.json`.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| api_token | string | yes | — | Bearer token for API auth |
| default_team_id | integer | yes | — | User's chosen default team |
| api_base | string | no | `https://api.resultmaps.com` | API base URL |

**Validation rules**:
- `api_token` MUST be non-empty and pass `GET /users/me` verification.
- `default_team_id` MUST be an integer matching a team the user
  belongs to (or null if user has no teams).
- `api_base` MUST be a valid URL with no trailing slash.

**State transitions**: None — config is a static document, not a
stateful entity.

### User Account (API response, not persisted)

Returned by `GET /users/me`.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | User ID (used to fetch teams) |
| name | string | Display name |
| email | string | Email address |

### Team (API response, not persisted)

Returned by `GET /users/{id}/teams`.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Team ID (stored as default_team_id) |
| name | string | Team display name |
| framework | string | Management framework (EOS, OKR, etc.) |

## Relationships

```text
User Account (1) ──has many──> Team (N)
Config.default_team_id ──references──> Team.id
Config.api_token ──authenticates──> User Account
```

## File System Layout

```text
~/.config/
└── resultkit/
    └── config.json    # Single config file
```

The config directory is created by setup if it does not exist.
The config file is written atomically (write to temp, then move).
