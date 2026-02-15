# Contract: GET /users/{id}/teams

**Purpose**: List teams the authenticated user belongs to for default
team selection.
**Used by**: US1 (first-time setup), US2 (reconfigure — team change)

## Request

```
GET /users/{id}/teams
Authorization: Bearer <api_token>
```

Path parameter:
- `id` — user ID from `GET /users/me` response

## Response — 200 OK

```json
{
  "data": [
    {
      "id": 1,
      "name": "Engineering",
      "framework": "EOS"
    },
    {
      "id": 2,
      "name": "Product",
      "framework": "OKR"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 2,
    "total_pages": 1
  }
}
```

**Fields used by setup**:
- `data[].id` → shown in team list, stored as `default_team_id`
- `data[].name` → shown in team list
- `data[].framework` → shown in team list

## Response — Empty (user has no teams)

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 0,
    "total_pages": 0
  }
}
```

**Setup behavior**: Display message that user has no teams, set
`default_team_id` to null, complete setup with warning.
