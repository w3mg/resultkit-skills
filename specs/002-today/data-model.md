# Data Model: rkit:today

## Entities

### DayPlan

Represents a single day's plan for the authenticated user.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Plan ID |
| date | string (YYYY-MM-DD) | Plan date |
| user_id | integer | Owner |
| created_at | string (ISO 8601) | |
| updated_at | string (ISO 8601) | |

Auto-created when accessing `today` endpoints.

### DayPlanItem

An item attached to a day plan. Extends the standard Item with
plan-specific fields.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Item ID (same as the Item entity) |
| name | string | Item name |
| description | string | nullable |
| due | string (YYYY-MM-DD) | nullable |
| status | string | One of: not_started, next, parked, blocked, done, archived, draft |
| on_weekly | boolean | Whether item is on the weekly board |
| team_id | integer | nullable |
| parent_id | integer | nullable |
| context | string | nullable |
| completed | boolean | **Plan-specific** — whether marked done on this day plan |
| position | integer | **Plan-specific** — display order on the plan |

### Relationships

```
User 1──* DayPlan (one plan per date per user)
DayPlan *──* Item (via DayPlanItem join — adds completed, position)
```

## State Transitions

### completed (plan-specific)

```
false ──(PATCH completed:true)──→ true
true  ──(PATCH completed:false)──→ false
```

This is independent of the item's `status` field. An item can be
`status: next` but `completed: true` on today's plan.

## Pagination

List responses use standard pagination wrapper:

```json
{
  "data": [ DayPlanItem, ... ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 5,
    "total_pages": 1
  }
}
```
