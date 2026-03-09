# Contract: Get Team Strategy

## Endpoint

`GET /teams/{id}/strategy`

## Parameters

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `year` | integer \| "All" | No | Current year | Filter by year. "All" or 0 for all years. |
| `quarter` | integer (1-4) \| "All" | No | Current quarter | Filter by quarter. "All" or 0 for all quarters. |

## Response (200)

```json
{
  "data": {
    "framework": "eos",
    "strategy": [
      {
        "id": 6520,
        "name": "Annual Goal",
        "description": null,
        "status": "active",
        "object_type": "yearly_goal",
        "type": 2,
        "color": null,
        "assignees": [],
        "creator": { "id": 591, "first_name": "Patrick", "last_name": "Angodung" },
        "due": "2026-12-31",
        "children": [
          {
            "id": 6528,
            "name": "Improve onboarding",
            "object_type": "rock",
            "status": "active",
            "children": []
          }
        ]
      }
    ],
    "unaligned": [
      {
        "id": 7281,
        "name": "Internal tooling cleanup",
        "object_type": "rock",
        "status": "active",
        "children": []
      }
    ]
  }
}
```

## Skill Usage

- Default invocation: `GET /teams/{default_team_id}/strategy` (current year/quarter)
- With filters: `GET /teams/{default_team_id}/strategy?year=2025&quarter=2`
- All history: `GET /teams/{default_team_id}/strategy?year=All`
