---
description: "Tasks for fixing rkit:1on1 broken API endpoints, response shapes, and adding done-filter/notes flows"
---

# Tasks: Fix rkit:1on1 Endpoints (Issue #97)

**Input**: Design documents from `/specs/011-1on1/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks are grouped by user story. All changes target `skills/1on1/SKILL.md` (skill logic) and `api-reference.md` (docs). Each flow section in SKILL.md is independently editable — sections marked [P] do not overlap.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different non-overlapping file sections)
- **[Story]**: Which user story this task belongs to (US1–US6)

---

## Phase 1: Foundation (Blocking — API Reference Update)

**Purpose**: Update the master `api-reference.md` with correct `/1-on-1` endpoints before any skill edits. All skill copies reference this after sync.

**⚠️ CRITICAL**: Must complete before Phase 5 (sync step).

- [x] T001 Update Meetings section in `api-reference.md`: rename header to "One-on-Ones (1-on-1)", replace all `/meetings` endpoint paths with `/1-on-1`, update `team_id` param to `group_id`, document `persons` nesting and `items.issues` response shape, add `GET /1-on-1/{id}/done` and `PUT /1-on-1/{id}/notes` endpoints, update terminology glossary rows and "Attach item to meeting" row
- [x] T002 Update API Endpoints Used table in `specs/011-1on1/spec.md`: replace all `/meetings` paths with `/1-on-1`, update section endpoint from `GET /meetings/{id}/items/{section}` to `GET /1-on-1/{id}/items/{section}` and add `GET /1-on-1/{id}/done`, add `PUT /1-on-1/{id}/notes`

**Checkpoint**: API reference and spec reflect correct endpoints — skill edits can now begin.

---

## Phase 2: User Story 1 — List One-on-Ones (Priority: P1) 🎯 MVP

**Goal**: Fix the List flow so `GET /1-on-1` is called with the correct `group_id` param and person names render correctly from `persons.person1`/`persons.person2`.

**Independent Test**: Run `/rkit:1on1` (no args) — should list one-on-ones without 404. With `--team {id}`, should pass `group_id` not `team_id`.

- [x] T003 [US1] In `skills/1on1/SKILL.md` List flow Step 1 bash blocks: change `GET "/meetings?team_id=TEAM_ID&per_page=100"` to `GET "/1-on-1?group_id=TEAM_ID&per_page=100"` and `GET "/meetings?per_page=100"` to `GET "/1-on-1?per_page=100"`
- [x] T004 [US1] In `skills/1on1/SKILL.md` List flow Step 2 display rules: update `With` column logic to read `persons.person1` / `persons.person2` instead of top-level `person1` / `person2`; note that `human_name` (pre-formatted) is available as a display shortcut for the meeting title

**Checkpoint**: List flow returns real data. Other flows may still 404.

---

## Phase 3: User Story 2 — View One-on-One Detail (Priority: P1)

**Goal**: Fix the Detail flow so `GET /1-on-1/{id}` is called and the response is correctly parsed — sections under `items`, blocked called `issues`.

**Independent Test**: Run `/rkit:1on1 {id}` — should show three columns (next/done/blocked) without 404 or empty output from wrong field names.

- [x] T005 [US2] In `skills/1on1/SKILL.md` Detail flow Step 1 bash block: change `GET "/meetings/MEETING_ID"` to `GET "/1-on-1/MEETING_ID"`
- [x] T006 [US2] In `skills/1on1/SKILL.md` Detail flow Step 2 display section: update response parsing to read sections from `items.next`, `items.done`, `items.issues` (not top-level `next`, `done`, `blocked`); note that `items.issues` IS the "Blocked" column — display it under the "### Blocked" header; update archived-filter note to reference `items.issues`; update persons parsing to use `persons.person1` / `persons.person2`

**Checkpoint**: Detail view renders all three columns correctly.

---

## Phase 4: User Stories 3–6 — Single Column, Move, Add, Remove (Priority: P2/P3)

**Goal**: Fix the remaining CRUD flows — all use `/meetings/{id}/...` paths that need changing to `/1-on-1/{id}/...`.

**Independent Test**: Each flow: run the corresponding command (e.g., `/rkit:1on1 {id} next`) — should not 404.

- [x] T007 [P] [US3] In `skills/1on1/SKILL.md` View Single Column flow Step 1 bash block: change `GET "/meetings/MEETING_ID/items/COLUMN?per_page=50"` to `GET "/1-on-1/MEETING_ID/items/COLUMN?per_page=50"`; update the note below to reference `/1-on-1/{id}/items/{section}`; keep `next` and `blocked` as valid sections (done column is handled by the dedicated endpoint, not this flow — update trigger line to `{meeting_id} next` or `{meeting_id} blocked` only)
- [x] T008 [P] [US4] In `skills/1on1/SKILL.md` Move Item flow: confirm bash blocks already use `GET "/items/ITEM_ID"` and `PATCH "/items/ITEM_ID"` — if so, no change needed; if any block incorrectly references `/meetings/`, fix it to `/items/`; this task is complete when all Move flow bash blocks reference only `/items/` paths
- [x] T009 [P] [US5] In `skills/1on1/SKILL.md` Add Item flow bash blocks: change `POST "/meetings/MEETING_ID/items"` to `POST "/1-on-1/MEETING_ID/items"` and `PUT "/meetings/MEETING_ID/items/ITEM_ID"` to `PUT "/1-on-1/MEETING_ID/items/ITEM_ID"`
- [x] T010 [P] [US6] In `skills/1on1/SKILL.md` Remove Item flow bash block: change `DELETE "/meetings/MEETING_ID/items/ITEM_ID"` to `DELETE "/1-on-1/MEETING_ID/items/ITEM_ID"`

**Checkpoint**: All six user stories work end-to-end.

---

## Phase 5: Polish & New Flows

**Purpose**: Add the done-items dedicated endpoint flow and notes flow; update argument parsing table; sync and version bump.

- [x] T011 In `skills/1on1/SKILL.md` argument parsing table: add rows for `{meeting_id} done` → "View Done Items (dedicated endpoint)", `{meeting_id} done --since YYYY-MM-DD` → "View Done Items with Date Filter", `{meeting_id} notes "text"` → "Save Notes (Enhancement)"; update single-column trigger row to show `{meeting_id} next` / `{meeting_id} blocked` only (not done); add `{meeting_id} issues` as an alias row pointing to "View Single Column (blocked)" — per spec US3 which shows `{id} issues` as a valid invocation
- [x] T012 In `skills/1on1/SKILL.md`: add new "Flow: Done Items" section after View Single Column — trigger `{meeting_id} done` or `{meeting_id} done --since YYYY-MM-DD`; Step 1 fetches `GET "/1-on-1/MEETING_ID/done?per_page=50"` (or with `?since=DATE&per_page=50`); Step 2 displays same table format (ID, Name, Creator, Due); header shows "### Done since {date}" when `--since` provided; archived items excluded by API default
- [x] T013 **(Enhancement — not in original spec requirements; discovered via API inspection in issue #97)** In `skills/1on1/SKILL.md`: add new "Flow: Save Notes" section after Done Items — trigger `{meeting_id} notes "text"`; Step 1 validates notes text not empty; Step 2 confirms with user ("Save notes to one-on-one {meeting_id}? This will overwrite existing notes."); executes `PUT "/1-on-1/MEETING_ID/notes" '{"notes":"TEXT"}'`; Step 3 handles 200 success and errors; add "Empty notes text → warn and do not submit" to Edge Cases
- [x] T014 Sync updated `api-reference.md` to all skill copies by running `/sync-plugin` (or manually copying `api-reference.md` to each `skills/*/references/api-reference.md`) and bumping plugin version in `.claude-plugin/plugin.json`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundation (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Can start after Phase 1 (or in parallel if api-reference isn't needed yet)
- **US2 (Phase 3)**: Can start after Phase 1 — independent of US1 tasks
- **US3–US6 (Phase 4)**: Can start after Phase 1 — all independent of each other (different flow sections)
- **Polish (Phase 5)**: T011–T013 depend on Phases 2–4 (must update existing flows first); T014 depends on T001

### Within Phase 4

All four tasks (T007, T008, T009, T010) edit different, non-overlapping sections of SKILL.md and are safely parallelizable.

### Parallel Opportunities

- T003, T005 (list + detail endpoint changes) can run in parallel — different sections
- T007, T008, T009, T010 — all parallel (different flow sections)
- T012, T013 (new flows) — can be written in parallel, then T011 updates the dispatch table

---

## Parallel Example: Phase 4

```bash
# Launch all four US3–US6 flow fixes together — non-overlapping SKILL.md sections:
Task T007: Fix View Single Column bash block in skills/1on1/SKILL.md
Task T008: Verify Move Item bash blocks in skills/1on1/SKILL.md
Task T009: Fix Add Item bash blocks in skills/1on1/SKILL.md
Task T010: Fix Remove Item bash block in skills/1on1/SKILL.md
```

---

## Implementation Strategy

### MVP First (US1 + US2 — P1 Stories)

1. Complete Phase 1: Foundation (T001, T002)
2. Complete Phase 2: Fix List flow (T003, T004)
3. Complete Phase 3: Fix Detail view (T005, T006)
4. **STOP and VALIDATE**: List and detail views work end-to-end
5. Proceed to Phase 4 for remaining flows

### Full Fix

1. Foundation → US1 + US2 (P1) → US3–US6 (P2/P3) → Polish + new flows
2. Final sync (T014) after all skill edits complete

---

## Notes

- All flow changes are within `skills/1on1/SKILL.md` — no new files needed
- `PATCH /items/{id}` (Move flow) is NOT a `/meetings/` endpoint — no change needed there
- `human_name` field simplifies display name construction but isn't required — update if clean
- T014 (sync) must run last — it distributes the final api-reference.md to all skill copies
