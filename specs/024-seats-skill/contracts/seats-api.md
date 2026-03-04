# API Contracts: Seats

**Date**: 2026-03-04 | **Branch**: `024-seats-skill`

## Endpoints

### GET /teams/{team_id}/seats

**Purpose**: Fetch full accountability chart tree for a team.

**Request**:
```
GET /teams/{team_id}/seats
Authorization: Bearer {token}
```

**Response 200**:
```json
{
  "data": [
    {
      "id": 11,
      "name": "Visionary",
      "accountabilities": "<ul><li>Strategic direction</li></ul>",
      "notes": null,
      "parent": null,
      "creator": { "id": 1, "login": "scottilevy", "first_name": "Scott", "last_name": "Levy" },
      "seat_owner": { "id": 1, "login": "scottilevy", "first_name": "Scott", "last_name": "Levy" },
      "team": { "id": 345, "name": "ResultMaps Incorporated", "framework": "eos" },
      "associated_team": { "id": 1, "name": "W3mG", "framework": "eos" },
      "measures": [{ "id": 793, "name": "KPI Name", "description": "" }],
      "goals": [{ "id": 7315, "name": "Goal Name", "description": null }],
      "links": [],
      "children": [
        {
          "id": 12,
          "name": "Integrator",
          "children": ["...recursive..."]
        }
      ],
      "created_at": "2018-01-23T18:59:28.000Z",
      "updated_at": "2026-03-04T05:53:47.000Z"
    }
  ]
}
```

**Notes**: The `data` array contains root-level seats. Each seat's `children` array contains fully nested child seats (recursive). No pagination — full tree in one call.

---

### GET /seats/{id}

**Purpose**: Fetch single seat detail.

**Request**:
```
GET /seats/{id}
Authorization: Bearer {token}
```

**Response 200**:
```json
{
  "data": {
    "id": 11,
    "name": "Visionary",
    "accountabilities": "<ul><li>Strategic direction</li></ul>",
    "notes": null,
    "parent": null,
    "creator": { "id": 1, "login": "scottilevy", "first_name": "Scott", "last_name": "Levy" },
    "seat_owner": { "id": 1, "login": "scottilevy", "first_name": "Scott", "last_name": "Levy" },
    "team": { "id": 345, "name": "ResultMaps Incorporated", "framework": "eos" },
    "associated_team": { "id": 1, "name": "W3mG", "framework": "eos" },
    "measures": [{ "id": 793, "name": "KPI Name", "description": "" }],
    "goals": [{ "id": 7315, "name": "Goal Name", "description": null }],
    "links": [{ "id": 2078, "title": "Example", "url": "https://example.com" }],
    "children": [{ "id": 1138, "name": "Executive Assistant" }],
    "created_at": "2018-01-23T18:59:28.000Z",
    "updated_at": "2026-03-04T05:53:47.000Z"
  }
}
```

**Notes**: Unlike the tree endpoint, `children` here are simplified `{id, name}` objects only.

**Response 404**: Seat not found.

---

### POST /seats

**Purpose**: Create a new seat.

**Request**:
```
POST /seats
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "VP Engineering",
  "team_id": 345,
  "parent_id": 11
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | yes | Seat name |
| team_id | integer | yes | Team ID |
| parent_id | integer | no | Parent seat ID (omit for root) |

**Response 201**: Created seat object (same shape as GET /seats/{id}).

**Response 422**: Validation error (e.g., "Team already has a root seat" when no parent_id and root exists).

---

### PATCH /seats/{id}

**Purpose**: Update seat fields.

**Request**:
```
PATCH /seats/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Updated Name",
  "seat_owner_id": 5
}
```

| Field | Type | Description |
|-------|------|-------------|
| name | string | Seat name |
| accountabilities | string | HTML-formatted responsibilities |
| notes | string | Free-text notes |
| seat_owner_id | integer | User ID to assign |
| associated_team_id | integer | Team ID to link |

**Response 200**: Updated seat object.

---

### DELETE /seats/{id}

**Purpose**: Archive (soft-delete) a seat.

**Request**:
```
DELETE /seats/{id}
Authorization: Bearer {token}
```

**Response 204**: No content — seat archived.

---

### PUT /seats/{id}/move

**Purpose**: Move a seat to a new parent.

**Request**:
```
PUT /seats/{id}/move
Authorization: Bearer {token}
Content-Type: application/json

{
  "parent_id": 15
}
```

**Response 200**: Updated seat object.

**Response 422**: "Cannot move root seat" or "parent_id is required".

---

### PUT /seats/{id}/restore

**Purpose**: Restore an archived seat.

**Request**:
```
PUT /seats/{id}/restore
Authorization: Bearer {token}
```

**Response 200**: Restored seat object.

**Response 422**: "Seat is not archived".

---

### GET /seats/{id}/measures

**Purpose**: List measures aligned to a seat.

**Response 200**:
```json
{ "data": [{ "id": 793, "name": "KPI Name", "description": "" }] }
```

---

### PUT /seats/{id}/measures

**Purpose**: Align a measure to a seat.

**Request**:
```json
{ "measure_id": 793 }
```

**Response 200**: Updated measures list.

---

### DELETE /seats/{id}/measures/{measure_id}

**Purpose**: Remove a measure alignment.

**Response 204**: No content.

---

### GET /seats/{id}/goals

**Purpose**: List goals aligned to a seat.

**Response 200**:
```json
{ "data": [{ "id": 7315, "name": "Goal Name", "description": null }] }
```

---

### PUT /seats/{id}/goals

**Purpose**: Align a goal to a seat.

**Request**:
```json
{ "goal_id": 7315 }
```

**Response 200**: Updated goals list.

---

### DELETE /seats/{id}/goals/{goal_id}

**Purpose**: Remove a goal alignment.

**Response 204**: No content.

---

### GET /seats/{id}/links

**Purpose**: List links on a seat.

**Response 200**:
```json
{ "data": [{ "id": 2078, "title": "Wiki", "url": "https://example.com" }] }
```

---

### POST /seats/{id}/links

**Purpose**: Create a link on a seat.

**Request**:
```json
{ "url": "https://example.com", "title": "Wiki" }
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| url | string | yes | URL |
| title | string | no | Display title (defaults to URL) |

**Response 201**: Created link object.

---

### DELETE /seats/{id}/links/{link_id}

**Purpose**: Delete a link from a seat.

**Response 204**: No content.

---

## Error Responses

All endpoints share these error patterns:

| Status | Meaning | Action |
|--------|---------|--------|
| 401 | Invalid/expired token | Run `/rkit:setup` to update token |
| 403 | Not authorized for this team/seat | Check team membership |
| 404 | Seat/team not found | Verify ID |
| 422 | Validation error | Check error message for specifics |
