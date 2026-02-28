# Tasks: Rebuild Skills with Skill Creator & L10 Route Coverage

**Input**: Design documents from `/specs/016-rebuild-l10-skills/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Plugin skills**: `skills/{name}/SKILL.md` (entry point per skill)
- **Shared scripts**: `skills/{name}/scripts/api.sh` (synced from root `scripts/api.sh`)
- **References**: `skills/{name}/references/api-reference.md` (synced from root `api-reference.md`)
- **Plugin manifest**: `.claude-plugin/plugin.json`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ensure the new level10 skill directory has shared files in place

- [x] T001 Sync shared files (api.sh, api-reference.md) to all skill directories including skills/level10/ via `/sync-plugin`

---

## Phase 2: User Story 1 - Dedicated L10 Skill for EOS Teams (Priority: P1) 🎯 MVP

**Goal**: Create a new `rkit:level10` skill that provides a complete EOS Level 10 workflow — view/create to-dos, issues, and headlines via L10 routes, plus move/done/archive via generic fallback routes.

**Independent Test**: Invoke `/rkit:level10` against an EOS team. Verify it lists to-dos, issues, and headlines. Create a to-do, mark it done, add an issue, add a headline, archive the headline — all without leaving the skill.

### Implementation for User Story 1

- [x] T002 [US1] Use `/skill-creator` to create rkit:level10 skill using specs/016-rebuild-l10-skills/contracts/level10-interface.md as the interface contract and constitution.md as the rules — output to skills/level10/SKILL.md
- [x] T003 [US1] Run `/skill-creator` evals on rkit:level10 and iterate until passing — skills/level10/SKILL.md

**Checkpoint**: At this point, `/rkit:level10` should handle the full L10 workflow: view board (no args), view single section (todos/issues/headlines), create items (add todo/issue/headline), move items (move, done), and manage headlines (remove, update). Non-EOS teams should get a clear error.

---

## Phase 3: User Story 2 - Rebuild All Skills via Skill Creator (Priority: P2)

**Goal**: Process all 11 existing skills through `/skill-creator` to ensure consistent structure, quality, and Constitution Section X compliance. Each skill must maintain behavioral equivalence with its pre-rebuild version.

**Independent Test**: Run `/skill-creator` evals against each rebuilt skill. Invoke each skill with known inputs and verify equivalent output to the pre-rebuild version.

**Recommended order** (per research.md R4 — sequential for regression safety, but skills are independent and [P]-marked tasks CAN run in parallel):

### Implementation for User Story 2

- [x] T004 [P] [US2] Rebuild rkit:setup via `/skill-creator improve` — preserve all flows (first-time setup, reconfigure), run evals — skills/setup/SKILL.md
- [x] T005 [P] [US2] Rebuild rkit:teams via `/skill-creator improve` — preserve list teams and list members flows, run evals — skills/teams/SKILL.md
- [x] T006 [P] [US2] Rebuild rkit:today via `/skill-creator improve` — preserve all 6 tool routing flows, run evals — skills/today/SKILL.md
- [x] T007 [P] [US2] Rebuild rkit:board via `/skill-creator improve` — preserve view board, view column, move, add, remove flows, run evals — skills/board/SKILL.md
- [x] T008 [P] [US2] Rebuild rkit:1on1 via `/skill-creator improve` — preserve list, view detail, view column, move, add, remove flows, run evals — skills/1on1/SKILL.md
- [x] T009 [P] [US2] Rebuild rkit:projects via `/skill-creator improve` — preserve list, view columns, add item flows, run evals — skills/projects/SKILL.md
- [x] T010 [P] [US2] Rebuild rkit:result-feed via `/skill-creator improve` — preserve team feed viewer flow, run evals — skills/result-feed/SKILL.md
- [x] T011 [P] [US2] Rebuild rkit:result-update via `/skill-creator improve` — preserve all 5 tool routing flows, run evals — skills/result-update/SKILL.md
- [x] T012 [P] [US2] Rebuild rkit:braindump via `/skill-creator improve` — preserve parsing logic, output format, issue/to-do pairing, run evals — skills/braindump/SKILL.md

**Checkpoint**: All 9 skills above should pass Skill Creator evals and maintain behavioral equivalence with their pre-rebuild versions.

---

## Phase 4: User Story 3 - L10 Route Awareness in Existing Skills (Priority: P3)

**Goal**: Update `rkit:weekly` and `rkit:headlines` to use L10-specific API routes when the team framework is EOS, while preserving generic route behavior for non-EOS teams.

**Independent Test**: Invoke `/rkit:weekly` on an EOS team and verify it calls `/teams/{id}/l10/todos` (not `/teams/{id}/items/next`). Invoke on a non-EOS team and verify it still uses generic routes.

**Note**: These tasks also fulfill the US2 Skill Creator rebuild requirement for these 2 skills.

### Implementation for User Story 3

- [x] T013 [US3] Rebuild rkit:weekly via `/skill-creator improve` with L10 route awareness: when team framework is EOS, use `GET /teams/{id}/l10/todos` for To-Do column and `GET /teams/{id}/l10/issues` for Issues column. Preserve generic routes for non-EOS teams. Run evals — skills/weekly/SKILL.md
- [x] T014 [US3] Rebuild rkit:headlines via `/skill-creator improve` with L10 route awareness: when team framework is EOS, use `GET /teams/{id}/l10/headlines` for listing and `POST /teams/{id}/l10/headlines` for creating. Preserve generic routes for non-EOS teams. Run evals — skills/headlines/SKILL.md

**Checkpoint**: All 12 skills (11 rebuilt + 1 new) should now pass Skill Creator evals. `rkit:weekly` and `rkit:headlines` should use L10 routes for EOS teams.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final sync, version bump, and full verification

- [x] T015 Run `/sync-plugin` to ensure all shared files are current across all 12 skill directories
- [x] T016 Bump version in .claude-plugin/plugin.json
- [x] T017 Final verification: confirm all 12 skills pass Skill Creator evals and no regressions exist

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Setup (T001) — shared files must be synced to level10/
- **US2 (Phase 3)**: No dependency on US1 — can start after Setup or in parallel with US1
- **US3 (Phase 4)**: No dependency on US1 or US2 — can start after Setup or in parallel
- **Polish (Phase 5)**: Depends on ALL user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Depends only on T001 (sync). No dependency on US2 or US3.
- **User Story 2 (P2)**: Independent of US1 and US3. Each skill rebuild is independent of other rebuilds.
- **User Story 3 (P3)**: Independent of US1 and US2. Weekly and headlines rebuilds are independent of each other.

### Within Each User Story

- US1: T002 (create) → T003 (eval) — sequential
- US2: All 9 skill rebuilds are independent ([P]) — can run in parallel or sequentially per risk preference
- US3: T013 (weekly) and T014 (headlines) are independent ([P]-eligible) — can run in parallel

### Parallel Opportunities

- US1, US2, and US3 can all proceed in parallel after T001 (sync)
- Within US2, all 9 skill rebuilds are independent and can run in parallel
- Within US3, weekly and headlines rebuilds are independent
- Maximum parallelism: T002 + T004-T012 + T013-T014 all running simultaneously after T001

---

## Parallel Example: User Story 2

```bash
# All 9 skill rebuilds can launch in parallel (different SKILL.md files, no dependencies):
Task: "Rebuild rkit:setup via /skill-creator improve — skills/setup/SKILL.md"
Task: "Rebuild rkit:teams via /skill-creator improve — skills/teams/SKILL.md"
Task: "Rebuild rkit:today via /skill-creator improve — skills/today/SKILL.md"
Task: "Rebuild rkit:board via /skill-creator improve — skills/board/SKILL.md"
Task: "Rebuild rkit:1on1 via /skill-creator improve — skills/1on1/SKILL.md"
Task: "Rebuild rkit:projects via /skill-creator improve — skills/projects/SKILL.md"
Task: "Rebuild rkit:result-feed via /skill-creator improve — skills/result-feed/SKILL.md"
Task: "Rebuild rkit:result-update via /skill-creator improve — skills/result-update/SKILL.md"
Task: "Rebuild rkit:braindump via /skill-creator improve — skills/braindump/SKILL.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: User Story 1 (T002-T003)
3. **STOP and VALIDATE**: Test `/rkit:level10` on an EOS team — full workflow
4. Ship if ready — this alone delivers the new L10 skill

### Incremental Delivery

1. T001 (sync) → Foundation ready
2. T002-T003 (level10) → Test independently → Ship (MVP!)
3. T004-T012 (rebuild 9 skills) → Test each → Ship
4. T013-T014 (weekly + headlines with L10 routes) → Test → Ship
5. T015-T017 (polish) → Final verification → Ship

### Sequential Strategy (Recommended)

Given this is a single-developer plugin project:

1. T001 → sync
2. T002-T003 → create level10 (MVP)
3. T004 → rebuild setup (lowest risk, validates Skill Creator workflow)
4. T005-T012 → rebuild remaining 8 skills (increasing complexity)
5. T013-T014 → rebuild weekly + headlines with L10 routes
6. T015-T017 → polish, version bump, verify

---

## Notes

- [P] tasks = different files, no dependencies — CAN run in parallel
- Sequential order within US2 is RECOMMENDED (per research.md R4) for regression safety, but not technically required
- Each skill rebuild is a `/skill-creator improve` invocation — NOT manual editing
- US3 tasks (weekly, headlines) also satisfy the US2 rebuild requirement for those 2 skills
- Total skills: 12 (9 rebuild-only + 2 rebuild-with-L10 + 1 new)
- Commit after each phase or logical group of skill rebuilds
