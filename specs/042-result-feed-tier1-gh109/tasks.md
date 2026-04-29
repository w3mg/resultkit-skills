# Tasks: Update Result-Feed Skill for Tier 1 Backend API Changes

**Input**: Design documents from `/specs/042-result-feed-tier1-gh109/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md
**GitHub Issue**: #109

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US7)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Verify current state and confirm API behavior before making changes

- [X] T001 Call `GET /result-feed/today` via `scripts/api.sh` and confirm response sections are structured objects (`{ items, notes, attachments }`) — not flat arrays. Record actual field names for comparison with SKILL.md.
- [X] T002 Call `POST /result-feed/today/reactions` via `scripts/api.sh` (with body `{"user_id": YOUR_ID}`) and confirm endpoint path and response shape (`reacted`, `count`). Also test `GET /result-feed/today/reactions?user_id=N`.
- [X] T003 Call `GET /teams/TEAM_ID` via `scripts/api.sh` and confirm `has_slack_webhook` and `has_discord_webhook` fields are present in the response.

**Checkpoint**: API behavior verified — proceed with documentation and skill updates.

---

## Phase 2: Foundational — API Reference Update

**Purpose**: Update the master `api-reference.md` so all downstream skill work references correct endpoints. This BLOCKS all SKILL.md changes.

- [X] T004 [US7] Fix the reactions endpoint entry in `api-reference.md`: change path from `/result-feed/{date}/react` to `/result-feed/{date}/reactions` and update response shape from `{ high_five_count, user_has_reacted }` to `{ reacted: boolean, count: integer }`.
- [X] T005 [P] [US7] Add `GET /result-feed/{date}/reactions` endpoint entry in `api-reference.md` with query param `user_id` and response `{ data: { reacted, count } }`.
- [X] T006 [P] [US7] Add `POST /result-feed/{date}/attachments` (file upload) endpoint entry in `api-reference.md` with multipart/form-data body, response `{ data: { id, filename, content_type, filesize, parent_object_type } }`, and error codes (400, 413).
- [X] T007 [P] [US7] Fix push-to-slack and push-to-discord entries in `api-reference.md`: change body param from `team_id` to `group_context_id`.
- [X] T008 [P] [US7] Update `PUT /result-feed/{date}/{section}` entry in `api-reference.md` to list `review` as a valid section alongside `done`, `next`, `blocked`.
- [X] T009 [P] [US7] Update `GET /result-feed/{date}` entry in `api-reference.md` to document `review` section in the response and document structured section shape (`{ items, notes, attachments }`) with attachment shape `{ id, filename, content_type, size }`.
- [X] T010 [P] [US7] Fix comment endpoint entries in `api-reference.md`: update response field from `body` to `comment` in both GET and POST `/result-feed/{date}/comments`. Add `user_id` query param to GET and `user_id` body param to POST.
- [X] T011 [P] [US7] Update `POST /result-feed/{date}/submit` entry in `api-reference.md` to document server-side side effects: ObjectMeta upsert (`last_status_provided`), daily recurrence item rollover.
- [X] T012 [P] [US7] Update glossary/synonym section in `api-reference.md`: fix reactions synonym from `/react` to `/reactions`, add "upload file" / "attach file" synonyms pointing to `/result-feed/{date}/attachments`, add "show reactions" / "reaction count" synonyms.

**Checkpoint**: `api-reference.md` is now accurate for all result-feed endpoints.

---

## Phase 3: User Story 1 — Fix Breaking Section Shape (Priority: P1) 🎯 MVP

**Goal**: Ensure SKILL.md correctly parses the new structured section objects so existing functionality doesn't break.

**Independent Test**: Run `/rkit:result-feed` → verify items display, notes appear when non-null, attachments show filename/type/size.

### Implementation for User Story 1

- [X] T013 [US1] Update section parsing in `skills/result-feed/SKILL.md` to access items via `section.items` (structured object) instead of treating sections as flat arrays. Apply to all section reads in `view_team_feeds`, `view_team_member_report`, and any other flow that reads section data.
- [X] T014 [US1] Update the Attachment schema in `skills/result-feed/SKILL.md` from `{ id, filename, url }` to `{ id, filename, content_type, size }`.
- [X] T015_a [US1] Update section rendering rules in `skills/result-feed/SKILL.md` to display attachments as `> Attachments: filename1 (content_type, size), filename2 (content_type, size)` instead of just comma-separated filenames.
- [X] T015_b [US1] Add notes display to section rendering in `skills/result-feed/SKILL.md`: when `section.notes` is non-null, display `> Notes: <text>` below the item list. When null, omit entirely (no "Notes: none" clutter).

**Checkpoint**: Section shape parsing and display is correct for done/next/blocked. Notes and attachments render properly.

---

## Phase 4: User Story 2 — Add Review Section Support (Priority: P1)

**Goal**: Add `review` as a fourth section in all display and update flows.

**Independent Test**: View a check-in with review items → verify "Review" section appears between "Done" and "Next".

### Implementation for User Story 2

- [X] T016 [US2] Add `review` section to the TeamResultFeed schema in `skills/result-feed/SKILL.md` — insert between `done` and `next` with same ResultFeedSection shape.
- [X] T017 [US2] Update the `view_team_feeds` display template in `skills/result-feed/SKILL.md` to render four sections in order: Done, Review, Next, Blocked (add `**Review**` block between Done and Next).
- [X] T018 [US2] Update the `update_section_meta` flow in `skills/result-feed/SKILL.md`: change valid sections from `done`, `next`, `blocked` to `done`, `review`, `next`, `blocked`.
- [X] T019_a [US2] Update the `view_team_member_report` flow in `skills/result-feed/SKILL.md` to display four sections using the same order.

**Checkpoint**: Review section displays and is editable. All four sections work in view and update flows.

---

## Phase 5: User Story 3 — Update Section Notes and Attachments (Priority: P2)

**Goal**: Ensure section update flow correctly handles notes and attachment_ids in PUT body.

**Independent Test**: Add notes to the "done" section → verify notes persist on next GET.

### Implementation for User Story 3

- [X] T019 [US3] Update `update_section_meta` PUT body in `skills/result-feed/SKILL.md` to include optional `notes` and `attachment_ids` fields: `{"notes":"TEXT","attachment_ids":[IDS]}`. Verify the body format matches the API contract; fix any mismatches found.

**Checkpoint**: Section notes and attachments can be updated via the skill.

---

## Phase 6: User Story 4 — View Team Member's Daily Update (Priority: P2)

**Goal**: Ensure team member detail view uses all four sections and correct response parsing.

**Independent Test**: Request a teammate's report → verify all four sections, notes, and attachments display.

### Implementation for User Story 4

- [X] T020 [US4] Update `view_team_member_report` response parsing in `skills/result-feed/SKILL.md` to render all four sections (done, review, next, blocked) with notes and attachments using the structured section shape.

**Checkpoint**: Team member detail view works with the updated API response shape.

---

## Phase 7: User Story 5 — React to and Comment on Check-ins (Priority: P3)

**Goal**: Fix reactions endpoint path, response field names, and add user_id support. Fix comment response field name.

**Independent Test**: High-five a teammate's report → verify `reacted: true` and `count` display. Post a comment → verify it appears in comment list.

### Implementation for User Story 5

- [X] T021 [US5] Fix `react_to_report` flow in `skills/result-feed/SKILL.md`: change endpoint from `POST /result-feed/DATE/react` to `POST /result-feed/DATE/reactions`. Add `user_id` to request body.
- [X] T022 [US5] Fix `react_to_report` response parsing in `skills/result-feed/SKILL.md`: change from `body.data.high_five_count` / `body.data.user_has_reacted` to `body.data.count` / `body.data.reacted`.
- [X] T023 [US5] Add "show reactions", "reaction count" triggers to the Tool Routing Table in `skills/result-feed/SKILL.md` mapping to a new `view_reactions` flow that calls `GET /result-feed/DATE/reactions?user_id=USER_ID` and displays `reacted` and `count`.
- [X] T024 [US5] Fix `list_comments` flow in `skills/result-feed/SKILL.md`: add `?user_id=USER_ID` query param to GET request. Update table display to use `comment` field instead of `body` for the comment text column.
- [X] T025 [US5] Fix `add_comment` flow in `skills/result-feed/SKILL.md`: add `user_id` to POST body. Update response display to show the `comment` field (not `body`).

**Checkpoint**: Reactions toggle correctly with new endpoint/fields. Comments display and create with correct field names.

---

## Phase 8: User Story 6 — Push Daily Update to Slack or Discord (Priority: P3)

**Goal**: Fix push body parameter from `team_id` to `group_context_id`.

**Independent Test**: Push a submitted check-in to Slack → verify success response.

### Implementation for User Story 6

- [X] T026 [US6] Fix `push_to_slack` flow in `skills/result-feed/SKILL.md`: change body field from `"team_id":TEAM_ID` to `"group_context_id":TEAM_ID` in the POST request.
- [X] T027 [US6] Fix `push_to_discord` flow description in `skills/result-feed/SKILL.md`: update the same body field change (`group_context_id` instead of `team_id`).
- [X] T027_a [US6] Add webhook availability check to `push_to_slack` and `push_to_discord` flows in `skills/result-feed/SKILL.md`: before pushing, check the team response for `has_slack_webhook` / `has_discord_webhook` and display "no webhook configured" if false, instead of letting the API call fail.

**Checkpoint**: Push to Slack/Discord works with correct body parameter.

---

## Phase 9: File Upload Flow (Priority: P3)

**Goal**: Add a new `upload_attachment` flow for file uploads.

**Independent Test**: Upload a file → verify document ID is returned.

### Implementation

- [X] T028 [US3] Add "upload file", "attach file", "upload attachment" triggers to the Tool Routing Table in `skills/result-feed/SKILL.md` mapping to a new `upload_attachment` flow.
- [X] T029 [US3] Add `upload_attachment` flow in `skills/result-feed/SKILL.md`: prompt user for file path, confirm, execute `curl -F "file=@PATH" ...` via api.sh pattern, display returned document ID. Handle 400 (missing file) and 413 (oversized, max 4.5 MB) errors.

**Checkpoint**: File upload works and returns document IDs usable in section attachment_ids.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Sync docs and ship

- [X] T030 Run `/sync-plugin` to copy master `api-reference.md` to all skills and bump the plugin version.
- [ ] T031 Run `/ship-it` to commit all changes, push, post summary on issue #109, and close it.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — verify API first
- **Phase 2 (API Reference)**: Depends on Phase 1 — must document before implementing
- **Phases 3-4 (US1, US2)**: Depend on Phase 2 — P1 stories, do first
- **Phases 5-6 (US3, US4)**: Depend on Phases 3-4 — P2 stories, build on section fixes
- **Phases 7-9 (US5, US6, Upload)**: Depend on Phase 2 — P3 stories, can run after API ref is done
- **Phase 10 (Polish)**: Depends on all previous phases

### User Story Dependencies

- **US7 (API Reference)**: Independent — done first as foundation
- **US1 (Section Shape)**: Depends on US7 — needs correct docs to verify against
- **US2 (Review Section)**: Depends on US1 — extends section handling
- **US3 (Notes/Attachments)**: Depends on US1 — uses updated section shape
- **US4 (Team Member View)**: Depends on US2 — needs review section in display
- **US5 (Reactions/Comments)**: Independent of section changes — only needs US7
- **US6 (Push Slack/Discord)**: Independent of section changes — only needs US7

### Parallel Opportunities

- T005–T012 (all [P] API reference tasks) can run in parallel
- T013–T015_b (US1 tasks) can run in parallel with each other
- T016–T019_a (US2 tasks) are sequential within the story
- T021–T025 (US5 tasks) can start as soon as Phase 2 completes
- T026–T027_a (US6 tasks) can run in parallel with US5

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 7)

1. Phase 1: Verify API behavior
2. Phase 2: Fix api-reference.md (US7)
3. Phase 3: Fix breaking section shape (US1)
4. Phase 4: Add review section (US2)
5. **STOP and VALIDATE**: Core display works with new API
6. Ship if ready — remaining stories are non-breaking enhancements

### Incremental Delivery

1. US7 (API docs) → Foundation ready
2. US1 + US2 (section fixes) → Core display works → Ship MVP
3. US3 + US4 (metadata + team view) → Enhanced features → Ship
4. US5 + US6 + Upload (reactions, comments, push, upload) → Full feature parity → Ship

---

## Notes

- No test tasks included — spec does not request TDD
- SKILL.md already has most flows; tasks focus on fixing mismatches and adding missing features
- All changes are to 2 files: `api-reference.md` (master) and `skills/result-feed/SKILL.md`
- Phase 10 uses `/sync-plugin` and `/ship-it` commands — no manual file copying
