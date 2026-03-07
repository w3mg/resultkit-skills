# API Contracts: Scorecard History Endpoints

**Branch**: `001-fix-measure-history` | **Date**: 2026-03-07

> No new endpoints. Both endpoints are unchanged in shape. This document captures the contracts as used by the skill.

## GET /api/v2/teams/:id/measures

Lists all measures for a team with weekly history values.

**Query params**: `year` (integer, default current), `include_archived` (boolean string)

**Response** (200):
```json
{
  "data": [
    {
      "id": 736,
      "name": "# Proposals",
      "unit": "#",
      "direction": "higher",
      "target_value": "5",
      "owner": { "id": 1, "first_name": "Jane", "last_name": "Smith" },
      "is_archived": false,
      "histories": [
        { "id": 12345, "date": "2026-01-05", "value": "3", "target_value": null },
        { "id": null,  "date": "2026-01-12", "value": null, "target_value": null }
      ]
    }
  ],
  "meta": { "year": 2026, "date_range": { "start": "2026-01-05", "end": "2026-12-28" } }
}
```

**Skill behavior**:
- Displays the 4 most recent calendar weeks as columns
- Recorded weeks (`id` and `value` non-null) → show value
- Unrecorded weeks (`id` or `value` null) → show "—"

---

## POST /api/v2/measures/:id/history

Records (upserts) a weekly value for a measure.

**Request body**:
```json
{ "date": "2026-01-05", "value": "3" }
```
`date` must be a Monday. `value` is a numeric string.

**Response** (200 — upsert):
```json
{
  "data": {
    "id": 12345,
    "measure_id": 736,
    "date": "2026-01-05",
    "value": "3",
    "target_value": null
  }
}
```

**Skill behavior**:
- On success: `"Recorded: {MEASURE_NAME} — {VALUE} for week of {RECORD_DATE} (history ID: {ID})."`
- `id` extracted with: `jq -r '.body.data.id // "?"'`
