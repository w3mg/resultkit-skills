# Tasks: Update Skills to Reflect Latest Endpoints

**Input**: Design documents from `/specs/017-update-skill-endpoints/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, research.md, quickstart.md

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. Since US1–US4 all modify `skills/level10/SKILL.md`, tasks are sequenced to avoid conflicts within the file. US5 modifies a different file and can run in parallel.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No project setup needed — both target files already exist. This phase is a read-only orientation step.

- [x] T001 Read current `skills/level10/SKILL.md` to understand existing structure and patterns
- [x] T002 [P] Read current `skills/weekly/SKILL.md` to understand L10 Route Selection table

**Checkpoint**: Both files read, patterns understood. Ready to implement.

---

## Phase 2: User Story 1 — View and Manage L10 Parked Items (Priority: P1) + User Story 2 — View L10 Done Items (Priority: P1) 🎯 MVP

**Goal**: Add Parked and Done sections to the L10 board view, enable viewing them individually, and support parking items.

**Independent Test**: Run `/rkit:level10` and confirm 5 sections appear (To-Dos, Done, Issues, Parked, Headlines). Run `/rkit:level10 done` and `/rkit:level10 parked` to see individual sections. Run `/rkit:level10 move {id} parked` to park an item.

### Implementation

- [x] T003 [US1] [US2] Update Argument Parsing table in `skills/level10/SKILL.md` — add rows: `done` → View Done Only, `parked` → View Parked Only, `move {item_id} parked` → Move Item to Parked
- [x] T004 [US1] [US2] Update "Flow: View L10 Board" Step 1 in `skills/level10/SKILL.md` — add `DONE` and `PARKED` fetch calls using `GET /teams/TEAM_ID/l10/done` and `GET /teams/TEAM_ID/l10/parked` alongside existing TODOS/ISSUES/HEADLINES
- [x] T005 [US1] [US2] Update "Flow: View L10 Board" Step 2 display in `skills/level10/SKILL.md` — add Done section (after To-Dos) and Parked section (after Issues) with same table format (ID, Name, Creator, Due). New section order: To-Dos, Done, Issues, Parked, Headlines
- [x] T006 [US1] [US2] Update "Flow: View Single Section" in `skills/level10/SKILL.md` — add `done` and `parked` to the list of supported SECTION values alongside `todos`, `issues`, `headlines`
- [x] T007 [US1] Update "Flow: Move Item" in `skills/level10/SKILL.md` — add `parked` as a valid target that maps to API column `parked`, add status mapping `parked` → "Parked" for L10 terminology

**Checkpoint**: `/rkit:level10` shows 5 sections. `/rkit:level10 done` and `/rkit:level10 parked` work. `/rkit:level10 move {id} parked` parks an item.

---

## Phase 3: User Story 3 — Remove Items from L10 Board (Priority: P2)

**Goal**: Add ability to remove items from the L10 board without deleting them.

**Independent Test**: Run `/rkit:level10 remove {item_id}` to remove an item from the board. Verify item still exists via `/rkit:today` or API.

### Implementation

- [x] T008 [US3] Add `remove {item_id}` row to Argument Parsing table in `skills/level10/SKILL.md` mapping to "Remove from L10 Board" flow
- [x] T009 [US3] Add new "Flow: Remove from L10 Board" section in `skills/level10/SKILL.md` — Step 1: resolve team, run EOS gate, fetch item via `GET /items/ITEM_ID`, check `on_weekly` is true (else "Item {id} is not on the Level 10 board."); Step 2: confirm with user ("Remove **{item_name}** (ID: {item_id}) from the Level 10 board? Item will still exist."); Step 3: execute `DELETE /teams/TEAM_ID/l10/items/ITEM_ID`; Step 4: handle response (204 → success message, error → Error Handling)

**Checkpoint**: `/rkit:level10 remove {id}` works. Items removed from board but still accessible.

---

## Phase 4: User Story 4 — Use L10-Specific Routes for All L10 Operations (Priority: P2)

**Goal**: Switch all existing PUT routes in the L10 skill from generic to L10-specific.

**Independent Test**: Verify all PUT operations in `skills/level10/SKILL.md` use `/l10/` prefixed routes instead of `/items/` routes.

### Implementation

- [x] T010 [US4] Update "Flow: Mark Done" Step 3 in `skills/level10/SKILL.md` — change route from `PUT /teams/TEAM_ID/items/done/ITEM_ID` to `PUT /teams/TEAM_ID/l10/done/ITEM_ID`
- [x] T011 [US4] Update "Flow: Move Item" Step 3 in `skills/level10/SKILL.md` — change route from `PUT /teams/TEAM_ID/items/API_COLUMN/ITEM_ID` to use L10 routes: `todos` → `PUT /teams/TEAM_ID/l10/todos/ITEM_ID`, `issues` → `PUT /teams/TEAM_ID/l10/issues/ITEM_ID`, `parked` → `PUT /teams/TEAM_ID/l10/parked/ITEM_ID`

**Checkpoint**: All PUT operations in level10 SKILL.md use `/l10/` routes consistently.

---

## Phase 5: User Story 5 — Weekly Skill Uses L10 Routes for All EOS Columns (Priority: P3)

**Goal**: Update the weekly skill to use L10 routes for done and parked columns on EOS teams.

**Independent Test**: Verify `skills/weekly/SKILL.md` L10 Route Selection table has EOS routes for all 4 columns.

### Implementation

- [x] T012 [P] [US5] Update "L10 Route Selection" table in `skills/weekly/SKILL.md` — add EOS routes for done (`GET /teams/{id}/l10/done`) and parked (`GET /teams/{id}/l10/parked`)
- [x] T013 [P] [US5] Update "Flow: View Weekly" EOS bash example in `skills/weekly/SKILL.md` — change `DONE` from `/teams/TEAM_ID/items/done` to `/teams/TEAM_ID/l10/done` and `PARKED` from `/teams/TEAM_ID/items/parked` to `/teams/TEAM_ID/l10/parked`
- [x] T014 [P] [US5] Update "Flow: View Single Column" in `skills/weekly/SKILL.md` — expand the EOS conditional to include `done` and `parked` alongside `next` and `blocked` for L10 route selection

**Checkpoint**: Weekly skill uses L10 routes for all 4 columns on EOS teams.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, validation, and final sync.

- [x] T015 Update Edge Cases section in `skills/level10/SKILL.md` — add: parked section empty → "(empty)", already-parked item → "already in Parked", item not on L10 board (remove) → "not on the Level 10 board", done section overflow indicator
- [x] T016 Run `/sync-plugin` to propagate shared files and bump plugin version
- [x] T017 Validate all existing flows still work — spot-check create todo, create issue, create headline, mark done, move, archive headline, update headline in `skills/level10/SKILL.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — read-only
- **Phase 2 (US1+US2)**: Depends on Phase 1
- **Phase 3 (US3)**: Depends on Phase 2 (same file, Argument Parsing table already updated)
- **Phase 4 (US4)**: Depends on Phase 2 (Move Item flow must exist with parked target before switching routes)
- **Phase 5 (US5)**: Can run in parallel with Phases 2–4 (different file)
- **Phase 6 (Polish)**: Depends on all prior phases

### User Story Dependencies

- **US1+US2 (P1)**: No dependencies on other stories — start first
- **US3 (P2)**: No dependency on US1/US2 conceptually, but same file — sequence after
- **US4 (P2)**: No dependency on US3 — sequence after US1/US2 since it modifies Move Item flow
- **US5 (P3)**: Independent file — can run in parallel with US1–US4

### Parallel Opportunities

- T001 and T002 can run in parallel (different files)
- T012, T013, T014 (US5) can run in parallel with any level10 task (different file)
- Within US5, T012/T013/T014 modify different sections of the same file — execute sequentially

---

## Parallel Example: US5 alongside US1+US2

```text
# These can run simultaneously since they modify different files:

# Stream A (level10/SKILL.md):
T003 → T004 → T005 → T006 → T007

# Stream B (weekly/SKILL.md):
T012 → T013 → T014
```

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1: Read both files
2. Complete Phase 2: Add Done + Parked to L10 board
3. **STOP and VALIDATE**: `/rkit:level10` shows 5 sections, individual views work, park works
4. Ship if ready — this alone closes the biggest gap

### Incremental Delivery

1. US1+US2 → 5-section L10 board (MVP)
2. US3 → Remove from board
3. US4 → Consistent L10 routes
4. US5 → Weekly L10 route consistency
5. Polish → Edge cases, sync, validation

### Recommended: Single Pass

Since all US1–US4 modify the same file and the total change is modest (~100 lines of Markdown), the most efficient approach is a single editing pass through `skills/level10/SKILL.md` covering all 4 stories, then a separate pass for `skills/weekly/SKILL.md` (US5). Use `/skill-creator` to build and validate each skill.

---

## Notes

- All tasks modify Markdown (SKILL.md) — no compiled code, no build step
- [P] tasks target different files, no conflicts
- Tasks without [P] modify the same file sequentially
- Use `/skill-creator` skill to build/modify each skill per the user's request
- Commit after each phase checkpoint for incremental delivery
- Run `/sync-plugin` after all edits to propagate shared files
