# API Contract: Result Feeds

**Source**: `~/projects/resultmaps-api2/openapi/openapi-v2.yaml`

## Endpoints

### Personal Result Feed

| Method | Path | Description | Request Body | Response |
|--------|------|-------------|-------------|----------|
| GET | `/result-feeds/{date}` | Get check-in for date (auto-creates) | — | `{ data: ResultFeed }` (200) |
| POST | `/result-feeds/{date}/{section}` | Create new item in section | `{ "name": "..." }` | `{ data: Item }` (201) |
| PUT | `/result-feeds/{date}/{section}/{item_id}` | Add existing item to section | — | `{ data: Item }` (200) |
| DELETE | `/result-feeds/{date}/{section}/{item_id}` | Remove item from section | — | 204 No Content |
| POST | `/result-feeds/{date}/submit` | Submit + share check-in | `{ "team_id": N, "item_ids": [...] }` (optional) | `{ data: ResultFeed }` (200) |

### Team Result Feeds

| Method | Path | Description | Query Params | Response |
|--------|------|-------------|-------------|----------|
| GET | `/teams/{id}/result-feeds` | List team's shared check-ins | `page`, `per_page` | `{ data: TeamResultFeed[], meta: Pagination }` (200) |

## Path Parameters

| Param | Type | Description | Example |
|-------|------|-------------|---------|
| `{date}` | string | `YYYY-MM-DD` or literal `today` | `today`, `2026-02-26` |
| `{section}` | string enum | `done`, `next`, `issues` | `done` |
| `{item_id}` | integer | Item ID | `415` |
| `{id}` | integer | Team ID | `42` |

## Request Bodies

### Create Item (POST /result-feeds/{date}/{section})

```json
{
  "name": "Finished quarterly report"
}
```

- `name` (string, required, min 1 char)

### Submit (POST /result-feeds/{date}/submit)

```json
{
  "team_id": 42,
  "item_ids": [101, 205]
}
```

- `team_id` (integer, optional) — team to share with; user must be a member
- `item_ids` (integer[], optional) — item IDs to highlight for the team

Body is entirely optional. If omitted, submits without sharing.

## Response Schemas

### ResultFeed

```json
{
  "id": 42,
  "date": "2026-02-26",
  "is_completed": false,
  "done": [Item, ...],
  "next": [Item, ...],
  "issues": [Item, ...]
}
```

### TeamResultFeed

```json
{
  "id": 42,
  "date": "2026-02-26",
  "is_completed": true,
  "user": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
  "done": [Item, ...],
  "next": [Item, ...],
  "issues": [Item, ...]
}
```

### Item (within sections)

```json
{
  "id": 415,
  "name": "Write proposal",
  "description": null,
  "due": "2026-02-25",
  "status": "next",
  "on_weekly": true,
  "team": { "id": 1, "name": "Acme Team" },
  "creator": { "id": 1, "login": "patrick", "first_name": "Patrick", "last_name": "Smith" },
  "assignees": [],
  "parent_id": null,
  "created_at": "2026-02-19T08:00:00Z",
  "updated_at": "2026-02-19T08:00:00Z"
}
```

### Pagination Meta

```json
{
  "page": 1,
  "per_page": 100,
  "total": 5,
  "total_pages": 1
}
```

## Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 400 | Invalid date format or section | `{ "error": { "code": "bad_request", "message": "..." } }` |
| 401 | Invalid/missing token | `{ "error": { "code": "unauthorized", "message": "..." } }` |
| 404 | Item/team not found, not a member | `{ "error": { "code": "not_found", "message": "..." } }` |
| 422 | Submit with empty done/next sections | `{ "error": { "code": "validation_error", "message": "..." } }` |

## Behavioral Notes

- GET auto-creates an empty report if none exists for the date
- PUT (add item) is idempotent — adding an already-present item returns 200
- DELETE (remove item) returns 404 if item is not in that section
- Submit is idempotent — re-submitting a completed report returns 200
- Submit validation: requires ≥1 item in both `done` and `next`
- Adding items triggers status side-effects: done→realized, next→active+#next, issues→blocked
- Removing items does NOT revert status side-effects
