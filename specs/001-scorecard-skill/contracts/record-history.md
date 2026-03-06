# Contract: Record Weekly Measure Value

**Endpoint**: `POST /api/v2/measures/:id/history`
**User Story**: US2 — Record a Weekly Value
**Auth**: canEditGroup

## Request

```bash
bash scripts/api.sh POST "/measures/$MEASURE_ID/history" \
  "{\"date\": \"$DATE\", \"value\": \"$VALUE\"}"
```

**Body**:
| Field | Required | Notes |
|-------|----------|-------|
| `date` | Yes | ISO date string (YYYY-MM-DD), must be a Monday |
| `value` | Yes | Numeric string (e.g., `"42"`, `"3.5"`) |

**Behavior**: Upsert — if an entry exists for (measure_id, date), it is updated. If not, it is created.

## Response (200)

```json
{
  "data": {
    "id": 10,
    "measure_id": 1,
    "date": "2026-01-05",
    "value": "42",
    "target_value": null
  }
}
```

## Skill Flow

1. Resolve measure name → measure ID (case-insensitive, from list call or cache).
2. Compute current Monday if no date provided.
3. Validate value is numeric (client-side, before API call).
4. Show confirmation: `Record value "42" for "Weekly Signups" (week of Jan 5, 2026)? [y/N]`
5. On confirm: POST, show result.

## Error Handling

| Code | Meaning | Skill Response |
|------|---------|----------------|
| 422 | Non-numeric value or invalid date | Show API error message |
| 403 | No edit access | "You don't have permission to edit this team's scorecard." |
| 404 | Measure not found | "Measure ID {id} not found." |
