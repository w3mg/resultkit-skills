---

description: "Task list template for feature implementation"
---

# Tasks: Monthly Measure Entry

**Input**: Design documents from `/specs/034-monthly-measure-entry-29/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. Phase 2 (api-reference.md) is foundational and must complete before skill phases.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

Single project — files at repo root:

```text
api-reference.md                          ← master API reference
skills/scorecard/SKILL.md                 ← scorecard skill
skills/scorecard/references/api-reference.md  ← synced copy (via /sync-plugin)
```

---

## Phase 1: Setup (API Verification)

**Purpose**: Confirm the live API accepts `period: "month"` before writing any code.

- [ ] T001 Call `POST /measures/{id}/history` with `{"date":"2026-03","value":"87","period":"month"}` via `scripts/api.sh` and confirm 200 response with `date: "2026-03-01"`

---

## Phase 2: Foundational (Update api-reference.md)

**Purpose**: Update the master API reference before skill changes — skills reference this doc.

**⚠️ CRITICAL**: Phases 3–4 can begin after this phase is complete.

- [X] T002 In `api-reference.md` under `## Team Scorecard Measures`, update the `POST /measures/{id}/history` row to document: optional `period` field (`"week"` | `"month"`), monthly date format (`YYYY-MM` or `YYYY-MM-01`, normalised to `YYYY-MM-01` in response), and that omitting `period` defaults to weekly (backward-compatible)

**Checkpoint**: `api-reference.md` accurately documents the extended endpoint — ready for skill updates.

---

## Phase 3: User Story 1 — Record a Monthly Scorecard Value (Priority: P1) 🎯 MVP

**Goal**: Admin can record a monthly measure value using `period=month` flag on the existing `record` command.

**Independent Test**: Run `/rkit:scorecard record "Measure Name" 87 period=month` as an admin — skill shows a month-aware confirmation, executes `POST /measures/{id}/history` with `period: "month"`, and confirms success with the normalised month date.

### Implementation for User Story 1

- [X] T003 [US1] In `skills/scorecard/SKILL.md` Argument Parsing table, extend the `record` row to: `record "NAME" VALUE [date=YYYY-MM-DD|YYYY-MM] [period=month]` with description "Record a value for a measure (weekly by default; add period=month for a monthly entry)"
- [X] T004 [US1] In `skills/scorecard/SKILL.md` Flow: Record Value, update the flow to handle `period=month`: (1) Step 1 — parse `PERIOD` from `period=...` arg (default `"week"`); if no `period=` arg was provided but the date argument is in `YYYY-MM-DD` format, ask the user "Record this as a weekly or monthly entry?" before proceeding (spec edge case); (2) Step 2 — when a natural-language month without a year (e.g., "March") is provided, resolve to the current year (`date +%Y`) without prompting; (3) Step 3 — when `PERIOD=month`, default date to `date +%Y-%m` instead of current Monday; if a `YYYY-MM-DD` date was provided with `period=month`, strip to `YYYY-MM`; (4) Step 5 — show `"for month of {DATE}"` in confirmation when monthly, `"for week of {DATE}"` when weekly; (5) Step 6 — include `"period": "month"` in API body only when monthly (weekly omits the field); (6) Step 7 — show measure ID, history entry ID, value, and `"for month of {DATE}"` in success message when monthly (Constitution V: all entity IDs required); (7) Error handling — 403: inform user that admin access is required (FR-006); 404: inform user the measure was not found and show the measure ID attempted — both inherited from existing error path

**Checkpoint**: `/rkit:scorecard record` works for monthly entries. US1 independently testable.

---

## Phase 4: User Story 2 — Clear Feedback on Invalid Monthly Entries (Priority: P2)

**Goal**: Invalid value or date format on a monthly entry produces a clear, actionable error message.

**Independent Test**: Run `/rkit:scorecard record "Name" n/a period=month` — skill reports "Value must be a number" without calling the API. Run with a valid value but bad date — skill surfaces the 422 error from the API.

### Implementation for User Story 2

- [X] T005 [US2] In `skills/scorecard/SKILL.md` Edge Cases section, add monthly-specific entries: (a) `period=month with non-numeric value` — caught client-side, same "Value must be a number" check; (b) `period=month with invalid date format` — API returns 422, skill surfaces error message; (c) `period=month with full date (YYYY-MM-DD)` — skill strips to YYYY-MM automatically (no error)
- [X] T006 [P] [US2] In `skills/scorecard/SKILL.md` frontmatter `description` field, add mention of monthly entry support (e.g., "recording weekly and monthly values"); in the `## Rules` section, note that `period=month` enables monthly entries

**Checkpoint**: All two user stories functional. Monthly entry recording fully supported.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, validate end-to-end, finalize.

- [X] T007 Run `/sync-plugin` to copy updated `api-reference.md` to all skill `references/` directories and bump the plugin patch version in `.claude-plugin/plugin.json`
- [X] T008 [P] Validate all changes with live API calls per `specs/034-monthly-measure-entry-29/quickstart.md` test commands (weekly no-regression + monthly entry + 422 cases)
- [X] T009 Commit all changes on branch `034-monthly-measure-entry-29` with a descriptive message

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: No dependencies on Phase 1 — can run in parallel with verification
- **US1 (Phase 3)**: Depends on Phase 2 complete
- **US2 (Phase 4)**: Depends on Phase 3 complete (edits same SKILL.md sections — T005 appends to edge cases written in T004 context; T006 edits frontmatter independently [P])
- **Polish (Phase 5)**: Depends on Phases 3–4 complete

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2 — no story dependencies
- **US2 (P2)**: Depends on US1 completing T003–T004 first (appends to same SKILL.md file)

### Within Each User Story

- T003 → T004 (US1: argument table first, then flow — same file, sequential)
- T005 → then T006 [P] (US2: edge cases first; frontmatter update is independent [P] but conventionally done after T005)

### Parallel Opportunities

- T001 (Phase 1) and T002 (Phase 2) can run in parallel
- T006 [P] (frontmatter) can run in parallel with T005 (different sections of same file — treat as separate edits if editor supports it; otherwise sequential)
- T008 [P] (validation) can run in parallel with T007 (sync-plugin)

---

## Parallel Example: Phase 1 + 2

```bash
# Launch together:
Task: "Verify POST /measures/{id}/history period=month via scripts/api.sh"  # T001
Task: "Update api-reference.md POST /measures/{id}/history row"             # T002
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: API Verification
2. Complete Phase 2: Update api-reference.md (CRITICAL — foundational)
3. Complete Phase 3: User Story 1 (monthly record flow)
4. **STOP and VALIDATE**: Run `/rkit:scorecard record "Name" 87 period=month` and confirm
5. If validating only P1, run `/sync-plugin` + commit

### Incremental Delivery

1. Phase 1 + 2 → API reference accurate ✓
2. Phase 3 (US1) → Monthly recording works ✓
3. Phase 4 (US2) → Validation errors are clear ✓
4. Phase 5 → Plugin synced and shipped ✓

### Single Developer Strategy

Work sequentially: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5.
Phases 1 and 2 can be done together (different files). Phase 3 before 4 (same file).

---

## Notes

- [P] tasks = different files or independent operations, no shared dependencies
- [Story] label maps each task to its user story for traceability
- T004 is the largest task — it modifies five steps within the existing Flow: Record Value section
- After skill changes, `/sync-plugin` is mandatory to propagate `api-reference.md` to skill reference copies
- Commit after each phase or logical group
