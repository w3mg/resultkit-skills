# Data Model: Goals, Rocks & Milestones API Migration

**Branch**: `038-goals-rocks-api-40` | **Date**: 2026-03-18

## Entities

### Goal (Yearly)

A yearly objective for an EOS team. Always a root-level node in the strategy tree.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Unique identifier |
| name | string | Required on create |
| description | string \| null | Optional |
| status | string | `active`, `complete`, `archived`, etc. |
| type | string | Always `"yearly_goal"` |
| achieve_by | date (YYYY-MM-DD) \| null | Target completion date |
| color | string \| null | Visual indicator |
| is_visible_to_team | boolean | Team visibility flag |
| assignees | Assignee[] | Array of assigned users |
| creator | Assignee | User who created the goal |
| created_at | datetime | ISO 8601 |
| updated_at | datetime | ISO 8601 |

### Rock (Quarterly)

A quarterly priority, optionally aligned to a yearly goal.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Unique identifier |
| name | string | Required on create |
| description | string \| null | Optional |
| status | string | `active`, `complete`, `archived`, etc. |
| type | string | Always `"rock"` |
| achieve_by | date (YYYY-MM-DD) \| null | Target completion date |
| color | string \| null | Visual indicator |
| is_visible_to_team | boolean | Team visibility flag |
| parent_id | integer \| null | Goal ID if aligned |
| persist_until_cleared | boolean | Keeps rock visible past quarter end |
| assignees | Assignee[] | Array of assigned users |
| creator | Assignee | User who created the rock |
| created_at | datetime | ISO 8601 |
| updated_at | datetime | ISO 8601 |

### Milestone

A specific deliverable aligned to a rock.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Unique identifier |
| name | string | Required on create |
| description | string \| null | Optional |
| status | string | `active`, `complete`, `archived`, etc. |
| type | string | Always `"milestone"` |
| due | date (YYYY-MM-DD) \| null | Due date |
| color | string \| null | Visual indicator |
| parent_id | integer \| null | Rock ID if aligned |
| assignees | Assignee[] | Array of assigned users |
| creator | Assignee | User who created the milestone |
| created_at | datetime | ISO 8601 |
| ~~updated_at~~ | — | Not included in milestone responses |

### Assignee (embedded)

| Field | Type | Notes |
|-------|------|-------|
| id | integer | User ID |
| login | string | May be empty string |
| first_name | string \| null | |
| last_name | string \| null | |
| profile_photo_thumb_path | string \| null | |

## Relationships

```
Goal (yearly_goal)
  └── Rock (rock)        [rock.parent_id → goal.id]
       └── Milestone      [milestone.parent_id → rock.id]
```

- Goals are always root-level (no parent)
- Rocks optionally align to one goal via `parent_id`
- Milestones optionally align to one rock via `parent_id`
- Alignment is set via PUT endpoints, not during create (except milestones which accept `parent_id` on create)

## Strategy Tree Node (from GET /teams/{id}/targets)

The tree response uses a different schema than the flat CRUD responses:

| Field | Type | Notes |
|-------|------|-------|
| id | integer | |
| name | string \| null | |
| description | string \| null | |
| status | string | |
| object_type | string | `yearly_goal`, `rock`, `milestone`, etc. |
| type | integer \| string | Integer for Goals (0=objective, 1=rock, 2=yearly), string for Items |
| color | string \| null | |
| assignees | Assignee[] | Simplified (id, first_name, last_name only) |
| creator | Assignee \| null | |
| due | date \| null | |
| children | StrategyNode[] | Recursive |
| inherited | boolean | Read-only if true |
| inherited_from | { team_id, team_name } \| null | Source team for inherited nodes |

## State Transitions

| Action | From Status | To Status | API Call |
|--------|-------------|-----------|----------|
| Create | — | `active` | POST /teams/{id}/goals\|rocks\|milestones |
| Update status | any | any valid | PATCH /goals\|rocks\|milestones/{id} |
| Archive | any | `archived` | DELETE /goals\|rocks\|milestones/{id} |
| Align to parent | any | unchanged | PUT /rocks\|milestones/{id} |
| Unlink from parent | any | unchanged | PATCH /rocks\|milestones/{id} (parent_id: null) |
