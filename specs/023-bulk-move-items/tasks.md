# Tasks: Bulk Move Items

**Input**: Design documents from `/specs/023-bulk-move-items/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, contracts/bulk-move-api.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. Two files edited in-place, no new files created.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Exact file paths included in descriptions

---

## Phase 1: User Story 1 - Bulk Move Items Under a Parent (Priority: P1) 🎯 MVP

**Goal**: Add a `bulk-move` flow to the existing `rkit:board` skill so users can move multiple items under a target parent in one command.

**Independent Test**: Run `/rkit:board bulk-move 1,2,3 100` — verify confirmation prompt mentions weekly board removal, and result shows moved/failed counts with per-item error table on partial failure.

### Implementation for User Story 1

- [X] T001 [US1] Add `bulk-move` entry to the argument parsing table in skills/board/SKILL.md
- [X] T002 [US1] Write the Bulk Move Items flow in skills/board/SKILL.md (parse args → validate → confirm with weekly board warning → PATCH /items/bulk-move via api.sh → display summary + error table)
- [X] T003 [US1] Add error handling for 401, 403, 404, 422 responses in the bulk-move flow in skills/board/SKILL.md

**Checkpoint**: User Story 1 complete — bulk-move command functional in rkit:board skill

---

## Phase 2: User Story 2 - Update API Reference (Priority: P2)

**Goal**: Document the new `PATCH /items/bulk-move` endpoint in api-reference.md so other skills and developers can discover it.

**Independent Test**: Read api-reference.md — verify Items section includes PATCH /items/bulk-move with body params, response shape, error codes, and user phrases in glossary.

### Implementation for User Story 2

- [X] T004 [P] [US2] Add PATCH /items/bulk-move to the Items section of api-reference.md (method, path, body params, response shape, error codes)
- [X] T005 [P] [US2] Add bulk-move user phrases to the glossary section of api-reference.md

**Checkpoint**: API reference fully documents the bulk-move endpoint

---

## Phase 3: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, mark spec complete.

- [X] T006 Run /sync-plugin to copy updated api-reference.md and api.sh to all skills
- [X] T007 Bump version in .claude-plugin/plugin.json and gemini-extension.json
- [X] T008 Set spec status to Complete in specs/023-bulk-move-items/spec.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **User Story 1 (Phase 1)**: No dependencies — can start immediately
- **User Story 2 (Phase 2)**: No dependency on US1 — can run in parallel
- **Polish (Phase 3)**: Depends on US1 and US2 completion

### User Story Dependencies

- **User Story 1 (P1)**: T001 → T002 → T003 (sequential — same file)
- **User Story 2 (P2)**: T004 and T005 can run in parallel (different sections of same file, but non-overlapping)

### Parallel Opportunities

- US1 (T001–T003) and US2 (T004–T005) operate on different files and can run in parallel
- T004 and T005 touch different sections of api-reference.md and can run in parallel

---

## Parallel Example: User Stories 1 & 2

```bash
# These two story tracks can execute in parallel (different files):
Track A: T001 → T002 → T003  (skills/board/SKILL.md)
Track B: T004 + T005          (api-reference.md)

# Then sequential:
T006 → T007 → T008           (Polish)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: US1 (bulk-move flow in board skill)
2. **STOP and VALIDATE**: Test bulk-move command independently
3. Continue to US2 and Polish

### Incremental Delivery

1. US1 → bulk-move command works → testable
2. US2 → api-reference updated → discoverable
3. Polish → synced, versioned, spec marked complete

---

## Notes

- No new files created — two existing files edited in-place
- skills/board/SKILL.md already has move, add, remove flows — bulk-move follows the same pattern
- Partial failure handling (summary + error table) is a new output pattern for this project
- Confirmation prompt must warn about weekly board removal side effect
