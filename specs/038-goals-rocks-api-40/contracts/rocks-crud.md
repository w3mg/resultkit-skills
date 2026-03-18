# Contract: Rocks CRUD

**EOS teams only** — returns 422 for non-EOS teams.

## List Rocks

```
GET /api/v2/teams/{id}/rocks?year={year}&quarter={quarter}&parent_id={parent_id}
Authorization: Bearer {token}
```

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| id | integer | yes | Team ID (path) |
| year | integer | no | Filter by year |
| quarter | integer | no | Filter by quarter |
| parent_id | integer | no | Filter by parent goal ID |

**Response (200)**: `{ "data": [Rock], "meta": { page, per_page, total, total_pages } }`

## Create Rock

```
POST /api/v2/teams/{id}/rocks
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Launch enterprise tier",
  "parent_id": 3645,
  "assignee_ids": [5]
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | yes | Rock name |
| parent_id | integer | no | Goal ID to align under |
| assignee_ids | integer[] | no | User IDs to assign |

**Response (201)**: `{ "data": Rock }`

## Align Rock

```
PUT /api/v2/rocks/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "parent_id": 3645
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| parent_id | integer | yes | Goal ID to align to |

**Response (200)**: `{ "data": Rock }`

## Update Rock

```
PATCH /api/v2/rocks/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Updated name",
  "status": "complete"
}
```

All fields optional. Only include fields being updated.

**Response (200)**: `{ "data": Rock }`

## Archive Rock

```
DELETE /api/v2/rocks/{id}
Authorization: Bearer {token}
```

**Response (200)**: `{ "data": Rock }` (with status: "archived")

## Errors (all endpoints)

| Status | Condition |
|--------|-----------|
| 401 | Invalid/missing token |
| 403 | Not authorized |
| 404 | Rock/team not found |
| 422 | Validation error or non-EOS team |
