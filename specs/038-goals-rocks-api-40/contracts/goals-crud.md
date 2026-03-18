# Contract: Goals CRUD

**EOS teams only** — returns 422 for non-EOS teams.

## List Goals

```
GET /api/v2/teams/{id}/goals?year={year}
Authorization: Bearer {token}
```

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| id | integer | yes | Team ID (path) |
| year | integer | no | Filter by year |

**Response (200)**: `{ "data": [Goal], "meta": { page, per_page, total, total_pages } }`

## Create Goal

```
POST /api/v2/teams/{id}/goals
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Hit $10M ARR",
  "achieve_by": "2026-12-31",
  "assignee_ids": [5]
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | yes | Goal name |
| achieve_by | date | no | Target date (YYYY-MM-DD) |
| assignee_ids | integer[] | no | User IDs to assign |

**Response (201)**: `{ "data": Goal }`

## Update Goal

```
PATCH /api/v2/goals/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "name": "Updated name",
  "status": "complete",
  "achieve_by": "2027-12-31",
  "assignee_ids": [5, 10]
}
```

All fields optional. Only include fields being updated.

**Response (200)**: `{ "data": Goal }`

## Archive Goal

```
DELETE /api/v2/goals/{id}
Authorization: Bearer {token}
```

**Response (200)**: `{ "data": Goal }` (with status: "archived")

## Errors (all endpoints)

| Status | Condition |
|--------|-----------|
| 401 | Invalid/missing token |
| 403 | Not authorized |
| 404 | Goal/team not found |
| 422 | Validation error or non-EOS team |
