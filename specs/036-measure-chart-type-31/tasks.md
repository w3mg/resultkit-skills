# Tasks: Measure chart_type Field

**Input**: Design documents from `/specs/036-measure-chart-type-31/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Organization**: Tasks grouped by user story. All edits are to existing files — no new files created.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Foundational (Blocking Prerequisite)

**Purpose**: Update the master API reference with `chart_type` documentation. All skill edits are informed by this reference.

**⚠️ CRITICAL**: Complete this before any skill edits.

- [ ] T001 Update `api-reference.md` (master, repo root) to add `chart_type` to all 4 measure endpoints: add optional `chart_type?` to POST `/teams/{id}/measures` and PATCH `/measures/{id}` request bodies; add `chart_type` to GET `/teams/{id}/measures` and GET `/seats/{id}/measures` response shape notes; add validation note listing valid values and null semantics

**Checkpoint**: api-reference.md reflects full chart_type API contract — skill edits can begin

---

## Phase 2: User Story 1 — Display chart_type in Measure Listings (Priority: P1) 🎯 MVP

**Goal**: Skills that list measures surface the `chart_type` field so users can see the configured visualization preference.

**Independent Test**: Run `/rkit:scorecard` on any team — measures with a non-null `chart_type` show the value; measures with null show `—` or nothing. No errors for either case.

- [ ] T002 [US1] In `skills/scorecard/SKILL.md`, update the list view jq expression and table formatter to include a `chart_type` column; display the raw value when non-null and `—` when null; column should be rightmost in the measure table
- [ ] T003 [P] [US1] In `skills/seats/SKILL.md`, update the "200: Show updated measures list" output block in the `align-measure` and `remove-measure` flows to include `chart_type` in the measures table (shown when non-null, omitted when null)

**Checkpoint**: Listing measures in both scorecard and seats contexts shows chart_type cleanly

---

## Phase 3: User Story 2 — Set chart_type When Creating a Measure (Priority: P2)

**Goal**: The `add` command in the scorecard skill accepts an optional `chart_type=VALUE` argument, validates it against the enum, and includes it in the create request.

**Independent Test**: Run `/rkit:scorecard add "Test" chart_type=trend` — measure is created with chart_type: trend confirmed in response. Run with `chart_type=invalid` — error shown with valid options listed, no API call made.

- [ ] T004 [US2] In `skills/scorecard/SKILL.md`, update the `add` command (Flow: Add Measure section): parse optional `chart_type=VALUE` from args; validate against enum (`pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`) and error with valid list if invalid; include `chart_type` in the create body only when provided; update the command table entry to show `chart_type=...` as optional param; update success output to show chart_type when set

**Checkpoint**: Creating a measure with a chart type works in one step

---

## Phase 4: User Story 3 — Update/Clear chart_type on Existing Measure (Priority: P3)

**Goal**: The `update` command accepts `chart_type=VALUE` or `chart_type=null`, validates it, and sends it in the PATCH body only when explicitly provided (omitting the key preserves existing value).

**Independent Test**: Run `/rkit:scorecard update "Revenue" chart_type=bar_chart` — chart_type updated. Run `/rkit:scorecard update "Revenue" chart_type=null` — chart_type cleared. Run `/rkit:scorecard update "Revenue" name="New Name"` — chart_type unchanged.

- [ ] T005 [US3] In `skills/scorecard/SKILL.md`, update the `update` command (Flow: Update Measure section): parse optional `chart_type=VALUE` or `chart_type=null` from args; validate non-null values against enum and error with valid list if invalid; include `chart_type` in PATCH body only when explicitly provided (skip entirely when not passed); add `chart_type` to the change summary display; update usage error message and "no fields provided" guard to include `chart_type` as a valid field

**Checkpoint**: All three update scenarios (set, clear, omit) work correctly

---

## Phase 5: Polish & Propagation

**Purpose**: Propagate the updated api-reference.md to all skill copies and bump the plugin version.

- [ ] T006 Run `/sync-plugin` to copy `api-reference.md` to all `skills/*/references/api-reference.md` and bump the plugin patch version in `.claude-plugin/plugin.json`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Phase 1 (api-reference updated)
- **US2 (Phase 3)**: Depends on Phase 1; independent of US1
- **US3 (Phase 4)**: Depends on Phase 1; independent of US1 and US2
- **Polish (Phase 5)**: Depends on Phase 1 (api-reference.md must be final before sync)

### User Story Dependencies

- **US1**: Independent of US2 and US3
- **US2**: Independent of US1 and US3
- **US3**: Independent of US1 and US2

All three user story phases depend only on Phase 1 (Foundational) and can proceed in parallel after T001.

### Within Each User Story

- US1: T002 and T003 are independent (different files) — run in parallel
- US2: T004 is a single file edit — sequential
- US3: T005 is a single file edit — sequential

---

## Parallel Opportunities

### After T001 completes, all of these can run in parallel:

```
Task: T002 — scorecard list display (skills/scorecard/SKILL.md)
Task: T003 — seats measure display (skills/seats/SKILL.md)
Task: T004 — scorecard add command (skills/scorecard/SKILL.md)  ← same file as T002, coordinate
Task: T005 — scorecard update command (skills/scorecard/SKILL.md) ← same file as T002/T004, coordinate
```

**Note**: T002, T004, T005 all edit `skills/scorecard/SKILL.md`. If implementing in a single session, do them sequentially (T002 → T004 → T005) to avoid conflicts. T003 edits `skills/seats/SKILL.md` and can run truly in parallel.

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Complete T001 (Foundational)
2. Complete T002 + T003 (US1 — display only)
3. **STOP and VALIDATE**: List measures in scorecard and seats — chart_type shows correctly
4. Run T006 (sync)

This delivers read-only chart_type visibility with zero risk — no write paths changed.

### Full Delivery

1. T001 → T002 + T003 → T004 → T005 → T006
2. Each story is independently testable before moving to the next

---

## Notes

- No new files — all tasks are targeted edits to existing SKILL.md files and api-reference.md
- `chart_type` display is additive — existing measure output is unchanged when chart_type is null
- The enum (`pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`) must be consistent across all edits
- T006 (`/sync-plugin`) must run after T001 is finalized; it also bumps the plugin version
