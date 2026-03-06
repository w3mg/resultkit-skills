# Data Model: V2 Seat API Field Renames

**Feature**: 030-seats-field-renames
**Date**: 2026-03-05

## Seat Entity (V2 — updated)

### Full Seat (tree node and detail response)

```json
{
  "id": 11,
  "name": "Visionary",
  "accountabilities": "<ul><li>Strategic direction</li></ul>",
  "notes": null,
  "parent": { "id": 5, "name": "Board" } | null,
  "creator": { "id": 1, "login": "scott", "first_name": "Scott", "last_name": "Levy" },
  "seat_owner": { "id": 2, "login": "jane", "first_name": "Jane", "last_name": "Doe" } | null,
  "team": { "id": 345, "name": "Acme Corp", "framework": "eos" },
  "associated_team": { "id": 1, "name": "Sub-team" } | null,
  "measures": [{ "id": 793, "name": "Revenue", "description": "" }],
  "goals": [{ "id": 7315, "name": "Q1 Goal", "description": null }],
  "links": [{ "id": 2078, "title": "Wiki", "url": "https://example.com" }],
  "children": [...],
  "created_at": "2018-01-23T18:59:28.000Z",
  "updated_at": "2026-03-04T05:53:47.000Z"
}
```

- **Tree endpoint** (`GET /teams/{id}/seats`): `children` are full recursive Seat objects
- **Detail endpoint** (`GET /seats/{id}`): `children` are `{ id, name }` only

### Create Seat Request

```json
// Root seat
{ "name": "CEO", "team_id": 10 }

// Child seat
{ "name": "VP Sales", "parent_id": 1, "seat_owner_id": 5, "accountabilities": "<p>...</p>" }
```

### Update Seat Request

```json
{
  "name": "New Name",
  "seat_owner_id": 5,
  "accountabilities": "<p>Key responsibilities</p>",
  "notes": "...",
  "associated_team_id": 3
}
```

## Field Rename Summary

### Input (request) renames

| Old Field | New Field | Endpoint |
|-----------|-----------|----------|
| `group_id` | `team_id` | POST /seats (root seat) |
| `accountability_owner_id` | `seat_owner_id` | POST /seats, PATCH /seats/{id} |
| `description` | `accountabilities` | POST /seats, PATCH /seats/{id} |

### Output (response) renames

| Old Field | New Field | Type Change |
|-----------|-----------|-------------|
| `description` | `accountabilities` | None |
| `owner` | `seat_owner` | None |
| `parent_id` (int) | `parent` ({ id, name } or null) | int → object |

### SeatSimple (children in detail response)

| Old Shape | New Shape |
|-----------|-----------|
| `{ id, name, parent_id, owner }` | `{ id, name }` |
