# Contract: GET /day-plans/today/items

**Used by**: US1 (View Today's Plan), stretch date view

## Request

```
GET /day-plans/today/items
Authorization: Bearer {api_token}
Accept: application/json
```

No query parameters required. Pagination params (`page`, `per_page`)
optional.

For date-specific: `GET /day-plans/{YYYY-MM-DD}/items`

## Response — 200 OK

```json
{
  "data": [
    {
      "id": 42,
      "name": "Fix login bug",
      "description": null,
      "due": "2026-02-15",
      "status": "next",
      "on_weekly": true,
      "team_id": 1,
      "parent_id": null,
      "context": null,
      "completed": false,
      "position": 1
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 1,
    "total_pages": 1
  }
}
```

## Response — 401 Unauthorized

```json
{ "error": "Unauthorized" }
```

## Notes

- Auto-creates today's plan if it doesn't exist
- Date-specific endpoint returns 404 if no plan exists for that date
- Items ordered by `position`
