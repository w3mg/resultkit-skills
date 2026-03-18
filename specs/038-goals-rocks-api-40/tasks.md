# Tasks: Goals, Rocks & Milestones API Migration

**Input**: Design documents from `/specs/038-goals-rocks-api-40/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No project initialization needed — this is a migration of existing files. Verify current state.

- [x] T001 Read current Strategy section in api-reference.md (lines 567-611) and Glossary entries (lines 718-722) to confirm baseline
- [x] T002 Read current skills/strategy/SKILL.md to confirm all 5 flows that need updating (view, create, update, align, detach)

**Checkpoint**: Baseline understood — ready to begin edits

---

## Phase 2: User Story 1 - Update API Reference for New Endpoints (Priority: P1) 🎯 MVP

**Goal**: Replace the Strategy section in api-reference.md with the new Goals, Rocks & Milestones endpoints. Rename the read endpoint, remove 7 old mutation endpoints, add 14 new typed endpoints.

**Independent Test**: Read api-reference.md and confirm: (1) no references to old strategy mutation paths, (2) `GET /teams/{id}/targets` documented, (3) all 14 new endpoints present with correct field names (`type` not `goal_type`, `color` not `progress_color`), (4) EOS-only restriction noted.

### Implementation for User Story 1

- [x] T003 [US1] Rename `GET /teams/{id}/strategy` to `GET /teams/{id}/targets` in the endpoint table and all references in api-reference.md
- [x] T004 [US1] Remove all 7 strategy mutation endpoints from the endpoint table, mutation route aliases paragraph, and old create/align/delete request descriptions in api-reference.md (POST /teams/{id}/strategy, PATCH /strategy/{objectType}/{objectId}, DELETE /strategy/{objectType}/{objectId}, PUT /strategy/align, PUT /teams/{id}/strategy, PATCH /teams/{id}/strategy, DELETE /teams/{id}/strategy)
- [x] T005 [US1] Add Goals endpoints section (GET /teams/{id}/goals, POST /teams/{id}/goals, PATCH /goals/{id}, DELETE /goals/{id}) with query params, request bodies, and curl-verified response shapes in api-reference.md
- [x] T006 [US1] Add Rocks endpoints section (GET /teams/{id}/rocks, POST /teams/{id}/rocks, PUT /rocks/{id}, PATCH /rocks/{id}, DELETE /rocks/{id}) with query params, request bodies, and response shapes in api-reference.md
- [x] T007 [US1] Add Milestones endpoints section (GET /teams/{id}/milestones, POST /teams/{id}/milestones, PUT /milestones/{id}, PATCH /milestones/{id}, DELETE /milestones/{id}) with query params, request bodies, and response shapes in api-reference.md
- [x] T008 [US1] Document EOS-only restriction (422 for non-EOS teams) and milestone year/quarter filter bug with parent_id workaround in api-reference.md
- [x] T009 [US1] Update response envelopes section — replace old strategy envelopes with new goals/rocks/milestones envelopes in api-reference.md
- [x] T010 [US1] Verify and remove any references to old MCP tool names (`get_team_strategy`, `create_strategy_node`, `align_strategy_node`, `update_strategy_node`, `remove_strategy_node`) from api-reference.md and skills/strategy/SKILL.md (FR-012)

**Checkpoint**: api-reference.md Strategy section is fully migrated. Old endpoints gone, new endpoints documented.

---

## Phase 3: User Story 2 - Update Strategy Skill to Use New Endpoints (Priority: P1)

**Goal**: Update all 5 flows in skills/strategy/SKILL.md to call the new typed endpoints instead of the removed generic strategy endpoints.

**Independent Test**: Run each strategy operation against the live API: (1) view tree via GET /teams/{id}/targets, (2) create a goal/rock/milestone via typed POST, (3) update via typed PATCH, (4) align via typed PUT, (5) detach via PATCH with parent_id:null and archive via typed DELETE.

### Implementation for User Story 2

- [x] T011 [US2] Update View flow — change `GET /teams/$TEAM_ID/strategy` to `GET /teams/$TEAM_ID/targets` in skills/strategy/SKILL.md (Strategy Tree Fetch section, ~line 58)
- [x] T012 [US2] Redesign Create flow — replace single `POST /teams/$TEAM_ID/strategy` with type-routing logic: determine goal/rock/milestone from parent type or explicit user intent, call `POST /teams/$TEAM_ID/goals`, `/rocks`, or `/milestones` with correct request bodies per contracts in skills/strategy/SKILL.md (Flow: Create Strategy Object section, ~lines 204-248). Note: create-with-parent uses single POST with `parent_id` in body (not POST + separate PUT alignment). For milestones, MUST use `parent_id` filter when listing (FR-013: year/quarter filters have known bug).
- [x] T013 [US2] Redesign Update flow — replace `PATCH /strategy/$OBJECT_TYPE/$OBJECT_ID` with type-routing: map object_type to `PATCH /goals/{id}`, `PATCH /rocks/{id}`, or `PATCH /milestones/{id}` in skills/strategy/SKILL.md (Flow: Update Strategy Object section, ~lines 252-294)
- [x] T014 [US2] Redesign Align flow — replace `PUT /strategy/align` with `PUT /rocks/{id}` or `PUT /milestones/{id}` using only `{ "parent_id": PID }` in skills/strategy/SKILL.md (Flow: Align Strategy Object section, ~lines 298-338)
- [x] T015 [US2] Redesign Detach flow — split into two paths: (a) without --archive: PATCH to set parent_id to null (unlink), (b) with --archive: DELETE to archive. Replace old `DELETE /strategy/$OBJECT_TYPE/$OBJECT_ID` in skills/strategy/SKILL.md (Flow: Detach Strategy Object section, ~lines 342-384)
- [x] T016 [US2] Update Schemas section — replace old CreateResponse and response envelopes with new goal/rock/milestone response shapes using correct field names (type, color, no updated_at on milestones) in skills/strategy/SKILL.md (~lines 388-432)
- [x] T017 [US2] Add EOS-only error handling — add 422 "EOS teams only" message to error table and ensure mutation flows surface it clearly in skills/strategy/SKILL.md (Error Handling section, ~lines 436-457)

**Checkpoint**: skills/strategy/SKILL.md is fully migrated. All 5 flows use new typed endpoints.

---

## Phase 4: User Story 4 - Update User Phrase Mappings (Priority: P2)

**Goal**: Update the Glossary section in api-reference.md so natural-language commands about goals, rocks, and milestones route to the correct new endpoints.

**Independent Test**: Search api-reference.md Glossary for "goal", "rock", "milestone", "align", "detach" and confirm each maps to the correct new endpoint path.

### Implementation for User Story 4

- [x] T018 [US4] Replace strategy glossary entries (lines 718-722 in api-reference.md) with new entries: map "strategy tree/goals and rocks/OKRs" → `GET /teams/{id}/targets`, "create goal/add rock/add milestone" → typed POST endpoints, "update goal/rock/milestone" → typed PATCH endpoints, "align rock to goal/link milestone" → typed PUT endpoints, "detach/archive goal/rock/milestone" → typed PATCH (unlink) and DELETE (archive) endpoints
- [x] T019 [US4] Add new phrase entries for goals-specific terminology: "yearly goal", "annual goal", "1-year goal" → goals endpoints; "quarterly rock", "90-day priority" → rocks endpoints; "milestone", "deliverable" → milestones endpoints in api-reference.md Glossary

**Checkpoint**: Glossary entries cover all new typed endpoints and common natural-language phrases.

---

## Phase 5: User Story 3 - Sync Updated References to All Skills (Priority: P2)

**Goal**: Propagate the updated api-reference.md to all skill directories and bump the plugin version.

**Independent Test**: After sync, diff any `skills/*/references/api-reference.md` against the master — they should be identical. Plugin version should be incremented.

### Implementation for User Story 3

- [x] T020 [US3] Run `/sync-plugin` to copy master api-reference.md and scripts/api.sh to all skill directories and bump plugin version

**Checkpoint**: All ~40 skill copies of api-reference.md match master. Plugin version bumped.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and cleanup

- [x] T021 Verify GET /teams/{id}/targets returns expected response shape by calling the live API via scripts/api.sh
- [x] T022 Verify at least one typed create endpoint (POST /teams/{id}/goals) works against the live API via scripts/api.sh
- [x] T023 Verify the Pagination note in api-reference.md is updated if DELETE behavior changed (old: 204 No Content; new goals/rocks/milestones DELETE may return 200 with body)
- [x] T024 Confirm no remaining references to old strategy mutation paths (`/strategy/align`, `PATCH /strategy/`, `DELETE /strategy/`, `POST /teams/{id}/strategy`) in api-reference.md or skills/strategy/SKILL.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — read-only orientation
- **US1 (Phase 2)**: Depends on Setup — can start immediately after
- **US2 (Phase 3)**: Can start after Setup — edits a different file (SKILL.md) than US1 (api-reference.md)
- **US4 (Phase 4)**: Depends on US1 completion — same file (api-reference.md), different section (Glossary)
- **US3 (Phase 5)**: Depends on US1 + US4 — api-reference.md must be fully updated before sync
- **Polish (Phase 6)**: Depends on all story phases being complete

### User Story Dependencies

- **US1 (P1)**: No dependencies — can start after Setup
- **US2 (P1)**: No dependencies on US1 — edits different file. Can run in parallel with US1.
- **US4 (P2)**: Depends on US1 — same file, should run after US1 completes
- **US3 (P2)**: Depends on US1 + US4 — sync happens after all api-reference.md edits are done

### Within Each User Story

- US1: Sequential T003→T004→T005→T006→T007→T008→T009→T010 (all same file, same section; T010 repurposed for FR-012 MCP tool reference cleanup)
- US2: T011 first (view flow), then T012-T015 can proceed sequentially (same file), T016-T017 after flows complete
- US4: T018→T019 (same file section)
- US3: Single task T020

### Parallel Opportunities

- **US1 and US2 can run in parallel** — they edit different files (api-reference.md vs skills/strategy/SKILL.md)
- Within US1, tasks are sequential (same file section)
- Within US2, tasks are sequential (same file)

---

## Parallel Example: US1 + US2

```bash
# These two stories can be worked on simultaneously:
# Worker A: api-reference.md (US1 tasks T003-T010)
# Worker B: skills/strategy/SKILL.md (US2 tasks T011-T017)
```

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1: Setup (read current state)
2. Complete Phase 2: US1 (api-reference.md migration) — **in parallel with** Phase 3: US2 (SKILL.md migration)
3. **STOP and VALIDATE**: Verify endpoints via api.sh, confirm old paths are gone
4. Deploy/demo if ready — the skill is functional at this point

### Incremental Delivery

1. US1 (api-reference.md) → Reference is accurate
2. US2 (SKILL.md) → Skill is functional with new endpoints
3. US4 (Glossary) → Natural language routing works
4. US3 (Sync) → All skill copies updated
5. Polish → Final verification

---

## Notes

- US1 and US2 are both P1 and can run in parallel (different files)
- US3 (sync) is always last since it propagates api-reference.md changes
- No test tasks generated (not requested in spec)
- All edits are to existing files — no new files created
- Total: 24 tasks across 6 phases
- Commit after each phase checkpoint
