# Tasks: Measure Data Source Fields

**Input**: Design documents from `specs/035-measure-data-source-30/`
**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, quickstart.md ✅

**Organization**: Tasks grouped by user story. US2 (api-reference docs) is completed first since it is the source of truth referenced by skill changes. US1 and US3 both modify `skills/scorecard/SKILL.md` via `/skill-creator` and must be done sequentially.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup

**Purpose**: Confirm current state of affected files before making changes.

- [X] T001 [P] Read current Measure fields documentation in `api-reference.md` (lines ~540–563) to confirm baseline before edits
- [X] T002 [P] Read `skills/scorecard/SKILL.md` Step 6 (List display jq) and Step 4 (Record name resolution) to confirm baseline before edits

**Checkpoint**: Baseline confirmed — ready to begin changes

---

## Phase 2: Foundational

No blocking prerequisites for this feature. All user story phases can proceed after Phase 1.

---

## Phase 3: User Story 2 — api-reference.md Reflects New Measure Fields (Priority: P1)

**Goal**: `api-reference.md` accurately documents `data_source_type` (always present), `roll_up_type` and `roll_up_measure_ids` (conditional on `data_source_type=3`) for GET, POST, and PATCH measures endpoints.

**Independent Test**: Open `api-reference.md` and verify: (1) Measure fields section lists `data_source_type` with values 0–3; (2) POST and PATCH bodies list roll-up optional params; (3) a note states roll-up fields are response-only when `data_source_type=3`; (4) 422 validation constraints are documented.

- [X] T003 [US2] Add `data_source_type` to Measure fields line in `api-reference.md` — append to the fields list at line ~553: `data_source_type` (integer: 0=manual, 1=google_sheets, 2=other_api, 3=roll_up, always present)
- [X] T004 [US2] Add roll-up conditional response fields note to `api-reference.md` after the Measure fields line — document that `roll_up_type` (`"sum"` | `"average"`) and `roll_up_measure_ids` (integer[]) appear in responses only when `data_source_type=3`
- [X] T005 [US2] Update `POST /teams/{id}/measures` row in `api-reference.md` — add optional body params: `data_source_type` (default 0), `roll_up_type`, `roll_up_measure_ids`
- [X] T006 [US2] Update `PATCH /measures/{id}` row in `api-reference.md` — add optional body params: `data_source_type`, `roll_up_type`, `roll_up_measure_ids`
- [X] T007 [US2] Add 422 validation constraints for roll-up fields to `api-reference.md` notes section — cross-team IDs, self-reference, circular references all return 422; `roll_up_type` must be `"sum"` or `"average"`

**Checkpoint**: `api-reference.md` updated — US2 complete and independently verifiable

---

## Phase 4: User Story 1 — View Scorecard with Roll-up Measures (Priority: P1) 🎯 MVP

**Goal**: `/rkit:scorecard` list view shows a `[roll-up: sum]` or `[roll-up: avg]` inline label on roll-up measures, following the existing `[archived]` label pattern.

**Independent Test**: Run `/rkit:scorecard` on a team with a roll-up measure — the measure name displays `[roll-up: sum]` or `[roll-up: average]`; manual measures are unchanged.

- [X] T008 [US1] Use `/skill-creator` to update the jq extraction in List Scorecard Step 6 of `skills/scorecard/SKILL.md` — in the `@tsv` block, append to the name field: `+ (if $m.data_source_type == 3 then " [roll-up: " + ($m.roll_up_type // "?") + "]" else "" end)` (place after the existing `[archived]` suffix logic; outputs "sum" or "average" verbatim from API)

**Checkpoint**: List view displays roll-up badge — US1 complete and independently verifiable

---

## Phase 5: User Story 3 — Scorecard Entry Respects data_source_type (Priority: P2)

**Goal**: Attempting to record a value for a roll-up measure (`data_source_type=3`) produces an informational message and stops — no API call is made.

**Independent Test**: Run `/rkit:scorecard record "Total Revenue" 500` where "Total Revenue" has `data_source_type=3` — expect message `"Total Revenue" is a roll-up measure (auto-calculated from other measures). Manual value entry is not supported.` with no confirmation prompt.

- [X] T009 [US3] Use `/skill-creator` to add roll-up entry guard to Record Value flow in `skills/scorecard/SKILL.md` — after Step 4 (Resolve measure name), before Step 5 (Confirm), insert: check `data_source_type` on the matched measure; if `=3`, print `"{MEASURE_NAME}" is a roll-up measure (auto-calculated from other measures). Manual value entry is not supported.` and stop

**Checkpoint**: Roll-up entry guard active — US3 complete and independently verifiable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, verify consistency.

- [X] T010 Run `/sync-plugin` to copy updated master `api-reference.md` to all `skills/*/references/api-reference.md` copies and bump plugin version
- [X] T011 Verify `skills/scorecard/references/api-reference.md` reflects the new measure fields after sync (spot-check `data_source_type` line)
- [X] T012 Commit all changes with message `Complete: Measure Data Source Fields (branch: 035-measure-data-source-30, closes #30)` per CLAUDE.md commit checklist (includes version bump and `git push`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US2 (Phase 3)**: Depends on Phase 1 completion; no dependency on skill phases
- **US1 (Phase 4)**: Depends on Phase 1 completion; US2 recommended first (reference accuracy) but not strictly blocking
- **US3 (Phase 5)**: Depends on Phase 4 completion (both modify same SKILL.md via `/skill-creator`; must be sequential)
- **Polish (Phase 6)**: Depends on US2 + US1 + US3 all complete

### User Story Dependencies

- **US2 (api-reference.md)**: Independent — touches only `api-reference.md`
- **US1 (SKILL.md list view)**: Independent of US2 — touches only `skills/scorecard/SKILL.md`
- **US3 (SKILL.md entry guard)**: Must follow US1 — same file, sequential `/skill-creator` sessions

### Parallel Opportunities

- T001 and T002 (Phase 1 setup reads) — fully parallel
- T003–T007 (US2 edits) — sequential within the same file
- US2 and US1 (Phase 3 and Phase 4) — can be worked in parallel by different developers if needed
- US3 must follow US1 (same SKILL.md file)

---

## Parallel Example: US2 + US1 (if two developers)

```text
Developer A: T003 → T004 → T005 → T006 → T007  (api-reference.md)
Developer B: T008                                 (SKILL.md list view)

Then together: T009 → T010 → T011 → T012
```

---

## Implementation Strategy

### MVP First (US2 + US1)

1. Complete Phase 1: Setup (T001, T002)
2. Complete Phase 3: US2 — update api-reference.md (T003–T007)
3. Complete Phase 4: US1 — update SKILL.md list view (T008)
4. **STOP and VALIDATE**: Run `/rkit:scorecard` to confirm roll-up badge displays
5. Continue to US3 (entry guard) if time allows

### Incremental Delivery

1. T001–T002 → baseline confirmed
2. T003–T007 → api-reference.md accurate
3. T008 → list view shows roll-up context (MVP)
4. T009 → entry guard prevents confusion
5. T010–T012 → ship

---

## Notes

- T008 and T009 MUST go through `/skill-creator` (project convention — not a numbered constitution rule)
- T010 (`/sync-plugin`) handles version bump automatically — do not manually bump before running it
- `[P]` tasks = different files, no blocking dependencies
- US1 and US3 touch the same SKILL.md — do not run their `/skill-creator` sessions concurrently
