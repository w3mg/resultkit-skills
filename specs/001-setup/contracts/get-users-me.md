# Contract: GET /users/me

**Purpose**: Verify API token and retrieve authenticated user profile.
**Used by**: US1 (first-time setup), US2 (reconfigure — token change)

## Request

```
GET /users/me
Authorization: Bearer <api_token>
```

No query parameters. No request body.

## Response — 200 OK

Response is wrapped in a `data` property.

```json
{
  "data": {
    "id": 42,
    "login": "scottlevy",
    "email": "scott@example.com",
    "first_name": "Scott",
    "last_name": "Levy",
    "api_token": "rm_abc123...",
    "default_team": { "id": 1, "name": "Engineering" },
    "current_team": { "id": 1, "name": "Engineering" }
  }
}
```

**Fields used by setup**:
- `first_name`, `last_name` → displayed in setup confirmation
- `email` → displayed in setup confirmation
- `default_team` → user's preferred/home team (`TeamSummary | null`)
- `current_team` → user's active team context, falls back to `default_team` if invalid (`TeamSummary | null`)

**TeamSummary**: `{ id: integer, name: string }`

## Response — 401 Unauthorized

```json
{
  "error": "Invalid or missing token"
}
```

**Setup behavior**: Display error, ask user for correct token.
