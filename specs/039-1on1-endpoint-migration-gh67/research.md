# Research: Update rkit:1on1 Skill to New API Endpoints

**Branch**: `039-1on1-endpoint-migration-gh67` | **Date**: 2026-04-13

## Decision: Endpoint Path Migration

**Decision**: Replace all `/meetings/*` paths in `skills/1on1/SKILL.md` with `/1-on-1/*` paths as specified in the API Change Handoff (issue #67).

**Rationale**: The API team has deleted the old `/api/v2/meetings/*` routes and replaced them with `/api/v2/1-on-1/*`. The skill will return errors (404/routing failures) for every operation until the paths are updated.

**Alternatives considered**: None — this is a required breaking change fix.

---

## Decision: Notes Flow (New Feature)

**Decision**: Implement the `notes` subcommand using `PUT /1-on-1/{id}/notes` as the highest-priority new endpoint per the API handoff.

**Rationale**: Notes are core to 1:1 meeting value. The endpoint is straightforward (PUT with a `notes` field) and follows the same pattern as other write operations in the skill.

**Alternatives considered**: Skipping notes and doing path-rename only. Rejected because the API handoff explicitly calls out notes as a key new capability for "API Skill Maintainers."

---

## Decision: Out-of-Scope Endpoints

**Decision**: Notes-lock, align/unalign, assistants, attachments, goals, measures, set-positions, and fetch are not implemented in this feature.

**Rationale**: These are lower-priority endpoints that require additional UX design (e.g., how does "align a goal" work in a CLI skill?). Shipping the path fix and notes first restores full functionality without scope creep.

---

## Live API Verification (Required Before Implementation)

**Status**: ⚠️ Dev/worktree environment has no `~/.config/resultkit/config.json`. Implementation proceeded based on the API Change Handoff document (issue #67) as the authoritative source. The handoff doc was authored by the API team directly from the merged code — it is treated as equivalent to live API verification for this migration. If any response shape discrepancies are discovered at runtime, fix them and re-ship.

Original note: Implementer SHOULD verify the following before writing skill logic (per CLAUDE.md mandatory rule):

### Verify these before coding:

```bash
API_SH="scripts/api.sh"

# 1. List endpoint — confirm envelope shape matches old /meetings
"$API_SH" GET "/1-on-1?per_page=5"
# Expected: { data: [...], meta: { page, per_page, total } }
# Each item should have: id, type ("one_on_one"), date, persons

# 2. Detail endpoint — confirm persons, items arrays, notes field
"$API_SH" GET "/1-on-1/MEETING_ID"
# Expected: { data: { id, persons: {person1, person2}, items: {done,next,blocked}, notes } }

# 3. Items section endpoint
"$API_SH" GET "/1-on-1/MEETING_ID/items/next?per_page=10"
# Expected: { data: [...items...], meta: {...} }

# 4. Notes endpoint — request body shape
"$API_SH" PUT "/1-on-1/MEETING_ID/notes" '{"notes": "test note"}'
# Expected: 200 with updated meeting data

# 5. Create item endpoint
"$API_SH" POST "/1-on-1/MEETING_ID/items" '{"name": "Test item"}'
# Expected: 201 with new item

# 6. Attach existing item
"$API_SH" PUT "/1-on-1/MEETING_ID/items/ITEM_ID"
# Expected: 200

# 7. Remove item
"$API_SH" DELETE "/1-on-1/MEETING_ID/items/ITEM_ID"
# Expected: 200 or 204
```

### Known from API handoff doc (use as guide until verified):

- `GET /1-on-1` response includes `type: "one_on_one"` — same filter the skill already applies client-side
- `POST /1-on-1/{id}/notes` (per handoff) → the handoff says `PUT /1-on-1/{id}/notes`; confirm method
- Response on GET /1-on-1/{id} includes `persons.person1` and `persons.person2` objects with `id`, `login`, `first_name`, `last_name`

---

## Codebase Scan: Active Files Referencing /meetings

Files that need updating (active skill code and master reference):

| File | Change Required |
|------|----------------|
| `skills/1on1/SKILL.md` | Replace all `/meetings/...` paths with `/1-on-1/...` |
| `api-reference.md` | Replace `/meetings` section with `/1-on-1` endpoints |
| `skills/*/references/api-reference.md` | Updated via `/sync-plugin` (do not edit directly) |

Files with `/meetings` references that do NOT need updating (historical specs):

- `specs/007-meeting/`, `specs/011-1on1/`, `specs/019-1on1-columns/`, `specs/028-1on1-archive-filter/` — completed historical specs, read-only
- `specs/017-update-skill-endpoints/research.md` — historical research doc

---

## Resolved: All NEEDS CLARIFICATION Items

No clarification markers were present in the spec. All decisions are made.
