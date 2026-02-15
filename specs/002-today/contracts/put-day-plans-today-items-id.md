# Contract: PUT /day-plans/today/items/{item_id}

**Used by**: US3 (Add Item to Today — existing item)

## Request

```
PUT /day-plans/today/items/{item_id}
Authorization: Bearer {api_token}
Content-Type: application/json
Accept: application/json
```

Optional body:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| position | integer | no | Desired position on plan |

For date-specific: `PUT /day-plans/{YYYY-MM-DD}/items/{item_id}` (plan
must already exist)

## Response — 200 OK

```json
{
  "id": 42,
  "name": "Fix login bug",
  "completed": false,
  "position": 6
}
```

## Response — 404 Not Found

Item with given ID does not exist.

## Response — 401 Unauthorized

```json
{ "error": "Unauthorized" }
```

## Notes

- Attaches an existing item to today's plan
- Auto-creates today's plan if it doesn't exist
- Idempotent — if item is already on plan, confirms it's there
- Constitution IV: Confirm before executing (PUT is a write)
