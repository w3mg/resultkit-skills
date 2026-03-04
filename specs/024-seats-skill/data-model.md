# Data Model: rkit:seats Skill

**Date**: 2026-03-04 | **Branch**: `024-seats-skill`

## Entities

### Seat (Full — from tree endpoint)

Returned by `GET /teams/{id}/seats` as recursive tree nodes.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | integer | no | Seat ID |
| name | string | no | Seat/role name |
| accountabilities | string (HTML) | yes | HTML-formatted responsibilities |
| notes | string | yes | Free-text notes |
| parent | SeatRef | yes | Parent seat (null for root) |
| creator | UserSimple | no | User who created the seat |
| seat_owner | UserSimple | yes | Assigned user (null = vacant) |
| team | TeamSimple | no | Owning team |
| associated_team | TeamSimple | yes | Linked sub-team |
| measures | MeasureRef[] | no | Aligned KPIs/measurables |
| goals | GoalRef[] | no | Aligned rocks/goals |
| links | LinkRef[] | no | External links |
| children | Seat[] | no | Child seats (full recursive in tree, SeatRef[] in detail) |
| created_at | datetime | no | Creation timestamp |
| updated_at | datetime | no | Last update timestamp |

### Seat (Detail — from single endpoint)

Returned by `GET /seats/{id}`. Same fields as above except:
- `children` contains `SeatRef[]` (just `{id, name}`) instead of full recursive `Seat[]`

### SeatRef

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Seat ID |
| name | string | Seat name |

### UserSimple

| Field | Type | Description |
|-------|------|-------------|
| id | integer | User ID |
| login | string | Username |
| first_name | string | First name |
| last_name | string | Last name |

### TeamSimple

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Team ID |
| name | string | Team name |
| framework | string | Management framework (eos, okr, 4dx, etc.) |

### MeasureRef

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | integer | no | Measure ID |
| name | string | no | Measure name |
| description | string | yes | Measure description |

### GoalRef

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | integer | no | Goal ID |
| name | string | no | Goal name |
| description | string | yes | Goal description |

### LinkRef

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Link ID |
| title | string | Display title |
| url | string | External URL |

## Relationships

```
Team 1──* Seat (root)
Seat 1──* Seat (children, recursive)
Seat *──1 UserSimple (seat_owner, nullable)
Seat *──1 UserSimple (creator)
Seat *──1 TeamSimple (team)
Seat *──1 TeamSimple (associated_team, nullable)
Seat *──1 SeatRef (parent, nullable)
Seat 1──* MeasureRef (aligned measures)
Seat 1──* GoalRef (aligned goals)
Seat 1──* LinkRef (links)
```

## Writable Fields

### POST /seats (Create)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | yes | Seat name |
| team_id | integer | yes | Team to create in |
| parent_id | integer | no | Parent seat (omit for root) |

### PATCH /seats/{id} (Update)

| Field | Type | Description |
|-------|------|-------------|
| name | string | Seat name |
| accountabilities | string (HTML) | Responsibilities |
| notes | string | Free-text notes |
| seat_owner_id | integer | Assign user to seat |
| associated_team_id | integer | Link a sub-team |

### PUT /seats/{id}/move

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| parent_id | integer | yes | New parent seat ID |
