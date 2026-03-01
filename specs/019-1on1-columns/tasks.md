# Tasks: 1:1 Columns

**Input**: Design documents from `/specs/019-1on1-columns/`
**Prerequisites**: plan.md (required), spec.md (required), research.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: Setup (API Verification)

**Purpose**: Verify the meetings API team filtering mechanism before modifying the skill

- [X] T001 Verify `GET /meetings` team_id filtering against live API using `scripts/api.sh` — call `GET /meetings?team_id=TEAM_ID&per_page=5` and compare with unfiltered `GET /meetings?per_page=5`. Inspect meeting objects for team-related fields. Document the working filtering mechanism (query param, client-side field match, or member-based fallback). **Result**: No config available for live verification. User confirmed team_id filtering works (backlog item 210978 completed). Implementing with team_id query param as primary, member-based matching as fallback.

**Checkpoint**: API behavior confirmed — proceed with skill modification

---

## Phase 2: User Story 1 - List 1:1s for a Team (Priority: P1) MVP

**Goal**: Users can run `/rkit:1on1` and see only 1:1 meetings scoped to their default team (or a `--team` override).

**Independent Test**: Run `/rkit:1on1` with a configured default team. Verify only 1:1s for that team appear in the table output.

### Implementation for User Story 1

- [X] T002 [US1] Add "Team ID Resolution" section to `skills/1on1/SKILL.md` after the Error Handling section — use the same 3-tier pattern as other skills: (1) `--team {id}` flag in args, (2) `default_team_id` from config, (3) neither → no team filter applied
- [X] T003 [US1] Update "Flow: List One-on-Ones" Step 1 in `skills/1on1/SKILL.md` — when team ID is resolved, fetch team detail via `GET /teams/TEAM_ID` for the team name, then fetch meetings with team_id filter (use mechanism confirmed in T001). Keep client-side `type: "one_on_one"` filter. **Fallback**: if T001 finds no `team_id` query param, fetch team members from `GET /teams/TEAM_ID` and filter meetings client-side by matching `person1.id` or `person2.id` against the member ID set.
- [X] T004 [US1] Update "Flow: List One-on-Ones" Step 2 display in `skills/1on1/SKILL.md` — when team-filtered, show header `## One-on-Ones — {team_name} (ID: {team_id})`. When no team filter, show `## One-on-Ones` with hint: "Tip: Set a default team with `/rkit:setup` to filter by team." Empty result with team shows "No one-on-ones found for {team_name}."
- [X] T005 [US1] Update "Argument Parsing" table in `skills/1on1/SKILL.md` — add `--team {id} (anywhere in args)` row with flow "Override team ID for any flow", matching the pattern used in `rkit:weekly` and `rkit:headlines`

**Checkpoint**: US1 complete — team-scoped 1:1 listing works

---

## Phase 3: User Story 2 - View Columns from a 1:1 (Priority: P2)

**Goal**: Users can run `/rkit:1on1 {meeting_id}` and see items grouped by Next, Done, and Blocked columns.

**Independent Test**: Run `/rkit:1on1 {known_meeting_id}` and verify three column sections appear with item tables.

### Implementation for User Story 2

- [X] T006 [US2] Audit existing "Flow: View One-on-One Detail" in `skills/1on1/SKILL.md` against spec requirements (FR-005, FR-006) — confirm the detail view shows header with both participants, three column sections (Next, Done, Blocked) with item tables showing ID, name, creator, due date, and "(empty)" for empty columns. Document any discrepancies; fix if found.

**Checkpoint**: US2 verified — column view confirmed working

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: API documentation and version management

- [X] T007 [P] Update `api-reference.md` Meetings section to document the team_id filtering param on `GET /meetings` (based on T001 findings)
- [X] T008 [P] Run `/sync-plugin` to copy updated api-reference.md and api.sh to all skill directories
- [X] T009 Bump version in `.claude-plugin/plugin.json` and `gemini-extension.json` (patch bump)
- [X] T010 Update spec status to "Complete" in `specs/019-1on1-columns/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on T001 (API verification confirms filtering mechanism)
- **US2 (Phase 3)**: No dependencies on US1 — can run in parallel. Depends only on T001 for context.
- **Polish (Phase 4)**: Depends on T001 (API findings) and US1 completion

### User Story Dependencies

- **User Story 1 (P1)**: Depends on T001. T002 → T003 → T004 are sequential (same file, same section). T005 can run after T002.
- **User Story 2 (P2)**: Depends on T001. Independent of US1 — audit only, no expected code changes.

### Within User Story 1

- T002 (team ID resolution section) → T003 (list flow update references the new section) → T004 (display update references T003 changes)
- T005 (argument parsing table) can run after T002 (needs to know the `--team` pattern exists)

### Parallel Opportunities

- T007 and T008 can run in parallel (different files)
- US1 and US2 can run in parallel (US2 is audit-only)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001: Verify API behavior
2. Complete T002–T005: Implement team-scoped listing
3. **STOP and VALIDATE**: Test with `/rkit:1on1` and `/rkit:1on1 --team {id}`
4. Proceed to US2 audit and polish

### Incremental Delivery

1. T001 → API verified
2. T002–T005 → Team-scoped list works (MVP)
3. T006 → Column view confirmed
4. T007–T010 → Docs, sync, version bump

---

## Notes

- T001 is critical: the filtering mechanism determines how T003 is written
- Most work is in a single file (`skills/1on1/SKILL.md`) so tasks are sequential within US1
- US2 is an audit task — the existing skill already implements column viewing
- T007 updates the master api-reference.md; T008 propagates it via /sync-plugin
