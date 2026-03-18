# Contract: GET /teams/{id}/targets

**Replaces**: `GET /teams/{id}/strategy`

## Request

```
GET /api/v2/teams/{id}/targets?year={year}&quarter={quarter}
Authorization: Bearer {token}
```

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| id | integer | yes | Team ID (path) |
| year | integer \| "All" | no | Filter year (default: current year) |
| quarter | integer \| "All" | no | Filter quarter (default: current quarter) |

## Response (200)

```json
{
  "data": {
    "framework": "eos",
    "strategy": [StrategyNode],
    "unaligned": [StrategyNode]
  }
}
```

Same schema as old `GET /teams/{id}/strategy`. Only the path changed.

## Errors

| Status | Condition |
|--------|-----------|
| 401 | Invalid/missing token |
| 403 | Not authorized for this team |
| 404 | Team not found |
