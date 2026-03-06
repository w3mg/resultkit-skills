# Contract: List Team Measures

**Endpoint**: `GET /api/v2/teams/:id/measures`
**User Story**: US1 — View Team Scorecard
**Auth**: canViewGroup

## Request

```bash
bash scripts/api.sh GET "/teams/$TEAM_ID/measures?year=$YEAR&include_archived=$INCLUDE_ARCHIVED"
```

**Query Parameters**:
| Param | Required | Default | Notes |
|-------|----------|---------|-------|
| `year` | No | current year | 4-digit integer |
| `include_archived` | No | false | boolean |
| `owner_id` | No | — | filter by owner user ID |

## Response (200)

```json
{
  "data": [
    {
      "id": 1,
      "name": "Weekly Signups",
      "description": null,
      "target_value": "100",
      "unit": "#",
      "direction": "higher",
      "owner": { "id": 5, "first_name": "Alice", "last_name": "Smith", "login": "alice" },
      "is_archived": false,
      "histories": [
        { "id": 10, "date": "2026-01-05", "value": "42", "target_value": null },
        { "id": null, "date": "2026-01-12", "value": null, "target_value": null }
      ]
    }
  ],
  "meta": {
    "year": 2026,
    "date_range": { "start": "2026-01-05", "end": "2026-12-28" }
  }
}
```

## Skill Display

Show last 4 weeks of history per measure in a table:

```
Team Scorecard — Acme (EOS) — 2026
Showing last 4 weeks

ID  Name            Unit  Dir     Target  Owner       Jan 5   Jan 12  Jan 19  Jan 26
──  ──────────────  ────  ──────  ──────  ──────────  ──────  ──────  ──────  ──────
1   Weekly Signups  #     higher  100     Alice S.    42      —       —       —
2   Revenue         $     higher  50000   (none)      —       —       —       —
```

## Error Handling

| Code | Meaning | Skill Response |
|------|---------|----------------|
| 401 | Bad token | "Auth failed. Run /rkit:setup to update your token." |
| 403 | No view access | "You don't have permission to view this team's scorecard." |
| 404 | Team not found | "Team ID {id} not found." |
