# Contract: Milestones CRUD

**EOS teams only** — returns 422 for non-EOS teams.

## List Milestones

```
GET /api/v2/teams/{id}/milestones?parent_id={parent_id}
Authorization: Bearer {token}
```

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| id | integer | yes | Team ID (path) |
| parent_id | integer | no | Filter by parent rock ID (**recommended** — year/quarter filters have a known bug) |
| year | integer | no | **AVOID** — returns incorrect results (known bug) |
| quarter | integer | no | **AVOID** — returns incorrect results (known bug) |

**Response (200)**: `{ "data": [Milestone], "meta": { page, per_page, total, total_pages } }`

## Create Milestone

```
POST /api/v2/teams/{id}/milestones
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Sign 3 enterprise customers",
  "parent_id": 3646,
  "due": "2026-03-31"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | yes | Milestone name |
| parent_id | integer | no | Rock ID to align under |
| due | date | no | Due date (YYYY-MM-DD) |

**Response (201)**: `{ "data": Milestone }`

## Align Milestone

```
PUT /api/v2/milestones/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "parent_id": 3646
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| parent_id | integer | yes | Rock ID to align to |

**Response (200)**: `{ "data": Milestone }`

## Update Milestone

```
PATCH /api/v2/milestones/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Updated name",
  "status": "complete",
  "due": "2026-04-30"
}
```

All fields optional. Only include fields being updated.

**Response (200)**: `{ "data": Milestone }`

## Archive Milestone

```
DELETE /api/v2/milestones/{id}
Authorization: Bearer {token}
```

**Response (200)**: `{ "data": Milestone }` (with status: "archived")

## Errors (all endpoints)

| Status | Condition |
|--------|-----------|
| 401 | Invalid/missing token |
| 403 | Not authorized |
| 404 | Milestone/team not found |
| 422 | Validation error or non-EOS team |
