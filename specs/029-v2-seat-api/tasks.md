# Tasks: V2 Seat API Integration

**Input**: Design documents from `/specs/029-v2-seat-api/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/skill-commands.md, quickstart.md

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks are grouped by user story. US2 (Inspect Seat) requires no changes and has no tasks. All changes are in-place edits to `skills/seats/SKILL.md` and `api-reference.md`.

**Existing behavior (no tasks required)**: FR-007 (Show IDs), FR-011 (HTML strip accountabilities), FR-012 (team resolution via --team / default_team_id), FR-013 (API error display), FR-014 (framework-aware terminology) are all implemented in the current skill and require no changes for this feature.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files or independent sections)
- **[Story]**: Which user story this task belongs to

---

## Phase 1: Setup (Field Name Verification)

**Purpose**: Confirm V2 field names with a live API call before editing any files. These findings supersede assumptions in research.md.

- [x] T001 Verify root seat creation field: SKIPPED — no live config available; V2 spec field names (`group_id`, `accountability_owner_id`) applied directly per tasks.md note. Verify after deploying.
- [x] T002 [P] Verify owner assignment field: SKIPPED — no live config available; see T001.
- [x] T003 [P] Verify include_archived param: SKIPPED — no live config available; see T001.

---

## Phase 2: Foundational (api-reference.md Updates)

**Purpose**: Update the master `api-reference.md` before the skill, so the reference stays accurate and `/sync-plugin` can distribute it.

**⚠️ CRITICAL**: Complete Phase 1 first to confirm field names before editing docs.

- [x] T004 Update `api-reference.md` POST /seats row: change body docs from `team_id` to `group_id` for root seat creation (line ~500)
- [x] T005 [P] Update `api-reference.md` PATCH /seats/{id} row: change `seat_owner_id` to `accountability_owner_id` in the body field docs (line ~502)
- [x] T006 [P] Update `api-reference.md` GET /teams/{id}/seats row: confirm `include_archived=true` is a supported query param — remove `?` uncertainty from the params column (line ~499)

**Checkpoint**: api-reference.md now reflects V2 field names — skill edits can begin

---

## Phase 3: User Story 1 — View Team Accountability Chart (Priority: P1)

**Goal**: Users can view the full recursive accountability chart including archived seats via `--include-archived` flag.

**Independent Test**: Run `/rkit:seats` against a team with a multi-level tree and verify the tree renders. Run `/rkit:seats --include-archived` and verify archived seats appear with `[archived]` label.

- [x] T007 [US1] Add `--include-archived` row to the Argument Parsing table in `skills/seats/SKILL.md` (after the `*(no args)*` row)
- [x] T008 [US1] Update "Flow: View Accountability Chart — Step 2" in `skills/seats/SKILL.md`: when `--include-archived` is present, append `?include_archived=true` to the `GET /teams/{team_id}/seats` URL
- [x] T009 [US1] Update "Flow: View Accountability Chart — Step 3" tree rendering in `skills/seats/SKILL.md`: for each seat node where `archived: true`, append ` [archived]` to the output line

**Checkpoint**: `/rkit:seats` and `/rkit:seats --include-archived` both work correctly

---

## Phase 4: User Story 3 — Create and Update Seats (Priority: P3)

**Goal**: Create and update flows use the correct V2 field names: `group_id` for root seat creation and `accountability_owner_id` for owner assignment.

**Independent Test**: Create a root seat (no parent) and verify it succeeds. Update a seat's owner and verify it succeeds. Confirm the owner-change cascade note appears in the confirmation.

- [x] T010 [US3] Fix "Flow: Create Seat — Step 4" in `skills/seats/SKILL.md`: split into two cases — root seat body uses `{"name":"NAME","group_id":TEAM_ID}`, child seat body uses `{"name":"NAME","parent_id":PARENT_ID}` (remove the combined body with both fields)
- [x] T011 [US3] Fix "Flow: Update Seat — Step 2" flag mapping in `skills/seats/SKILL.md`: change `--owner {uid} → "seat_owner_id": {uid}` to `--owner {uid} → "accountability_owner_id": {uid}`
- [x] T012 [US3] Update "Flow: Update Seat — Step 3" confirmation in `skills/seats/SKILL.md`: when `--owner` flag is present, append "Note: changing the owner will reassign all aligned measures and goals to the new owner." to the confirm message

**Checkpoint**: `/rkit:seats create "CEO"` creates root seat; `/rkit:seats update {id} --owner {uid}` shows cascade note

---

## Phase 5: User Story 4 — Move, Archive, and Restore Seats (Priority: P4)

**Goal**: Delete confirmation communicates recursive archive behavior; restore confirmation communicates non-recursive behavior.

**Independent Test**: Run `/rkit:seats delete {id}` and verify the confirmation mentions "ALL descendants". Run `/rkit:seats restore {id}` and verify the confirmation mentions descendants remain archived.

- [x] T013 [US4] Update "Flow: Delete Seat — Step 2" confirmation in `skills/seats/SKILL.md`: change message to "Archive seat [ID: {id}]? This will archive this seat AND all its descendants. This cannot be undone without restoring each seat individually."
- [x] T014 [US4] Update "Flow: Restore Seat — Step 2" confirmation in `skills/seats/SKILL.md`: change message to "Restore seat [ID: {id}]? Only this seat will be restored — descendant seats remain archived and must be restored individually."

**Checkpoint**: Delete and restore confirmations clearly communicate recursive vs. non-recursive behavior

---

## Phase 6: User Story 5 — Manage Measures, Goals, and Links (Priority: P5)

**Goal**: Add the missing `update-link` command so users can edit an existing link's URL or title without removing and re-adding it.

**Independent Test**: Run `/rkit:seats update-link {id} --link {lid} --title "New Title"` and verify the link is updated and the result displays the new values.

- [x] T015 [US5] Add `update-link {id} --link {lid} [--url "..."] [--title "..."]` row to the Argument Parsing table in `skills/seats/SKILL.md` (after the `add-link` row)
- [x] T016 [US5] Add "Flow: Update Link" section to `skills/seats/SKILL.md` after the "Flow: Add Link" section with the following steps:
  - Step 1: Parse seat ID, `--link {lid}`, and optional `--url` / `--title` from args; error if neither `--url` nor `--title` provided
  - Step 2: Confirm: "Update link [ID: {lid}] on seat [ID: {id}]: {list of changes}?"
  - Step 3: Execute `PATCH /seats/{SEAT_ID}/links/{LID}` with `{"url":"...","title":"..."}` (include only provided fields)
  - Step 4: 200 → show updated link (ID, Title, URL); other errors → error handling table

**Checkpoint**: `/rkit:seats update-link {seat_id} --link {lid} --title "Wiki"` updates the link and shows the result

---

## Phase 7: Polish & Cross-Cutting

**Purpose**: Sync changes to all skill copies and close out the issue.

- [ ] T017 Run `/sync-plugin` to copy updated `api-reference.md` to `skills/seats/references/api-reference.md` and all other skill references, and bump the plugin version
- [ ] T018 [P] Run live verification steps from `quickstart.md` to confirm all 6 changes work end-to-end with the real API
- [ ] T019 Close GitHub Issue #19 with `gh issue close 19 --repo w3mg/resultkit-skills --comment "Implemented in 029-v2-seat-api: group_id fix, accountability_owner_id fix, --include-archived flag, update-link command, recursive archive/restore messaging."`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Verification)**: No dependencies — start immediately (requires live API config)
- **Phase 2 (api-reference.md)**: Depends on Phase 1 confirmation — BLOCKS sync in Phase 7
- **Phase 3–6 (User Stories)**: All depend on Phase 1 verification; can run in parallel after Phase 1
- **Phase 7 (Polish)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 (Phase 3)**: Independent — only touches chart view flow
- **US3 (Phase 4)**: Independent — only touches create/update flows
- **US4 (Phase 5)**: Independent — only touches delete/restore confirmation messages
- **US5 (Phase 6)**: Independent — adds a new flow section, no conflict with other changes
- **US2**: No changes required — seat detail view is correct as-is

### Parallel Opportunities

After Phase 1 verification:
- T004, T005, T006 can run in parallel (different rows in api-reference.md)
- T007–T009 (US1), T010–T012 (US3), T013–T014 (US4), T015–T016 (US5) can all run in parallel — they touch different sections of SKILL.md
- T018 and T019 can run in parallel once all edits are done

---

## Implementation Strategy

### MVP (User Story 1 + US3 field name fixes)

The highest-value changes are the field name corrections (T010–T011) and the `--include-archived` flag (T007–T009). These fix correctness issues. Start here.

1. Complete Phase 1: Verify field names
2. Complete Phase 2: Update api-reference.md
3. Complete Phase 3: Add `--include-archived` (US1)
4. Complete Phase 4: Fix field names in create/update (US3)
5. **STOP and VALIDATE**: Test chart view with archived seats, test create/update with correct fields
6. Continue with US4 (messaging) and US5 (update-link) as desired

### Full Delivery

1. Phase 1 → Phase 2 → Phases 3–6 in parallel → Phase 7
2. Total: 19 tasks across 7 phases

---

## Notes

- All changes are in-place edits — no new files created in `skills/seats/`
- T001–T003 require a configured `~/.config/resultkit/config.json`; skip and assume V2 spec field names if no config is available, then verify after deploying
- After T017 (`/sync-plugin`), the plugin version will be bumped — users must run `/plugin marketplace update` to get the fix
