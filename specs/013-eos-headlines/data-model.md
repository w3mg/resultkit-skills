# Data Model: rkit:headlines

**Date**: 2026-02-24

## Entities

Headlines are a dedicated API resource scoped to EOS teams. No new config fields are needed — the skill reuses `default_team_id`.

### Headline

A short status update belonging to an EOS team, retrieved and managed via `/teams/{id}/headlines`.

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| id | integer | `id` | Unique headline ID |
| text | string | `text` | The headline content |
| creator | object | `creator` | `{ id, login, first_name, last_name }` |
| expires_at | string \| null | `expires_at` | YYYY-MM-DD format, or null if no expiration |
| created_at | string | `created_at` | ISO 8601 timestamp |
| updated_at | string | `updated_at` | ISO 8601 timestamp |

### Team (existing)

The team context for headlines. Must have `framework = 'eos'`.

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| id | integer | `id` | Team ID from config or `--team` flag |
| name | string | `name` | Used in display messages |
| framework | string | `framework` | Must be `'eos'` for headlines |

### Config (existing, no changes)

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| api_token | string | — | Required for auth |
| default_team_id | integer | — | Used for team resolution |
| api_base | string | `https://api.resultmaps.com/api/v2` | API base URL |

No config schema extension needed. Headlines use `default_team_id`, same as `rkit:weekly`.

## Visibility Rules

A headline is "active" (appears in GET list) if **either**:

1. `created_at` is within the last 7 days, **OR**
2. `expires_at` is strictly in the future (`expires_at > user's local today`)

This is an OR condition. Key implications for the skill:
- Archiving (DELETE) sets `expires_at = today` → fails condition 2, but may still pass condition 1
- A headline with no expiration (`null`) is only visible for 7 days from creation

## State Transitions

```
Headline lifecycle:
  Created → Active (visible in list)
    ├── Update text → Active (same visibility)
    ├── Update expires_at → Active (if new date is future) or Hidden (if new date is past/today)
    └── Archive (DELETE) → expires_at set to today
          └── Still visible if created within 7 days
          └── Hidden once created_at > 7 days ago
```

## Relationships

```
Team (EOS framework)
  └── Headlines (0..many)
        └── Creator (User)
```
