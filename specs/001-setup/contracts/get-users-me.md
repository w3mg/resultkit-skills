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

```json
{
  "id": 42,
  "name": "Scott Levy",
  "email": "scott@example.com",
  "api_token": "rm_abc123..."
}
```

**Fields used by setup**:
- `id` → passed to `GET /users/{id}/teams`
- `name` → displayed in setup confirmation
- `email` → displayed in setup confirmation

## Response — 401 Unauthorized

```json
{
  "error": "Invalid or missing token"
}
```

**Setup behavior**: Display error, ask user for correct token.
