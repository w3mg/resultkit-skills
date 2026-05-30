# Tasks: Result Feed API 077 Tier 1 Update

**Input**: Design documents from `/specs/041-result-feed-tier1-gh109/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Organization**: Tasks grouped by user story to enable independent implementation and testing.
**Files modified**: `api-reference.md` (master) · `skills/result-feed/SKILL.md` · all skill copies via `/sync-plugin`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: Read and internalize current state of the two master files before any edits.

**⚠️ CRITICAL**: Both reads must complete before any edit task begins.

- [ ] T001 Read `api-reference.md` lines covering result-feed (grep for `result-feed`, `react`, `reactions`, `push-to-slack`, `comments`)
- [ ] T002 Read `skills/result-feed/SKILL.md` in full

**Checkpoint**: Current state understood — ready to begin user story phases in parallel.

---

## Phase 2: User Story 1 — Fix React Endpoint (Priority: P1) 🎯 MVP

**Goal**: Rename `/react` → `/reactions`, fix response field names, add GET reactions to both api-reference.md and SKILL.md.

**Independent Test**: Run `react_to_report` via the skill and confirm the API call uses `/result-feed/{date}/reactions`; the output shows `reacted` and `count` fields. Also confirm GET reactions is reachable from the routing table.

### Implementation for User Story 1

- [ ] T003 [P] [US1] In `api-reference.md`: replace the `POST /result-feed/{date}/react` row with `POST /result-feed/{date}/reactions` — update path, note optional body `{ user_id }`, update response shape to `{ data: { reacted: boolean, count: integer } }`
- [ ] T004 [P] [US1] In `api-reference.md`: add a new row for `GET /result-feed/{date}/reactions` — param `?user_id=N`, response `{ data: { reacted: boolean, count: integer } }`, synonyms: "show reactions", "reaction count", "who high-fived"
- [ ] T005 [US1] In `api-reference.md`: update the reactions glossary/lookup entry (near bottom) — change path from `/result-feed/{date}/react` to `/result-feed/{date}/reactions`; add the GET variant
- [ ] T006 [US1] In `api-reference.md`: remove `high_five_count` and `user_has_reacted` field descriptions (lines referencing those old field names)
- [ ] T007 [US1] In `skills/result-feed/SKILL.md`: update `react_to_report` Step 3 — change endpoint from `POST "/result-feed/DATE/react"` to `POST "/result-feed/DATE/reactions"` with optional body `'{"user_id":USER_ID}'`
- [ ] T008 [US1] In `skills/result-feed/SKILL.md`: update `react_to_report` Step 4 response handler — parse `body.data.reacted` and `body.data.count` instead of `high_five_count`/`user_has_reacted`; update display message accordingly
- [ ] T009 [US1] In `skills/result-feed/SKILL.md`: add `get_reactions` flow — `GET /result-feed/DATE/reactions?user_id=USER_ID`, display `reacted: {yes/no}` and `count: N`
- [ ] T010 [US1] In `skills/result-feed/SKILL.md`: add routing table row for `get_reactions` with triggers: "show reactions", "reaction count", "how many high-fives", "did I react"

**Checkpoint**: React toggle and GET reactions work correctly against the live API.

---

## Phase 3: User Story 2 — Review Section Support (Priority: P2)

**Goal**: Add `review` as a valid section name in api-reference.md and SKILL.md everywhere `done`, `next`, `blocked` are listed.

**Independent Test**: Ask the skill to "add item 42 to review" — no validation error; ask "set notes on review" — succeeds.

### Implementation for User Story 2

- [ ] T011 [P] [US2] In `api-reference.md`: add `review` to valid section list in the `PUT /result-feed/{date}/{section}/{item_id}` row description; also update the `POST /result-feed/{date}/{section}` and `DELETE /result-feed/{date}/{section}/{item_id}` rows similarly
- [ ] T012 [P] [US2] In `api-reference.md`: update `PUT /result-feed/{date}/{section}/{item_id}` row — add note that body optionally accepts `{ notes: string, attachment_ids: integer[] }` (per API 077)
- [ ] T013 [P] [US2] In `api-reference.md`: update `PUT /result-feed/{date}/{section}` row — add `review` to the synonyms/trigger phrases (e.g., "set notes on review", "edit review section notes")
- [ ] T014 [US2] In `skills/result-feed/SKILL.md`: update `update_section_meta` Step 1 — change valid section list from "`done`, `next`, or `blocked`" to "`done`, `review`, `next`, or `blocked`"
- [ ] T015 [US2] In `skills/result-feed/SKILL.md`: update routing table trigger for `update_section_meta` — add review variants: "set notes on review", "edit review section notes"
- [ ] T016 [US2] In `skills/result-feed/SKILL.md`: update `TeamResultFeed` schema block — add `"review": { "items": [...], "notes": null, "attachments": [] }` field
- [ ] T017 [P] [US2] In `api-reference.md`: fix comments GET/POST response description — rename field `body` → `comment` in the response object description to match API 077 (field in response is `comment`, not `body`)

**Checkpoint**: The `review` section is accepted everywhere `done`/`next`/`blocked` are accepted.

---

## Phase 4: User Story 4 — Fix Push-to-Slack/Discord Body Param (Priority: P2)

**Goal**: Change the `team_id` body parameter to `group_context_id` in both api-reference.md and SKILL.md for push-to-slack and push-to-discord.

**Independent Test**: Push to Slack — verify the outgoing request body contains `group_context_id` not `team_id`. No 422 body-validation errors from the API.

### Implementation for User Story 4

- [ ] T018 [P] [US4] In `api-reference.md`: update `POST /result-feed/{date}/push-to-slack` row — change `body: team_id*` to `body: group_context_id*` (optional `exclude_item_ids[]`)
- [ ] T019 [P] [US4] In `api-reference.md`: update `POST /result-feed/{date}/push-to-discord` row — same param rename
- [ ] T020 [US4] In `skills/result-feed/SKILL.md`: update `push_to_slack` Step 4 — change request body from `'{"team_id":TEAM_ID,...}'` to `'{"group_context_id":TEAM_ID,...}'`
- [ ] T021 [US4] In `skills/result-feed/SKILL.md`: update `push_to_discord` flow description — same param rename (push_to_discord delegates to same body shape as push_to_slack)

**Checkpoint**: Push-to-Slack and Push-to-Discord calls use `group_context_id`.

---

## Phase 5: User Story 3 — File Upload (Priority: P3)

**Goal**: Document and expose `POST /result-feed/{date}/attachments` in api-reference.md and add an `upload_attachment` flow to the skill.

**Independent Test**: Ask the skill "attach a file to my check-in" — skill routes to `upload_attachment` and explains the multipart upload flow; returns document ID on success.

### Implementation for User Story 3

- [ ] T022 [P] [US3] In `api-reference.md`: add new row for `POST /result-feed/{date}/attachments` — multipart/form-data, field `file`, max 4.5 MB, response `{ data: { id, filename, content_type, filesize } }`, errors 400/413, synonyms: "upload file", "attach file", "add attachment", "upload attachment to check-in"
- [ ] T023 [P] [US3] In `api-reference.md`: add glossary/lookup entry for file upload near the result-feed entries
- [ ] T024 [US3] In `skills/result-feed/SKILL.md`: add routing table row for `upload_attachment` with triggers: "upload attachment", "attach file", "add file to check-in", "upload file to report"
- [ ] T025 [US3] In `skills/result-feed/SKILL.md`: add `upload_attachment` flow section — resolve date, confirm upload, execute `"$API_SH" POST_MULTIPART "/result-feed/DATE/attachments" file=PATH`, handle 201/400/413 responses (note: if api.sh doesn't support multipart natively, document the curl command instead)
- [ ] T026 [US3] In `skills/result-feed/SKILL.md`: add `Attachment (upload response)` schema block showing `{ id, filename, content_type, filesize }`

**Checkpoint**: File upload flow is documented and reachable; document ID surfaced for use in `attachment_ids`.

---

## Phase 6: Polish & Sync

**Purpose**: Verify correctness and propagate changes to all skill copies.

- [ ] T027 Audit `api-reference.md` — confirm no remaining references to `/result-feed/{date}/react` (old path), `high_five_count`, `user_has_reacted`, or `team_id` in push-to-slack/discord body descriptions
- [ ] T028 Run `/sync-plugin` to copy updated `api-reference.md` to all `skills/*/references/api-reference.md` copies and bump plugin version
- [ ] T029 [P] Verify `skills/result-feed/references/api-reference.md` matches the master after sync

**Checkpoint**: All skill copies updated; plugin version bumped; changes are complete and committed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — start immediately
- **User Stories (Phases 2–5)**: All depend on Phase 1 reads being complete
  - **US1 and US2 and US4 tasks that edit different files**: Can run in parallel (api-reference edits vs SKILL.md edits)
  - **US2 and US4**: Both P2 — can run in parallel after Phase 1
  - **US3**: P3 — start after US1/US2/US4 or run concurrently
- **Polish (Phase 6)**: Depends on all user story phases complete

### Within Each User Story

- `api-reference.md` edits for a story marked [P] can run in parallel with each other
- SKILL.md edits within a story run sequentially (same file)
- api-reference.md edits and SKILL.md edits for different stories can run in parallel (different files)

---

## Parallel Opportunities

```bash
# After Phase 1 completes, these can all run concurrently:
Task: T003–T006  (api-reference.md react endpoint changes — US1)
Task: T007–T010  (SKILL.md react changes — US1)
Task: T011–T013  (api-reference.md review section + comments field — US2)
Task: T018–T019  (api-reference.md push body param — US4)
```

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Complete Phase 1 (reads)
2. Complete Phase 2 (US1 — react endpoint fix)
3. **VALIDATE**: Test react toggle and GET reactions against live API
4. Ship US1 independently if needed

### Full Incremental Delivery

1. Phase 1 → Phase 2 (US1) → Validate US1
2. Phase 3 (US2) + Phase 4 (US4) in parallel → Validate review section and push params
3. Phase 5 (US3) → Validate file upload
4. Phase 6 (Polish + sync) → `/sync-plugin` → Commit

---

## Notes

- [P] tasks = different files, no dependencies on incomplete sibling tasks
- SKILL.md edits for the same flow must be sequential (same file)
- After T028 (`/sync-plugin`), verify the sync worked before committing
- No tests requested — manual verification via `quickstart.md` test checklist
