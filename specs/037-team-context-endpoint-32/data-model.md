# Data Model: Team Context Endpoint

**Branch**: `037-team-context-endpoint-32` | **Date**: 2026-03-13

## Entities

### TeamContext (set-team-context response)

Returned by `PATCH /users/me/team-context`.

| Field | Type | Description |
|-------|------|-------------|
| `id`  | integer | Team ID |
| `name` | string | Team display name |

Response envelope: `{ "data": { "id": integer, "name": string } }`

### TeamSimple (existing — updated behavior)

Returned as `current_team` in `GET /users/me` response.

| Field | Type | Description |
|-------|------|-------------|
| `id`  | integer | Team ID |
| `name` | string | Team display name |

**Behavior change**: `current_team` is now reliably populated after a `PATCH /users/me/team-context` call. Previously always `null` or stale due to a meta_key bug (now fixed in the API).

## State Transitions

None — team context is a simple overwite. No state machine.

## Validation Rules (API-enforced)

- `team_id` must be present in the request body.
- `team_id` must be an integer.
- The team must exist.
- The authenticated user must be a member of the team.
