# Tasks: Teams Envelope Fix & Error Handling Update

**Input**: Design documents from `/specs/022-teams-envelope-fix/`
**Prerequisites**: plan.md, spec.md, research.md, contracts/teams-api.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: User Story 1 — Teams Skill Handles Data Envelope (Priority: P1) 🎯 MVP

**Goal**: `/rkit:teams` correctly parses the new `{ "data": [...] }` envelope from `GET /teams`

**Independent Test**: Run `/rkit:teams` and verify teams are listed in a table with ID, name, framework, and default marker.

- [X] T001 [US1] Update Step 3 response parsing in `skills/teams/SKILL.md` — replace "The `body` is a **flat JSON array** (not wrapped in `data`/`meta`). Each element is a team object." and "Because the response is a flat array, access it as `body` directly — not `body.data`." with instructions to extract the teams array from `body.data` (standard data envelope). Update all references to iterate over `body.data` instead of `body`.

**Checkpoint**: US1 complete — `/rkit:teams` works with new envelope

---

## Phase 2: User Story 2 — Setup Skill Handles Data Envelope (Priority: P1)

**Goal**: `/rkit:setup` correctly parses the new `{ "data": [...] }` envelope during team selection

**Independent Test**: Run `/rkit:setup` with a valid token. Verify team selection step displays available teams.

- [X] T002 [US2] Update Step 4 (first-time setup) in `skills/setup/SKILL.md` — change "returns authenticated user's teams as a flat array — no pagination" and "The response is a flat JSON array (not wrapped in `data`). Each team has `is_default`" to document the standard data envelope. Update parsing to extract teams from the `data` field of the JSON response body.
- [X] T003 [US2] Update Option 2 (reconfigure default team) in `skills/setup/SKILL.md` — the reconfigure flow at Step 10 Option 2 also calls `GET /teams` and displays a table. Update this flow's parsing to use the `data` envelope format, matching the changes in T002.

**Checkpoint**: US2 complete — `/rkit:setup` team selection works with new envelope

---

## Phase 3: User Story 3 — API Reference Documents Envelope & Errors (Priority: P2)

**Goal**: api-reference.md accurately reflects the current API response format

**Independent Test**: Read api-reference.md and verify Teams section documents data envelope and Error Responses includes 500 internal_error.

- [X] T004 [US3] Update `GET /teams` documentation in `api-reference.md` — remove any implication that the response is a bare array. Add a note that `GET /teams` now returns the standard `{ "data": [...] }` envelope matching all other list endpoints. The response fields per team are unchanged.
- [X] T005 [US3] Add `500 internal_error` to the Error Responses table in `api-reference.md` — add row: `| 500 | internal_error | Internal server error |`

**Checkpoint**: US3 complete — API reference accurate

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, finalize

- [X] T006 Run `/sync-plugin` to copy updated api-reference.md to all skills
- [X] T007 Bump version in `.claude-plugin/plugin.json` and `gemini-extension.json`
- [X] T008 Set spec status to Complete in `specs/022-teams-envelope-fix/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **US1 (Phase 1)**: No dependencies — start immediately
- **US2 (Phase 2)**: No dependency on US1 (different file: setup/SKILL.md vs teams/SKILL.md)
- **US3 (Phase 3)**: No dependency on US1 or US2 (different file: api-reference.md)
- **Polish (Phase 4)**: Depends on US3 (api-reference.md must be updated before syncing)

### Parallel Opportunities

- US1, US2, and US3 can all run in parallel (different files, no dependencies)
- Sequential execution is fine for this size — total of 8 tasks

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: US1 — Fix teams skill (T001)
2. **STOP and VALIDATE**: `/rkit:teams` displays teams correctly
3. Continue to US2, US3, Polish

### Incremental Delivery

1. US1: Fix teams skill → teams listing works
2. US2: Fix setup skill → first-time setup works
3. US3: Update API reference → documentation accurate
4. Polish → Sync, version bump, finalize

## Notes

- This is a minimal fix: 2 SKILL.md edits + 1 api-reference.md update
- No new files, no new skills, no new patterns
- The 500 `internal_error` is already handled by existing generic "Other non-200" error handlers in all skills
- The setup skill uses raw curl (not api.sh) because config doesn't exist during first-time setup — the parsing change applies to the curl response body
