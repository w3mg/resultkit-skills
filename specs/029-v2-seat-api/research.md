# Research: V2 Seat API Integration

**Feature**: 029-v2-seat-api
**Date**: 2026-03-05

## 1. Existing Implementation State

The `rkit:seats` skill (`skills/seats/SKILL.md`) is already implemented and covers:
- Full chart view (`GET /teams/{id}/seats`)
- Seat detail (`GET /seats/{id}`)
- Create, update, delete, move, restore
- Sub-resources: align/remove measure, align/remove goal, add/remove link

The `api-reference.md` already documents all 15 V2 seat endpoints with correct paths and response shapes.

**Decision**: This feature is an incremental update, not a full build. Work is scoped to:
1. Field name corrections (two discrepancies found, detailed below)
2. Missing `--include-archived` flag on chart view
3. Missing `update-link` command
4. Richer recursive-archive and non-recursive-restore messaging

---

## 2. Field Name Discrepancies

### 2a. Root seat creation: `group_id` vs `team_id`

| Source | Field name used |
|--------|----------------|
| Existing SKILL.md (line 206) | `team_id` |
| Existing api-reference.md | `team_id` |
| V2 API change spec (issue #19) | `group_id` |

**Decision**: Use `group_id` as specified by the official V2 API change handoff document. The V2 spec explicitly shows `{ "name": "CEO", "group_id": 10 }` for root seat creation. The existing field `team_id` may be a legacy alias — because "Breaking Changes: None" is stated, the API may accept both, but new code should use the V2-canonical name `group_id`.

**Rationale**: The V2 change handoff is the authoritative source for this feature. All new skill code and api-reference documentation should reflect V2 field names.

**Note**: When a live config is available, verify by calling `POST /seats` with `group_id` vs `team_id` to confirm which (or both) the API accepts. Update this document accordingly.

### 2b. Owner assignment: `accountability_owner_id` vs `seat_owner_id`

| Source | Field name used |
|--------|----------------|
| Existing SKILL.md Update flow (line 232) | `seat_owner_id` |
| Existing api-reference.md | `seat_owner_id` |
| V2 API change spec (issue #19) | `accountability_owner_id` |

**Decision**: Use `accountability_owner_id` as specified by the V2 API change handoff. The existing `seat_owner_id` may be a legacy alias.

**Note**: Verify with a live `PATCH /seats/{id}` call using both field names to confirm. Update this document accordingly.

---

## 3. Missing Feature: `--include-archived` on Chart View

The V2 API spec documents `include_archived=true` as a query parameter on `GET /teams/{id}/seats`. The existing api-reference.md marks this as `include_archived?` (uncertain). The SKILL.md has no `--include-archived` flag.

**Decision**: Add `--include-archived` flag to the chart view flow. When present, pass `include_archived=true` as a query parameter. Archived seats in the response will have `archived: true` — display them with an `[archived]` tag in the tree.

**Rationale**: Without this flag, archived seats are invisible. Users who accidentally archive a seat need a way to find and restore it.

---

## 4. Missing Feature: `update-link` Command

The api-reference.md documents `PATCH /seats/{id}/links/{link_id}` but the SKILL.md has no `update-link` command in its argument parsing table. The flow for updating an existing link's URL or title is completely absent.

**Decision**: Add `update-link {seat_id} --link {lid} [--url "..."] [--title "..."]` to the argument parsing table and implement the corresponding flow.

**Rationale**: Users who add a link with the wrong URL or title need a way to fix it without removing and re-adding. This is a basic CRUD gap.

---

## 5. Recursive Archive / Non-Recursive Restore Messaging

The existing SKILL.md delete confirmation says: "Archive seat [ID: {id}]? This will remove it from the chart." It does not mention that archiving is recursive (all children are also archived).

The existing restore confirmation says nothing about non-recursive behavior (children remain archived).

**Decision**: Update delete confirmation to explicitly state that all descendant seats will also be archived. Update restore confirmation to note that children remain archived and must be restored individually.

**Rationale**: Users need to understand the blast radius before confirming a delete. A recursive archive of an Integrator seat would archive every seat below it in the org chart — that must be visible in the confirmation.

---

## 6. Root Seat Archive Constraint

The api-reference.md states: "Cannot archive root seat." The V2 spec says "one root seat per team — enforced on create, delete, and move."

**Decision**: The existing 422 error handling already catches this. No additional work needed — the API returns a 422 with a message, and the skill surfaces it. The confirmation message can note this constraint for clarity.

---

## 7. Link Title Default

The V2 spec states: "Link title defaults to URL when not provided or set to null."

The existing SKILL.md handles this: "Omit title from body if not provided (API defaults to URL)."

**Decision**: No change needed. Behavior is already correct.

---

## Summary of Changes Required

| Area | Change | Priority |
|------|--------|----------|
| `SKILL.md` + `api-reference.md` | `team_id` → `group_id` for root seat creation | High |
| `SKILL.md` + `api-reference.md` | `seat_owner_id` → `accountability_owner_id` for owner assignment | High |
| `SKILL.md` | Add `--include-archived` flag and chart flow support | High |
| `SKILL.md` | Add `update-link` command and flow | Medium |
| `SKILL.md` | Enhance delete confirmation with recursive-archive warning | Medium |
| `SKILL.md` | Enhance restore confirmation with non-recursive note | Low |
| `api-reference.md` | Confirm `include_archived=true` param for `GET /teams/{id}/seats` | Medium |
