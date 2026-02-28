# Data Model: Update Skills to Reflect Latest Endpoints

**Date**: 2026-02-28
**Feature**: 017-update-skill-endpoints

## Entities

No new entities are introduced. This feature modifies skill behavior (which API routes are called), not the underlying data model.

### Existing Entities (referenced, not modified)

#### Item
The core entity moved between L10 board sections.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary identifier |
| name | string | Display name |
| description | string | Optional |
| due | date (YYYY-MM-DD) | Nullable |
| status | enum | `not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft` |
| on_weekly | boolean | Whether item appears on team weekly/L10 board |
| creator | UserSimple | `{ id, login, first_name, last_name }` |
| assignees | UserSimple[] | Array of assigned users |
| team | TeamSimple | Nullable. `{ id, name }` |
| parent_id | integer | Nullable |
| created_at | datetime | ISO 8601 |
| updated_at | datetime | ISO 8601 |

#### Headline
Team-level announcement (EOS only).

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary identifier |
| text | string | Headline content |
| creator | UserSimple | `{ id, login, first_name, last_name }` |
| expires_at | date (YYYY-MM-DD) | Nullable |
| created_at | datetime | ISO 8601 |
| updated_at | datetime | ISO 8601 |

## State Transitions

### L10 Board Item Movement

```
                ┌────────┐
    ┌──────────▶│  Done  │
    │           └────────┘
    │               ▲
┌────────┐          │          ┌────────┐
│ To-Dos │──────────┼─────────▶│ Issues │
│ (next) │◀─────────┼──────────│(blocked│
└────────┘          │          └────────┘
    │               │              │
    │           ┌────────┐         │
    └──────────▶│ Parked │◀────────┘
                └────────┘
```

All transitions are bidirectional (any section → any section) via PUT routes. The `remove` operation (DELETE) removes from all sections by setting `on_weekly=false`.

### Route Mapping (L10 Skill)

| Operation | Current Route | New Route |
|-----------|---------------|-----------|
| View todos | `GET /teams/{id}/l10/todos` | *(no change)* |
| View done | *(missing)* | `GET /teams/{id}/l10/done` |
| View issues | `GET /teams/{id}/l10/issues` | *(no change)* |
| View parked | *(missing)* | `GET /teams/{id}/l10/parked` |
| View headlines | `GET /teams/{id}/l10/headlines` | *(no change)* |
| Mark done | `PUT /teams/{id}/items/done/{item_id}` | `PUT /teams/{id}/l10/done/{item_id}` |
| Move to todos | `PUT /teams/{id}/items/next/{item_id}` | `PUT /teams/{id}/l10/todos/{item_id}` |
| Move to issues | `PUT /teams/{id}/items/blocked/{item_id}` | `PUT /teams/{id}/l10/issues/{item_id}` |
| Move to parked | *(missing)* | `PUT /teams/{id}/l10/parked/{item_id}` |
| Remove from board | *(missing)* | `DELETE /teams/{id}/l10/items/{item_id}` |

### Route Mapping (Weekly Skill — EOS teams only)

| Column | Current EOS Route | New EOS Route |
|--------|-------------------|---------------|
| next | `GET /teams/{id}/l10/todos` | *(no change)* |
| done | `GET /teams/{id}/items/done` | `GET /teams/{id}/l10/done` |
| blocked | `GET /teams/{id}/l10/issues` | *(no change)* |
| parked | `GET /teams/{id}/items/parked` | `GET /teams/{id}/l10/parked` |
