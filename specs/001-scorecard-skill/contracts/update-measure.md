# Contract: Update Measure

**Endpoint**: `PATCH /api/v2/measures/:id`
**User Story**: US4 — Update or Archive a Measure
**Auth**: canEditGroup

## Request

```bash
bash scripts/api.sh PATCH "/measures/$MEASURE_ID" \
  "{\"measure\": {\"name\": \"$NAME\", \"unit\": \"$UNIT\", \"direction\": \"$DIRECTION\", \"target_value\": \"$TARGET\"}}"
```

**Body** (`measure` wrapper required; all fields optional — partial update):
| Field | Notes |
|-------|-------|
| `name` | New display name |
| `unit` | New unit string |
| `direction` | `"higher"` or `"lower"` |
| `target_value` | Numeric string or `null` to clear |
| `archived` | `true` to soft-delete, `false` to restore |

## Response (200)

```json
{
  "data": {
    "id": 1,
    "name": "New Name",
    "unit": "%",
    "direction": "lower",
    "target_value": null,
    "owner": null,
    "is_archived": false
  }
}
```

Note: Response does NOT include `histories`.

## Skill Flow

1. Resolve measure name → measure ID.
2. Show confirmation: `Update "Weekly Signups" — set target=100? [y/N]`
3. On confirm: PATCH with only the fields the user specified.
4. Show updated measure fields.

## Error Handling

| Code | Meaning | Skill Response |
|------|---------|----------------|
| 404 | Measure not found | "Measure ID {id} not found." |
| 403 | No edit access | "You don't have permission to edit this measure." |
| 422 | Validation error | Show API error message |
