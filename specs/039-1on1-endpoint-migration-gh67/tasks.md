# Tasks: Update rkit:1on1 Skill to New API Endpoints

**Input**: Design documents from `specs/039-1on1-endpoint-migration-gh67/`
**Branch**: `039-1on1-endpoint-migration-gh67`
**GitHub Issue**: #67

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- No test tasks (not requested in spec)

---

## Phase 1: Setup (API Verification)

**Purpose**: Verify live API endpoint shapes before writing any skill logic — required by CLAUDE.md rules.

- [ ] T001 Call `scripts/api.sh GET "/1-on-1?per_page=5"` and confirm envelope matches old `/meetings` shape (`data[]` with `id`, `type`, `persons`)
- [ ] T002 Call `scripts/api.sh GET "/1-on-1/MEETING_ID"` and confirm response includes `persons`, `items.done/next/blocked`, and `notes` fields
- [ ] T003 [P] Call `scripts/api.sh GET "/1-on-1/MEETING_ID/items/next?per_page=10"` and confirm section items response shape
- [ ] T004 [P] Call `scripts/api.sh PUT "/1-on-1/MEETING_ID/notes" '{"notes":"test"}'` and confirm request body field name and success response
- [ ] T005 [P] Call `scripts/api.sh POST "/1-on-1/MEETING_ID/items" '{"name":"Test"}'` and confirm 201 response with item shape
- [ ] T006 Document any response shape differences from the old `/meetings` endpoints in `specs/039-1on1-endpoint-migration-gh67/research.md`

**Checkpoint**: All new endpoint shapes confirmed — safe to begin implementation.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Read and understand the current SKILL.md fully before making any changes.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T007 Read `skills/1on1/SKILL.md` in full and inventory every occurrence of `/meetings` (list, detail, view column, add item, attach item, remove item flows)
- [ ] T008 Read `api-reference.md` (master) and locate the `/meetings` section to understand what needs replacing

**Checkpoint**: Codebase fully understood — implementation can begin.

---

## Phase 3: User Story 1 - Fix Core Endpoint Paths (Priority: P1) 🎯 MVP

**Goal**: Replace all `/meetings/...` calls with `/1-on-1/...` in `skills/1on1/SKILL.md` so every existing flow works again.

**Independent Test**: Run `/rkit:1on1` — should list one-on-ones without error. Run `/rkit:1on1 {id}` — should show meeting detail with next/done/blocked columns.

### Implementation for User Story 1

- [ ] T009 [US1] In `skills/1on1/SKILL.md` Flow "List One-on-Ones": replace `GET "/meetings?team_id=TEAM_ID&per_page=100"` with `GET "/1-on-1?team_id=TEAM_ID&per_page=100"` and `GET "/meetings?per_page=100"` with `GET "/1-on-1?per_page=100"`
- [ ] T010 [US1] In `skills/1on1/SKILL.md` Flow "View One-on-One Detail": replace `GET "/meetings/MEETING_ID"` with `GET "/1-on-1/MEETING_ID"`
- [ ] T011 [US1] In `skills/1on1/SKILL.md` Flow "View Single Column": replace `GET "/meetings/MEETING_ID/items/COLUMN?per_page=50"` with `GET "/1-on-1/MEETING_ID/items/COLUMN?per_page=50"`
- [ ] T012 [US1] In `skills/1on1/SKILL.md` Flow "Add Item — new item": replace `POST "/meetings/MEETING_ID/items"` with `POST "/1-on-1/MEETING_ID/items"`
- [ ] T013 [US1] In `skills/1on1/SKILL.md` Flow "Add Item — existing item": replace `PUT "/meetings/MEETING_ID/items/ITEM_ID"` with `PUT "/1-on-1/MEETING_ID/items/ITEM_ID"`
- [ ] T014 [US1] In `skills/1on1/SKILL.md` Flow "Remove Item": replace `DELETE "/meetings/MEETING_ID/items/ITEM_ID"` with `DELETE "/1-on-1/MEETING_ID/items/ITEM_ID"`
- [ ] T015 [US1] Grep `skills/1on1/SKILL.md` for any remaining `/meetings` strings and fix any missed occurrences
- [ ] T016 [US1] Update error message in Edge Cases section of `skills/1on1/SKILL.md`: "Meeting {id} not found" remains valid but confirm wording is still appropriate

**Checkpoint**: All core flows use `/1-on-1/...`. User Story 1 is fully functional.

---

## Phase 4: User Story 2 - Save Notes Flow (Priority: P2)

**Goal**: Add a `notes` subcommand to the skill so users can save notes to a 1:1 meeting via `PUT /1-on-1/{id}/notes`.

**Independent Test**: Run `/rkit:1on1 {id} notes "My notes"` — skill should confirm, then save and report success.

### Implementation for User Story 2

- [ ] T017 [US2] In `skills/1on1/SKILL.md` Argument Parsing table: add row `| {meeting_id} notes "text" | Save Notes |`
- [ ] T018 [US2] In `skills/1on1/SKILL.md`: add new section `## Flow: Save Notes` after the Remove Item section with:
  - Trigger: `{meeting_id} notes "text"`
  - Confirmation prompt: "Save notes to one-on-one {id}? (This will overwrite existing notes.)"
  - API call: `"$API_SH" PUT "/1-on-1/MEETING_ID/notes" "{\"notes\":\"TEXT\"}"`
  - Success: "Notes saved to one-on-one {id}."
  - Error handling: use standard Error Handling section
- [ ] T019 [US2] In `skills/1on1/SKILL.md` Edge Cases section: add entry "Empty notes text → warn and do not submit"

**Checkpoint**: Notes flow works end-to-end. User Story 2 independently functional.

---

## Phase 5: User Story 3 - Done Items with Date Filter (Priority: P3)

**Goal**: Add support for fetching done items via `GET /1-on-1/{id}/done` with optional date filter.

**Independent Test**: Run `/rkit:1on1 {id} done` — should return done items from the dedicated endpoint.

### Implementation for User Story 3

- [ ] T020 [US3] In `skills/1on1/SKILL.md` Argument Parsing table: add row `| {meeting_id} done [--since DATE] | View Done Items (filtered) |`
- [ ] T021 [US3] In `skills/1on1/SKILL.md`: add new section `## Flow: Done Items with Date Filter` with:
  - Trigger: `{meeting_id} done` or `{meeting_id} done --since YYYY-MM-DD`
  - API call (no filter): `"$API_SH" GET "/1-on-1/MEETING_ID/done?per_page=50"`
  - API call (with date): `"$API_SH" GET "/1-on-1/MEETING_ID/done?since=DATE&per_page=50"` (confirm param name from API verification)
  - Display: same table format as single column view (ID, Name, Creator, Due)

**Checkpoint**: Done items flow works with and without date filter.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Update the shared API reference, sync to all skills, and ship.

- [ ] T022 In `api-reference.md` (master): replace the `/meetings` section (currently documenting 7 endpoints) with a `/1-on-1` section documenting all 17 endpoints from the API handoff (GET list, POST find-or-create, GET fetch, GET detail, GET items, POST items, GET done, PUT notes, PUT notes-lock, POST align, POST unalign, POST set-positions, POST assistants, GET attachments, POST attachments, DELETE attachments, GET goals, GET measures)
- [ ] T023 In `api-reference.md` (master) glossary mapping section: update `meeting, 1:1, one-on-one` → points to `/1-on-1` (not `/meetings`)
- [ ] T024 Run `/sync-plugin` to copy updated `api-reference.md` to all `skills/*/references/api-reference.md` copies and bump plugin version
- [ ] T025 [P] Grep entire repo (excluding `specs/` historical docs) for any remaining `/meetings` references in active skill files — fix any found
- [ ] T026 Verify `.claude-plugin/plugin.json` version was bumped by `/sync-plugin`; if not, bump patch version manually
- [ ] T027 Commit all changes: `git add skills/1on1/SKILL.md api-reference.md skills/*/references/api-reference.md .claude-plugin/plugin.json && git commit -m "Fix #67: Migrate rkit:1on1 skill from /meetings to /1-on-1 endpoints, add notes flow"`
- [ ] T028 Push branch: `git push origin 039-1on1-endpoint-migration-gh67`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: No dependencies — can run in parallel with Phase 1
- **US1 (Phase 3)**: Depends on Phase 1 (API shapes verified) + Phase 2 (files read)
- **US2 (Phase 4)**: Depends on US1 complete (notes flow added to same file)
- **US3 (Phase 5)**: Depends on US2 complete (same file, sequential edits safer)
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Unblocked after Phase 1+2 — no story dependencies
- **US2 (P2)**: Depends on US1 (same SKILL.md file; implement sequentially to avoid conflicts)
- **US3 (P3)**: Depends on US2 (same SKILL.md file)

### Parallel Opportunities

- T003, T004, T005 can run in parallel with T001/T002 (different endpoints)
- T007 and T008 can run in parallel (different files)
- T009–T014 can be done in a single editing pass of SKILL.md (one file, sequential)
- T022 and T025 can run in parallel (different files)

---

## Parallel Example: Phase 1

```bash
# Launch all API verification calls together:
Task: "Verify GET /1-on-1 list shape (T001)"
Task: "Verify GET /1-on-1/{id} detail shape (T002)"
Task: "Verify GET /1-on-1/{id}/items/next shape (T003)"
Task: "Verify PUT /1-on-1/{id}/notes shape (T004)"
Task: "Verify POST /1-on-1/{id}/items shape (T005)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: API verification
2. Complete Phase 2: Read codebase
3. Complete Phase 3: Fix all /meetings → /1-on-1 paths
4. **STOP and VALIDATE**: Test list, detail, add, remove, move flows
5. Ship as emergency fix — restores broken functionality

### Incremental Delivery

1. Setup + Foundational → codebase understood
2. US1: Fix paths → all existing flows restored (MVP)
3. US2: Add notes → new notes capability
4. US3: Add done filter → done items date filtering
5. Polish: Update docs, sync, ship

### Notes

- Edit `skills/1on1/SKILL.md` in a single session (avoid merge conflicts from concurrent edits)
- Verify each API call in Phase 1 before writing the corresponding skill logic
- The `/sync-plugin` command handles propagation to all skill copies — do not edit copies directly
- Commit message must reference `Fix #67` so the issue can be auto-closed
