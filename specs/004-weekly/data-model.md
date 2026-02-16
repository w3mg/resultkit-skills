# Data Model: rkit:weekly

## Entities

### Team

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Team ID |
| name | string | Team name |
| framework | string | nullable; one of: EOS, OKR, 4DX, V2MOM, SRT, or null |

### WeeklyItem

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Item ID |
| name | string | Item name |
| description | string | nullable |
| due | string (YYYY-MM-DD) | nullable |
| status | string | next, done, blocked, parked |
| on_weekly | boolean | true for all weekly items |
| team_id | integer | |
| owner | object | Assignee/owner info returned inline |

### Column Mapping

| Column | API Path | Status Value |
|--------|----------|-------------|
| Next | next | next |
| Done | done | done |
| Issues | issues | blocked |
| Parked | parked | parked |

## Pagination

`per_page=50`. If `total > 50`, show "(N more...)".
