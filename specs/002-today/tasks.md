---
description: "Task list for rkit:today skill implementation"
---

# Tasks: rkit:today

**Input**: Design documents from `/specs/002-today/`
**Prerequisites**: plan.md (required), spec.md (required), research.md,
data-model.md, contracts/

**Tests**: Not requested in spec. Manual invocation testing only.

**Organization**: Tasks grouped by user story for independent
implementation and testing.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Include exact file paths in descriptions

## Path Conventions

- Skills: `skills/rkit/today/`
- Shared scripts: `scripts/` (already exists from 001-setup)
- Config: `~/.config/resultkit/config.json`

---

## Phase 1: Setup (Project Structure)

**Purpose**: Create directory structure and reference files

- [x] T001 Create directory structure: `skills/rkit/today/references/`
- [x] T002 [P] Copy `api-reference.md` to `skills/rkit/today/references/api-reference.md`

---

## Phase 2: User Story 1 — View Today's Plan (Priority: P1) MVP

**Goal**: User runs `/rkit:today` with no args and sees a table of
today's plan items with position, name, status, completion, and ID.

**Independent Test**: Ensure config exists, invoke `/rkit:today`,
verify items displayed as table with completion status. Test with
empty plan (no items).

### Implementation for User Story 1

- [x] T003 [US1] Create SKILL.md skeleton at `skills/rkit/today/SKILL.md`:
  - Skill metadata (name: `rkit:today`, description, `user-invocable: true`)
  - `allowed-tools: Bash, Read`
  - Reference to `references/api-reference.md`
  - Rules section: constitution principles (confirm writes, show IDs,
    concise output, direct execution)
  - Current State section: config check, api.sh path detection
- [x] T004 [US1] Implement argument parsing in `skills/rkit/today/SKILL.md`:
  - Parse user input from skill args
  - No args → view today's plan (US1)
  - `done {id}` → mark complete (US2)
  - `undo {id}` → mark incomplete (US2)
  - `add "text"` → create new item (US3)
  - `attach {id}` → attach existing item (US3)
  - `remove {id}` → remove from plan (US4)
  - `{YYYY-MM-DD}` → view that date's plan (stretch)
  - Route to appropriate flow section
- [x] T005 [US1] Implement view today's plan flow in `skills/rkit/today/SKILL.md`:
  - Call `GET /day-plans/today/items` via api.sh
  - Parse response: extract `data` array and `meta`
  - If empty: display "No items on today's plan" with add hint
  - If items: display as table with columns: #, ID, Name, Status, Done
  - Show `✓` for completed items, blank for incomplete
  - Show summary line: X items, Y completed, Z remaining
- [x] T006 [US1] Implement error handling in `skills/rkit/today/SKILL.md`:
  - `NO_CONFIG` / `NO_TOKEN` → "Config not found. Run `/rkit:setup` first."
  - `CURL_FAILED` → "Network error. Check your connection."
  - Status 401 → "Unauthorized (401). Run `/rkit:setup` to update your token."
  - Status 404 → "No plan found for that date."
  - Other errors → show status code and response body

**Checkpoint**: View-only functionality complete. MVP usable.

---

## Phase 3: User Story 2 — Mark Item Complete/Incomplete (Priority: P2)

**Goal**: User marks a plan item as done or undone via
`/rkit:today done {id}` or `/rkit:today undo {id}`.

**Independent Test**: Add items to today's plan, run
`/rkit:today done 42`, verify item shows as complete. Run
`/rkit:today undo 42`, verify item shows as incomplete.

### Implementation for User Story 2

- [x] T007 [US2] Implement "done" flow in `skills/rkit/today/SKILL.md`:
  - Extract item ID from args
  - Describe action: "Mark item {id} as complete?"
  - On confirmation: call `PATCH /day-plans/today/items/{id}` with
    `{"completed": true}` via api.sh
  - On success: confirm completion, show updated plan (reuse US1 view)
  - On 404: "Item {id} not found on today's plan."
- [x] T008 [US2] Implement "undo" flow in `skills/rkit/today/SKILL.md`:
  - Extract item ID from args
  - Describe action: "Mark item {id} as incomplete?"
  - On confirmation: call `PATCH /day-plans/today/items/{id}` with
    `{"completed": false}` via api.sh
  - On success: confirm change, show updated plan
  - On 404: "Item {id} not found on today's plan."

**Checkpoint**: View + complete/incomplete functional.

---

## Phase 4: User Story 3 — Add Item to Today (Priority: P3)

**Goal**: User creates a new item on today's plan or attaches an
existing item via `/rkit:today add "text"` or
`/rkit:today attach {id}`.

**Independent Test**: Run `/rkit:today add "Write tests"`, verify new
item appears on plan with an ID. Run `/rkit:today attach 42`, verify
existing item appears on plan.

### Implementation for User Story 3

- [x] T009 [US3] Implement "add" flow in `skills/rkit/today/SKILL.md`:
  - Extract item name from args (quoted string)
  - Describe action: "Create item '{name}' on today's plan?"
  - On confirmation: call `POST /day-plans/today/items` with
    `{"name": "<text>"}` via api.sh
  - On success: show new item with ID, show updated plan
  - On 422: show validation error
- [x] T010 [US3] Implement "attach" flow in `skills/rkit/today/SKILL.md`:
  - Extract item ID from args
  - Describe action: "Attach item {id} to today's plan?"
  - On confirmation: call `PUT /day-plans/today/items/{id}` via api.sh
  - On success: confirm attachment, show updated plan
  - On 404: "Item {id} not found."

**Checkpoint**: View + complete + add/attach functional.

---

## Phase 5: User Story 4 — Remove Item from Today (Priority: P3)

**Goal**: User removes an item from today's plan (item still exists
in system) via `/rkit:today remove {id}`.

**Independent Test**: Add item to plan, run `/rkit:today remove {id}`,
verify item no longer on plan. Verify item still exists in system.

### Implementation for User Story 4

- [x] T011 [US4] Implement "remove" flow in `skills/rkit/today/SKILL.md`:
  - Extract item ID from args
  - Describe action: "Remove item {id} from today's plan? (Item will
    still exist in your items.)"
  - On confirmation: call `DELETE /day-plans/today/items/{id}` via api.sh
  - On success: confirm removal, show updated plan
  - On 404: "Item {id} not found on today's plan."

**Checkpoint**: All 4 user stories functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Stretch features, validation, and deployment

- [x] T012 Implement date view stretch feature in `skills/rkit/today/SKILL.md`:
  - Detect `YYYY-MM-DD` date argument
  - Call `GET /day-plans/{date}/items` instead of `today`
  - Show date in header: "Plan for 2026-02-13"
  - 404 → "No plan exists for {date}."
- [x] T013 Validate constitution compliance for all 9 principles against `skills/rkit/today/SKILL.md`
- [x] T014 Run quickstart.md walkthrough end-to-end at `specs/002-today/quickstart.md` (manual — requires live token)
- [x] T015 [P] Verify edge cases from spec:
  - No config → prompt `/rkit:setup`
  - Item ID doesn't exist → 404 error
  - Item already on plan (PUT) → idempotent, confirm already there
  - Empty plan → helpful message with add hint
- [x] T016 Run `scripts/install.sh` and verify skill is available as `/rkit:today`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Phase 1 — MVP target
- **US2 (Phase 3)**: Depends on Phase 2 (extends SKILL.md with done/undo flows)
- **US3 (Phase 4)**: Depends on Phase 2 (extends SKILL.md with add/attach flows)
- **US4 (Phase 5)**: Depends on Phase 2 (extends SKILL.md with remove flow)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: No story dependencies — establishes SKILL.md skeleton + view flow
- **US2 (P2)**: Depends on US1 (reuses view flow for showing updated plan)
- **US3 (P3)**: Depends on US1 (reuses view flow). Independent of US2.
- **US4 (P3)**: Depends on US1 (reuses view flow). Independent of US2, US3.

### Within Each User Story

- SKILL.md sections are written sequentially (same file)
- api.sh calls must work before skill logic can execute

### Parallel Opportunities

- T001 and T002 can run in parallel (different directories)
- US3 (Phase 4) and US4 (Phase 5) are independent of each other
  once US1 is complete — could proceed in parallel
- US2 (Phase 3), US3 (Phase 4), US4 (Phase 5) all depend on US1
  but are independent of each other
- T013, T014, T015 in Polish phase can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: US1 — View Today's Plan (T003–T006)
3. **STOP and VALIDATE**: Run quickstart view-only flow
4. Skill is usable after this point

### Incremental Delivery

1. Setup → directory structure ready
2. US1 → View today's plan works → MVP!
3. US2 → Done/undo works → daily workflow supported
4. US3 → Add/attach works → plan building supported
5. US4 → Remove works → plan editing complete
6. Polish → date view, validated, installed, deployed

---

## Notes

- All user story tasks modify the same file (`SKILL.md`) — within a
  story, tasks are sequential.
- No new Bash scripts needed — uses existing `api.sh` from 001-setup.
- No automated tests — validation is manual invocation per quickstart.
- Commit after each phase completion.
- No foundational phase needed — api.sh already exists from 001-setup.
