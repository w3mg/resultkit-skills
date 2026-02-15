# Contract: POST /day-plans/today/items

**Used by**: US3 (Add Item to Today — new item)

## Request

```
POST /day-plans/today/items
Authorization: Bearer {api_token}
Content-Type: application/json
Accept: application/json

{ "name": "Write tests for auth module" }
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | yes | Item name |

For date-specific: `POST /day-plans/{YYYY-MM-DD}/items` (plan must
already exist)

## Response — 201 Created

```json
{
  "id": 99,
  "name": "Write tests for auth module",
  "completed": false,
  "position": 6
}
```

## Response — 422 Unprocessable Entity

```json
{ "errors": { "name": ["can't be blank"] } }
```

## Response — 401 Unauthorized

```json
{ "error": "Unauthorized" }
```

## Notes

- Creates a new item AND adds it to today's plan in one call
- Auto-creates today's plan if it doesn't exist
- Position is auto-assigned (appended to end)
- Constitution IV: Confirm before executing (POST is a write)
