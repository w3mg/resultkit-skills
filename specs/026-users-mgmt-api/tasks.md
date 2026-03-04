# Tasks: Extend rkit:profile with Measurables, Rocks, Feedback, Progress, and Integrations

**Input**: Design documents from `/specs/026-users-mgmt-api/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. All changes target `skills/profile/SKILL.md`.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

**Purpose**: Verify current skill state before making changes.

- [x] T001 Read `skills/profile/SKILL.md` in full to confirm current Argument Parsing table and existing flow sections before editing

---

## Phase 2: Foundational (Blocking Prerequisite)

**Purpose**: Update the Argument Parsing table — this is the routing table Claude Code uses to dispatch all flows. Must be updated before any new flow can be reached.

**⚠️ CRITICAL**: No user story can be tested until T002 is complete.

- [x] T002 Add 12 new argument rows to the Argument Parsing table in `skills/profile/SKILL.md` (see data-model.md Argument Resolution Table: measurables, measurables {user_id}, rocks, rocks {year}, rocks {user_id}, feedback given, feedback received, feedback {user_id} given|received, progress, progress {period}, integrations, integrations set {category} {value})

**Checkpoint**: Routing table complete — user story flows can now be added in any order.

---

## Phase 3: User Story 1 — Personal Progress Dashboard (Priority: P1) 🎯 MVP

**Goal**: Users can run `/rkit:profile progress [period]` and see strategy metrics and practice scorecard.

**Independent Test**: Run `/rkit:profile progress` and verify two sections are shown — Strategy (rocks/milestones) and Practice Streak (current, longest, all-time) with day-by-day scorecard.

- [x] T003 [US1] Add `## Flow: Progress` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config (same pattern as Stats Step 1)
  - Step 2: Extract optional PERIOD arg (week/month/quarter); build URL `GET /users/me/progress` with `?period=${PERIOD}` if provided
  - Step 3: Error handling — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401; display actionable messages matching existing patterns. *(403/404 intentionally omitted — endpoint is always `/users/me/progress` with no `{user_id}` param; these error codes cannot occur.)*
  - Step 4: On status 200 — display Strategy section (rocks_realized_all_time, milestones_realized_all_time, milestones_realized_this_quarter as labeled key-value), Practice Streak (current_streak, longest_streak, all_time as labeled key-value), and Practice Scorecard as a day-by-day list (day_name + ✓/✗ for `completed`)

**Checkpoint**: `/rkit:profile progress` and `/rkit:profile progress week` fully functional.

---

## Phase 4: User Story 2 — Measurables / Scorecard (Priority: P2)

**Goal**: Users can run `/rkit:profile measurables [user_id]` and see their scorecard KPIs.

**Independent Test**: Run `/rkit:profile measurables` and verify a table with ID, Name, Target, Latest value, and On Track status is displayed.

- [x] T004 [US2] Add `## Flow: Measurables` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config
  - Step 2: Extract USER_ID from args — use numeric arg if provided, otherwise `me`
  - Step 3: Call `GET /users/${USER_ID}/measurables`
  - Step 4: Error handling — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 ("Access denied (403). You must share a team with user {id} to view their data."), 404 ("User {id} not found (404).")
  - Step 5: On status 200 — display table with columns: ID | Name | Target | Latest | On Track (✓/✗ from most recent `values` entry). Footer: `{N} measurables`. Empty list → "No measurables found."

**Checkpoint**: `/rkit:profile measurables` and `/rkit:profile measurables 42` fully functional.

---

## Phase 5: User Story 3 — Rocks / Quarterly Goals (Priority: P2)

**Goal**: Users can run `/rkit:profile rocks [user_id|year]` and see rocks with milestone progress.

**Independent Test**: Run `/rkit:profile rocks` and verify a table with ID, Rock, Status, Due, Milestones, Team is displayed.

- [x] T005 [US3] Add `## Flow: Rocks` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config
  - Step 2: Parse args — if arg is 4-digit integer → `YEAR=${arg}`; if arg is non-year integer → `USER_ID=${arg}`; default `USER_ID=me`. Build URL: `GET /users/${USER_ID}/rocks?per_page=100&page=${PAGE}` (append `&year=${YEAR}` if set)
  - Step 3: Paginated fetch loop using `meta.total_pages` (same pattern as account members)
  - Step 4: Error handling — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 (team-sharing message), 404
  - Step 5: On status 200 — display table with columns: ID | Rock | Status | Due | Milestones | Team. Status labels: on_track→"On Track", off_track→"Off Track", completed→"Done", dropped→"Dropped". Milestones as `{completed}/{total}`. Footer: `{N} rocks`. Empty → "No rocks found."

**Checkpoint**: `/rkit:profile rocks`, `/rkit:profile rocks 2025`, and `/rkit:profile rocks 42` fully functional.

---

## Phase 6: User Story 4 — Feedback (Priority: P3)

**Goal**: Users can run `/rkit:profile feedback given|received [user_id]` and see paginated feedback items.

**Independent Test**: Run `/rkit:profile feedback received` and verify a table with ID, From, Message, Date is displayed. Run `/rkit:profile feedback given` and verify To column is used instead.

- [x] T006 [US4] Add `## Flow: Feedback` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config
  - Step 2: Parse args — extract DIRECTION ("given" or "received") and optional USER_ID (numeric arg). If direction missing: use AskUserQuestion to ask "given" or "received"
  - Step 3: Paginated fetch: `GET /users/${USER_ID}/feedback?direction=${DIRECTION}&per_page=100&page=${PAGE}`
  - Step 4: Error handling — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 (team-sharing), 404
  - Step 5: On status 200 — display table. For `received`: columns ID | From | Message | Date (from_user name; message truncated at 60 chars). For `given`: columns ID | To | Message | Date (to_user name). Footer: `{N} items`. Empty → "No feedback found."

**Checkpoint**: `/rkit:profile feedback received`, `/rkit:profile feedback given`, and `/rkit:profile feedback 42 received` fully functional.

---

## Phase 7: User Story 5 — Integrations (Priority: P3)

**Goal**: Users can view (`/rkit:profile integrations`) and update (`/rkit:profile integrations set {category} {value}`) their third-party integration selections.

**Independent Test**: Run `/rkit:profile integrations` and verify all three categories (task_management, sales_revops, team_communication) show current value and options. Run `integrations set task_management none` and confirm it prompts before disconnecting.

- [x] T007 [US5] Add `## Flow: View Integrations` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config
  - Step 2: Call `GET /users/me/integrations`
  - Step 3: Error handling — NO_CONFIG, NO_TOKEN, CURL_FAILED, 401
  - Step 4: On status 200 — display three labeled rows showing category, current `selected` value (or "—" if null), and `options` list. Format: `Task Management: {selected}  (options: {opt1, opt2, ...})`. *(data-model.md confirms API returns `{selected, options[]}` per category — no assumption.)*

- [x] T008 [US5] Add `## Flow: Update Integrations` section to `skills/profile/SKILL.md` with:
  - Step 1: Resolve api.sh path and config
  - Step 2: Extract CATEGORY and VALUE from args. Validate CATEGORY is one of: task_management, sales_revops, team_communication. If invalid → "Unknown category '{cat}'. Valid categories: task_management, sales_revops, team_communication." — stop. If VALUE missing → "Usage: `/rkit:profile integrations set {category} {value}`" — stop
  - Step 3: Translate VALUE "none" or "null" → JSON null. All other values → quoted string
  - Step 4: Fetch current integrations (`GET /users/me/integrations`) to show diff
  - Step 5: Use AskUserQuestion to confirm: `Update {category}: '{current}' → '{new_value}'? Confirm?`. If declined → "Cancelled." — stop
  - Step 6: `PATCH /users/me/integrations` with body `{"{category}": <value_or_null>}`
  - Step 7: Error handling — 401, 422 (show validation error). On 200 → "Integrations updated."

**Checkpoint**: View and update flows fully functional.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T009 Update `skills/profile/SKILL.md` frontmatter:
  - Update `description:` field to mention all 5 new subcommands (measurables, rocks, feedback, progress, integrations) so the skill is discoverable when users ask about those topics
  - Verify `allowed-tools:` frontmatter covers all new API call patterns (no changes expected since all calls go through the existing `api.sh` path, but confirm the existing scoped `Bash(command *)` patterns are sufficient)
- [x] T010 Update Edge Cases section in `skills/profile/SKILL.md` to add entries for all new flows. From spec.md Edge Cases:
  - `{user_id}` does not exist → 404 response shown
  - `{user_id}` does not share a team → 403 with team-sharing explanation (applies to measurables, rocks, feedback)
  - Feedback direction omitted → prompt user for "given" or "received"
  - Invalid period passed to progress → show API error response
  - `integrations set` called without category or value → show usage hint and stop
  - Rocks or measurables returns empty list → show "0 found" and stop gracefully
- [x] T011 Run `/sync-plugin` to copy updated SKILL.md to plugin cache and bump version

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — blocks all user stories
- **Phases 3–7 (User Stories)**: All depend on Phase 2 completion; can proceed in any order after T002
- **Phase 8 (Polish)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 Progress (P1)**: Independent after Phase 2
- **US2 Measurables (P2)**: Independent after Phase 2
- **US3 Rocks (P2)**: Independent after Phase 2
- **US4 Feedback (P3)**: Independent after Phase 2
- **US5 Integrations (P3)**: Independent after Phase 2

### Within User Stories

All flows follow the same step pattern (resolve → fetch → errors → display). Each flow section is a self-contained SKILL.md addition.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. T001 — Read SKILL.md
2. T002 — Update Argument Parsing table
3. T003 — Add Progress flow
4. **STOP and VALIDATE**: Run `/rkit:profile progress`
5. Proceed to US2–US5 in priority order

### Incremental Delivery

Each phase (T003 → T008) adds one independently testable subcommand. Test each before proceeding to the next.

### Notes

- All tasks target `skills/profile/SKILL.md` — serialize edits to avoid conflicts
- T007 and T008 (Integrations) are logically paired but independently addable
- T011 (`/sync-plugin`) is the final step — do not run until all SKILL.md changes are complete
