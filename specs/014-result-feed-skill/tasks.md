# Tasks: rkit:result-feed Skill

**Input**: Design documents from `/specs/014-result-feed-skill/`
**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/result-feeds-api.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. Each story adds flow definitions to skills/result-feed/SKILL.md.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

All paths relative to repository root (`/home/patrick/projects/resultkit-skills/`):

- `api-reference.md` — master API reference (repo root)
- `skills/result-feed/SKILL.md` — skill entry point
- `skills/result-feed/scripts/api.sh` — copied from `scripts/api.sh`
- `skills/result-feed/references/api-reference.md` — copied from master

---

## Phase 1: Setup

**Purpose**: Update shared docs and create skill directory structure

- [x] T001 Add Result Feeds section to api-reference.md after the Day Plans section and before Meetings. Include: endpoint table (6 endpoints with Method, Path, Description, User Phrases, Web URL columns), ResultFeed and TeamResultFeed field docs, submit request body docs, section name mapping note (issues=blocked internally). Add glossary entries for "check-in", "90-second practice", "result feed", "daily report" mapping to Result Feed endpoints. Source: specs/014-result-feed-skill/contracts/result-feeds-api.md cross-referenced with ~/projects/resultmaps-api2/openapi/openapi-v2.yaml
- [x] T002 Run /sync-plugin to copy updated api-reference.md and api.sh to all existing skill directories and bump plugin version in .claude-plugin/plugin.json
- [x] T003 Create skill directory structure: mkdir -p skills/result-feed/scripts skills/result-feed/references && cp scripts/api.sh skills/result-feed/scripts/api.sh && cp api-reference.md skills/result-feed/references/api-reference.md

---

## Phase 2: Foundational (SKILL.md Skeleton)

**Purpose**: Write the SKILL.md frame — all sections except flow definitions. MUST complete before user story flows.

**CRITICAL**: No flow definitions can be written until this skeleton is in place.

- [x] T004 Write SKILL.md frontmatter and Current State block in skills/result-feed/SKILL.md. Frontmatter: name rkit:result-feed, description "View and manage daily check-in reports (90-second practice). Build your done/next/issues, submit, share with team, and view team check-ins.", disable-model-invocation: true, user-invocable: true, allowed-tools: Bash, Read, AskUserQuestion. Current State: config check (same inline bash pattern as skills/today/SKILL.md), api.sh path resolution with fallback chain (update skill name to result-feed in all paths), Today date.
- [x] T005 Write Rules section in skills/result-feed/SKILL.md. Rules: interpret first/act second, confirm writes (GET immediate, POST/PUT/DELETE confirm), show IDs, concise output, direct execution (Bash + api.sh only).
- [x] T006 Write Tool Routing Table in skills/result-feed/SKILL.md. Map trigger phrases to 7 flows: get_result_feed ("show my check-in", "90 seconds", "result feed", "daily report", "what did I do", "show {date}"), create_new_item ("add done", "add next", "add issue", "new done item", "got done"), attach_existing_item ("add item {id} to done", "put {id} in next", "attach {id} to issues"), remove_item ("remove {id} from done", "take {id} off next", "drop {id} from issues"), submit_check_in ("submit", "finalize", "done for the day", "submit check-in"), view_team_feeds ("team check-ins", "team feed", "team result feed", "show team").
- [x] T007 Write How to Interpret section in skills/result-feed/SKILL.md. Include parameter extraction (item ID, date, section, item name), default-to-view behavior, ambiguity handling. Add Date Resolution table: (nothing)/today → today, tomorrow → YYYY-MM-DD, yesterday → YYYY-MM-DD, day names → YYYY-MM-DD, explicit dates → YYYY-MM-DD. Add Section Resolution: done/next/issues mapping with note that "blocked" should be interpreted as "issues".
- [x] T008 Write Schemas section in skills/result-feed/SKILL.md. Include example JSON for: ResultFeed (id, date, is_completed, done[], next[], issues[]), TeamResultFeed (ResultFeed + user), Item (id, name, status, due, team, creator, assignees, parent_id, timestamps), Pagination meta (page, per_page, total, total_pages).
- [x] T009 Write Error Handling section in skills/result-feed/SKILL.md. Standard rkit error table: NO_CONFIG → "Config not found. Run /rkit:setup first.", NO_TOKEN → "No API token. Run /rkit:setup to configure.", CURL_FAILED → "Network error. Check your connection.", 401 → "Unauthorized. Run /rkit:setup to update your token.", 404 → context-dependent message, 422 → show validation error from response body, other → show status code and error.
- [x] T010 Write References section in skills/result-feed/SKILL.md. Link to references/api-reference.md.

**Checkpoint**: SKILL.md skeleton complete — all sections present except flow definitions. Skill is invocable but will fall through to "no matching flow" for any input.

---

## Phase 3: User Story 1 — View Today's Check-In (Priority: P1) MVP

**Goal**: User can invoke `/rkit:result-feed` and see their check-in for today (or a specified date) with Done/Next/Issues sections, item IDs, names, and completion status.

**Independent Test**: Run `/rkit:result-feed` with no args — should display today's check-in. Run with a date — should display that date's check-in. Empty check-in shows hint to add items.

### Implementation for User Story 1

- [x] T011 [US1] Write get_result_feed flow in skills/result-feed/SKILL.md. Steps: (1) determine date segment (no args → today, date arg → YYYY-MM-DD), (2) call api.sh GET "/result-feeds/DATE_SEGMENT", (3) parse response — on success extract body.data (id, date, is_completed, done[], next[], issues[]), (4) display as headed report: "## Result Feed — {date_label}" with completion status, then three section tables (Done, Next, Issues) each showing # | ID | Name rows, then summary line "{total} items — {done_count} done, {next_count} next, {issues_count} issues". Empty sections show "No items." Empty check-in shows hint: 'Use `add done "task name"` to add items.' Handle errors per error handling table; 404 → "No check-in found for {date}."

**Checkpoint**: User Story 1 complete — `/rkit:result-feed` shows today's check-in. MVP functional.

---

## Phase 4: User Story 2 — Add Items to Check-In Sections (Priority: P1)

**Goal**: User can create new items in a section or attach existing items by ID to a section. Updated check-in is re-displayed after each action.

**Independent Test**: Run `add done "Finished report"` — should create item and show updated check-in. Run `attach 415 to next` — should add existing item and show updated check-in.

### Implementation for User Story 2

- [x] T012 [US2] Write create_new_item flow in skills/result-feed/SKILL.md. Steps: (1) extract item name and section from args, (2) confirm: 'Create item "{name}" in {section} section?', (3) call api.sh POST "/result-feeds/DATE_SEGMENT/SECTION" with body '{"name":"ITEM_NAME"}' (escape quotes in name), (4) on 201 show "Created item {id}: {name} in {section}", (5) re-fetch and display updated check-in using get_result_feed. Handle 400 (invalid section), 422 (validation error).
- [x] T013 [US2] Write attach_existing_item flow in skills/result-feed/SKILL.md. Steps: (1) extract item ID and section from args, (2) confirm: 'Add item {id} to {section} section?', (3) call api.sh PUT "/result-feeds/DATE_SEGMENT/SECTION/ITEM_ID", (4) on 200 show "Item {id} added to {section}", (5) re-fetch and display updated check-in using get_result_feed. Handle 404 (item not found or not viewable), 400 (invalid section). Note idempotent behavior — already-present items return 200.

**Checkpoint**: User Stories 1 + 2 complete — user can view and build their check-in.

---

## Phase 5: User Story 3 — Submit Check-In (Priority: P2)

**Goal**: User can submit their check-in, which always shares with the default team. Confirmation shows team name. User can override team.

**Independent Test**: With items in done + next, run `submit` — should show confirmation with team name, then submit and re-display as completed.

### Implementation for User Story 3

- [x] T014 [US3] Write submit_check_in flow in skills/result-feed/SKILL.md. Steps: (1) determine date segment, (2) read default_team_id from config via jq, (3) if no default_team_id: prompt user "No default team configured. Which team ID should this be shared with?", (4) fetch team name via api.sh GET "/teams/TEAM_ID" to display in confirmation, (5) confirm: 'Submit check-in for {date_label} and share with team "{team_name}" (ID: {team_id})?', (6) if user specified a different team in their command, use that instead, (7) call api.sh POST "/result-feeds/DATE_SEGMENT/submit" with body '{"team_id":TEAM_ID}', (8) on 200 show "Check-in submitted and shared with {team_name}.", then re-display the updated check-in using get_result_feed, (9) on 422 show validation error (likely "Done and Next sections must each have at least one item"), (10) on 404 show "Team not found." Handle idempotent re-submit (200 on already-completed feed).

**Checkpoint**: User Stories 1-3 complete — full check-in workflow (view, add, submit) functional.

---

## Phase 6: User Story 4 — Remove Items from Check-In (Priority: P2)

**Goal**: User can remove an item from a check-in section without deleting the item or reverting its status.

**Independent Test**: With an item in a section, run `remove {id} from done` — should remove and re-display check-in.

### Implementation for User Story 4

- [x] T015 [US4] Write remove_item flow in skills/result-feed/SKILL.md. Steps: (1) extract item ID and section from args, (2) confirm: 'Remove item {id} from {section}? (Item will not be deleted.)', (3) call api.sh DELETE "/result-feeds/DATE_SEGMENT/SECTION/ITEM_ID", (4) on 204 show "Item {id} removed from {section}.", then re-fetch and display updated check-in using get_result_feed, (5) on 404 show "Item {id} not found in {section} section." Handle 400 (invalid section).

**Checkpoint**: User Stories 1-4 complete — full CRUD on check-in sections.

---

## Phase 7: User Story 5 — View Team Check-Ins (Priority: P3)

**Goal**: User can view completed check-ins shared by team members, with full item details per section per member.

**Independent Test**: Run `team check-ins` — should display paginated list of team members' check-ins with user names, dates, and all items per section.

### Implementation for User Story 5

- [x] T016 [US5] Write view_team_feeds flow in skills/result-feed/SKILL.md. Steps: (1) determine team ID: explicit arg → use that, else read default_team_id from config, else prompt, (2) call api.sh GET "/teams/TEAM_ID/result-feeds", (3) parse response — extract body.data array and body.meta, (4) for each TeamResultFeed in data: display "### {first_name} {last_name} (@{login}) — {date}" header, then three section blocks (Done, Next, Issues) each listing items as "- [{id}] {name}", (5) after all feeds: show pagination summary "Page {page}/{total_pages} — {total} check-ins". Empty result: "No shared check-ins found for this team." Handle 404 (team not found or not a member).

**Checkpoint**: All 5 user stories complete — full skill functionality.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and ship

- [x] T017 Review complete SKILL.md against constitution principles in skills/result-feed/SKILL.md. Verify: (I) SKILL.md is sole entry point, (II) self-contained — no cross-skill deps, (III) all values from config, (IV) all writes confirmed, (V) IDs shown everywhere, (VII) only Bash+api.sh, (VIII) all error states handled, (IX) concise tables/summaries. Fix any violations.
- [ ] T018 Commit, bump version, and push. Follow CLAUDE.md commit checklist: bump version in .claude-plugin/plugin.json, stage all changed files, commit with descriptive message, git pull --rebase origin main, git push origin main, print update instructions.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on T003 (skill directory exists)
- **User Stories (Phase 3-7)**: All depend on Phase 2 completion (SKILL.md skeleton)
  - US1 (Phase 3): No story dependencies — first to implement
  - US2 (Phase 4): Depends on US1 (re-uses get_result_feed for re-display)
  - US3 (Phase 5): Independent of US2/US4 but logically follows US2
  - US4 (Phase 6): Independent of US3/US5
  - US5 (Phase 7): Independent of US3/US4
- **Polish (Phase 8)**: Depends on all user stories complete

### Within Each User Story

- Each flow is a self-contained section added to SKILL.md
- Flows reference the Tool Routing Table (written in Phase 2)
- Write flows re-use the get_result_feed display logic from US1

### Parallel Opportunities

- **Phase 1**: T001 (api-reference) can start immediately; T002-T003 depend on T001
- **Phase 2**: T004-T010 are sequential (same file, building skeleton top-to-bottom)
- **Phase 3-7**: US3, US4, US5 could theoretically be written in parallel (different flow sections), but since they're in the same file and US2 depends on US1's display logic, sequential is safer
- **Phase 8**: T017 and T018 are sequential

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T010)
3. Complete Phase 3: US1 — View Check-In (T011)
4. **STOP and VALIDATE**: `/rkit:result-feed` shows today's check-in
5. Ship as v1 if desired

### Incremental Delivery

1. Setup + Foundational → Skill directory and skeleton ready
2. Add US1 (View) → Test → Ship (MVP!)
3. Add US2 (Add Items) → Test → Ship (core workflow)
4. Add US3 (Submit) → Test → Ship (full workflow)
5. Add US4 (Remove) → Test → Ship (full CRUD)
6. Add US5 (Team View) → Test → Ship (complete feature)
7. Polish → Final review → Ship

---

## Notes

- All flow definitions are sections within the single skills/result-feed/SKILL.md file
- Tasks are ordered for sequential execution since they modify the same file
- Each user story checkpoint is a shippable increment
- The api-reference.md update (T001) must be verified against the live OpenAPI spec
- The API is not yet deployed to production — skill will work once deployed
