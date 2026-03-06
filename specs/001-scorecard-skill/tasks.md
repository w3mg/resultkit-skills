# Tasks: Scorecard Skill (rkit:scorecard)

**Input**: Design documents from `/specs/001-scorecard-skill/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.
**Tests**: Not requested — no test tasks generated.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup

**Purpose**: Create the skill directory structure and update the API reference with the 5 new endpoints. Must complete before any implementation.

- [x] T001 Create skill directory structure: `skills/scorecard/`, `skills/scorecard/scripts/`, `skills/scorecard/references/` (empty dirs — files come from sync)
- [x] T002 Add "Team Scorecard Measures" section to master `api-reference.md` covering all 5 endpoints: `GET /teams/:id/measures`, `POST /teams/:id/measures`, `PATCH /measures/:id`, `DELETE /measures/:id`, `POST /measures/:id/history` — include request params, response shape, and natural-language synonyms per existing `api-reference.md` table format
- [x] T003 Run `/sync-plugin` to copy `api-reference.md` and `api.sh` into `skills/scorecard/references/` and `skills/scorecard/scripts/` and bump plugin version

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the SKILL.md entry point with frontmatter, config loading, api.sh path resolution, team ID resolution, and shared measure name resolution logic. These are used by every user story.

**⚠️ CRITICAL**: All user story phases depend on this foundation being in place.

- [x] T004 Create `skills/scorecard/SKILL.md` with frontmatter block: `name: rkit:scorecard`, description covering scorecard viewing/recording/managing measures, `user-invocable: true`, `disable-model-invocation: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion` — reference `skills/seats/SKILL.md` frontmatter as the pattern
- [x] T005 Add **Current State** section to `skills/scorecard/SKILL.md`: inline Bash commands to read `~/.config/resultkit/config.json` (masked token display) and resolve `api.sh` path using the multi-path probe pattern from `skills/seats/SKILL.md`
- [x] T006 Add **Rules** section to `skills/scorecard/SKILL.md`: confirm writes (GET immediate, POST/PATCH/DELETE require confirmation), show IDs, concise output, direct execution (Bash + api.sh, no agents), framework-aware terminology (EOS → "Measurables" instead of "Measures")
- [x] T007 Add **Argument Parsing** table to `skills/scorecard/SKILL.md` covering: no args (list), `--year YYYY`, `--include-archived`, `record <name> <value> [date=YYYY-MM-DD]`, `add <name> [unit=...] [direction=...] [target=...]`, `update <name> [name=...] [unit=...] [direction=...] [target=...]`, `archive <name>`
- [x] T008 Add **Team ID Resolution** section to `skills/scorecard/SKILL.md`: (1) `--team {id}` flag, (2) `default_team_id` from config, (3) error → "No default team configured. Run `/rkit:setup` first."
- [x] T009 Add **Measure Name Resolution** section to `skills/scorecard/SKILL.md`: call `GET /teams/:id/measures?include_archived=true` to get full list, case-insensitive exact match first, then substring match, multiple matches → show numbered disambiguation list and stop, no match → "No measure found matching '{name}'."

**Checkpoint**: SKILL.md has frontmatter + shared infrastructure. Ready for user story flows.

---

## Phase 3: User Story 1 — View Team Scorecard (Priority: P1) 🎯 MVP

**Goal**: User runs `/rkit:scorecard` and sees all active measures with last 4 weeks of history in a readable table.

**Independent Test**: Run `/rkit:scorecard` — verify table of measures with name, ID, unit, direction, target, owner, and 4 recent weekly values. Run `/rkit:scorecard --include-archived` — verify archived measures appear with `[archived]` label. See `quickstart.md` Scenarios 1.

- [x] T010 [US1] Add **Flow: List Scorecard** section to `skills/scorecard/SKILL.md`: triggered when no args (or only `--year`/`--include-archived` flags). Call `GET /teams/:id/measures?year=$YEAR&include_archived=$INCLUDE_ARCHIVED` via api.sh, handle pagination (loop `page` until `meta.total_pages` is reached, accumulating all measures), display as a Markdown table with columns: ID, Name, Unit, Direction, Target, Owner, and one column per calendar week date for the last 4 weeks (show blank/em-dash for unrecorded slots, not skipping null-value weeks) — per `contracts/list-measures.md` display format
- [x] T011 [US1] Add empty-state handling to the **Flow: List Scorecard** section in `skills/scorecard/SKILL.md`: if `data` array is empty and `--include-archived` not set, show "No active measures on this scorecard. Use `/rkit:scorecard add <name>` to create one."
- [x] T012 [US1] Add framework-aware header to **Flow: List Scorecard** in `skills/scorecard/SKILL.md`: read team `framework` field from config or team API response, use "Measurables" for EOS teams and "Measures" for all others in the table header and output labels
- [x] T013 [US1] Add error handling to **Flow: List Scorecard** in `skills/scorecard/SKILL.md`: 401 → "Auth failed. Run /rkit:setup.", 403 → "You don't have permission to view this team's scorecard.", 404 → "Team ID {id} not found.", other → show HTTP status + API error message

**Checkpoint**: US1 complete — `/rkit:scorecard` shows a scorecard table.

---

## Phase 4: User Story 2 — Record a Weekly Value (Priority: P2)

**Goal**: User runs `/rkit:scorecard record "Measure Name" 42` and a weekly value is upserted for the current Monday (or specified date).

**Independent Test**: Record a value for an existing measure; confirm with `y`; run `/rkit:scorecard` and verify the value appears in the correct week column. See `quickstart.md` Scenario 2.

- [x] T014 [US2] Add **Flow: Record Value** section to `skills/scorecard/SKILL.md`: triggered when first arg is `record`. Parse measure name (arg 2) and value (arg 3). Validate value is numeric client-side (matches `^-?[0-9]+(\.[0-9]+)?$`) — if not, show "Value must be a number." and stop without API call. Resolve measure name via shared resolution logic (T009). Compute current Monday date using `date -d "$(date +%Y-%m-%d) - $(date +%u) days + 1 day" +%Y-%m-%d` (Linux) with macOS fallback. If `date=YYYY-MM-DD` arg provided, use that instead.
- [x] T015 [US2] Add confirmation + API call to **Flow: Record Value** in `skills/scorecard/SKILL.md`: show "Record value '{value}' for '{name}' (ID: {id}) for week of {date}? [y/N]", on confirm call `POST /measures/:id/history` with `{"date":"$DATE","value":"$VALUE"}` via api.sh per `contracts/record-history.md`, show "Recorded: {name} — {value} for week of {date}."
- [x] T016 [US2] Add error handling to **Flow: Record Value** in `skills/scorecard/SKILL.md`: 422 → show API error message (non-numeric value or invalid date from server), 403 → "You don't have permission to record values for this team.", 404 → "Measure not found."

**Checkpoint**: US1 + US2 both independently functional.

---

## Phase 5: User Story 3 — Create a Measure (Priority: P3)

**Goal**: User runs `/rkit:scorecard add "Name"` (with optional unit/direction/target) and a new measure is created on the team scorecard.

**Independent Test**: Create a measure with name only; confirm; run `/rkit:scorecard` and verify new measure appears. See `quickstart.md` Scenario 3.

- [x] T017 [US3] Add **Flow: Create Measure** section to `skills/scorecard/SKILL.md`: triggered when first arg is `add`. Parse: name (required, arg 2), `unit=...`, `direction=...`, `target=...` from remaining args. If name is missing or blank, show "Measure name is required." and stop.
- [x] T018 [US3] Add confirmation + API call to **Flow: Create Measure** in `skills/scorecard/SKILL.md`: show "Create measure '{name}' (unit: {unit|none}, direction: {direction}, target: {target|none})? [y/N]", on confirm call `POST /teams/:id/measures` with `{"measure":{"name":"$NAME","unit":"$UNIT","direction":"$DIR","target_value":"$TARGET"}}` (omit null fields) per `contracts/create-measure.md`, show "Created: {name} (ID: {id})."
- [x] T019 [US3] Add error handling to **Flow: Create Measure** in `skills/scorecard/SKILL.md`: 422 → show API error message, 403 → "You don't have permission to add measures to this team."

**Checkpoint**: US1 + US2 + US3 all independently functional.

---

## Phase 6: User Story 4 — Update or Archive a Measure (Priority: P4)

**Goal**: User runs `/rkit:scorecard update "Name" target=100` or `/rkit:scorecard archive "Name"` to modify or soft-delete a measure.

**Independent Test**: Update a measure's target; run `/rkit:scorecard` and verify the new target appears. Archive a measure; run `/rkit:scorecard` and verify it's gone from default view; run with `--include-archived` and verify it appears with `[archived]` label. See `quickstart.md` Scenarios 4–5.

- [x] T020 [US4] Add **Flow: Update Measure** section to `skills/scorecard/SKILL.md`: triggered when first arg is `update`. Parse measure name (arg 2) and any combination of `name=...`, `unit=...`, `direction=...`, `target=...` from remaining args. Resolve measure name via shared logic (T009). Build partial JSON body with only the provided fields.
- [x] T021 [US4] Add confirmation + API call to **Flow: Update Measure** in `skills/scorecard/SKILL.md`: show "Update '{name}' (ID: {id}) — set {field list}? [y/N]", on confirm call `PATCH /measures/:id` with `{"measure":{...fields...}}` per `contracts/update-measure.md`, show "Updated: {name}." with changed fields.
- [x] T022 [US4] Add **Flow: Archive Measure** section to `skills/scorecard/SKILL.md`: triggered when first arg is `archive`. Resolve measure name (T009). Show "Archive '{name}' (ID: {id})? It will be hidden from the default scorecard view. [y/N]", on confirm call `DELETE /measures/:id` per `contracts/archive-measure.md`, show "Archived: {name} (ID: {id}). It will no longer appear in the default scorecard view."
- [x] T023 [US4] Add error handling to both update and archive flows in `skills/scorecard/SKILL.md`: 403 → "You don't have permission to edit this measure.", 404 → "Measure not found.", 422 → show API error message

**Checkpoint**: All 4 user stories fully functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Finalize the skill for distribution and validate end-to-end.

- [x] T024 Review `skills/scorecard/SKILL.md` against `constitution.md` — verify all 9 principles are satisfied (I: skill format, II: self-contained, III: config-driven, IV: confirm writes with scoped allowed-tools, V: show IDs, VI: framework-aware, VII: direct execution, VIII: graceful degradation, IX: concise output)
- [x] T025 Run `/sync-plugin` to bump plugin version and ensure `skills/scorecard/` is included in the plugin manifest `.claude-plugin/plugin.json`
- [x] T026 [P] Verify `skills/scorecard/SKILL.md` is listed in `.claude-plugin/plugin.json` skills array
- [x] T027 Run quickstart.md Scenarios 1–6 manually to validate all flows end-to-end
- [x] T028 Run `/ship-it` to commit, push, and merge — then tell user to run `/plugin marketplace update`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001–T003 complete)
- **US1 (Phase 3)**: Depends on Phase 2 complete
- **US2 (Phase 4)**: Depends on Phase 2 complete; US1 not required but name resolution (T009) must be done
- **US3 (Phase 5)**: Depends on Phase 2 complete; US1/US2 not required
- **US4 (Phase 6)**: Depends on Phase 2 complete; US1/US2/US3 not required
- **Polish (Phase 7)**: Depends on all desired user stories complete

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2
- **US2 (P2)**: Independent after Phase 2 — reuses name resolution from T009
- **US3 (P3)**: Independent after Phase 2
- **US4 (P4)**: Independent after Phase 2 — reuses name resolution from T009

### Within Each User Story

- Argument parsing + validation before API call
- Confirmation prompt before any write API call
- Error handling added alongside each flow

### Parallel Opportunities

- T001, T002 can run in parallel (different files)
- Phase 3, 4, 5, 6 can be worked in parallel once Phase 2 is done (all edit different SKILL.md sections, though careful coordination needed for single-file edits)
- T024, T026 can run in parallel

---

## Parallel Example: Phase 2

```text
# All foundational SKILL.md sections can be drafted in parallel (different sections):
T004: Frontmatter block
T005: Current State section
T006: Rules section
T007: Argument Parsing table
T008: Team ID Resolution section
T009: Measure Name Resolution section

# Then assemble into final SKILL.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T009)
3. Complete Phase 3: User Story 1 (T010–T013)
4. **STOP and VALIDATE**: Run `/rkit:scorecard` — verify scorecard table appears
5. Run `/sync-plugin` and ship if ready

### Incremental Delivery

1. Setup + Foundational → shared infrastructure ready
2. Add US1 → view scorecard (most common operation)
3. Add US2 → record weekly values (most frequent write)
4. Add US3 → create measures (setup operation)
5. Add US4 → update + archive (maintenance operations)
6. Polish + ship

---

## Notes

- All skill logic lives in `skills/scorecard/SKILL.md` — this is a single-file Claude Code skill
- `api.sh` and `api-reference.md` are managed by master copies and distributed via `/sync-plugin`; never edit the copies inside `skills/scorecard/` directly
- Measure name resolution (T009) is foundational because US2, US4 depend on it; US3 does not (new measures don't need resolution)
- Constitution Principle X: Use `/skill-creator` skill when iterating on SKILL.md content quality and evals
- The `001-` prefix conflicts with `001-setup` — consider renaming to `031-scorecard-skill` post-implementation
