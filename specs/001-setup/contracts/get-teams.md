# Contract: GET /teams

**Purpose**: List authenticated user's teams for default team selection.
**Used by**: US1 (first-time setup), US2 (reconfigure — team change)

## Request

```
GET /teams
Authorization: Bearer <api_token>
```

Optional query parameters:
- `include_muted` (boolean, default: false) — include muted teams

## Response — 200 OK

Returns a **flat JSON array** (no pagination wrapper). Default team
appears first, then alphabetical by name.

```json
[
  {
    "id": 1,
    "name": "Engineering",
    "framework": "EOS",
    "organization_name": "Acme Corp",
    "organization_id": 10,
    "parent_name": null,
    "parent_id": null,
    "is_default": true,
    "is_muted": false
  },
  {
    "id": 2,
    "name": "Product",
    "framework": "OKR",
    "organization_name": "Acme Corp",
    "organization_id": 10,
    "parent_name": "Engineering",
    "parent_id": 1,
    "is_default": false,
    "is_muted": false
  }
]
```

**Fields used by setup**:
- `id` → shown in team list, stored as `default_team_id`
- `name` → shown in team list
- `framework` → shown in team list
- `is_default` → pre-select the user's current default team

## Response — Empty (user has no teams)

```json
[]
```

**Setup behavior**: Display message that user has no teams, set
`default_team_id` to null, complete setup with warning.
