# Tasks: 1on1 Skill — Filter Archived Items from Output

**Input**: Design documents from `specs/028-1on1-archive-filter/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)

---

## Phase 1: Setup

**Purpose**: Confirm working state before making changes.

- [x] T001 Read `skills/1on1/SKILL.md` in full to establish baseline before edits

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No cross-cutting prerequisites for this fix — both user stories are independent and affect different flows. Phase 2 is minimal.

- [x] T002 Verify live API behavior: call `GET /meetings/14` via `scripts/api.sh` and confirm that archived items appear in the `next` array with `status: "archived"`; call `GET /meetings/14/items/next` and confirm archived items are absent by default

**Checkpoint**: Root cause confirmed against live API. Ready for implementation.

---

## Phase 3: User Story 1 — View One-on-One Detail Without Archived Items (Priority: P1) 🎯 MVP

**Goal**: The View Detail flow filters archived items from `next`, `done`, and `blocked` columns before rendering.

**Independent Test**: Run `/rkit:1on1 14` and verify the Next column item count matches the website (no archived items shown).

- [x] T003 [US1] Update Display rules in Flow: View One-on-One Detail → Step 2 in `skills/1on1/SKILL.md`: add rule "Exclude items with `status: 'archived'` from all three columns before rendering; items with null/missing status are treated as active"; update column item count (`{count} items`) to reflect the filtered count

**Checkpoint**: Full 1:1 detail view matches website. User Story 1 independently testable.

---

## Phase 4: User Story 2 — Single Column View Already Correct (Priority: P2)

**Goal**: Confirm the single-column flow already excludes archived items via the API, and add a clarifying note to prevent future regression.

**Independent Test**: Run `/rkit:1on1 14 next` and verify item count matches the Next column from the website and from the full detail view.

- [x] T004 [US2] Add a comment to Flow: View Single Column in `skills/1on1/SKILL.md` noting that `GET /meetings/{id}/items/{section}` excludes archived items by API default (`include_archived` defaults to false) — no client-side filtering needed

**Checkpoint**: Single-column flow behavior documented. User Story 2 confirmed.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Verify edge cases and finalize.

- [x] T005 Confirm the Edge Cases section in `skills/1on1/SKILL.md` covers: "All items in a column are archived → show '(empty)'"; add this case if absent

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1
- **US1 (Phase 3)**: Depends on Phase 2 — primary fix
- **US2 (Phase 4)**: Depends on Phase 1 only — independent of US1 (no code change, just documentation)
- **Polish (Phase 5)**: Depends on Phase 3 completion

### Parallel Opportunities

- T004 (US2 — comment/doc only) and T003 (US1 — display rule change) are logically independent but both target `skills/1on1/SKILL.md` — execute sequentially to avoid edit conflicts

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (read SKILL.md)
2. Complete Phase 2: Verify live API behavior
3. Complete Phase 3: Add archived-item filter to View Detail display rules
4. **STOP and VALIDATE**: `/rkit:1on1 14` output matches website
5. Continue to US2 (Phase 4) and Polish (Phase 5)

### Incremental Delivery

1. Phase 3 complete → 1:1 detail view no longer shows archived items
2. Phase 4 complete → single-column behavior documented, regression risk eliminated
3. Phase 5 complete → edge case coverage confirmed

---

## Notes

- All edits target `skills/1on1/SKILL.md` — edit sequentially
- The fix is entirely client-side (display rule change); no API calls change
- No api-reference.md update needed — this is a skill behavior fix, not an API change
