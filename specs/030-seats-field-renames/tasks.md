# Tasks: V2 Seat API Field Renames

**Input**: Design documents from `/specs/030-seats-field-renames/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to

---

## Phase 1: Setup

**Purpose**: Verify current state and confirm which edits are needed.

- [ ] T001 Confirm old field names present in `skills/seats/SKILL.md` (grep for `group_id`, `accountability_owner_id`, Owner column in Direct Reports table)
- [ ] T002 [P] Confirm old field names present in master `api-reference.md` (grep for `group_id` in seat rows, `accountability_owner_id`)

---

## Phase 2: Foundational — Update API Reference

**Purpose**: Update the shared reference doc that all skills depend on. Must complete before Polish/sync step.

**⚠️ CRITICAL**: Update the master `api-reference.md` at the repo root — never edit the copy inside `skills/seats/references/` directly. The copy is updated via sync-plugin in the Polish phase.

- [ ] T003 Update POST /seats description in `api-reference.md`: replace `group_id or parent_id` with `team_id or parent_id`, replace `accountability_owner_id?` with `seat_owner_id?`
- [ ] T004 Update PATCH /seats/{id} description in `api-reference.md`: replace `accountability_owner_id?` with `seat_owner_id?`
- [ ] T005 Update terminology table entry in `api-reference.md` (line ~635): replace `accountability_owner_id` with `seat_owner_id` in the seat owner row

**Checkpoint**: api-reference.md no longer mentions old seat input field names

---

## Phase 3: User Story 1 — Create a Seat Without Errors (Priority: P1) 🎯 MVP

**Goal**: Fix the Create Seat flow so root seat creation uses `team_id` instead of `group_id`.

**Independent Test**: Run `/rkit:seats create "Test" --team {id}` — seat should be created without a 422 error.

- [ ] T006 [US1] Fix Create Seat root body in `skills/seats/SKILL.md` — Flow: Create Seat → Step 4 → Root seat bash block: change `"group_id":TEAM_ID` to `"team_id":TEAM_ID`

**Checkpoint**: Creating a root seat no longer returns 422 "group_id is not allowed"

---

## Phase 4: User Story 2 — View Seat Details With Correct Fields (Priority: P2)

**Goal**: Fix the Direct Reports table so it no longer shows an Owner column that children don't carry.

**Independent Test**: Run `/rkit:seats {id}` on a seat with children — Direct Reports shows ID and Name columns only.

- [ ] T007 [US2] Fix Direct Reports table in `skills/seats/SKILL.md` — Flow: View Seat Details → Step 3: replace three-column table header `| ID | Name | Owner |` and row `| {id} | {name} | {owner or Vacant} |` with two-column versions `| ID | Name |` and `| {id} | {name} |`

**Checkpoint**: Seat detail view renders Direct Reports with ID and Name only; no broken Owner column

---

## Phase 5: User Story 3 — Update a Seat Without Errors (Priority: P3)

**Goal**: Fix the Update Seat flow so the `--owner` flag maps to `seat_owner_id` instead of `accountability_owner_id`.

**Independent Test**: Run `/rkit:seats update {id} --owner {uid}` — update should succeed without a 422 error.

- [ ] T008 [US3] Fix Update Seat `--owner` mapping in `skills/seats/SKILL.md` — Flow: Update Seat → Step 2 → Build PATCH body table: change `"accountability_owner_id": {uid}` to `"seat_owner_id": {uid}`

**Checkpoint**: Updating a seat's owner no longer returns 422 "accountability_owner_id is not allowed"

---

## Phase 6: Polish & Sync

**Purpose**: Propagate api-reference.md changes to all skills and ship.

- [ ] T009 Run `/sync-plugin` to copy master `api-reference.md` to `skills/seats/references/api-reference.md` and bump plugin version
- [ ] T010 Verify no remaining old field names in seats skill: grep `skills/seats/SKILL.md` for `group_id`, `accountability_owner_id` — expect zero matches
- [ ] T011 [P] Verify no remaining old field names in `skills/seats/references/api-reference.md` for seat rows — expect zero matches
- [ ] T012 Commit all changes and push; close GitHub issue #20

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: No hard dependency on Phase 1 (verification is optional) — but run before Polish
- **User Story phases (3–5)**: Independent of each other and of Phase 2 — all three SKILL.md edits touch different sections
- **Polish (Phase 6)**: Depends on Phases 2–5 all complete

### User Story Dependencies

- **US1 (P1)**: Independent — edit Create Seat section only
- **US2 (P2)**: Independent — edit View Seat Details section only
- **US3 (P3)**: Independent — edit Update Seat section only

All three story tasks (T006, T007, T008) edit different sections of SKILL.md and can be completed in any order.

### Parallel Opportunities

- T001 and T002 can run in parallel (different files)
- T003, T004, T005 can run in parallel (different lines in same file — apply as one edit pass)
- T006, T007, T008 can run in parallel (different sections of SKILL.md)
- T010 and T011 can run in parallel

---

## Parallel Example: SKILL.md Edits

```bash
# All three SKILL.md edits are independent sections — apply together:
Task: "T006 — Fix Create Seat root body (group_id → team_id)"
Task: "T007 — Fix Direct Reports table (remove Owner column)"
Task: "T008 — Fix Update Seat --owner mapping (accountability_owner_id → seat_owner_id)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only — T006)

1. Apply T006 (one-line edit to SKILL.md)
2. Test: `/rkit:seats create "Test" --team {id}` — no 422 error
3. Ship if urgent

### Full Fix (All Stories — Recommended)

1. Phase 1: Verify (T001, T002) — optional but fast
2. Phase 2: Update api-reference.md (T003–T005) — one edit pass
3. Phases 3–5: Apply all three SKILL.md edits (T006–T008) — one edit pass
4. Phase 6: Sync, verify, commit (T009–T012)

Total: ~6 targeted edits across 2 files + sync.

---

## Notes

- All edits are to `skills/seats/SKILL.md` and master `api-reference.md` only
- Never edit `skills/seats/references/api-reference.md` directly — sync-plugin manages it
- No new functionality is added; this is a compatibility fix only
- Old field names return 422 from the live API — this is a production breakage
