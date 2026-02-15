# Contract: DELETE /day-plans/today/items/{item_id}

**Used by**: US4 (Remove Item from Today)

## Request

```
DELETE /day-plans/today/items/{item_id}
Authorization: Bearer {api_token}
Accept: application/json
```

For date-specific: `DELETE /day-plans/{YYYY-MM-DD}/items/{item_id}`

## Response — 200 OK

```json
{ "message": "Item removed from plan" }
```

## Response — 404 Not Found

Item not on today's plan.

## Response — 401 Unauthorized

```json
{ "error": "Unauthorized" }
```

## Notes

- Removes item from the day plan only
- Item continues to exist in the system (not archived, not deleted)
- Constitution IV: Confirm before executing (DELETE is a write)
