# Tasks: rkit:board

**Input**: Design documents from `/specs/003-board/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. All implementation happens in a single file (`skills/rkit/board/SKILL.md`) following the established Claude Code skill pattern from rkit:today.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- All SKILL.md tasks are sequential within a phase (same file)

## Phase 1: Setup

**Purpose**: Create skill directory structure and reference files

- [X] T001 Create directory structure: `skills/rkit/board/` and `skills/rkit/board/references/`
- [X] T002 Copy API reference to `skills/rkit/board/references/api-reference.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: SKILL.md skeleton with shared infrastructure used by all flows

**CRITICAL**: No user story flows can be written until this phase is complete

- [X] T003 Create `skills/rkit/board/SKILL.md` with frontmatter (name, description, disable-model-invocation, user-invocable, allowed-tools), title, and Current State section (config check + api.sh path resolution) — follow rkit:today pattern
- [X] T004 Write Rules section in `skills/rkit/board/SKILL.md` — confirm writes, show IDs, concise output, direct execution (same as rkit:today)
- [X] T005 Write Argument Parsing table in `skills/rkit/board/SKILL.md` mapping input patterns to flows: (no args) → View Board, `{id}` → View Board, `{id} {column}` → View Single Column, `move {item_id} {target_id}` → Move, `add {board_id} ...` → Add, `remove {item_id}` → Remove
- [X] T006 Write Board ID Resolution section in `skills/rkit/board/SKILL.md` — shared logic for resolving board ID from args, `default_board_id` config (integer, `"ask"`, or absent), and user prompt fallback per FR-009/FR-010
- [X] T007 Write shared error handling section in `skills/rkit/board/SKILL.md` — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 404, 422 patterns (same as rkit:today)

**Checkpoint**: SKILL.md skeleton complete — all shared infrastructure in place

---

## Phase 3: User Story 1 — View Item as Board (Priority: P1) MVP

**Goal**: User can run `/rkit:board {id}` or `/rkit:board` and see an item's children rendered as columns with their items underneath.

**Independent Test**: Run `/rkit:board {known_item_id}` and verify columns display with item names, IDs, statuses, and due dates in table format.

### Implementation for User Story 1

- [X] T008 [US1] Write Flow: View Board — Step 1 in `skills/rkit/board/SKILL.md`: Resolve board ID (use Board ID Resolution), fetch columns via `GET /items/{board_id}/children?per_page=50`, handle no-children edge case ("No children found for item {id}.")
- [X] T009 [US1] Write Flow: View Board — Step 2 in `skills/rkit/board/SKILL.md`: Apply 10-column cap (FR-008), show "(N more columns not shown)" if exceeded. For each column (up to 10), fetch children via `GET /items/{column_id}/children?per_page=50`
- [X] T010 [US1] Write Flow: View Board — Step 3 in `skills/rkit/board/SKILL.md`: Display board as formatted output. Each column header shows name and ID (FR-002). Each item shows name, ID, status, due date (FR-003). Empty columns show "(empty)". Columns with >50 items show "(N more...)" per FR-006

**Checkpoint**: `/rkit:board {id}` renders a full board view. MVP complete.

---

## Phase 4: User Story 2 — View Single Column (Priority: P2)

**Goal**: User can run `/rkit:board {id} {column_name_or_id}` to see just one column and its items.

**Independent Test**: Run `/rkit:board {board_id} {column_name}` and verify only that column's items are shown.

### Implementation for User Story 2

- [X] T011 [US2] Write Flow: View Single Column in `skills/rkit/board/SKILL.md`: Fetch columns, match by ID (numeric) or case-insensitive substring match on name (per research R4). If no match, show "No column matching '{input}' on board {id}." with available column list. If multiple name matches, list with IDs and ask user to pick; suggest renaming one. Then fetch and display that column's items using same format as US1 single-column output

**Checkpoint**: Single-column view works with name and ID matching.

---

## Phase 5: User Story 3 — Move Item Between Columns (Priority: P2)

**Goal**: User can run `/rkit:board move {item_id} {target_column_id}` to re-parent an item under a different column.

**Independent Test**: Run `/rkit:board move {item_id} {target_id}`, confirm the action, and verify the item's parent changes.

### Implementation for User Story 3

- [X] T012 [US3] Write Flow: Move Item in `skills/rkit/board/SKILL.md`: Validate item exists (`GET /items/{item_id}`), validate target column exists (`GET /items/{target_id}`). If item already under target column, warn and skip. Otherwise describe move and confirm with user. Execute via `PUT /items/{item_id}/move` with `{"parent_id": {target_id}}`. Show confirmation with item name and new column name

**Checkpoint**: Move between columns works with validation and confirmation.

---

## Phase 6: User Story 5 — Remove Item from Column (Priority: P2)

**Goal**: User can run `/rkit:board remove {item_id}` and choose where the item goes — orphan it, move to another project, or move to a one-on-one/other source.

**Independent Test**: Run `/rkit:board remove {item_id}`, select "remove from all projects", verify orphan + day plan offer.

### Implementation for User Story 5

- [X] T013 [US5] Write Flow: Remove Item — Step 1 in `skills/rkit/board/SKILL.md`: Resolve board ID via Board ID Resolution (same as view/add). Validate item exists (`GET /items/{item_id}`), fetch board columns (`GET /items/{board_id}/children`), check item's parent_id matches a column ID. If not, warn "Item {id} is not on this board."
- [X] T014 [US5] Write Flow: Remove Item — Step 2 in `skills/rkit/board/SKILL.md`: Prompt user with options: (1) "Remove from all projects" (2) "Move to another project" (3) "Move to a one-on-one or other source". Present as friendly choices per FR-013 — no mention of "orphan"
- [X] T015 [US5] Write Flow: Remove Item — Step 3 in `skills/rkit/board/SKILL.md`: Execute chosen option. Option 1: `PUT /items/{id}/move` with `{"parent_id": null}`, then ask if user wants it on their day plan — if yes, `PUT /day-plans/today/items/{item_id}` (FR-012). Options 2/3: prompt for target parent ID, then `PUT /items/{id}/move` with `{"parent_id": {target_id}}`. Confirm with user before executing. Show confirmation

**Checkpoint**: Remove flow works with all three destination options and day plan offer.

---

## Phase 7: User Story 4 — Add Item to Column (Priority: P3)

**Goal**: User can run `/rkit:board add {board_id} {column_id} "name"` to create an item in a column, or omit column to be prompted.

**Independent Test**: Run `/rkit:board add {board_id} "task name"`, pick a column, confirm, verify item created.

### Implementation for User Story 4

- [X] T016 [US4] Write Flow: Add Item in `skills/rkit/board/SKILL.md`: Parse args — if column_id provided, use it; if not, fetch columns via `GET /items/{board_id}/children?per_page=50` and prompt user to pick (FR-007). Describe action and confirm. Execute via `POST /items` with `{"name": "...", "parent_id": {column_id}}`. Show confirmation with new item ID

**Checkpoint**: Add item works with column picker and direct column specification.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final edge cases and references

- [X] T017 Write Edge Cases section in `skills/rkit/board/SKILL.md` — consolidate all edge cases: item not found (404), no config (prompt /rkit:setup), api.sh not found, duplicate column names, pagination overflow
- [X] T018 Write References section in `skills/rkit/board/SKILL.md` — link to `references/api-reference.md`
- [X] T019 Run `scripts/install.sh` and verify `rkit:board` installs correctly to `~/.claude/skills/rkit:board/` with api.sh in scripts/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — MVP, must complete first
- **US2 (Phase 4)**: Depends on Phase 3 (reuses board view display format)
- **US3 (Phase 5)**: Depends on Phase 2 only — can parallel with US2
- **US5 (Phase 6)**: Depends on Phase 2 only — can parallel with US2/US3
- **US4 (Phase 7)**: Depends on Phase 2 only — can parallel with others
- **Polish (Phase 8)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Foundation only — MVP
- **US2 (P2)**: Foundation + US1 display format (sequential after US1)
- **US3 (P2)**: Foundation only — independent of other stories
- **US5 (P2)**: Foundation only — independent of other stories
- **US4 (P3)**: Foundation only — independent of other stories

### Within Each User Story

All tasks are sequential (single file: SKILL.md). No [P] parallelism within phases.

### Parallel Opportunities

- After Phase 2 completes: US3, US5, and US4 can theoretically be written in parallel (independent flows in same file — in practice sequential due to single-file constraint)
- T001 and T002 in Setup are independent and can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T007)
3. Complete Phase 3: US1 — View Board (T008–T010)
4. **STOP and VALIDATE**: Install with `scripts/install.sh`, run `/rkit:board {id}` against live API
5. If board view works → MVP complete

### Incremental Delivery

1. Setup + Foundational → Skeleton ready
2. US1 → Board view works → MVP
3. US2 → Single column filter works
4. US3 → Move between columns works
5. US5 → Remove with destination prompt works
6. US4 → Add to column works
7. Polish → Edge cases, install verification

---

## Notes

- All implementation is in a single file: `skills/rkit/board/SKILL.md`
- Follow the established pattern from `skills/rkit/today/SKILL.md` for structure and conventions
- Each flow section is self-contained within SKILL.md
- No automated tests — validation is manual via Claude Code invocation against live API
- Commit after each phase checkpoint
