# Tasks: Fix 1on1 Skill API Endpoints

**Input**: Design documents from `/specs/001-fix-1on1-endpoints-gh97/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅  
**Tests**: Not requested — no test tasks generated.  
**Organization**: Tasks grouped by user story for independent implementation and verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- All changes are in `skills/1on1/SKILL.md` and the two copies of `api-reference.md`

---

## Phase 1: Foundational — Live API Verification

**Purpose**: Resolve the four open unknowns from research.md before writing any skill code. These verifications block all user story implementation.

**⚠️ CRITICAL**: Use `scripts/api.sh` to call the real API. Update `specs/001-fix-1on1-endpoints-gh97/research.md` with findings. No coding until verification is done.

- [ ] T001 Verify `GET /1-on-1?group_id={id}&per_page=5` returns 200 with meetings list — run `scripts/api.sh GET "/1-on-1?group_id=TEAM_ID&per_page=5"` and record actual response shape in research.md
- [ ] T002 Verify `GET /1-on-1/{id}` returns 200 with `persons` and `items` nested objects — run `scripts/api.sh GET "/1-on-1/MEETING_ID"` and confirm `persons.person1`, `items.done`, `items.issues`, `items.next` structure
- [ ] T003 Verify single-column endpoint — test `scripts/api.sh GET "/1-on-1/MEETING_ID/items?status=active"` and `scripts/api.sh GET "/1-on-1/MEETING_ID/done"` and record which paths work and what params they accept in research.md
- [ ] T004 Verify item attachment endpoints — test `scripts/api.sh PUT "/1-on-1/MEETING_ID/items/ITEM_ID"` and `scripts/api.sh DELETE "/1-on-1/MEETING_ID/items/ITEM_ID"` and record 200/404/other in research.md
- [ ] T005 Verify status values — test `scripts/api.sh PATCH "/items/ITEM_ID" '{"status":"active"}'` on a 1on1 item and confirm `active`/`realized` are accepted (vs `next`/`done`) — record in research.md

**Checkpoint**: research.md updated with verified endpoint behavior. All four unknowns resolved. Implementation can now begin.

---

## Phase 2: User Story 1 — List One-on-Ones (Priority: P1) 🎯 MVP

**Goal**: `GET /1-on-1` is called correctly with `group_id` filter; meetings list displays.

**Independent Test**: Run `/rkit:1on1` — a table of one-on-one meetings appears (no 404 error). With a configured default team, the list is scoped to that team.

- [ ] T006 [US1] In `skills/1on1/SKILL.md` Flow "List One-on-Ones" Step 1: replace `GET "/meetings?team_id=TEAM_ID&per_page=100"` with `GET "/1-on-1?group_id=TEAM_ID&per_page=100"` and replace `GET "/meetings?per_page=100"` with `GET "/1-on-1?per_page=100"`
- [ ] T007 [US1] In `skills/1on1/SKILL.md` Flow "List One-on-Ones" Step 2 display rules: replace `person1`/`person2` top-level field references with `persons.person1`/`persons.person2` nested access

**Checkpoint**: `/rkit:1on1` returns a meeting list without 404.

---

## Phase 3: User Story 2 — View One-on-One Detail (Priority: P1)

**Goal**: `GET /1-on-1/{id}` is called; detail renders with correct persons and column mapping.

**Independent Test**: Run `/rkit:1on1 {id}` — three-column view shows with correct participant names and items in the right columns.

- [ ] T008 [US2] In `skills/1on1/SKILL.md` Flow "View One-on-One Detail" Step 1: replace `GET "/meetings/MEETING_ID"` with `GET "/1-on-1/MEETING_ID"`
- [ ] T009 [US2] In `skills/1on1/SKILL.md` Flow "View One-on-One Detail" Step 2: update response parsing to read items from `items.next`, `items.done`, `items.issues` (replace references to top-level `next`, `done`, `blocked` arrays)
- [ ] T010 [US2] In `skills/1on1/SKILL.md` Flow "View One-on-One Detail" Step 2: update heading format to read person names from `persons.person1` and `persons.person2` (nested), map `items.issues` → Blocked column in display

**Checkpoint**: `/rkit:1on1 {id}` shows three columns with correct items and names.

---

## Phase 4: User Story 3 — Add / Remove Items (Priority: P2)

**Goal**: Create, attach, and detach item endpoints use `/1-on-1/{id}/items` path.

**Independent Test**: Run `/rkit:1on1 {id} add "text"` — item is created and confirmed. Run `/rkit:1on1 {id} remove {item_id}` — item is detached.

- [ ] T011 [US3] In `skills/1on1/SKILL.md` Flow "Add Item" Step 2 (new item): replace `POST "/meetings/MEETING_ID/items"` with `POST "/1-on-1/MEETING_ID/items"`
- [ ] T012 [US3] In `skills/1on1/SKILL.md` Flow "Add Item" Step 2 (existing item): update `PUT "/meetings/MEETING_ID/items/ITEM_ID"` to `PUT "/1-on-1/MEETING_ID/items/ITEM_ID"` if verified in T004; otherwise remove the "add existing item" flow and note it as unverified
- [ ] T013 [US3] In `skills/1on1/SKILL.md` Flow "Remove Item" Step 1: update `DELETE "/meetings/MEETING_ID/items/ITEM_ID"` to `DELETE "/1-on-1/MEETING_ID/items/ITEM_ID"` if verified in T004; otherwise remove the flow and note it as unverified

**Checkpoint**: Adding a new item to a one-on-one works end-to-end without 404.

---

## Phase 5: User Story 4 — View Single Column (Priority: P2)

**Goal**: Single-column view uses the verified endpoint path and status param.

**Independent Test**: Run `/rkit:1on1 {id} next` — only next items display without error.

- [ ] T014 [US4] In `skills/1on1/SKILL.md` Flow "View Single Column" Step 1: replace `GET "/meetings/MEETING_ID/items/COLUMN?per_page=50"` with the verified endpoint from T003 (e.g., `GET "/1-on-1/MEETING_ID/items?status=active&per_page=50"` or `GET "/1-on-1/MEETING_ID/done"`)
- [ ] T015 [US4] In `skills/1on1/SKILL.md` Flow "View Single Column" Step 1: update column-to-path/status mapping table to use verified values from T003 and T005 (e.g., `next` → `status=active`, `done` → `status=realized` or `/done` endpoint)

**Checkpoint**: `/rkit:1on1 {id} next`, `done`, and `blocked` all return correct items.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Update documentation and edge-case copy to match real API. These run after all flows are verified working.

- [ ] T016 [P] In root `api-reference.md`: rewrite the `## Meetings` section (lines ~707–723) to document real `/1-on-1` endpoints — correct paths, `group_id` param, nested `persons` response shape, `items.done/issues/next` detail shape, and status values (`active`, `realized`)
- [ ] T017 [P] In `skills/1on1/SKILL.md` Edge Cases section: update "Meeting not found (404)" wording to reference `/1-on-1/{id}` path; update any remaining `/meetings` references in comments or notes
- [ ] T018 Run `/sync-plugin` to copy updated root `api-reference.md` to `skills/1on1/references/api-reference.md` and bump plugin version
- [ ] T019 Close GitHub issue #97 by running `/ship-it` to merge branch, commit, push, and post implementation summary

**Checkpoint**: All flows tested, api-reference.md updated in both locations, issue #97 closed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Foundational)**: No dependencies — start immediately
- **Phase 2 (US1)**: Depends on Phase 1 (T001 must complete — list endpoint verified)
- **Phase 3 (US2)**: Depends on Phase 1 (T002 must complete — detail endpoint verified)
- **Phase 4 (US3)**: Depends on Phase 1 (T004 must complete — attach/detach endpoints verified)
- **Phase 5 (US4)**: Depends on Phase 1 (T003, T005 must complete — single-column endpoint verified)
- **Phase 6 (Polish)**: Depends on Phases 2–5 all complete

### User Story Dependencies

- **US1 (P1)**: Can start after T001 — no dependency on US2/US3/US4
- **US2 (P1)**: Can start after T002 — no dependency on US1/US3/US4
- **US3 (P2)**: Can start after T004 — no dependency on US1/US2
- **US4 (P2)**: Can start after T003 + T005 — no dependency on other stories

### Parallel Opportunities

- T001–T005 (verification tasks) can run in parallel if multiple API calls are made simultaneously
- T006–T007 (US1) and T008–T010 (US2) can run in parallel after Phase 1 — they touch different flows in SKILL.md but same file, so coordinate to avoid conflicts
- T016 and T017 (Polish) can run in parallel — different files

---

## Parallel Example: Verification Phase

```bash
# Run all API verifications together (Phase 1):
scripts/api.sh GET "/1-on-1?group_id=TEAM_ID&per_page=5"
scripts/api.sh GET "/1-on-1/MEETING_ID"
scripts/api.sh GET "/1-on-1/MEETING_ID/items?status=active"
scripts/api.sh PUT "/1-on-1/MEETING_ID/items/ITEM_ID"
scripts/api.sh PATCH "/items/ITEM_ID" '{"status":"active"}'
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Verify list and detail endpoints (T001, T002)
2. Complete Phase 2: Fix list endpoint in SKILL.md (T006, T007)
3. Complete Phase 3: Fix detail endpoint and response parsing (T008–T010)
4. **STOP and VALIDATE**: Test `/rkit:1on1` and `/rkit:1on1 {id}` independently
5. The skill's primary value (browsing meetings) is now restored

### Full Delivery

1. MVP above
2. Add Phase 4 (US3) — fix write operations
3. Add Phase 5 (US4) — fix single-column view
4. Phase 6 — polish docs and close issue

---

## Notes

- All code changes are confined to `skills/1on1/SKILL.md` — one file
- Documentation changes: root `api-reference.md` (master), then `/sync-plugin` for skill copy
- Never edit `skills/1on1/references/api-reference.md` directly — it's synced from root
- If T004 shows attach/detach endpoints don't exist on `/1-on-1`, remove those flows rather than leaving broken code
- Commit after each phase checkpoint to preserve working increments
