# API Contracts: New Team Endpoints

**Branch**: `024-teams-tabs-endpoints` | **Date**: 2026-03-03

## Activity Logs

### GET /teams/{id}/activity-logs

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/teams/{id}/activity-logs` | Bearer token (team member) | Paginated list of membership changes |

**Query params**: `page`, `per_page`

**Response (200)**:
```json
{
  "data": [
    {
      "id": 1001,
      "action": "member_added",
      "target_user": { "id": 42, "login": "jdoe", "first_name": "Jane", "last_name": "Doe" },
      "actor": { "id": 1, "login": "admin", "first_name": "Admin", "last_name": "User" },
      "details": "",
      "created_at": "2026-02-15T14:30:00.000Z"
    }
  ],
  "meta": { "page": 1, "per_page": 25, "total": 10, "total_pages": 1 }
}
```

**Action values**: `member_added`, `member_removed`, `role_changed`

**Error Responses**:

| Status | Code | Cause | Skill Message |
|--------|------|-------|---------------|
| 401 | `unauthorized` | Invalid/expired token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | `forbidden` | Not a team member | "Access denied (403). You must be a team member to view activity logs." |
| 404 | `not_found` | Team not found | "Team {id} not found (404)." |

---

## Labels

### GET /teams/{id}/labels

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/teams/{id}/labels` | Bearer token (team member) | List team labels |

**Response (200)**:
```json
{
  "data": [
    { "id": 501, "name": "Engineering", "color": "#3b82f6", "created_at": "2026-01-15T10:00:00.000Z" }
  ],
  "meta": { "page": 1, "per_page": 100, "total": 5, "total_pages": 1 }
}
```

### POST /teams/{id}/labels

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/teams/{id}/labels` | Bearer token (team admin) | Create label |

**Request Body**: `{ "name": string*, "color": string* }` (color is hex code)

### PATCH /teams/{id}/labels/{label_id}

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| PATCH | `/teams/{id}/labels/{label_id}` | Bearer token (team admin) | Update label |

**Request Body**: `{ "name"?: string, "color"?: string }`

### DELETE /teams/{id}/labels/{label_id}

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| DELETE | `/teams/{id}/labels/{label_id}` | Bearer token (team admin) | Delete label |

**Label error responses**: 401, 403 (non-member for GET; non-admin for writes), 404

---

## Integrations

### GET /teams/{id}/integrations

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/teams/{id}/integrations` | Bearer token (team admin) | List integrations |

**Response (200)**:
```json
{
  "data": [
    {
      "id": 12345,
      "type": "slack",
      "name": "#updates",
      "webhook_url": "https://hooks.slack.com/services/T00/B00/xxxx",
      "enabled": true,
      "created_at": "2026-01-10T08:00:00.000Z",
      "updated_at": "2026-02-01T12:00:00.000Z"
    }
  ],
  "meta": { "page": 1, "per_page": 100, "total": 2, "total_pages": 1 }
}
```

**Integration type values**: `slack` (others TBD)

### POST /teams/{id}/integrations

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/teams/{id}/integrations` | Bearer token (team admin) | Create/update integration (upsert by type) |

**Request Body**: `{ "type": string*, "name": string*, "webhook_url": string* }`

### PATCH /teams/{id}/integrations/{integration_id}

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| PATCH | `/teams/{id}/integrations/{integration_id}` | Bearer token (team admin) | Update integration |

**Request Body**: `{ "name"?: string, "webhook_url"?: string }`

### DELETE /teams/{id}/integrations/{integration_id}

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| DELETE | `/teams/{id}/integrations/{integration_id}` | Bearer token (team admin) | Delete integration (disables it) |

**Integration error responses**: 401, 403 (non-admin), 404

---

## Member Role Change

### PATCH /teams/{id}/members/{user_id}

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| PATCH | `/teams/{id}/members/{user_id}` | Bearer token (team admin) | Change member role |

**Request Body**:
```json
{ "role": "admin" }
```

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `role` | string | Yes | `"admin"` or `"member"` |

**Response (200)**:
```json
{
  "data": {
    "id": 42,
    "login": "jdoe",
    "first_name": "Jane",
    "last_name": "Doe",
    "email": "jdoe@example.com",
    "role": "admin"
  }
}
```

**Error Responses**:

| Status | Code | Cause | Skill Message |
|--------|------|-------|---------------|
| 401 | `unauthorized` | Invalid/expired token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | `forbidden` | Not a team admin | "Access denied (403). Only team admins can change roles." |
| 404 | `not_found` | Team or user not found | "Team or member not found (404)." |
| 422 | `validation_error` | Invalid role value | Show validation error from response body. |

---

## Logo Upload

### POST /teams/{id}/logo

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/teams/{id}/logo` | Bearer token (team admin) | Upload team logo (multipart/form-data) |

**Request**: `multipart/form-data` with `file` field (image)

**Error Responses**: 401, 403 (non-admin), 422 (invalid file)

**Note**: No skill flow — web UI only.
