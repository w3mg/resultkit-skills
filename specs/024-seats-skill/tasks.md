# Tasks: rkit:seats Skill

**Input**: Design documents from `/specs/024-seats-skill/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/seats-api.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Skill source: `skills/seats/` at repository root
- Single SKILL.md file with all flows
- Shared scripts: `skills/seats/scripts/api.sh`
- References: `skills/seats/references/api-reference.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create skill directory structure and copy shared files

- [X] T001 Create directory structure: `skills/seats/`, `skills/seats/scripts/`, `skills/seats/references/`
- [X] T002 [P] Copy `scripts/api.sh` to `skills/seats/scripts/api.sh`
- [X] T003 [P] Copy `api-reference.md` to `skills/seats/references/api-reference.md`

---

## Phase 2: Foundational (SKILL.md Skeleton)

**Purpose**: Create the SKILL.md framework that ALL user story flows depend on

**CRITICAL**: No flow can be added until the skeleton is complete

- [X] T004 Create `skills/seats/SKILL.md` with frontmatter: name `rkit:seats`, description, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion`
- [X] T005 Add Current State section to `skills/seats/SKILL.md` — config check inline command and api.sh path resolution with plugin root/cache/legacy fallbacks (match pattern from `skills/result-feed/SKILL.md`)
- [X] T006 Add Rules section to `skills/seats/SKILL.md` — Confirm Writes (GET immediate, POST/PUT/PATCH/DELETE confirm), Show IDs, Concise Output, Direct Execution, Framework-Aware terminology
- [X] T007 Add Argument Parsing table to `skills/seats/SKILL.md` — all commands: (no args)=view chart, `{id}`=view detail, `--team {id}`, `create`, `update`, `delete`, `move`, `restore`, `align-measure`, `remove-measure`, `align-goal`, `remove-goal`, `add-link`, `remove-link`
- [X] T008 Add Team ID Resolution section to `skills/seats/SKILL.md` — 1) `--team` flag, 2) config `default_team_id`, 3) error message
- [X] T009 Add Error Handling table to `skills/seats/SKILL.md` — map status 0/401/403/404/422 and error codes NO_CONFIG/NO_TOKEN/CURL_FAILED to user-facing messages; add edge cases for missing config, missing api.sh, no default team, empty chart
- [X] T010 Add Schemas section to `skills/seats/SKILL.md` — JSON examples for Seat (tree), Seat (detail), SeatRef, UserSimple, TeamSimple, MeasureRef, GoalRef, LinkRef; note response envelope differences (`data: [Seat[]]` vs `data: Seat`)
- [X] T011 Add References section to `skills/seats/SKILL.md` — link to `references/api-reference.md`

**Checkpoint**: SKILL.md skeleton complete — flow implementation can begin

---

## Phase 3: User Story 1 — View Accountability Chart (Priority: P1) MVP

**Goal**: Display the full team accountability chart as a tree with seat names, owners, and IDs

**Independent Test**: Run `/rkit:seats` against a team with seats and verify tree output with box-drawing characters

### Implementation for User Story 1

- [X] T012 [US1] Add Flow: View Accountability Chart to `skills/seats/SKILL.md` — Step 1: Resolve team ID via Team ID Resolution; Step 2: `GET /teams/{TEAM_ID}/seats` via api.sh; Step 3: Parse `body.data` array; handle empty array with "No seats found" message; Step 4: Render recursive tree using box-drawing characters (`├──`, `└──`, `│`) showing `SeatName (OwnerName) [ID: N]` or `SeatName (Vacant) [ID: N]` per node; display header `Accountability Chart — TeamName [Team: ID]`
- [X] T013 [US1] Add tree output format specification to `skills/seats/SKILL.md` — document the exact tree rendering format with indentation rules, box-drawing character usage, and handling of last-child (`└──`) vs middle-child (`├──`)

**Checkpoint**: `/rkit:seats` displays the full accountability chart tree — MVP complete

---

## Phase 4: User Story 2 — View Seat Details (Priority: P2)

**Goal**: Display full detail view for a single seat including accountabilities, measures, goals, links, and direct reports

**Independent Test**: Run `/rkit:seats 11` and verify all seat fields are displayed with IDs

### Implementation for User Story 2

- [X] T014 [US2] Add Flow: View Seat Details to `skills/seats/SKILL.md` — Step 1: Extract seat ID from args; Step 2: `GET /seats/{ID}` via api.sh; Step 3: Handle 404 with "Seat not found" error; Step 4: Display structured detail block — header with seat name and ID, owner (or Vacant), parent, team, associated team, accountabilities (HTML stripped via sed), notes, measures table, goals table, links table, direct reports table; all with IDs shown

**Checkpoint**: `/rkit:seats {id}` displays complete seat details

---

## Phase 5: User Story 3 — Create and Update Seats (Priority: P3)

**Goal**: Enable creating new seats and updating existing seat fields with confirmation

**Independent Test**: Run `/rkit:seats create "Test Seat" --parent 11`, confirm, verify seat appears in chart; run `/rkit:seats update {id} --name "New Name"`, confirm, verify change

### Implementation for User Story 3

- [X] T015 [US3] Add Flow: Create Seat to `skills/seats/SKILL.md` — Step 1: Parse `create "NAME" --parent {id}` from args; Step 2: Resolve team ID; Step 3: Describe action and ask for confirmation; Step 4: `POST /seats` with body `{name, team_id, parent_id?}` via api.sh; Step 5: Handle 201 (show created seat detail) and 422 (show validation error, e.g., "Team already has a root seat")
- [X] T016 [US3] Add Flow: Update Seat to `skills/seats/SKILL.md` — Step 1: Parse `update {id}` with flags `--name`, `--owner`, `--notes`, `--accountabilities`, `--associated-team` from args; Step 2: Build PATCH body from provided flags (name, seat_owner_id, notes, accountabilities, associated_team_id); Step 3: Describe changes and ask for confirmation; Step 4: `PATCH /seats/{ID}` via api.sh; Step 5: Handle 200 (show updated seat detail) and errors

**Checkpoint**: Create and update seat operations work with confirmation

---

## Phase 6: User Story 4 — Delete, Move, and Restore Seats (Priority: P4)

**Goal**: Enable archiving, moving, and restoring seats with confirmation

**Independent Test**: Run `/rkit:seats delete {id}`, confirm archive; run `/rkit:seats move {id} --parent {pid}`, confirm move; run `/rkit:seats restore {id}`, confirm restore

### Implementation for User Story 4

- [X] T017 [P] [US4] Add Flow: Delete Seat to `skills/seats/SKILL.md` — Step 1: Parse `delete {id}` from args; Step 2: Describe action ("Archive seat {name} [ID: {id}]?") and ask for confirmation; Step 3: `DELETE /seats/{ID}` via api.sh; Step 4: Handle 204 (confirm archived) and errors
- [X] T018 [P] [US4] Add Flow: Move Seat to `skills/seats/SKILL.md` — Step 1: Parse `move {id} --parent {pid}` from args; Step 2: Describe action ("Move seat {name} under {parent_name}?") and ask for confirmation; Step 3: `PUT /seats/{ID}/move` with body `{parent_id}` via api.sh; Step 4: Handle 200 (show updated seat) and 422 ("Cannot move root seat")
- [X] T019 [P] [US4] Add Flow: Restore Seat to `skills/seats/SKILL.md` — Step 1: Parse `restore {id}` from args; Step 2: Describe action and ask for confirmation; Step 3: `PUT /seats/{ID}/restore` via api.sh; Step 4: Handle 200 (show restored seat) and 422 ("Seat is not archived")

**Checkpoint**: Delete, move, and restore operations work with confirmation

---

## Phase 7: User Story 5 — Manage Seat Sub-Resources (Priority: P5)

**Goal**: Enable aligning/removing measures and goals, and adding/removing links on seats

**Independent Test**: Run `/rkit:seats align-measure {id} --measure {mid}`, confirm, verify in seat detail; run `/rkit:seats add-link {id} --url "..." --title "..."`, confirm, verify

### Implementation for User Story 5

- [X] T020 [P] [US5] Add Flow: Align/Remove Measure to `skills/seats/SKILL.md` — `align-measure {id} --measure {mid}`: confirm, `PUT /seats/{ID}/measures` with `{measure_id}`; `remove-measure {id} --measure {mid}`: confirm, `DELETE /seats/{ID}/measures/{MID}`; handle 200/204 and errors
- [X] T021 [P] [US5] Add Flow: Align/Remove Goal to `skills/seats/SKILL.md` — `align-goal {id} --goal {gid}`: confirm, `PUT /seats/{ID}/goals` with `{goal_id}`; `remove-goal {id} --goal {gid}`: confirm, `DELETE /seats/{ID}/goals/{GID}`; handle 200/204 and errors
- [X] T022 [P] [US5] Add Flow: Add/Remove Link to `skills/seats/SKILL.md` — `add-link {id} --url "..." --title "..."`: confirm, `POST /seats/{ID}/links` with `{url, title?}`; `remove-link {id} --link {lid}`: confirm, `DELETE /seats/{ID}/links/{LID}`; handle 201/204 and errors

**Checkpoint**: All sub-resource operations work with confirmation

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: API documentation, plugin sync, and validation

- [X] T023 Add seats endpoints to `api-reference.md` at repository root (already documented at lines 448–491) — document all 16 seats endpoints (GET/POST/PATCH/DELETE/PUT) with request/response shapes per contracts/seats-api.md
- [X] T024 Run `/sync-plugin` to copy updated `api-reference.md` and `api.sh` to all skills including seats
- [X] T025 Validate SKILL.md completeness — verify all 10 flows are present (view chart, view detail, create, update, delete, move, restore, align-measure/goal, remove-measure/goal, add/remove-link), all argument patterns from the Argument Parsing table have corresponding flows, and error handling covers all documented status codes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on T001 (directory exists) — BLOCKS all user stories
- **User Stories (Phase 3–7)**: All depend on Phase 2 completion (SKILL.md skeleton)
  - US1 (P1): No dependencies on other stories
  - US2 (P2): No dependencies on other stories
  - US3 (P3): No dependencies on other stories
  - US4 (P4): No dependencies on other stories
  - US5 (P5): No dependencies on other stories
- **Polish (Phase 8)**: Depends on all user stories being complete

### Within Each User Story

- All flows are added to the same `skills/seats/SKILL.md` file
- Within a story, tasks are sequential (same file)
- Across stories, tasks are sequential (same file) but logically independent

### Parallel Opportunities

- T002, T003 can run in parallel (different target files)
- T017, T018, T019 are marked [P] — logically independent flows, but all edit SKILL.md so execute sequentially in practice
- T020, T021, T022 are marked [P] — same situation (logically independent, same file)
- Across stories: since all flows go into one SKILL.md, true parallelism is limited to setup tasks

---

## Parallel Example: Phase 1 Setup

```bash
# These can run truly in parallel (different files):
Task T002: "Copy scripts/api.sh to skills/seats/scripts/api.sh"
Task T003: "Copy api-reference.md to skills/seats/references/api-reference.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational skeleton (T004–T011)
3. Complete Phase 3: View Accountability Chart (T012–T013)
4. **STOP and VALIDATE**: Run `/rkit:seats` against live API
5. Deploy if ready — read-only chart viewer delivers immediate value

### Incremental Delivery

1. Setup + Foundational → SKILL.md skeleton ready
2. Add US1: View Chart → Test → Deploy (MVP!)
3. Add US2: View Details → Test → Deploy
4. Add US3: Create/Update → Test → Deploy
5. Add US4: Delete/Move/Restore → Test → Deploy
6. Add US5: Sub-Resources → Test → Deploy
7. Polish: API docs, sync, validation

### Single-Developer Strategy

Since all flows go into one SKILL.md file, execute sequentially:
Phase 1 → Phase 2 → Phase 3 (MVP) → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8

---

## Notes

- All flows are added to a single `skills/seats/SKILL.md` file
- True parallelism is limited to setup file copies (T002/T003)
- Each user story adds independent flows — no cross-story dependencies
- Write operations MUST include confirmation per Constitution IV
- All output MUST include entity IDs per Constitution V
- HTML stripping for accountabilities uses sed (per research.md R2)
- Tree rendering uses box-drawing characters (per research.md R3)
- `POST /seats` (not `POST /teams/{id}/seats`) for creation (per research.md R1)
