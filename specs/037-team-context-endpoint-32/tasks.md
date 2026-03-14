# Tasks: Team Context Endpoint

**Input**: Design documents from `/specs/037-team-context-endpoint-32/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)

---

## Phase 1: Setup

**Purpose**: Read existing files to confirm exact insertion points before editing.

- [ ] T001 Read `api-reference.md` lines 270–300 to confirm Users table structure and exact lines to edit

**Checkpoint**: Insertion points confirmed — ready to update api-reference.md

---

## Phase 2: Foundational

No blocking prerequisites for this feature — the API endpoint is already deployed and the existing codebase requires no structural changes.

---

## Phase 3: User Story 1 — Update API Reference (Priority: P1) 🎯 MVP

**Goal**: Add `PATCH /users/me/team-context` to the master api-reference.md and update the `GET /users/me` entry so all skills have accurate documentation.

**Independent Test**: Read updated `api-reference.md` and confirm: (1) a new row for `PATCH /users/me/team-context` exists in the Users table with `team_id` parameter, 200/400/401/422 codes, and user phrases; (2) the `GET /users/me` row notes `current_team` is now populated; (3) the User fields prose documents the `current_team` behavior change.

### Implementation for User Story 1

- [ ] T002 [US1] Add `PATCH /users/me/team-context` row to Users table in `api-reference.md` (after the `POST /users/me/password` row) with description, body param (`team_id*`), success/error codes, user phrases ("switch team", "use team", "set active team", "change my team"), idempotency note
- [ ] T003 [US1] Update `GET /users/me` row in `api-reference.md` to append note: "`current_team` reflects the team last set via `PATCH /users/me/team-context` (was always null before 2026-03-13 API fix)"
- [ ] T004 [US1] Update User fields prose block in `api-reference.md` (around line 290) to clarify `current_team` is non-null after a team-context set call
- [ ] T005 [US1] Add row to User Phrases lookup table in `api-reference.md`: `switch team, use team, set active team, change my team, team context | Set Active Team | PATCH /users/me/team-context`

**Checkpoint**: `api-reference.md` documents the new endpoint completely. User Story 1 is fully testable by reading the file.

---

## Phase 4: User Story 2 — Add `use` Action to `rkit:teams` (Priority: P2)

**Goal**: Add a `use {team_id}` action to `skills/teams/SKILL.md` that calls `PATCH /users/me/team-context` with confirmation, so users can switch their active team from within the skill.

**Independent Test**: Run `/rkit:teams use {team_id}` — confirm skill shows a confirmation prompt with team name and ID, executes the PATCH on approval, and displays "Active team set to **{name}** (ID: {id})." on success.

### Implementation for User Story 2

- [ ] T006 [US2] Read `skills/teams/SKILL.md` fully to confirm current Argument Parsing table, Rules section, and end of file for insertion points
- [ ] T007 [US2] Add `use {team_id}` row to Argument Parsing table in `skills/teams/SKILL.md`: "Set the server-side active team to the given team ID (requires confirmation)"
- [ ] T008 [US2] Update `description` frontmatter in `skills/teams/SKILL.md` to mention team-switching (e.g., add "switch your active team" to the description triggers)
- [ ] T009 [US2] Add `## Flow: Set Active Team` section to `skills/teams/SKILL.md` with: arg validation, `GET /teams/{team_id}` fetch for team name, confirmation prompt, `PATCH /users/me/team-context` execution, success output ("Active team set to **{name}** (ID: {id})."), and error handling (401 → setup, 422 → human-readable, 404 → team not found)

**Checkpoint**: `rkit:teams use {team_id}` works end-to-end: shows confirmation, executes PATCH, confirms active team.

---

## Phase 5: Polish & Sync

**Purpose**: Distribute updated api-reference.md to all skill copies and verify.

- [ ] T010 Run `/sync-plugin` to copy master `api-reference.md` to all `skills/*/references/api-reference.md` copies and bump plugin version
- [ ] T011 [P] Verify `skills/teams/references/api-reference.md` contains the new `PATCH /users/me/team-context` entry after sync
- [ ] T012 [P] Spot-check two other skill api-reference copies (e.g., `skills/setup/references/api-reference.md`, `skills/profile/references/api-reference.md`) to confirm sync applied correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 3 (US1)**: Depends on T001 (insertion points confirmed)
- **Phase 4 (US2)**: Depends on T006 (SKILL.md read); can start in parallel with Phase 3 since different files
- **Phase 5 (Polish)**: Depends on Phase 3 (T005 complete) — sync requires api-reference.md to be finalized

### User Story Dependencies

- **US1 (P1)**: Depends only on T001 — no dependency on US2
- **US2 (P2)**: Depends only on T006 — no dependency on US1; can run in parallel with US1

### Within Each User Story

- US1: T002 → T003 → T004 → T005 (all same file, sequential)
- US2: T006 → T007 → T008 → T009 (all same file, sequential; T007 and T008 are independent but in same file)

### Parallel Opportunities

- US1 (T002–T005) and US2 (T006–T009) can run in parallel — different files
- T011 and T012 (verification spot-checks) can run in parallel after T010

---

## Parallel Example: US1 + US2 simultaneously

```bash
# After T001 completes, launch both story tracks in parallel:
Task A: "Update api-reference.md — T002 through T005"
Task B: "Update skills/teams/SKILL.md — T006 through T009"
# Then run T010 (sync) after Task A completes
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001 (Setup)
2. Complete T002–T005 (US1 — api-reference.md updates)
3. **STOP and VALIDATE**: Confirm api-reference.md is correct
4. Run T010 (sync)

### Full Delivery

1. T001 → T002–T005 (US1) and T006–T009 (US2) in parallel
2. T010 → sync → T011, T012 (verify)

### Total Tasks: 12

| Story | Tasks | Count |
|-------|-------|-------|
| Setup | T001 | 1 |
| US1 (P1) — api-reference.md | T002–T005 | 4 |
| US2 (P2) — teams SKILL.md | T006–T009 | 4 |
| Polish/Sync | T010–T012 | 3 |

---

## Notes

- No new files created — all changes are edits to existing files
- [P] marks same-phase tasks that touch different files (US1 and US2 tracks are parallel)
- `/sync-plugin` (T010) handles distributing api-reference.md — never edit skill copies directly
- Commit after each story phase completes
