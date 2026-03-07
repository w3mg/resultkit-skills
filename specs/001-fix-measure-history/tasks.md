# Tasks: Fix Measure History Display in Scorecard

**Input**: Design documents from `/specs/001-fix-measure-history/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)

---

## Phase 1: Setup

**Purpose**: No project initialization needed — `skills/scorecard/` already exists and `SKILL.md` is the only file being modified.

- [x] T001 Read `skills/scorecard/SKILL.md` Step 6 display jq expression to confirm it handles non-null `.value` correctly before making any changes

**Checkpoint**: Display logic confirmed correct — no display-side code changes needed.

---

## Phase 3: User Story 1 — View Weekly Scorecard History (Priority: P1) 🎯 MVP

**Goal**: Confirm the scorecard display correctly shows real history values now that the API returns non-null data.

**Independent Test**: Run `/rkit:scorecard` for a team with historical data and verify recorded weeks show actual values (not all "—").

### Implementation for User Story 1

- [ ] T002 [US1] Live API test: call `GET /teams/:id/measures` via `scripts/api.sh` and confirm `histories` contains non-null `value` fields for recorded weeks — no code change if confirmed
- [ ] T003 [US1] If T002 shows any display-side bug: fix jq expression in `skills/scorecard/SKILL.md` Step 6 (map build or column lookup) so non-null values render correctly

**Checkpoint**: `/rkit:scorecard` shows real values for recorded weeks, "—" for unrecorded weeks, no errors for any data state.

---

## Phase 4: User Story 2 — Record a New Weekly Value (Priority: P2)

**Goal**: Record success message includes the history entry ID returned by the API.

**Independent Test**: Run `/rkit:scorecard record "Measure Name" 5`, confirm response includes `(history ID: <integer>)`.

### Implementation for User Story 2

- [x] T004 [US2] Update Step 7 (Handle response) in `skills/scorecard/SKILL.md` record flow: extract `HISTORY_ID` with `jq -r '.body.data.id // "?"'` and include it in the 200 success message as `(history ID: {HISTORY_ID})`
- [ ] T005 [US2] Verify: run `/rkit:scorecard record` against live API and confirm (a) success message format is `"Recorded: {NAME} — {VALUE} for week of {DATE} (history ID: {ID})."` and (b) a follow-up `/rkit:scorecard` view shows the newly recorded value in the correct week slot (SC-003)

**Checkpoint**: Record flow shows history ID in confirmation; view after record shows the value in correct week column.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T006 Run `/sync-plugin` to copy updated `skills/scorecard/SKILL.md` to all plugin skill copies and bump plugin version
- [x] T007 Close GitHub Issue #22 after confirming both user stories pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies — start immediately
- **Phase 3 (US1)**: Depends on Phase 1 verification — pure read/test, no code change expected
- **Phase 4 (US2)**: Independent of US1 — can start immediately after Phase 1
- **Phase 5**: Depends on US1 and US2 both complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent — verify display, no code change expected
- **User Story 2 (P2)**: Independent — one-line fix to record success message

### Parallel Opportunities

- T002 (US1 live API test) and T004 (US2 SKILL.md edit) can run in parallel — different concerns

---

## Parallel Example

```
# US1 and US2 can proceed in parallel after T001:
T002: Live API call to verify display (US1)
T004: Edit SKILL.md record message (US2)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. T001: Inspect display jq expression
2. T002: Live API verification
3. T003: Fix if needed (likely no change)
4. **STOP and VALIDATE**: Scorecard shows real values

### Incremental Delivery

1. US1 (display verification) → confirm scorecard works
2. US2 (record ID in message) → one-line SKILL.md edit
3. Phase 5 → sync + close issue

---

## Notes

- This is a minimal feature: the display code was already correct; the only expected code change is the record success message (T004)
- T003 is conditional — only needed if live API testing reveals a display bug
- No tests in spec — manual live API verification is the validation method
- Total expected code change: ~2 lines in `skills/scorecard/SKILL.md`
