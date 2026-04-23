# Research: Fix 1on1 Skill API Endpoints

**Feature**: 001-fix-1on1-endpoints-gh97  
**Date**: 2026-04-22

## Decision 1: Base endpoint path

**Decision**: Use `/1-on-1` as the base path for all one-on-one meeting endpoints.  
**Rationale**: The issue documents that the API routes live at `src/app/api/v2/1-on-1/` in the resultmaps-api2 codebase, confirming the actual path. The `/meetings` path the skill currently uses returns 404.  
**Alternatives considered**: `/meetings` — confirmed non-existent in V2 API.

## Decision 2: Team filter parameter

**Decision**: Use `group_id` (not `team_id`) when filtering one-on-ones by team.  
**Rationale**: Documented in issue from direct inspection of `route.ts` in the API codebase.  
**Alternatives considered**: `team_id` — returns all meetings unfiltered (or possibly 422); incorrect.

## Decision 3: Response shape — persons

**Decision**: Read participant names from `persons.person1` / `persons.person2` (nested object), not from top-level `person1` / `person2` fields.  
**Rationale**: Issue includes actual JSON response shape showing `persons` as a nested key. The skill currently references top-level fields that don't exist.  
**Alternatives considered**: Top-level fields — confirmed absent in actual response.

## Decision 4: Response shape — detail items

**Decision**: Read items from `items.done`, `items.issues`, and `items.next` on the meeting detail response. Map `items.issues` → Blocked column.  
**Rationale**: Issue documents actual detail response structure. The skill currently reads from non-existent top-level `blocked`, `done`, `next` arrays.  
**Alternatives considered**: Top-level arrays — confirmed absent.

## Decision 5: Status values for 1on1 items

**Decision**: Use `active` for "next" items and `realized` for "done" items in 1on1 API calls.  
**Rationale**: Documented in issue. These differ from the general items API status values (`next`, `done`) because the 1on1 service uses its own status vocabulary.  
**Alternatives considered**: `next`/`done` — likely to fail or return wrong results in the 1on1 context.  
**⚠️ Requires live API verification**: Confirm `active`/`realized` values against real API before coding the Move Item flow and single-column view. The PATCH `/items/{id}` endpoint may accept either vocabulary — test both.

## Decision 6: Item attach/detach endpoints

**Decision**: Assume `PUT /1-on-1/{id}/items/{item_id}` (attach) and `DELETE /1-on-1/{id}/items/{item_id}` (detach) exist, mirroring the old `/meetings/` pattern.  
**Rationale**: The issue notes these need verification. The API codebase has `[id]/items/route.ts` which likely handles these HTTP methods.  
**⚠️ Requires live API verification**: Call `PUT /1-on-1/{id}/items/{item_id}` and `DELETE /1-on-1/{id}/items/{item_id}` against the real API to confirm they exist and return expected status codes (200/204). If they don't exist, remove the Add Existing Item and Remove Item flows from the skill until confirmed.

## Decision 7: Single-column view endpoint

**Decision**: Use `GET /1-on-1/{id}/items?status=<value>` or `GET /1-on-1/{id}/done` for single-column views, rather than the old `GET /meetings/{id}/items/{section}` pattern.  
**Rationale**: Issue documents `GET /1-on-1/{id}/items` and `GET /1-on-1/{id}/done` as the real routes. The `/items` endpoint likely accepts a `status` query param.  
**⚠️ Requires live API verification**: Test `GET /1-on-1/{id}/items?status=active`, `GET /1-on-1/{id}/items?status=realized`, and `GET /1-on-1/{id}/done` to confirm which endpoints work and what params they accept.

## Unresolved items (verify during implementation)

These must be confirmed by calling the real API with `scripts/api.sh` before writing the skill logic:

1. `PUT /1-on-1/{id}/items/{item_id}` — does it exist? What does it return?
2. `DELETE /1-on-1/{id}/items/{item_id}` — does it exist? What does it return?
3. Single-column filtering: `GET /1-on-1/{id}/items?status=active` vs `GET /1-on-1/{id}/done` — which paths and params work?
4. Status values: does `PATCH /items/{id}` accept `active`/`realized` or `next`/`done` for meeting items?
