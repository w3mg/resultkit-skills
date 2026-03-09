# Data Model: Strategy Skill (rkit:strategy)

**Branch**: `001-strategy-skill` | **Date**: 2026-03-09

## Entities

### StrategyResponse

Top-level response from `GET /teams/{id}/strategy`.

| Field | Type | Description |
|-------|------|-------------|
| `framework` | string | Team's management framework: `"eos"`, `"okr"`, `"4dx"` |
| `strategy` | StrategyNode[] | Nested tree of aligned strategy objects |
| `unaligned` | StrategyNode[] | Objects not linked to any parent |

### StrategyNode

A node in the strategy tree. Recursive via `children`.

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique object ID |
| `name` | string \| null | Display name |
| `description` | string \| null | Optional description |
| `status` | string | One of: active, complete, archived, deferred, review, draft, cancelled, at_risk, off_track |
| `object_type` | string | One of: yearly_goal, rock, focus_area, objective, key_result, milestone, action |
| `type` | integer \| string \| null | Goal type integer (0=objective/WIG, 1=rock, 2=yearly) or Item type string (KeyResult, ResultArea) |
| `color` | string \| null | Progress color |
| `assignees` | StrategyAssignee[] | Users assigned to this object |
| `creator` | StrategyAssignee \| null | User who created this object |
| `due` | string \| null | Due date (YYYY-MM-DD) |
| `children` | StrategyNode[] | Child nodes in the tree |
| `inherited` | boolean | True if from a parent team (read-only) |
| `inherited_from` | object \| null | `{ team_id: int, team_name: string }` — source team for inherited nodes |

### StrategyAssignee

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | User ID |
| `first_name` | string \| null | First name |
| `last_name` | string \| null | Last name |

## Framework-to-Object-Type Mapping

| Level | EOS | OKR | 4DX |
|-------|-----|-----|-----|
| Root container | — | focus_area | focus_area |
| Top-level goal | yearly_goal | objective | objective (WIG) |
| Quarterly priority | rock | rock | rock (Battle) |
| Sub-goal / measure | milestone | key_result | key_result (Lead Measure) |
| Action item | action | action | action |

## State Transitions

Strategy objects use `status` field. Key transitions:

- `active` → `complete` (goal achieved)
- `active` → `archived` (soft delete via detach + also_archive)
- `active` → `deferred` (postponed)
- `active` → `at_risk` / `off_track` (progress alerts)
- `complete` → `active` (reopened)

## Relationships

- **Team → StrategyResponse**: One team has one strategy tree (per year/quarter view).
- **StrategyNode → StrategyNode**: Parent-child via `children` array (recursive tree).
- **StrategyNode → StrategyAssignee**: Many-to-many via `assignees` array.
- **StrategyNode → inherited_from**: Optional link to source team for inherited nodes.

## Validation Rules

- `name` is required for create (POST).
- `parent_id` + `parent_type` required for create-as-child and for detach (DELETE).
- `object_id` + `object_type` + `parent_id` + `parent_type` all required for align (PUT).
- `assignees` on update replaces the full list (send complete list, not delta).
- `also_archive` defaults to false on detach.
- Inherited nodes cannot be modified (403 on write attempts).
