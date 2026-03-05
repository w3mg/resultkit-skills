# Data Model: V2 Seat API Integration

**Feature**: 029-v2-seat-api
**Date**: 2026-03-05

This feature does not introduce new data models — all entities are defined by the ResultMaps V2 API. This document records the canonical field names for use in skill code.

---

## Seat (Full Object)

Returned by `GET /teams/{id}/seats` (tree) and `GET /seats/{id}` (detail).

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Unique seat ID |
| `name` | string | Seat/role name |
| `accountabilities` | string \| null | HTML-formatted text; strip for display |
| `notes` | string \| null | HTML-formatted text; strip for display |
| `parent` | SeatSimple \| null | Null for root seat |
| `creator` | UserSimple | Who created the seat |
| `seat_owner` | UserSimple \| null | Assigned owner; null = Vacant |
| `team` | TeamSimple | Team this seat belongs to (includes `framework`) |
| `associated_team` | TeamSimple \| null | Optional linked team |
| `measures` | Measure[] | Aligned KPIs/measurables |
| `goals` | Goal[] | Aligned rocks/goals |
| `links` | Link[] | Attached URLs |
| `children` | Seat[] \| SeatSimple[] | Recursive in tree; simplified in detail |
| `archived` | boolean | Present when `include_archived=true` on tree endpoint |
| `created_at` | ISO 8601 string | |
| `updated_at` | ISO 8601 string | |

## SeatSimple

Used for `children` in detail response and `parent` field.

| Field | Type |
|-------|------|
| `id` | integer |
| `name` | string |
| `parent_id` | integer \| null |
| `owner` | UserSimple \| null |

## UserSimple

| Field | Type |
|-------|------|
| `id` | integer |
| `login` | string |
| `first_name` | string |
| `last_name` | string |

## TeamSimple

| Field | Type |
|-------|------|
| `id` | integer |
| `name` | string |
| `framework` | string (`eos`, `okr`, etc.) |

## Measure

| Field | Type |
|-------|------|
| `id` | integer |
| `name` | string |
| `description` | string \| null |

## Goal

| Field | Type |
|-------|------|
| `id` | integer |
| `name` | string |
| `description` | string \| null |

## Link

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | |
| `title` | string | Defaults to URL when not provided |
| `url` | string | Must be http/https |

---

## V2 Request Field Names (Canonical)

These are the field names to use in API request bodies. The V2 spec is authoritative.

### POST /seats (create)

| Use case | Field | Value |
|----------|-------|-------|
| Root seat (no parent) | `group_id` | Team ID integer |
| Child seat | `parent_id` | Parent seat ID integer |
| Seat name | `name` | string (required) |
| Initial owner | `accountability_owner_id` | User ID integer (optional) |
| Accountabilities | `accountabilities` | HTML string (optional) |
| Notes | `notes` | string (optional) |
| Associated team | `associated_team_id` | Team ID integer (optional) |

### PATCH /seats/{id} (update)

| Flag | Field | Value |
|------|-------|-------|
| `--name` | `name` | string |
| `--owner` | `accountability_owner_id` | User ID integer |
| `--notes` | `notes` | string |
| `--accountabilities` | `accountabilities` | HTML string |
| `--associated-team` | `associated_team_id` | Team ID integer |

### PUT /seats/{id}/move

| Field | Value |
|-------|-------|
| `parent_id` | New parent seat ID integer |

### PUT /seats/{id}/measures (align)

| Field | Value |
|-------|-------|
| `measure_id` | Measure ID integer |

### PUT /seats/{id}/goals (align)

| Field | Value |
|-------|-------|
| `goal_id` | Goal ID integer |

### POST /seats/{id}/links (create)

| Field | Value | Required |
|-------|-------|----------|
| `url` | URL string | Yes |
| `title` | string | No (defaults to URL) |

### PATCH /seats/{id}/links/{link_id} (update)

| Field | Value | Required |
|-------|-------|----------|
| `url` | URL string | No |
| `title` | string | No (null resets to URL) |

---

## Response Envelopes

| Endpoint | Envelope |
|----------|---------|
| `GET /teams/{id}/seats` | `{ "data": [ Seat, ... ] }` — array of root seats, recursive children |
| `GET /seats/{id}` | `{ "data": { ...Seat } }` |
| `POST /seats` | `{ "data": { ...Seat } }` — status 201 |
| `PATCH /seats/{id}` | `{ "data": { ...Seat } }` — status 200 |
| `DELETE /seats/{id}` | 204 no content |
| `PUT /seats/{id}/move` | `{ "data": { ...Seat } }` — status 200 |
| `PUT /seats/{id}/restore` | `{ "data": { ...Seat } }` — status 200 |
| `GET /seats/{id}/measures` | `{ "data": [ Measure, ... ] }` |
| `PUT /seats/{id}/measures` | `{ "data": [ Measure, ... ] }` — status 200 |
| `DELETE /seats/{id}/measures/{id}` | 204 no content |
| `GET /seats/{id}/goals` | `{ "data": [ Goal, ... ] }` |
| `PUT /seats/{id}/goals` | `{ "data": [ Goal, ... ] }` — status 200 |
| `DELETE /seats/{id}/goals/{id}` | 204 no content |
| `GET /seats/{id}/links` | `{ "data": [ Link, ... ] }` |
| `POST /seats/{id}/links` | `{ "data": { ...Link } }` — status 201 |
| `PATCH /seats/{id}/links/{id}` | `{ "data": { ...Link } }` — status 200 |
| `DELETE /seats/{id}/links/{id}` | 204 no content |
