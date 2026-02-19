# Tasks: Board Summary View

**Input**: Design documents from `/specs/010-board-summary-view/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Not requested. Manual validation via quickstart.md.

**Organization**: Single file change — tasks are sequential steps modifying `skills/rkit/board/SKILL.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to

---

## Phase 1: Setup

**Purpose**: No setup needed. This modifies an existing skill file.

(No tasks)

---

## Phase 2: Foundational

**Purpose**: No foundational work. Same API calls, same data, same dependencies.

(No tasks)

---

## Phase 3: User Story 1 + 2 — Board Summary + Drill Into One Column (Priority: P1)

**Goal**: View Board shows a summary table first (column name, ID, item count), then asks user whether to drill into one column, all columns, or none. Selecting one column shows only that column's items.

**Independent Test**: Run `/rkit:board {id}` — summary table appears first. Pick one column — only that column's items shown.

### Implementation

- [ ] T001 [US1] Replace Step 2 ("Apply column cap and fetch column items") in `skills/rkit/board/SKILL.md` — keep the same fetch logic but after collecting all column data, add a new Step 3 that displays a summary table showing row number, column name, column ID, and item count (length of fetched data array or meta.total if overflow)
- [ ] T002 [US1] Add Step 4 to `skills/rkit/board/SKILL.md` — after summary table, use AskUserQuestion to ask "View full item details?" with options: "All columns", "Pick one", "None"
- [ ] T003 [US2] Add "Pick one" handling in Step 4 of `skills/rkit/board/SKILL.md` — when user selects "Pick one", ask which column (by row number, name, or ID using same matching logic as View Single Column flow), then display only that column's items using existing detail format
- [ ] T004 [US1] Update Step 5 display rules in `skills/rkit/board/SKILL.md` — "All columns" shows full detail for every column (same as current behavior), "None" ends the flow

**Checkpoint**: Summary table displays, user can pick one column or all. View Single Column, Move, Add, Remove flows unchanged.

---

## Phase 4: User Story 3 — Drill Into All Columns (Priority: P2)

**Goal**: Selecting "All columns" displays full item details for every column.

**Independent Test**: Run `/rkit:board {id}`, pick "All columns" — all column items shown.

### Implementation

(Covered by T004 — "All columns" reuses the existing full display logic. No separate task needed.)

**Checkpoint**: All three options work.

---

## Phase 5: User Story 4 — Skip Detail (Priority: P3)

**Goal**: Selecting "None" ends the flow cleanly.

**Independent Test**: Run `/rkit:board {id}`, pick "None" — no item detail shown.

### Implementation

(Covered by T004 — "None" simply ends the flow. No separate task needed.)

**Checkpoint**: All options work.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T005 Reinstall skill by running `scripts/install.sh` to update `~/.claude/skills/rkit:board/SKILL.md`
- [ ] T006 Run quickstart.md validation — invoke `/rkit:board` against a real board and verify summary table, drill-in prompt, and detail display all work correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **T001**: No dependencies — starts immediately
- **T002**: Depends on T001 (summary must exist before prompt)
- **T003**: Depends on T002 (prompt must exist before "pick one" handling)
- **T004**: Depends on T002 (prompt must exist before "all/none" handling)
- **T005**: Depends on T001–T004 (all SKILL.md changes complete)
- **T006**: Depends on T005 (skill must be installed)

### Parallel Opportunities

- T003 and T004 can be written in parallel (both extend Step 4, different branches of the prompt)
- In practice, all changes are in one file section so sequential is simplest

---

## Implementation Strategy

### MVP First (T001–T002)

1. T001: Summary table displays after fetch
2. T002: Prompt appears after summary
3. **STOP and VALIDATE**: Summary shows, prompt works

### Complete (T001–T006)

1. T001–T004: All SKILL.md changes
2. T005: Reinstall
3. T006: End-to-end validation

---

## Notes

- All changes are in one section of one file: "Flow: View Board" in `skills/rkit/board/SKILL.md`
- Total tasks: 6 (4 implementation + 1 install + 1 validation)
- No new files, no new API calls, no config changes
