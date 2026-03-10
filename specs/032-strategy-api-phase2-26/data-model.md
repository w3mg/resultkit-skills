# Data Model: Strategy API Phase 2

## StrategyNode

A node in the strategy tree returned by `GET /teams/{id}/strategy`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Unique node ID |
| `name` | string | Display name |
| `description` | string\|null | Optional description |
| `status` | string | `active`, `complete`, `archived`, `deferred`, `at_risk`, `off_track`, `draft`, `cancelled`, `review` |
| `object_type` | string | `yearly_goal`, `objective`, `rock`, `focus_area`, `key_result`, `milestone`, `action` |
| `type` | integer | Internal type code (not used by skill) |
| `color` | string\|null | Optional color tag |
| `assignees` | array | `[{ id, first_name, last_name }]` |
| `creator` | object | `{ id, first_name, last_name }` |
| `due` | string\|null | ISO date `YYYY-MM-DD` or null |
| `children` | array | Nested `StrategyNode[]` |
| `inherited` | boolean | True if node cascaded from a parent team |
| `inherited_from` | object\|null | `{ team_id, team_name }` when inherited |

## Framework Hierarchy

| Framework | L1 | L2 | L3 | L4 |
|-----------|----|----|----|----|
| EOS | Yearly Goal | Objective | Rock | Milestone |
| OKR | Yearly Goal | Objective | Key Result | Milestone |
| 4DX | Yearly Goal | WIG (objective) | Lead Measure (key_result) | Action |

`object_type` values: `yearly_goal`, `objective`, `rock`, `focus_area`, `key_result`, `milestone`, `action`

## StrategyResponse Envelope

```json
{
  "data": {
    "framework": "eos | okr | 4dx",
    "strategy": [StrategyNode],
    "unaligned": [StrategyNode]
  }
}
```

## State Transitions

Nodes can move between:
- `active` ↔ `archived` (via also_archive on DELETE, or PATCH status)
- `active` ↔ `complete`, `at_risk`, `off_track`, `deferred`, `cancelled`
- Inherited nodes → **read-only** (no state transitions allowed via skill)
