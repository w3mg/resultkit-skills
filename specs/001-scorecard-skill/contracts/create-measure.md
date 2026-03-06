# Contract: Create Measure

**Endpoint**: `POST /api/v2/teams/:id/measures`
**User Story**: US3 — Create a Measure
**Auth**: canEditGroup

## Request

```bash
bash scripts/api.sh POST "/teams/$TEAM_ID/measures" \
  "{\"measure\": {\"name\": \"$NAME\", \"unit\": \"$UNIT\", \"direction\": \"$DIRECTION\", \"target_value\": \"$TARGET\"}}"
```

**Body** (`measure` wrapper required):
| Field | Required | Default | Notes |
|-------|----------|---------|-------|
| `name` | Yes | — | Must not be blank |
| `unit` | No | `""` | Display string (e.g., `"#"`, `"$"`, `"%"`) |
| `direction` | No | `"higher"` | `"higher"` or `"lower"` |
| `target_value` | No | `null` | Numeric string |
| `owner_id` | No | `null` | Out of scope for v1 |

## Response (201)

```json
{
  "data": {
    "id": 3,
    "name": "Revenue",
    "description": null,
    "target_value": "50000",
    "unit": "$",
    "direction": "higher",
    "owner": null,
    "is_archived": false,
    "histories": []
  }
}
```

## Skill Flow

1. Parse name and optional fields from user input.
2. Show confirmation: `Create measure "Revenue" (unit: $, direction: higher, target: 50000)? [y/N]`
3. On confirm: POST, show created measure with ID.

## Error Handling

| Code | Meaning | Skill Response |
|------|---------|----------------|
| 422 | Name missing or blank | "Measure name is required." |
| 403 | No edit access | "You don't have permission to add measures to this team." |
