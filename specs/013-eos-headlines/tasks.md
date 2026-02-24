# Tasks: rkit:headlines

**Input**: Design documents from `/specs/013-eos-headlines/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. All implementation happens in a single file (`skills/headlines/SKILL.md`) following the established Claude Code skill pattern from rkit:weekly and rkit:board.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- All SKILL.md tasks are sequential within a phase (same file)

## Phase 1: Setup

**Purpose**: Create skill directory structure and copy shared files

- [X] T001 Create directory structure: `skills/headlines/`, `skills/headlines/scripts/`, and `skills/headlines/references/`
- [X] T002 [P] Copy `scripts/api.sh` to `skills/headlines/scripts/api.sh` and ensure executable (`chmod +x`)
- [X] T003 [P] Copy `api-reference.md` to `skills/headlines/references/api-reference.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: SKILL.md skeleton with shared infrastructure used by all flows

**CRITICAL**: No user story flows can be written until this phase is complete

- [X] T004 Create `skills/headlines/SKILL.md` with frontmatter (name: rkit:headlines, description, disable-model-invocation: true, user-invocable: true, allowed-tools: Bash, Read, AskUserQuestion), title, and Current State section (config check + api.sh path resolution) — follow rkit:weekly pattern
- [X] T005 Write Rules section in `skills/headlines/SKILL.md` — confirm writes, show IDs, concise output, direct execution (same rules as rkit:weekly and rkit:board)
- [X] T006 Write Argument Parsing table in `skills/headlines/SKILL.md` mapping input patterns to flows: (no args) → View Headlines, `add "text"` → Add Headline, `remove {id}` → Archive Headline, `update {id} ...` → Update Headline, `--team {id}` → team override (anywhere in args)
- [X] T007 Write Team ID Resolution section in `skills/headlines/SKILL.md` — `--team {id}` flag → use that; else `default_team_id` from config → use that; else "No default team configured. Run `/rkit:setup` first." (same as rkit:weekly)
- [X] T008 Write Error Handling section in `skills/headlines/SKILL.md` — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 (permission denied), 404 (not found), 422 (non-EOS team, validation errors). Include specific message for 422 EOS gate: "Headlines are only available for teams using the EOS framework."

**Checkpoint**: SKILL.md skeleton complete — all shared infrastructure in place

---

## Phase 3: User Story 1 — View Headlines (Priority: P1) MVP

**Goal**: User can run `/rkit:headlines` and see a table of active headlines for their default EOS team.

**Independent Test**: Run `/rkit:headlines` against an EOS team with headlines and verify table displays with ID, text, creator, expires, and created columns.

### Implementation for User Story 1

- [X] T009 [US1] Write Flow: View Headlines — Step 1 in `skills/headlines/SKILL.md`: Resolve team ID using Team ID Resolution. Fetch team detail via `GET /teams/{team_id}` to get team name for display. Then fetch headlines via `GET /teams/{team_id}/headlines?per_page=100`. Handle errors per Error Handling section
- [X] T010 [US1] Write Flow: View Headlines — Step 2 in `skills/headlines/SKILL.md`: Display headlines as formatted table. Show team name in header: "Headlines: {team_name} (ID: {team_id})". Table columns: ID, Text, Creator, Expires, Created. Creator shows `first_name last_name` (fall back to `login` if names empty). Dates show YYYY-MM-DD. Empty list → "No active headlines for {team_name}." If `meta.total > 100`, show "(showing 100 of {total})"

**Checkpoint**: `/rkit:headlines` renders a headline table. MVP read-only view complete.

---

## Phase 4: User Story 2 — Add Headline (Priority: P1) MVP

**Goal**: User can run `/rkit:headlines add "headline text"` to create a new headline with default 7-day expiration.

**Independent Test**: Run `/rkit:headlines add "New client signed"`, confirm, then run `/rkit:headlines` and verify the new headline appears.

### Implementation for User Story 2

- [X] T011 [US2] Write Flow: Add Headline in `skills/headlines/SKILL.md`: Parse args to extract headline text (remaining non-flag text after `add`) and optional `--expires {YYYY-MM-DD}` flag. Validate text is non-empty — if empty, show "Headline text cannot be empty." If no `--expires` provided, compute default as 7 days from today (YYYY-MM-DD). Resolve team ID. Describe action and confirm: 'Create headline "{text}" for {team_name} (expires {date})?' Execute via `POST /teams/{team_id}/headlines` with `{"text": "...", "expires_at": "YYYY-MM-DD"}`. On 201 success, show: 'Created headline **{id}**: "{text}" (expires {date}).' Handle errors per Error Handling section

**Checkpoint**: `/rkit:headlines add "text"` creates headlines with confirmation. Core MVP (view + add) complete.

---

## Phase 5: User Story 3 — Archive Headline (Priority: P2)

**Goal**: User can run `/rkit:headlines remove {id}` to archive (soft-delete) a headline.

**Independent Test**: Run `/rkit:headlines remove {headline_id}`, confirm, then run `/rkit:headlines` and verify the headline is gone (or see the 7-day visibility warning).

### Implementation for User Story 3

- [X] T012 [US3] Write Flow: Archive Headline in `skills/headlines/SKILL.md`: Parse `remove {headline_id}` from args. Resolve team ID. Describe action and confirm: 'Archive headline **{headline_id}** from {team_name}?' Execute via `DELETE /teams/{team_id}/headlines/{headline_id}`. On 204 success, show: 'Archived headline **{headline_id}**.' Then warn per FR-012: "Note: recently-created headlines may still appear for up to 7 days after archiving." Handle 403 (permission denied), 404 (not found) per Error Handling section

**Checkpoint**: Archive flow works with confirmation and 7-day visibility warning.

---

## Phase 6: User Story 4 — Update Headline (Priority: P3)

**Goal**: User can run `/rkit:headlines update {id} --text "new text"` and/or `--expires {date}` to edit a headline.

**Independent Test**: Run `/rkit:headlines update {id} --text "Updated"`, confirm, then run `/rkit:headlines` and verify the text changed.

### Implementation for User Story 4

- [X] T013 [US4] Write Flow: Update Headline in `skills/headlines/SKILL.md`: Parse `update {headline_id}` with `--text "..."` and/or `--expires {YYYY-MM-DD}` flags. At least one must be provided — if neither, show "Provide at least one of --text or --expires to update." Resolve team ID. Build PATCH body with only the provided fields. Describe action and confirm: 'Update headline **{headline_id}**: {changes}?' Execute via `PATCH /teams/{team_id}/headlines/{headline_id}` with body. On 200 success, show updated headline details (ID, text, expires). Handle 403, 404, 422 per Error Handling section

**Checkpoint**: Update flow works for text-only, expires-only, and both-at-once.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final edge cases and references

- [X] T014 Write Edge Cases section in `skills/headlines/SKILL.md` — consolidate all edge cases: no config (→ /rkit:setup), api.sh not found (→ install instructions), non-EOS team (422), headline not found (404), permission denied (403), empty text, invalid date format, pagination overflow, recently-archived still visible, network error, unauthorized (401)
- [X] T015 Write References section in `skills/headlines/SKILL.md` — link to `references/api-reference.md`
- [X] T016 Run `/sync-plugin` to sync shared files and verify `skills/headlines/` has correct api.sh and api-reference.md copies
- [ ] T017 Test locally via `claude --plugin-dir .` and run `/rkit:headlines` against live API to validate all flows

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — MVP read-only view
- **US2 (Phase 4)**: Depends on Phase 2 — MVP create (can parallel with US1 in theory, but same file)
- **US3 (Phase 5)**: Depends on Phase 2 — can start after foundational
- **US4 (Phase 6)**: Depends on Phase 2 — can start after foundational
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Foundation only — MVP read
- **US2 (P1)**: Foundation only — MVP create (independent of US1 flow, but same SKILL.md file, so written after US1)
- **US3 (P2)**: Foundation only — independent of US1/US2 flows
- **US4 (P3)**: Foundation only — independent of other story flows

### Within Each User Story

All tasks are sequential (single file: SKILL.md). No [P] parallelism within phases.

### Parallel Opportunities

- T002 and T003 in Setup can run in parallel (different files)
- After Phase 2, all user story phases could theoretically run in parallel, but they target the same SKILL.md file — in practice they are sequential
- The only real parallelism is in Phase 1 setup file copies

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T008)
3. Complete Phase 3: US1 — View Headlines (T009–T010)
4. Complete Phase 4: US2 — Add Headline (T011)
5. **STOP and VALIDATE**: Run `/rkit:headlines` and `/rkit:headlines add "test"` against live API
6. If view + create work → MVP complete

### Incremental Delivery

1. Setup + Foundational → Skeleton ready
2. US1 → View headlines works → Read-only MVP
3. US2 → Add headlines works → Full MVP (view + create)
4. US3 → Archive works → Basic lifecycle complete
5. US4 → Update works → Full CRUD
6. Polish → Edge cases, install verification

---

## Notes

- All implementation is in a single file: `skills/headlines/SKILL.md`
- Follow the established pattern from `skills/weekly/SKILL.md` for team-scoped skill structure
- Follow the established pattern from `skills/board/SKILL.md` for flow section format
- Each flow section is self-contained within SKILL.md
- No automated tests — validation is manual via Claude Code invocation against live API
- Commit after each phase checkpoint
- This is a simpler skill than rkit:board (4 user stories vs 5, 1-2 API calls per operation vs up to 11)
