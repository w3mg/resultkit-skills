# Research: V2 Seat API Field Renames

**Feature**: 030-seats-field-renames
**Date**: 2026-03-05

## Summary

No ambiguity. The API change handoff doc (issue #20) fully specifies all renames with before/after examples and affected endpoints. No external research was required.

## Findings

### Decision: Which files need changes

**Decision**: Two files need direct changes: `skills/seats/SKILL.md` and master `api-reference.md` (which sync-plugin copies to `skills/seats/references/api-reference.md`).

**Finding**: The SKILL.md was partially updated when issue #19 was implemented. The Schemas section, tree rendering, and seat detail display already use the correct new field names (`seat_owner`, `accountabilities`, `parent` as object). However, two write flows were missed:
- Create seat (root): still sends `group_id` (should be `team_id`)
- Update seat: still maps `--owner` flag to `accountability_owner_id` (should be `seat_owner_id`)

Additionally, the Direct Reports table in seat detail view shows an Owner column, but children are now `{ id, name }` only — the Owner column must be removed.

**Rationale**: Targeted fix — only change the three broken spots in SKILL.md and the api-reference.md entries.

### Decision: SeatSimple children rendering

**Decision**: Remove the Owner column from the Direct Reports table in "View Seat Details".

**Rationale**: Children in `GET /seats/{id}` responses are now `{ id, name }` only. Attempting to read `.owner` or `.seat_owner` on children returns `undefined`/null. The table should only show ID and Name.

### Decision: api-reference.md scope

**Decision**: Update only the seat-related rows and field documentation in api-reference.md. Do not modify unrelated entries (the `group_id` reference on line 182 is for projects, not seats — leave it).

**Rationale**: The `group_id` reference on line 182 is for `DELETE /teams/{id}/projects/{project_id}` which is a different domain. Only seat endpoint entries need updating.

## Changes Required

### `skills/seats/SKILL.md`

| Location | Current | Correct |
|----------|---------|---------|
| Create Seat root body | `"group_id":TEAM_ID` | `"team_id":TEAM_ID` |
| Update Seat `--owner` mapping | `"accountability_owner_id": {uid}` | `"seat_owner_id": {uid}` |
| Direct Reports table columns | `ID \| Name \| Owner` | `ID \| Name` |

### `api-reference.md` (master)

| Location | Current | Correct |
|----------|---------|---------|
| POST /seats description | `group_id or parent_id`, `accountability_owner_id?` | `team_id or parent_id`, `seat_owner_id?` |
| PATCH /seats/{id} description | `accountability_owner_id?` | `seat_owner_id?` |
| Terminology table (line 635) | `accountability_owner_id` | `seat_owner_id` |
