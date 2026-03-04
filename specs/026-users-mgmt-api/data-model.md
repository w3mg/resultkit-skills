# Data Model: Extend rkit:profile

**Feature**: 026-users-mgmt-api
**Date**: 2026-03-04

## Entities (API Response Shapes)

### UserMeasurable
Returned by `GET /users/{id}/measurables` — array in `body.data`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Measurable ID |
| `name` | string | Metric name |
| `target_value` | number or null | Goal value |
| `target_unit` | string or null | Unit label |
| `is_archived` | boolean | Filter out if active_only=true (default) |
| `values` | array | Periodic entries: `[{date, value, on_track, percent_change}]` |

**Display rule**: Show most recent value entry. `on_track` → ✓ / ✗.

---

### UserRock
Returned by `GET /users/{id}/rocks` — paginated, array in `body.data`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Rock ID |
| `name` | string | Rock title |
| `status` | string | `on_track` \| `off_track` \| `completed` \| `dropped` |
| `due_date` | date string or null | Quarter end date |
| `team.name` | string | Team the rock belongs to |
| `milestones_total` | integer | Total milestones |
| `milestones_completed` | integer | Completed milestones |

**Display rule**: Status labels → On Track / Off Track / Done / Dropped. Milestone progress as `{completed}/{total}`.

---

### FeedbackEntry
Returned by `GET /users/{id}/feedback?direction=given|received` — paginated, array in `body.data`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Feedback ID |
| `message` | string | High5 message text |
| `from_user` | object | `{id, first_name, last_name}` |
| `to_user` | object | `{id, first_name, last_name}` |
| `created_at` | datetime | ISO 8601 |

**Display rule**: For `received` — show from_user name; for `given` — show to_user name.

---

### PersonalProgress
Returned by `GET /users/me/progress` — single object in `body.data`.

| Field | Type | Notes |
|-------|------|-------|
| `strategy.rocks_realized_all_time` | integer | Lifetime rocks completed |
| `strategy.milestones_realized_all_time` | integer | Lifetime milestones completed |
| `strategy.milestones_realized_this_quarter` | integer | Current quarter milestones |
| `practice_scorecard.days` | array | `[{date, day_name, completed}]` — last N days |
| `practice_totals.all_time` | integer | All-time practice days |
| `practice_totals.current_streak` | integer | Current streak length |
| `practice_totals.longest_streak` | integer | Longest ever streak |

---

### UserIntegrations
Returned by `GET /users/me/integrations` — single object in `body.data`.

| Field | Type | Notes |
|-------|------|-------|
| `task_management.selected` | string or null | Current selection |
| `task_management.options` | array of strings | Available choices |
| `sales_revops.selected` | string or null | Current selection |
| `sales_revops.options` | array of strings | Available choices |
| `team_communication.selected` | string or null | Current selection |
| `team_communication.options` | array of strings | Available choices |

**Write**: `PATCH /users/me/integrations` body — include only the category being changed; set to `null` to disconnect.

---

## State Transitions (Rocks status)

```
on_track → off_track → completed
         ↘ dropped
```

These are read-only in this feature (display only; updates are not in scope).

---

## Argument Resolution Table

| Args Pattern | USER_ID | Direction | Period/Year |
|---|---|---|---|
| `measurables` | `me` | — | API default |
| `measurables {user_id}` | `{user_id}` | — | API default |
| `rocks` | `me` | — | current year |
| `rocks {year}` | `me` | — | `{year}` |
| `rocks {user_id}` | `{user_id}` | — | current year |
| `feedback given` | `me` | `given` | — |
| `feedback received` | `me` | `received` | — |
| `feedback {user_id} given` | `{user_id}` | `given` | — |
| `feedback {user_id} received` | `{user_id}` | `received` | — |
| `progress` | — (me only) | — | API default |
| `progress {period}` | — | — | `{period}` |
| `integrations` | — (me only) | — | — |
| `integrations set {cat} {val}` | — | — | — |
