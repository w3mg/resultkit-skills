# Research: Strategy API Phase 2 Update

## Findings

### 1. Strategy skill already exists (Phase 2 compliant)

**Decision**: The `rkit:strategy` skill lives on branch `origin/001-strategy-skill` and was built against the Phase 2 API from the start.

**Evidence** (from `skills/strategy/SKILL.md` on that branch):
- `GET /teams/$TEAM_ID/strategy` — no `?cascade=` param sent ✅
- `POST /teams/$TEAM_ID/strategy` — `object_type` absent from body; `is_focus_area` included when applicable ✅
- `PUT /strategy/align` — team-less route, no `link_type` in body ✅
- `PATCH /strategy/$OBJECT_TYPE/$OBJECT_ID` — team-less route ✅
- `DELETE /strategy/$OBJECT_TYPE/$OBJECT_ID` — `parent_id`, `parent_type`, `also_archive` in body; no `?action=` param ✅
- `action` object_type in Framework Label Mapping for 4DX ✅
- `inherited: true` nodes blocked from edit operations ✅

**Rationale**: No changes required to the strategy skill SKILL.md. The skill was written for the Phase 2 contract.

**Alternatives considered**: Patching an existing Phase 1 skill — N/A, no Phase 1 strategy skill existed on main.

---

### 2. Strategy endpoints missing from api-reference.md

**Decision**: Add a Strategy section to `api-reference.md` documenting all Phase 2 endpoints.

**Evidence**: `grep strategy api-reference.md` returns no strategy endpoint rows. The master reference has no `/teams/{id}/strategy` or `/strategy/*` routes documented.

**Rationale**: `api-reference.md` is the source of truth for all skill developers. Without these entries, future skill updates would lack a reference contract.

**Alternatives considered**: Leaving documentation out until the skill merges — rejected; api-reference.md should reflect the live API state independently of skill merge status.

---

### 3. Strategy skill integration path

**Decision**: This branch (032) integrates the strategy skill from `origin/001-strategy-skill` into main via the normal skill directory structure, adds it to the plugin manifest, and updates api-reference.md.

**Rationale**: The 001-strategy-skill branch is ready; the only remaining work is the api-reference.md update and plugin manifest inclusion. Merging via this branch keeps the API change handoff tracking linked.

---

## Phase 2 Endpoint Summary (source: GitHub Issue #26)

| Method | Route | Key Change |
|--------|-------|-----------|
| GET | `/teams/{id}/strategy` | No `cascade` param; adds `inherited`/`inherited_from` fields; 4DX `action` type |
| POST | `/teams/{id}/strategy` | Remove `object_type` from body; add `is_focus_area` boolean |
| PUT | `/teams/{id}/strategy` | Delegates to `/strategy/align`; `link_type` removed |
| PATCH | `/teams/{id}/strategy` | Unchanged; prefer `/strategy/{type}/{id}` |
| DELETE | `/teams/{id}/strategy` | Now requires `parent_id`+`parent_type` in body; `also_archive` replaces `?action=archive`; default is unlink |
| PUT | `/strategy/align` | NEW team-less align endpoint |
| PATCH | `/strategy/{objectType}/{objectId}` | NEW team-less update endpoint |
| DELETE | `/strategy/{objectType}/{objectId}` | NEW team-less detach endpoint |
