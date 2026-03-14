# Contract: Set Team Context

## Endpoint

`PATCH /api/v2/users/me/team-context`

## Request

```
PATCH /api/v2/users/me/team-context
Authorization: Bearer <token>
Content-Type: application/json

{
  "team_id": <integer>
}
```

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `team_id` | integer | ID of the team to set as active |

## Responses

### 200 OK

```json
{
  "data": {
    "id": 8,
    "name": "Engineering"
  }
}
```

### Error Responses

| Status | Condition | Skill Action |
|--------|-----------|--------------|
| 400 | Malformed JSON body | "Bad request (400). Check your input." |
| 401 | Missing or invalid Bearer token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 422 | `team_id` missing, not an integer, team not found, or user not a member | "Cannot set team (422): {error message from API}" |

## Idempotency

Calling with the same `team_id` multiple times is safe and always returns 200.

## Skill Action: `use {team_id}`

Triggered by: `use {team_id}` argument to `/rkit:teams`

**Flow**:
1. Extract `team_id` from args. If missing: "Usage: `/rkit:teams use {team_id}`" — stop.
2. Fetch team name: `GET /teams/{team_id}` → extract `body.data.name`.
3. Confirm: "Set active team to **{name}** (ID: {team_id})?"
4. On confirm: `PATCH /users/me/team-context` with `{"team_id": team_id}`
5. On 200: "Active team set to **{name}** (ID: {id})."
6. On error: Show status code and API error message.
