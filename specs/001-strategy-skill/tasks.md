# Tasks: Strategy Skill (rkit:strategy)

**Input**: Design documents from `/specs/001-strategy-skill/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.
**Tests**: Not requested — no test tasks generated.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)

---

## Phase 1: Setup

**Purpose**: Create the skill directory structure. API reference already updated with strategy endpoints.

- [ ] T001 Create skill directory structure: `skills/strategy/`, `skills/strategy/scripts/`, `skills/strategy/references/`
- [ ] T002 Run `/sync-plugin` to copy `api-reference.md` and `api.sh` into `skills/strategy/references/` and `skills/strategy/scripts/` and bump plugin version

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the SKILL.md entry point with frontmatter, config loading, api.sh path resolution, team ID resolution, tree fetching, and shared object name resolution logic. These are used by every user story.

**⚠️ CRITICAL**: All user story phases depend on this foundation being in place.

- [ ] T003 Create `skills/strategy/SKILL.md` with frontmatter block: `name: rkit:strategy`, description covering strategy tree viewing and management, `user-invocable: true`, `disable-model-invocation: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion` — reference `skills/seats/SKILL.md` frontmatter as the pattern
- [ ] T004 Add **Current State** section to `skills/strategy/SKILL.md`: inline Bash commands to read `~/.config/resultkit/config.json` (masked token display) and resolve `api.sh` path using the multi-path probe pattern from `skills/seats/SKILL.md`
- [ ] T005 Add **Rules** section to `skills/strategy/SKILL.md`: confirm writes (GET immediate, POST/PUT/PATCH/DELETE require confirmation), show IDs and object_types, concise output, direct execution (Bash + api.sh, no agents), framework-aware terminology, block edits on inherited nodes
- [ ] T006 Add **Argument Parsing** table to `skills/strategy/SKILL.md` covering: no args (view tree), `--year YYYY` / `--year All`, `--quarter N` / `--quarter All`, `create <name> [under <parent>] [due=...] [assignees=...] [--focus-area]`, `update <name> [name=...] [status=...] [due=...] [assignees=...]`, `align <name> under <parent>`, `detach <name> from <parent> [--archive]`
- [ ] T007 Add **Team ID Resolution** section to `skills/strategy/SKILL.md`: (1) `--team {id}` flag, (2) `default_team_id` from config, (3) error → "No default team configured. Run `/rkit:setup` first."
- [ ] T008 Add **Strategy Tree Fetch** section to `skills/strategy/SKILL.md`: call `GET /teams/:id/strategy?year=$YEAR&quarter=$QUARTER` via api.sh, store full response JSON for reuse by all flows
- [ ] T009 Add **Object Name Resolution** section to `skills/strategy/SKILL.md`: flatten the strategy tree (strategy + unaligned) into a list via recursive jq walk, case-insensitive substring match on `name`, multiple matches → show numbered disambiguation list with id, object_type, status, and parent context, no match → "No strategy object found matching '{name}'."
- [ ] T010 Add **Framework Label Mapping** section to `skills/strategy/SKILL.md`: define label maps — EOS: yearly_goal→"Yearly Goal", rock→"Rock", milestone→"Milestone"; OKR: objective→"Objective", rock→"Rock", key_result→"Key Result", focus_area→"Focus Area"; 4DX: objective→"WIG", rock→"Battle", key_result→"Lead Measure"; fallback: use object_type as-is

**Checkpoint**: SKILL.md has frontmatter + shared infrastructure. Ready for user story flows.

---

## Phase 3: User Story 1 — View Team Strategy Tree (Priority: P1) 🎯 MVP

**Goal**: User runs `/rkit:strategy` and sees the full strategy tree as an indented hierarchy with unaligned items in a separate section.

**Independent Test**: Run `/rkit:strategy` — verify nested tree shows name, framework-aware label, status indicator, assignees, due date, and ID for each node. Run with `--year All` — verify all years shown. See `quickstart.md`.

- [ ] T011 [US1] Add **Flow: View Strategy Tree** section to `skills/strategy/SKILL.md`: triggered when no subcommand. Call tree fetch (T008). Display header: "Strategy for {team_name} ({framework}) — {year} Q{quarter}". Recursively render each node with 2-space indentation per level, format: `{status_emoji} {FrameworkLabel}: {name} (#{id}, due {due}[, → {assignees}])`. Status emoji mapping: active→🟢, complete→✅, archived→📦, deferred→⏸️, at_risk→🟡, off_track→🔴, draft→📝, cancelled→❌, review→🔍.
- [ ] T012 [US1] Add **Unaligned Section** rendering to the view flow in `skills/strategy/SKILL.md`: if `unaligned` array is non-empty, show "Unaligned:" header followed by each unaligned node (same format, no indentation for children since they're top-level in unaligned)
- [ ] T013 [US1] Add **Inherited Node Display** to the view flow in `skills/strategy/SKILL.md`: if `inherited: true`, append "[inherited from {team_name}]" to the node's display line
- [ ] T014 [US1] Add empty-state handling: if both `strategy` and `unaligned` arrays are empty, show "No strategy objects found for {year} Q{quarter}. Use `/rkit:strategy create <name>` to get started."
- [ ] T015 [US1] Add error handling to the view flow: 401 → "Auth failed. Run /rkit:setup.", 403 → "You don't have permission to view this team's strategy.", 404 → "Team ID {id} not found.", other → show HTTP status + API error message

**Checkpoint**: US1 complete — `/rkit:strategy` shows a strategy tree.

---

## Phase 4: User Story 2 — Create a Strategy Object (Priority: P2)

**Goal**: User runs `/rkit:strategy create "Name" [under "Parent"]` and a new strategy object is created in the team's tree.

**Independent Test**: Create a rock under a yearly goal; confirm; run `/rkit:strategy` and verify it appears as a child. See `quickstart.md`.

- [ ] T016 [US2] Add **Flow: Create Strategy Object** section to `skills/strategy/SKILL.md`: triggered when first arg is `create`. Parse: name (required, arg 2), `under <parent-name>` (optional), `due=YYYY-MM-DD`, `assignees=<comma-sep names or IDs>`, `status=...`, `--focus-area` flag. If name is missing, show "Object name is required." and stop.
- [ ] T017 [US2] Add parent resolution to create flow in `skills/strategy/SKILL.md`: if `under` specified, fetch tree (T008), resolve parent name (T009), derive `parent_id` and `parent_type` from the matched node's `object_type` and `id`. If parent is inherited, show "Cannot create children under inherited node '{name}' — it belongs to {inherited_from.team_name}." and stop.
- [ ] T018 [US2] Add confirmation + API call to create flow in `skills/strategy/SKILL.md`: show "Create '{name}' [under '{parent_name}' ({parent_type})]? [y/N]", on confirm call `POST /teams/:id/strategy` with appropriate body per `contracts/create-strategy.md`, show "Created: {name} ({object_type} #{id})."
- [ ] T019 [US2] Add error handling to create flow: 422 → show API error message, 403 → "You don't have permission to create strategy objects in this team."

**Checkpoint**: US1 + US2 both independently functional.

---

## Phase 5: User Story 3 — Update a Strategy Object (Priority: P3)

**Goal**: User runs `/rkit:strategy update "Name" status=complete` and the strategy object is updated.

**Independent Test**: Update a rock's status to "complete"; confirm; run `/rkit:strategy` and verify the status change. See `quickstart.md`.

- [ ] T020 [US3] Add **Flow: Update Strategy Object** section to `skills/strategy/SKILL.md`: triggered when first arg is `update`. Parse object name (arg 2) and any combination of `name=...`, `description=...`, `status=...`, `due=...`, `assignees=...` from remaining args. Fetch tree (T008), resolve object name (T009). If object is inherited, show "Cannot update inherited node '{name}' — it belongs to {inherited_from.team_name}." and stop.
- [ ] T021 [US3] Add confirmation + API call to update flow in `skills/strategy/SKILL.md`: show "Update '{name}' ({object_type} #{id}) — set {field list}? [y/N]", on confirm call `PATCH /strategy/{object_type}/{id}` with partial body per `contracts/update-strategy.md`, show "Updated: {name}." with changed fields.
- [ ] T022 [US3] Add error handling to update flow: 403 → "You don't have permission to update this object.", 404 → "Strategy object not found.", 422 → show API error message

**Checkpoint**: US1 + US2 + US3 all independently functional.

---

## Phase 6: User Story 4 — Align (Link) Strategy Object (Priority: P4)

**Goal**: User runs `/rkit:strategy align "Rock Name" under "Goal Name"` and the object is linked to the parent.

**Independent Test**: Align an unaligned rock to a yearly goal; confirm; run `/rkit:strategy` and verify it appears under the goal. See `quickstart.md`.

- [ ] T023 [US4] Add **Flow: Align Strategy Object** section to `skills/strategy/SKILL.md`: triggered when first arg is `align`. Parse: object name (arg 2), `under <parent-name>` (required). Fetch tree (T008), resolve both object and parent names (T009). Derive `object_type` and `parent_type` from matched nodes. If either is inherited, show error and stop.
- [ ] T024 [US4] Add confirmation + API call to align flow in `skills/strategy/SKILL.md`: show "Link '{object_name}' ({object_type} #{id}) under '{parent_name}' ({parent_type} #{parent_id})? [y/N]", on confirm call `PUT /strategy/align` with body per `contracts/align-strategy.md`, show "Linked: {object_name} now under {parent_name}."
- [ ] T025 [US4] Add error handling to align flow: 403 → "You don't have permission to link objects in this team.", 422 → show API error message

**Checkpoint**: US1–US4 all independently functional.

---

## Phase 7: User Story 5 — Detach (Remove) Strategy Object (Priority: P5)

**Goal**: User runs `/rkit:strategy detach "Rock Name" from "Goal Name"` and the object is unlinked from the parent.

**Independent Test**: Detach a rock from a goal; confirm; run `/rkit:strategy` and verify the rock moved to unaligned. With `--archive`, verify it's gone entirely. See `quickstart.md`.

- [ ] T026 [US5] Add **Flow: Detach Strategy Object** section to `skills/strategy/SKILL.md`: triggered when first arg is `detach`. Parse: object name (arg 2), `from <parent-name>` (required), `--archive` flag (optional). Fetch tree (T008), resolve both object and parent names (T009). Derive `object_type`, `object_id`, `parent_type`, `parent_id` from matched nodes. If object is inherited, show error and stop.
- [ ] T027 [US5] Add confirmation + API call to detach flow in `skills/strategy/SKILL.md`: show "Detach '{object_name}' ({object_type} #{id}) from '{parent_name}'? {also_archive ? 'Object will also be archived.' : 'Object will be preserved (moved to unaligned).'} [y/N]", on confirm call `DELETE /strategy/{object_type}/{id}` with body `{parent_id, parent_type, also_archive}` per `contracts/delete-strategy.md`, show confirmation message.
- [ ] T028 [US5] Add error handling to detach flow: 403 → "You don't have permission to detach objects in this team.", 404 → "Strategy object or parent not found.", 204 → success (no body expected)

**Checkpoint**: All 5 user stories fully functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Finalize the skill for distribution and validate end-to-end.

- [ ] T029 Review `skills/strategy/SKILL.md` against `constitution.md` — verify all 9 principles are satisfied (I: skill format, II: self-contained, III: config-driven, IV: confirm writes with scoped allowed-tools, V: show IDs, VI: framework-aware, VII: direct execution, VIII: graceful degradation, IX: concise output)
- [ ] T030 Run `/sync-plugin` to bump plugin version and ensure `skills/strategy/` is included in the plugin manifest `.claude-plugin/plugin.json`
- [ ] T031 [P] Verify `skills/strategy/SKILL.md` is listed in `.claude-plugin/plugin.json` skills array
- [ ] T032 Run quickstart.md scenarios manually to validate all flows end-to-end
- [ ] T033 Run `/ship-it` to commit, push, and merge — then tell user to run `/plugin marketplace update`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001–T002 complete)
- **US1 (Phase 3)**: Depends on Phase 2 complete
- **US2 (Phase 4)**: Depends on Phase 2 complete; US1 not required but tree fetch (T008) and name resolution (T009) must be done
- **US3 (Phase 5)**: Depends on Phase 2 complete
- **US4 (Phase 6)**: Depends on Phase 2 complete
- **US5 (Phase 7)**: Depends on Phase 2 complete
- **Polish (Phase 8)**: Depends on all desired user stories complete

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2
- **US2 (P2)**: Independent after Phase 2 — reuses tree fetch + name resolution
- **US3 (P3)**: Independent after Phase 2 — reuses tree fetch + name resolution
- **US4 (P4)**: Independent after Phase 2 — reuses tree fetch + name resolution
- **US5 (P5)**: Independent after Phase 2 — reuses tree fetch + name resolution

### Within Each User Story

- Argument parsing + validation before API call
- Name resolution before any write API call
- Inherited node check before any write API call
- Confirmation prompt before any write API call
- Error handling added alongside each flow

### Parallel Opportunities

- T001 can start immediately
- Phase 3–7 can be worked in parallel once Phase 2 is done (all edit different SKILL.md sections)
- T029, T031 can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T010)
3. Complete Phase 3: User Story 1 (T011–T015)
4. **STOP and VALIDATE**: Run `/rkit:strategy` — verify tree displays correctly
5. Run `/sync-plugin` and ship if ready

### Incremental Delivery

1. Setup + Foundational → shared infrastructure ready
2. Add US1 → view strategy tree (most common operation)
3. Add US2 → create strategy objects (primary write operation)
4. Add US3 → update objects (status changes, renames)
5. Add US4 → align objects (tree organization)
6. Add US5 → detach objects (cleanup)
7. Polish + ship

---

## Notes

- All skill logic lives in `skills/strategy/SKILL.md` — this is a single-file Claude Code skill
- `api.sh` and `api-reference.md` are managed by master copies and distributed via `/sync-plugin`; never edit the copies inside `skills/strategy/` directly
- Object name resolution (T009) is foundational because US2–US5 all need it to resolve user-provided names to API-required IDs and object_types
- Framework label mapping (T010) is foundational because the tree display (US1) and all confirmations reference framework-aware labels
- The tree is fetched once per invocation and reused — no need to re-fetch between operations
