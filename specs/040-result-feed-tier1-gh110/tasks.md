# Tasks: Daily Update API v2 — Tier 1 Backend Gap Coverage

**Input**: Design documents from `/specs/040-result-feed-tier1-gh110/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No project scaffolding needed — existing plugin structure. This phase updates the master API reference with all new/changed endpoints.

- [x] T001 Update result-feed section shape documentation in `api-reference.md` — change `done` (Item[]), `next` (Item[]), `blocked` (Item[]) to new object shape with `items`, `notes`, `attachments` fields
- [x] T002 [P] Add `PUT /result-feed/{date}/{section}` endpoint documentation to the Result Feed table in `api-reference.md`
- [x] T003 [P] Add `POST /result-feed/{date}/push-to-slack` endpoint documentation to `api-reference.md`
- [x] T004 [P] Add `POST /result-feed/{date}/push-to-discord` endpoint documentation to `api-reference.md`
- [x] T005 [P] Add `POST /result-feed/{date}/react` endpoint documentation to `api-reference.md`
- [x] T006 [P] Add `GET /result-feed/{date}/comments` endpoint documentation to `api-reference.md`
- [x] T007 [P] Add `POST /result-feed/{date}/comments` endpoint documentation to `api-reference.md`
- [x] T008 [P] Add `GET /teams/{id}/result-feed/{date}/{user_id}` endpoint documentation to `api-reference.md`
- [x] T009 [P] Add `POST /users/me/group-context` endpoint documentation to `api-reference.md`
- [x] T010 Add `has_slack_webhook` and `has_discord_webhook` fields to the Teams endpoint documentation in `api-reference.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fix the breaking section shape change in `rkit:result-feed` — MUST be done before any new feature work.

**⚠️ CRITICAL**: The breaking change fix must land first. All new endpoint routes depend on the updated schema documentation in the SKILL.md.

- [x] T011 Update the Schemas section in `skills/result-feed/SKILL.md` — change `TeamResultFeed` schema to show `done`/`next`/`blocked` as objects (`{ items: Item[], notes: string|null, attachments: Attachment[] }`) instead of flat `Item[]` arrays. Add `Attachment` schema (`{ id, filename, url }`).
- [x] T012 Update the display logic in Step 3 of `skills/result-feed/SKILL.md` — change section rendering from `section` (array) to `section.items` (array within object). Add rendering for `section.notes` (display if non-null) and `section.attachments` (display filenames if present).

**Checkpoint**: After T012, `/rkit:result-feed` correctly displays team check-ins with the new section shape.

---

## Phase 3: User Story 1 - View Daily Update with Notes & Attachments (Priority: P1) 🎯 MVP

**Goal**: Ensure `/rkit:result-feed` correctly parses and displays the new section shape, including notes and attachments.

**Independent Test**: Run `/rkit:result-feed` and verify all three sections display items, notes, and attachments correctly.

### Implementation for User Story 1

- [x] T013 [US1] Verify the result-feed skill's display format handles empty notes (null) and empty attachments ([]). Confirm no extraneous "Notes: " or "Attachments: " lines appear when fields are empty — update display logic in `skills/result-feed/SKILL.md` if needed.
- [x] T014 [US1] Test `/rkit:result-feed` against live API to verify items display correctly under new section shape. Fix any parsing issues found in `skills/result-feed/SKILL.md`.

**Checkpoint**: `/rkit:result-feed` shows team check-ins correctly with notes and attachments. MVP complete.

---

## Phase 4: User Story 2 - Update Section Notes & Attachments (Priority: P2)

**Goal**: Users can add/update/clear notes and attachments on their result-feed sections.

**Independent Test**: User updates notes on a section and verifies it appears on next view.

### Implementation for User Story 2

- [x] T015 [US2] Add `update_section_meta` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "add notes", "update notes", "set notes on done/next/blocked", "edit section notes", "attach files", "add attachment"
- [x] T016 [US2] Implement `update_section_meta` tool/flow in `skills/result-feed/SKILL.md` — confirm action, call `PUT /result-feed/{date}/{section}` with `{ notes, attachment_ids }`, display success/failure. Include clearing notes with null. Note: `attachment_ids` are pre-existing IDs (attachment upload is handled outside this skill).

**Checkpoint**: Users can add, update, and clear notes on result-feed sections.

---

## Phase 5: User Story 3 - View Team Member's Daily Update (Priority: P2)

**Goal**: Team leads can view a specific teammate's full daily report.

**Independent Test**: User views a teammate's check-in by user ID and date.

### Implementation for User Story 3

- [x] T017 [P] [US3] Add `view_team_member_report` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "show {user}'s check-in", "view {user}'s report", "team member report", "what did {user} do"
- [x] T018 [US3] Implement `view_team_member_report` tool/flow in `skills/result-feed/SKILL.md` — resolve team ID and date, accept user_id as an explicit argument from the user, call `GET /teams/{id}/result-feed/{date}/{user_id}`, display full report with `is_quiet` indicator. Handle 403/404 errors.

**Checkpoint**: Team leads can drill into any team member's daily report.

---

## Phase 6: User Story 4 - React to a Check-in (Priority: P3)

**Goal**: Users can high-five a teammate's daily update.

**Independent Test**: User reacts to a report and sees count update.

### Implementation for User Story 4

- [x] T019 [P] [US4] Add `react_to_report` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "high-five", "react", "high five {user}", "give kudos", "🙏"
- [x] T020 [US4] Implement `react_to_report` tool/flow in `skills/result-feed/SKILL.md` — confirm action (this is a non-destructive toggle but Constitution IV requires confirmation for POST), call `POST /result-feed/{date}/react`, display updated `high_five_count` and `user_has_reacted` status.

**Checkpoint**: Users can toggle high-five reactions on check-ins.

---

## Phase 7: User Story 5 - Comment on a Check-in (Priority: P3)

**Goal**: Users can read and post comments on daily updates.

**Independent Test**: User lists comments and posts a new one.

### Implementation for User Story 5

- [x] T021 [P] [US5] Add `list_comments` and `add_comment` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "show comments", "read comments", "comments on {date}", "comment on check-in", "add comment", "reply to {user}"
- [x] T022 [US5] Implement `list_comments` tool/flow in `skills/result-feed/SKILL.md` — call `GET /result-feed/{date}/comments`, display comments with body, user_id, and timestamp in a clean format.
- [x] T023 [US5] Implement `add_comment` tool/flow in `skills/result-feed/SKILL.md` — confirm comment text, call `POST /result-feed/{date}/comments` with `{ body }`, display created comment. Handle validation errors.

**Checkpoint**: Users can read and post comments on check-ins.

---

## Phase 8: User Story 6 - Push to Slack/Discord (Priority: P3)

**Goal**: Users can share their daily update to Slack or Discord.

**Independent Test**: User pushes check-in to Slack and sees success/failure message.

### Implementation for User Story 6

- [x] T024 [P] [US6] Add `push_to_slack` and `push_to_discord` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "share to slack", "push to slack", "send to discord", "share to discord", "share check-in"
- [x] T025 [US6] Implement `push_to_slack` and `push_to_discord` tool/flows in `skills/result-feed/SKILL.md` — resolve team ID, fetch team data via `GET /teams/{id}` and display `has_slack_webhook`/`has_discord_webhook` flags (FR-012), confirm action, call `POST /result-feed/{date}/push-to-slack` or `push-to-discord` with `{ team_id, exclude_item_ids }`. Handle 200/422/502/403 responses with clear messages.

**Checkpoint**: Users can push check-ins to Slack/Discord channels.

---

## Phase 9: User Story 7 - Set Group Context (Priority: P3)

**Goal**: Users can set their active group context for sharing.

**Independent Test**: User sets group context and confirms success.

### Implementation for User Story 7

- [x] T026 [P] [US7] Add `set_group_context` to the Tool Routing Table in `skills/result-feed/SKILL.md` with triggers: "set team context", "switch team", "share to team {id}", "set group context"
- [x] T027 [US7] Implement `set_group_context` tool/flow in `skills/result-feed/SKILL.md` — confirm action, call `POST /users/me/group-context` with `{ group_id }`, display success.

**Checkpoint**: Users can set their active team for sharing.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files and finalize.

- [x] T028 Run `/sync-plugin` to copy master `api-reference.md` to all skill `references/` directories
- [x] T029 Verify `/rkit:result-feed` against live API — run end-to-end: view team feed, view member detail, react, comment, push to slack (if webhook available)
- [x] T030 Update the `rkit:result-feed` skill `description` in SKILL.md frontmatter to mention new capabilities (reactions, comments, push-to-slack/discord, section notes)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — update api-reference.md first
- **Foundational (Phase 2)**: Depends on T001 (updated schema docs) — fixes breaking change
- **US1 (Phase 3)**: Depends on Phase 2 — validate the fix works
- **US2–US7 (Phases 4–9)**: Depend on Phase 2 — can proceed in parallel with each other
- **Polish (Phase 10)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational only — MVP
- **US2 (P2)**: Independent of other stories — section meta updates
- **US3 (P2)**: Independent — team member detail view
- **US4 (P3)**: Independent — reactions
- **US5 (P3)**: Independent — comments
- **US6 (P3)**: Independent — webhook push (may check team webhook flags)
- **US7 (P3)**: Independent — group context

### Within Each User Story

- Add routing table entry first
- Implement tool/flow second
- Test against live API

### Parallel Opportunities

- T003–T009 (api-reference endpoint additions) can all run in parallel
- US2–US7 can all be implemented in parallel after Phase 2
- Within each story, routing table entry and flow implementation are sequential

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Update api-reference.md
2. Complete Phase 2: Fix breaking section shape in result-feed skill
3. Complete Phase 3: Validate US1 against live API
4. **STOP and VALIDATE**: `/rkit:result-feed` works correctly
5. Run `/sync-plugin` and ship

### Incremental Delivery

1. Phases 1–3 → Breaking change fixed, notes/attachments visible (MVP)
2. Add US2 → Users can edit section notes
3. Add US3 → Team member detail views
4. Add US4–US7 → Social features (reactions, comments, push, context)
5. Phase 10 → Polish, sync, verify

---

## Notes

- All changes are in Markdown skill files — no compiled code
- The `rkit:today` skill is NOT affected (uses `/day-plans/` endpoints, not `/result-feed/`)
- `api-reference.md` is the master — `/sync-plugin` copies it to all skills
- Total: 30 tasks across 10 phases
