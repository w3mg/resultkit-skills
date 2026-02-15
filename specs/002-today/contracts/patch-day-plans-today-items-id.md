# Contract: PATCH /day-plans/today/items/{item_id}

**Used by**: US2 (Mark Item Complete/Incomplete)

## Request

```
PATCH /day-plans/today/items/{item_id}
Authorization: Bearer {api_token}
Content-Type: application/json
Accept: application/json

{ "completed": true }
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| completed | boolean | yes | true or false |

For date-specific: `PATCH /day-plans/{YYYY-MM-DD}/items/{item_id}`

## Response — 200 OK

```json
{
  "id": 42,
  "name": "Fix login bug",
  "completed": true,
  "position": 1
}
```

## Response — 404 Not Found

Item not on today's plan.

## Response — 401 Unauthorized

```json
{ "error": "Unauthorized" }
```

## Notes

- Only toggles plan-specific `completed` flag
- Does NOT change the item's `status` field
- Constitution IV: Confirm before executing (PATCH is a write)
