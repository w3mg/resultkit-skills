# Research: rkit:1on1 Endpoint Migration

**Date**: 2026-04-23

## R1: Correct API Endpoint Paths

**Decision**: All one-on-one endpoints use `/1-on-1` prefix, not `/meetings`.

**Rationale**: Issue #97 confirmed by inspecting `resultmaps-api2/src/app/api/v2/1-on-1/` route files. The `/meetings` endpoints return 404.

**Mapping**:

| Skill currently uses | Correct endpoint |
|---|---|
| `GET /meetings` | `GET /1-on-1` |
| `GET /meetings/{id}` | `GET /1-on-1/{id}` |
| `GET /meetings/{id}/items/{section}` | `GET /1-on-1/{id}/items` (all), `GET /1-on-1/{id}/done` (done-specific) |
| `POST /meetings/{id}/items` | `POST /1-on-1/{id}/items` |
| `PUT /meetings/{id}/items/{item_id}` | `PUT /1-on-1/{id}/items/{item_id}` (needs verification) |
| `DELETE /meetings/{id}/items/{item_id}` | `DELETE /1-on-1/{id}/items/{item_id}` (needs verification) |

**Alternatives considered**: None. The API paths are fixed server-side.

## R2: Filter Parameter Name

**Decision**: Use `group_id` instead of `team_id` for team filtering on `GET /1-on-1`.

**Rationale**: Issue #97 confirmed from API source code. `team_id` param is not recognized.

## R3: Response Shape — Persons

**Decision**: Person data is nested under a `persons` object, not top-level.

**Rationale**: Confirmed from issue #97 inspection of actual API responses.

**Old assumption**: `person1`, `person2` as top-level fields.  
**Actual shape**:
```json
{
  "persons": {
    "person1": { "id": 1, "login": "...", "first_name": "...", "last_name": "..." },
    "person2": { "id": 2088, "login": "...", "first_name": "...", "last_name": "..." }
  }
}
```

## R4: Detail Response — Section Naming

**Decision**: Item sections are nested under `items` key, and "blocked" is called `issues`.

**Rationale**: Confirmed from issue #97 inspection of actual API responses.

**Old assumption**: Top-level `blocked`, `done`, `next` arrays.  
**Actual shape**:
```json
{
  "items": {
    "done": [...],
    "issues": [...],
    "next": [...]
  }
}
```

## R5: Done Items — Dedicated Endpoint

**Decision**: Done items have their own endpoint: `GET /1-on-1/{id}/done` with optional `since` date filter.

**Rationale**: From API route file `[id]/done/route.ts`. The generic items-by-section endpoint may not support "done" as a section value — done has a separate route.

## R6: Notes Endpoint

**Decision**: Notes can be saved via `PUT /1-on-1/{id}/notes` with body `{"notes": "text"}`.

**Rationale**: From API route file. Not referenced in original spec but available for enhancement.

## R7: Additional Fields Available

**Decision**: API returns additional fields not currently used by the skill.

Fields: `human_name`, `can_edit`, `can_view`, `can_edit_notes`, `measures`, `goals`, `notes`, `attachments`, `assistants`.

**How to apply**: `human_name` can simplify display name logic. Permission fields can improve error messages. Others are out of scope for this fix.
