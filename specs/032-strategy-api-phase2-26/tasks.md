# Tasks: Strategy API Phase 2 Update

**Input**: Design documents from `/specs/032-strategy-api-phase2-26/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Key context**: The `rkit:strategy` skill exists on `origin/001-strategy-skill` and is already Phase 2 compliant. Tasks focus on (1) integrating that skill into main, (2) documenting strategy endpoints in `api-reference.md`, and (3) verifying each user story acceptance scenario is met.

**Terminology note**: "Detach" (used in Phase 3 tasks) = the user-facing label for the unlink operation that issues a DELETE API call. The spec uses "Delete" and "remove" for the same action.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup — Integrate Strategy Skill

**Purpose**: Bring the strategy skill from `origin/001-strategy-skill` into this branch so all Phase 2 flows are available for verification.

- [x] T001 Cherry-pick `skills/strategy/` directory from `origin/001-strategy-skill` into `skills/strategy/` on this branch (use `git checkout origin/001-strategy-skill -- skills/strategy/`)

**Checkpoint**: `ls skills/strategy/SKILL.md` succeeds

---

## Phase 2: Foundational — API Reference and Plugin Manifest

**Purpose**: Document strategy endpoints and register the skill. These tasks MUST complete before any user story verification.

**⚠️ CRITICAL**: No user story verification can begin until this phase is complete.

- [x] T002 Add Strategy section to `api-reference.md` after the Teams section, documenting all 8 Phase 2 endpoints per `contracts/strategy-endpoints.md` — include: `GET /teams/{id}/strategy` (no `cascade`), `POST /teams/{id}/strategy` (no `object_type`, add `is_focus_area`), `PUT /strategy/align` (no `link_type`), `PATCH /strategy/{type}/{id}`, `DELETE /strategy/{type}/{id}` (requires `parent_id`+`parent_type` in body, `also_archive` replaces `?action=`), and note team-scoped equivalents
- [x] T003 [P] Add `strategy` skill entry to `.claude-plugin/plugin.json` skills list (following the same pattern as existing skills like `board`, `today`, `teams`) — satisfied by skills/strategy/ directory presence (plugin.json uses directory auto-discovery)

**Checkpoint**: `api-reference.md` contains a Strategy section; `plugin.json` lists the strategy skill

---

## Phase 3: User Story 1 — DELETE Strategy Object (Priority: P1) 🎯 MVP

**Goal**: Verify DELETE flow in `skills/strategy/SKILL.md` uses Phase 2 body params (`parent_id`, `parent_type`, `also_archive`) with no `?action=` query param.

**Independent Test**: Locate the Detach flow in SKILL.md — confirm `DELETE /strategy/$OBJECT_TYPE/$OBJECT_ID` call includes `parent_id`, `parent_type` in body JSON; confirm no `?action=` appears anywhere in the delete call; confirm `also_archive` is included only when `--archive` flag is set.

- [x] T004 [US1] Audit `skills/strategy/SKILL.md` "Flow: Detach Strategy Object" section — verify DELETE endpoint is `/strategy/$OBJECT_TYPE/$OBJECT_ID`, body includes `parent_id`, `parent_type`, `also_archive`, and no `?action=` param appears; fix if needed — PASS, no fix needed
- [x] T005 [US1] Verify inherited node guard in detach flow: confirm `inherited: true` check blocks detach with error message before reaching DELETE call in `skills/strategy/SKILL.md` — PASS, guard exists

**Checkpoint**: DELETE call in SKILL.md passes all Phase 2 requirements for US1

---

## Phase 4: User Story 2 — POST Without object_type (Priority: P2)

**Goal**: Verify POST flow in `skills/strategy/SKILL.md` omits `object_type` from the request body and includes `is_focus_area` when applicable.

**Independent Test**: Locate the Create flow in SKILL.md — confirm the POST body JSON does not contain `object_type`; confirm `is_focus_area` is included when `--focus-area` flag is set.

- [x] T006 [US2] Audit `skills/strategy/SKILL.md` "Flow: Create Strategy Object" section — verify POST body omits `object_type` entirely; verify `is_focus_area: true` is included when `--focus-area` flag is used; fix if needed — PASS, no fix needed

**Checkpoint**: POST call in SKILL.md passes Phase 2 requirements for US2

---

## Phase 5: User Story 3 — Align via Team-less Route (Priority: P3)

**Goal**: Verify PUT align flow uses `PUT /strategy/align` (team-less) without `link_type` in the body.

**Independent Test**: Locate the Align flow in SKILL.md — confirm endpoint is `/strategy/align` (not `/teams/$TEAM_ID/strategy`); confirm body contains `object_id`, `object_type`, `parent_id`, `parent_type` — no `link_type`.

- [x] T007 [US3] Audit `skills/strategy/SKILL.md` "Flow: Align Strategy Object" section — verify PUT endpoint is `/strategy/align`, body has no `link_type` field; fix if needed — PASS, no fix needed

**Checkpoint**: PUT call in SKILL.md passes Phase 2 requirements for US3

---

## Phase 6: User Story 4 — 4DX Hierarchy and Cascade Removal (Priority: P4)

**Goal**: Verify GET does not send `?cascade=`, and the skill handles `action` node type and `inherited` nodes without errors.

**Independent Test**: Locate the Tree Fetch and View flows in SKILL.md — confirm GET call has no `cascade` param; confirm `action` appears in Framework Label Mapping table; confirm inherited node display appends `[inherited from {team_name}]`.

- [x] T008 [US4] Audit `skills/strategy/SKILL.md` GET call in "Strategy Tree Fetch" section — confirm no `?cascade=` param is appended; fix if needed — PASS, no fix needed
- [x] T009 [P] [US4] Audit Framework Label Mapping table in SKILL.md — confirm `action` row exists covering 4DX L4 nodes; fix if needed — PASS, `action` row present
- [x] T010 [P] [US4] Audit View flow in SKILL.md — confirm `inherited: true` nodes display `[inherited from {team_name}]`; fix if needed — PASS, inherited display exists

**Checkpoint**: GET call and 4DX rendering in SKILL.md pass Phase 2 requirements for US4

---

## Phase 7: Polish & Distribution

**Purpose**: Propagate changes, sync skill copies, and prepare for release.

- [x] T011 Run `/sync-plugin` to copy updated `api-reference.md` to all skill `references/` directories including `skills/strategy/references/api-reference.md`
- [x] T012 [P] Bump plugin version in `.claude-plugin/plugin.json` (patch increment unless a minor/major bump is warranted) — bumped to 1.2.39
- [x] T013 Commit all changes (strategy skill files, api-reference.md, plugin.json, version bump) with message referencing issue #26
- [x] T014 Push branch `032-strategy-api-phase2-26` to origin and open PR against main — PR #28

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 (T001) — BLOCKS verification phases
- **Phase 3–6 (User Stories)**: All depend on Phase 2 completion; can run in parallel after Phase 2
- **Phase 7 (Polish)**: Depends on Phase 3–6 completion; T011 depends on T002 (api-reference.md updated)

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2 — verifies detach/DELETE flow
- **US2 (P2)**: Independent after Phase 2 — verifies create/POST flow
- **US3 (P3)**: Independent after Phase 2 — verifies align/PUT flow
- **US4 (P4)**: Independent after Phase 2 — verifies view/GET flow and 4DX rendering

### Parallel Opportunities

- T002 and T003 can run in parallel (different files)
- T004 and T005 are sequential (same SKILL.md section)
- T006 is independent of T004/T005 (different section of SKILL.md)
- T007 is independent of T004–T006 (different section of SKILL.md)
- T008, T009, T010 can run in parallel (different parts of SKILL.md)
- T011 and T012 can run in parallel (different files)

---

## Parallel Example: Phase 2

```bash
# Run in parallel (different files, no cross-dependencies):
Task: "Add Strategy section to api-reference.md" (T002)
Task: "Add strategy to plugin.json" (T003)
```

## Parallel Example: User Stories (after Phase 2)

```bash
# All four verification audits can run simultaneously:
Task: T004+T005 (US1 - DELETE/detach flow)
Task: T006 (US2 - POST/create flow)
Task: T007 (US3 - PUT/align flow)
Task: T008+T009+T010 (US4 - GET/view flow + 4DX)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Copy strategy skill (T001)
2. Complete Phase 2: api-reference.md + plugin.json (T002, T003)
3. Complete Phase 3: Verify DELETE/detach semantics (T004, T005)
4. **STOP and VALIDATE**: Detach flow confirmed Phase 2 compliant
5. Continue with remaining stories if time permits

### Incremental Delivery

1. Phase 1 + 2 → Strategy skill integrated, reference documented
2. Phase 3 (US1) → DELETE semantics verified ✅
3. Phase 4 (US2) → POST semantics verified ✅
4. Phase 5 (US3) → Align route verified ✅
5. Phase 6 (US4) → 4DX handling verified ✅
6. Phase 7 → Sync, version bump, ship

---

## Notes

- All audit tasks (T004–T010) are read-then-fix — read the SKILL.md section first, verify against the Phase 2 contract in `contracts/strategy-endpoints.md`, then fix in place if needed
- The strategy skill on `origin/001-strategy-skill` was authored against Phase 2; audits are expected to pass with no fixes needed, but must be explicitly confirmed
- Total tasks: 14
- Tests: None (not requested in spec)
- Suggested MVP scope: Phase 1 + Phase 2 + Phase 3 (US1) = T001–T005
