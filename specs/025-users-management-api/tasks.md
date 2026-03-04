# Tasks: Users Management API Endpoints

**Input**: Design documents from `/specs/025-users-management-api/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, contracts/ ✓, quickstart.md ✓

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. Each story delivers an independently testable increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to
- Paths are relative to repository root

---

## Phase 1: Setup (Skill Scaffold)

**Purpose**: Create the `rkit:profile` skill directory with boilerplate. No flows yet — just the structure and shell needed before story phases fill it in.

- [x] T001 Create skills/profile/ directory structure: `skills/profile/scripts/` and `skills/profile/references/` subdirectories
- [x] T002 Create skills/profile/SKILL.md with frontmatter (`name: rkit:profile`, `description`, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), AskUserQuestion`), Current State block (config + api.sh path detection matching pattern from skills/teams/SKILL.md), and Rules section (Confirm Writes / Show IDs / Concise Output / Direct Execution) — no flows yet

**Checkpoint**: `skills/profile/SKILL.md` exists with valid frontmatter and current state block. No flows implemented yet.

---

## Phase 2: User Story 1 — Document All New User Endpoints (Priority: P1) 🎯 MVP

**Goal**: All 14 new endpoints appear in api-reference.md with correct fields, key behaviors, and glossary phrases.

**Independent Test**: Read api-reference.md. Verify all 14 endpoints listed in quickstart.md Scenario 1 are present with fields, behavioral notes, and glossary entries from Scenario 2.

- [x] T003 [P] [US1] Add profile endpoints to Users section of api-reference.md: `GET /users/{id}/stats` (fields: wins_given, wins_received, goals_aspired, goals_realized, actions_done), `GET /users/{id}/measurables` (periodic scorecard data), `GET /users/{id}/rocks` (rocks with milestone progress), `GET /users/{id}/feedback` (given/received) — all four accept `"me"` alias for `{id}` and require team-sharing permission for other users
- [x] T004 [P] [US1] Add preferences endpoints to Users section of api-reference.md: `GET /users/me/preferences` (full object: login, first_name, last_name, email, secondary_email, time_zone, notifications.{morning_day_ahead,end_of_day_digest,weekly_digest_friday,week_ahead_sunday}, update_frequency, unsubscribe_all, startup_view_code, startup_view_label, preferred_team_id, slack_username, api_token, is_coach, profile_photo_thumb_path) and `PATCH /users/me/preferences` (partial update — only sent fields change; note notification booleans are the logical ON/OFF value, not raw DB `should_suppress`)
- [x] T005 [P] [US1] Add account and password endpoints to api-reference.md: `GET /users/check-login?login=` (response: `{available: bool}`, case-insensitive), `GET /users/me/accounts` (response includes `id`, `name`, `is_owner`), `GET /accounts/{id}/members` (response: member list with `id`, `first_name`, `last_name`, `email`, `is_owner`), `DELETE /accounts/{id}/members/{user_id}` (owner-only, 204 No Content; cannot remove owner), `POST /users/me/password` (body: `current_password?`, `password`, `password_confirmation`; `current_password` optional for OAuth users; response: `{success: true}`)
- [x] T006 [P] [US1] Add deferred endpoints to api-reference.md: `GET /users/me/progress` (personal progress dashboard — note: no skill flow), `GET /users/me/integrations` (integration selections — no skill flow), `PATCH /users/me/integrations` (update selections — no skill flow) — document response shapes from issue handoff
- [x] T007 [US1] Add user management glossary phrases to api-reference.md glossary section: "my stats", "my wins", "wins given", "wins received", "my score", "goals realized" → `/users/{id}/stats`; "my preferences", "my settings", "my profile", "notification settings" → `/users/me/preferences`; "update preferences", "change timezone", "toggle notifications", "turn off digest", "turn on notifications" → `PATCH /users/me/preferences`; "change password", "update password", "set password" → `POST /users/me/password`; "my accounts", "account list" → `/users/me/accounts`; "account members", "who's in my account" → `/accounts/{id}/members`; "remove account member", "remove from account" → `DELETE /accounts/{id}/members/{user_id}`; "login available", "check username" → `/users/check-login`

**Checkpoint**: All quickstart.md Scenarios 1–3 pass. api-reference.md has a complete Users section and updated glossary.

---

## Phase 3: User Story 2 — View My Profile Stats (Priority: P2)

**Goal**: `rkit:profile` (no args) and `rkit:profile stats [user_id]` fetch and display performance stats.

**Independent Test**: Run `/rkit:profile` and verify output matches quickstart.md Scenario 4 format. Run `/rkit:profile stats {other_id}` (shared team) and verify Scenario 6. Run with non-shared user and verify 403 message (Scenario 7).

- [x] T008 [US2] Add stats flow to skills/profile/SKILL.md: argument parsing table entry for *(no args)* → stats, `stats` → stats, `stats {user_id}` → stats for other user; fetch `GET /users/{id}/stats` via api.sh (default to `"me"` when no user_id given); display as labeled key-value list with header showing name and ID; handle 403 with "Access denied (403). You must share a team with user {id} to view their stats."; handle 401/404/NO_CONFIG per standard error table in contracts/profile-skill-contract.md

**Checkpoint**: quickstart.md Scenarios 4–7 all pass.

---

## Phase 4: User Story 3 — View and Update Preferences (Priority: P3)

**Goal**: `rkit:profile prefs` displays preferences; `rkit:profile prefs set {field} {value}` updates a single field with confirmation.

**Independent Test**: Run `/rkit:profile prefs` and verify all fields from quickstart.md Scenario 8 appear. Run `/rkit:profile prefs set time_zone "..."` and verify confirmation prompt (Scenario 9) and that only the target field changes after confirming. Run with unknown field and verify Scenario 11 error.

- [x] T009 [US3] Add prefs view flow to skills/profile/SKILL.md: argument `prefs` → fetch `GET /users/me/preferences`; display in formatted sections (Profile, Notifications, Settings) matching quickstart.md Scenario 8 output format; include user's numeric `id` in the Profile section (required by Show IDs principle); show notification values as ON/OFF; handle standard errors
- [x] T010 [US3] Add prefs update flow to skills/profile/SKILL.md: argument `prefs set {field} {value}` → validate field is a known key (reject unknown fields with usage hint per Scenario 11); show confirmation diff ("field: old → new" per contracts/profile-skill-contract.md Confirmation Prompts); on confirm, send `PATCH /users/me/preferences` with only `{field: value}` in body; display "Preferences updated." on success; handle 422 validation errors

**Checkpoint**: quickstart.md Scenarios 8–11 all pass.

---

## Phase 5: User Story 4 — Change Password (Priority: P4)

**Goal**: `rkit:profile password` interactively collects password inputs and changes the account password.

**Independent Test**: Run `/rkit:profile password`, enter valid current + new passwords, confirm → "Password changed successfully." (Scenario 12). Enter mismatched new/confirmation → error before API call (Scenario 14).

- [x] T011 [US4] Add password flow to skills/profile/SKILL.md: argument `password` → prompt for current password (note: optional for OAuth users — can leave blank), new password, and password confirmation; validate new password matches confirmation client-side before calling API (show "Password confirmation does not match." and stop if mismatch); show confirmation prompt "Change account password for {email}? Confirm?"; on confirm, call `POST /users/me/password` with `{current_password?, password, password_confirmation}` (omit current_password if blank); display "Password changed successfully." on `{success: true}`; handle 422 errors (show field-level messages from `errors` object, e.g., "Current password is incorrect.")

**Checkpoint**: quickstart.md Scenarios 12–15 all pass.

---

## Phase 6: User Story 5 — Account Members (Priority: P5)

**Goal**: `rkit:profile account members` lists account members; `rkit:profile account members remove {user_id}` removes a non-owner member with confirmation.

**Independent Test**: Run `/rkit:profile account members` and verify table output with name, email, ID, and Owner column (Scenario 16). Run remove command, confirm, verify success (Scenario 17). Attempt owner removal and verify 422 error (Scenario 18).

- [x] T012 [US5] Add account members list flow to skills/profile/SKILL.md: argument `account` or `account members [account_id]` → fetch `GET /users/me/accounts` to get account list; if no account_id specified and only one account exists, use it automatically; if no account_id specified and multiple accounts exist, display a numbered list of accounts (ID + name) and prompt the user to choose one (do not silently pick the first); fetch `GET /accounts/{id}/members` with pagination — loop through all pages until `meta.page >= meta.total_pages`, collecting all members; display as table (Name | Email | ID | Owner) per contracts/profile-skill-contract.md Account Members Output; show "N members" footer; handle "No accounts found." when accounts list is empty
- [x] T013 [US5] Add account member removal flow to skills/profile/SKILL.md: argument `account members remove {user_id} [account_id]` → fetch member details from members list to get name/email for confirmation; show confirmation prompt ("Remove {name} ({email}, ID: {id}) from account {account_name} (ID: {account_id})? This cannot be undone. Confirm?"); on confirm, call `DELETE /accounts/{id}/members/{user_id}`; display "{name} (ID: {id}) removed from account." on 204; handle 403 ("Access denied (403). Only the account owner can remove members.") and 422 ("Cannot remove the account owner.")

**Checkpoint**: quickstart.md Scenarios 16–20 all pass.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, and do a final end-to-end verification pass.

- [x] T014 Copy scripts/api.sh to skills/profile/scripts/api.sh (run `/sync-plugin` or copy manually if sync-plugin is not available in this context)
- [x] T015 Copy api-reference.md to skills/profile/references/api-reference.md (run `/sync-plugin` or copy manually)
- [x] T016 Bump plugin version in .claude-plugin/plugin.json (patch increment per CLAUDE.md commit checklist)
- [x] T017 Verify skills/profile/SKILL.md argument parsing table covers all documented flows (stats, stats {id}, prefs, prefs set {field} {value}, password, account, account members, account members remove {user_id})
- [x] T018 Run quickstart.md verification scenarios end-to-end: all 20 scenarios from quickstart.md pass (Scenarios 1–20)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (US1 — api-reference.md)**: Depends on Phase 1; T003–T006 can run in parallel, T007 depends on T003–T006
- **Phase 3 (US2 — stats)**: Depends on Phase 1 only (SKILL.md must exist); can start after T002
- **Phase 4 (US3 — prefs)**: Depends on Phase 1 only; can run in parallel with Phase 3
- **Phase 5 (US4 — password)**: Depends on Phase 1 only; can run in parallel with Phases 3 and 4
- **Phase 6 (US5 — account members)**: Depends on Phase 1 only; can run in parallel with Phases 3–5
- **Phase 7 (Polish)**: Depends on all story phases complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 1 (directory + SKILL.md stub); T003–T006 parallel, T007 sequential after them
- **US2 (P2)**: Depends on Phase 1 only (T002) — one task (T008)
- **US3 (P3)**: Depends on Phase 1 only — two tasks (T009, T010) sequential
- **US4 (P4)**: Depends on Phase 1 only — one task (T011)
- **US5 (P5)**: Depends on Phase 1 only — two tasks (T012, T013) sequential

### Within Each Story

- All SKILL.md flows are in the same file — write one flow at a time; each is independently testable
- api-reference.md tasks T003–T006 can run in parallel (different sections); T007 (glossary) after all sections done

### Parallel Opportunities

- T003, T004, T005, T006 (all US1 api-reference.md sections) — different sections, no dependencies
- T008 (US2), T009 (US3 start), T011 (US4) — different flows, all depend only on T002
- T014 and T015 (sync copies) can run in parallel
- T017 must complete before T018 (argument gaps would cause T018 scenarios to fail)

---

## Parallel Example: US1 (api-reference.md update)

```
Parallel:
  Task T003: Add profile endpoints section (stats, measurables, rocks, feedback)
  Task T004: Add preferences endpoints section
  Task T005: Add account/password/check-login endpoints
  Task T006: Add deferred endpoints (progress, integrations)

Then sequential:
  Task T007: Add glossary phrases (after T003–T006 complete)
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Create skill scaffold (T001–T002)
2. Complete Phase 2: Update api-reference.md (T003–T007)
3. **STOP and VALIDATE**: Verify all 14 endpoints documented per Scenarios 1–3
4. This alone satisfies the P1 requirement (API Skill Maintainer action item)

### Incremental Delivery

1. Phase 1 + Phase 2 → api-reference.md complete (MVP)
2. Phase 3 → Stats flow live (`/rkit:profile`)
3. Phase 4 → Preferences view/update live
4. Phase 5 → Password change live
5. Phase 6 → Account member management live
6. Phase 7 → Sync, version bump, final verification

### Single Developer (Sequential)

T001 → T002 → T003+T004+T005+T006 (parallel batch) → T007 → T008 → T009 → T010 → T011 → T012 → T013 → T014+T015 → T016 → T017+T018

---

## Notes

- [P] tasks operate on different sections of the same file (api-reference.md) or different aspects — safe to batch
- SKILL.md tasks (T008–T013) must be written sequentially since they all edit the same file
- Each flow in SKILL.md should be independently invocable — verify each scenario group before moving to next story
- `rkit:profile` is a net-new skill: the SKILL.md does not exist yet (unlike 024 which edited an existing skill)
- sync-plugin (/sync-plugin) handles copying api.sh and api-reference.md master copies to all skills; run it in Phase 7
- No tests requested — skip test tasks
