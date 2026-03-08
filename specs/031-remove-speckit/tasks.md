# Tasks: Remove Speckit from Plugin Distribution

**Input**: Design documents from `/specs/031-remove-speckit/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅

**Organization**: Tasks grouped by user story for independent implementation and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm preconditions before making changes

- [X] T001 Confirm `example-skills@anthropic-agent-skills` plugin is installed and `/speckit:specify` works inside the repo

---

## Phase 2: Foundational (Blocking Prerequisites)

N/A — each user story is independent and requires no shared foundation beyond T001.

---

## Phase 3: User Story 1 - Plugin install has no speckit (Priority: P1) 🎯 MVP

**Goal**: Remove `.claude/commands/speckit/` from the repo so plugin users never receive speckit commands

**Independent Test**: After deletion, open a fresh Claude Code session outside the repo (where rkit plugin is installed) and confirm no `speckit:*` commands appear from the plugin

### Implementation for User Story 1

- [X] T002 [P] [US1] Delete `.claude/commands/speckit/analyze.md`
- [X] T003 [P] [US1] Delete `.claude/commands/speckit/checklist.md`
- [X] T004 [P] [US1] Delete `.claude/commands/speckit/clarify.md`
- [X] T005 [P] [US1] Delete `.claude/commands/speckit/constitution.md`
- [X] T006 [P] [US1] Delete `.claude/commands/speckit/implement.md`
- [X] T007 [P] [US1] Delete `.claude/commands/speckit/plan.md`
- [X] T008 [P] [US1] Delete `.claude/commands/speckit/specify.md`
- [X] T009 [P] [US1] Delete `.claude/commands/speckit/tasks.md`
- [X] T010 [P] [US1] Delete `.claude/commands/speckit/taskstoissues.md`

**Checkpoint**: `.claude/commands/speckit/` directory no longer exists. Inside the repo, `/speckit:specify` still works via the `example-skills` plugin.

---

## Phase 4: User Story 2 - Dev workflow continues via plugin skill (Priority: P2)

**Goal**: Document in `CLAUDE.md` that speckit is sourced from `example-skills@anthropic-agent-skills`, not the repo, so future contributors know not to re-add `.claude/commands/speckit/`

**Independent Test**: Read CLAUDE.md and confirm it references `example-skills@anthropic-agent-skills` as the speckit source. Run `/next-issue` inside the repo and confirm speckit handoff works correctly.

### Implementation for User Story 2

- [X] T011 [US2] Update `CLAUDE.md` — add a note in the dev tooling section stating speckit is sourced from the `example-skills@anthropic-agent-skills` plugin, not from the repo, and that `.claude/commands/speckit/` must not be re-added

**Checkpoint**: CLAUDE.md documents the speckit source. Dev workflow (speckit via plugin) confirmed functional.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Publish the fix and verify end-to-end

- [X] T012 Bump version in `.claude-plugin/plugin.json` (patch bump)
- [ ] T013 Commit all changes (deleted files + CLAUDE.md update + version bump) with a descriptive message
- [ ] T014 Push branch, merge to main, and publish (`/ship-it`)
- [ ] T015 [P] Verify: outside the repo, run `/plugin marketplace update` and confirm no `speckit:*` commands appear from the rkit plugin; also confirm all `rkit:*` skills load correctly (FR-003)
- [ ] T016 [P] Verify: inside the repo, confirm `/speckit:specify` still works via `example-skills` plugin and `.specify/` directory is untouched

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 3)**: Depends on T001 (precondition check)
- **US2 (Phase 4)**: Independent of US1 — can run in parallel after T001
- **Polish (Phase 5)**: Depends on all US1 + US2 tasks complete

### User Story Dependencies

- **User Story 1 (P1)**: File deletions — all T002–T010 are fully parallel (different files)
- **User Story 2 (P2)**: Single doc update — independent of US1

### Parallel Opportunities

- T002–T010 (US1 deletions): All parallel — each is a different file
- T015 + T016 (verification): Parallel — different environments

---

## Parallel Example: User Story 1

```bash
# All 9 speckit file deletions can run simultaneously:
Delete .claude/commands/speckit/analyze.md
Delete .claude/commands/speckit/checklist.md
Delete .claude/commands/speckit/clarify.md
Delete .claude/commands/speckit/constitution.md
Delete .claude/commands/speckit/implement.md
Delete .claude/commands/speckit/plan.md
Delete .claude/commands/speckit/specify.md
Delete .claude/commands/speckit/tasks.md
Delete .claude/commands/speckit/taskstoissues.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (confirm preconditions)
2. Complete Phase 3: US1 (delete speckit files)
3. **STOP and VALIDATE**: Inside repo, confirm speckit still works via plugin
4. Proceed to Phase 4 (US2) and Phase 5 (Polish)

### Incremental Delivery

1. T001 → Preconditions confirmed
2. T002–T010 → Speckit removed from repo → verify plugin users no longer get speckit
3. T011 → CLAUDE.md updated → dev contributors know the source of truth
4. T012–T016 → Version bumped, published, end-to-end verified

---

## Notes

- [P] tasks = different files, no dependencies
- `.specify/` directory (templates, constitution, scripts) must NOT be touched — only `.claude/commands/speckit/` is deleted
- Other dev commands (`ship-it`, `sync-plugin`, `next-issue`, `close-issue`) stay in `.claude/commands/` — out of scope
- No code changes — this is pure file deletion + doc update
