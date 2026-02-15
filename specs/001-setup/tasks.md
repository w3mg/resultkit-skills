---
description: "Task list for rkit:setup skill implementation"
---

# Tasks: rkit:setup

**Input**: Design documents from `/specs/001-setup/`
**Prerequisites**: plan.md (required), spec.md (required), research.md,
data-model.md, contracts/

**Tests**: Not requested in spec. Manual invocation testing only.

**Organization**: Tasks grouped by user story for independent
implementation and testing.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Include exact file paths in descriptions

## Path Conventions

- Skills: `skills/rkit/setup/`
- Shared scripts: `scripts/`
- Config: `~/.config/resultkit/config.json`

---

## Phase 1: Setup (Project Structure)

**Purpose**: Create directory structure and reference files

- [x] T001 Create directory structure: `skills/rkit/setup/references/` and `scripts/`
- [x] T002 [P] Copy `api-reference.md` to `skills/rkit/setup/references/api-reference.md`

---

## Phase 2: Foundational (Shared Infrastructure)

**Purpose**: Build the shared `api.sh` script that ALL rkit skills
depend on. MUST complete before any user story work.

**CRITICAL**: No user story work can begin until this phase is complete.

- [x] T003 Create shared API caller at `scripts/api.sh` implementing FR-008 through FR-011:
  - Accept `METHOD PATH [BODY]` arguments
  - Read `api_token` and `api_base` from `~/.config/resultkit/config.json` via jq
  - Execute curl with Bearer auth header
  - Return JSON: `{ "status": <int>, "body": <object> }` on success
  - Return `{ "status": 0, "error": "NO_CONFIG" }` if config missing
  - Return `{ "status": 0, "error": "CURL_FAILED" }` on network error
  - Make executable (`chmod +x`)
- [x] T004 Create install script at `scripts/install.sh`:
  - Copy `skills/rkit/setup/` to `~/.claude/skills/rkit:setup/`
  - Copy `scripts/api.sh` to `~/.claude/skills/rkit:setup/scripts/`
  - Make executable (`chmod +x`)

**Checkpoint**: Foundation ready — api.sh works, install script ready.

---

## Phase 3: User Story 1 — First-Time Setup (Priority: P1) MVP

**Goal**: A new user runs `/rkit:setup` with no prior config and ends
with a valid `config.json` containing verified token and chosen team.

**Independent Test**: Delete `~/.config/resultkit/config.json`, invoke
`/rkit:setup`, provide a valid token, pick a team, confirm config is
written.

### Implementation for User Story 1

- [x] T005 [US1] Create SKILL.md skeleton at `skills/rkit/setup/SKILL.md`:
  - Skill metadata (name, description, namespace `rkit:setup`)
  - Reference to `scripts/api.sh` and `references/api-reference.md`
  - Instruction preamble: constitution principles (confirm writes,
    show IDs, concise output, direct execution)
- [x] T006 [US1] Implement config detection logic in `skills/rkit/setup/SKILL.md`:
  - Check if `~/.config/resultkit/config.json` exists
  - If missing or malformed → enter first-time setup flow
  - If exists → branch to reconfigure flow (US2, placeholder for now)
- [x] T007 [US1] Implement token input and verification in `skills/rkit/setup/SKILL.md`:
  - Ask user for API token
  - Call `GET /users/me` via `scripts/api.sh`
  - On 200: extract `id`, `name`, `email` from response
  - On 401: display error, ask for correct token
  - On network error: display actionable error message
- [x] T008 [US1] Implement team listing and selection in `skills/rkit/setup/SKILL.md`:
  - Call `GET /users/{id}/teams` via `scripts/api.sh`
  - Display teams as table: `| # | ID | Name | Framework |`
  - Ask user to pick a team by number
  - Handle empty teams: display message, set `default_team_id` to null
- [x] T009 [US1] Implement config writing in `skills/rkit/setup/SKILL.md`:
  - Create `~/.config/resultkit/` directory if needed (FR-007)
  - Write `config.json` with `api_token`, `default_team_id`, `api_base`
  - Default `api_base` to `https://api.resultmaps.com/api/v2` (FR-004)
  - Confirm before writing (Constitution IV: Confirm Writes)
- [x] T010 [US1] Implement confirmation output in `skills/rkit/setup/SKILL.md`:
  - Display: user name, email, chosen team name, team ID
  - Format as concise summary (Constitution IX)

**Checkpoint**: First-time setup fully functional. MVP complete.

---

## Phase 4: User Story 2 — Reconfigure Existing Setup (Priority: P2)

**Goal**: A user with existing config runs `/rkit:setup` and can
selectively update token, team, or API base without losing other
settings.

**Independent Test**: Create a valid config, run `/rkit:setup`, verify
current settings are shown with masked token, update one field, confirm
only that field changed.

### Implementation for User Story 2

- [x] T011 [US2] Implement existing config display in `skills/rkit/setup/SKILL.md`:
  - Read current config via jq
  - Mask token: show first 3 + last 4 characters (FR-006)
  - Display: masked token, team name (fetch via API), API base
- [x] T012 [US2] Implement selective update menu in `skills/rkit/setup/SKILL.md`:
  - Present options: update token, update default team, update API base
  - Preserve unchanged fields when writing (FR-005, SC-004)
- [x] T013 [US2] Implement token update flow in `skills/rkit/setup/SKILL.md`:
  - Ask for new token
  - Verify via `GET /users/me` before saving (FR-003)
  - On success: update only `api_token` in config
- [x] T014 [US2] Implement team re-selection in `skills/rkit/setup/SKILL.md`:
  - Fetch teams via `GET /users/{id}/teams`
  - Highlight current default team in list
  - On selection: update only `default_team_id` in config

**Checkpoint**: Reconfigure works independently. Both US1 and US2
functional.

---

## Phase 5: User Story 3 — Environment Variable Fallback (Priority: P3)

**Goal**: Setup detects `RESULTKIT_TOKEN` env var and offers to use it
automatically during first-time setup.

**Independent Test**: Set `RESULTKIT_TOKEN` env var, delete config, run
`/rkit:setup`, verify env var token is offered. Then with existing
config, verify env var is NOT silently used.

### Implementation for User Story 3

- [x] T015 [US3] Implement env var detection in `skills/rkit/setup/SKILL.md`:
  - Check `$RESULTKIT_TOKEN` environment variable at start of setup
  - If set and no config exists: offer to use env var token (skip
    manual input prompt)
  - If set and config exists: do NOT auto-use — show normal
    reconfigure flow (US2)
- [x] T016 [US3] Implement env var verification in `skills/rkit/setup/SKILL.md`:
  - If user accepts env var token: verify via `GET /users/me`
  - On success: proceed to team selection (same as US1 T008)
  - On failure: fall back to manual token input

**Checkpoint**: All 3 user stories functional and independently
testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and deployment readiness

- [x] T017 Validate constitution compliance for all 9 principles against `skills/rkit/setup/SKILL.md`
- [x] T018 Run quickstart.md walkthrough end-to-end at `specs/001-setup/quickstart.md` (manual — requires live token)
- [x] T019 [P] Verify edge cases from spec:
  - No teams → null default_team_id
  - Config directory creation failure → filesystem error message
  - Token valid but teams endpoint fails → save token, warn
  - Corrupted config → offer to recreate with confirmation
- [x] T020 Run `scripts/install.sh` and verify skill is available as `/rkit:setup`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all
  user stories
- **US1 (Phase 3)**: Depends on Phase 2 — MVP target
- **US2 (Phase 4)**: Depends on Phase 3 (extends config detection
  branch in SKILL.md)
- **US3 (Phase 5)**: Depends on Phase 3 (extends token input section
  in SKILL.md)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational only — no other story deps
- **US2 (P2)**: Depends on US1 (extends the config-exists branch)
- **US3 (P3)**: Depends on US1 (extends the token-input section).
  Independent of US2.

### Within Each User Story

- SKILL.md sections are written sequentially (same file)
- api.sh calls must work before skill logic can execute

### Parallel Opportunities

- T001 and T002 can run in parallel (different directories)
- T003 and T004 operate on different files (parallel)
- US2 (Phase 4) and US3 (Phase 5) are independent of each other
  once US1 is complete — could proceed in parallel
- T017, T018, T019 in Polish phase can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational — api.sh + install.sh (T003–T004)
3. Complete Phase 3: US1 — First-Time Setup (T005–T010)
4. **STOP and VALIDATE**: Run quickstart first-time flow
5. Skill is usable after this point

### Incremental Delivery

1. Setup + Foundational → api.sh ready
2. US1 → First-time setup works → MVP!
3. US2 → Reconfigure works → returning users supported
4. US3 → Env var fallback → power user convenience
5. Polish → validated, installed, deployed

---

## Notes

- All user story tasks modify the same file (`SKILL.md`) — within a
  story, tasks are sequential.
- api.sh is the only Bash script. SKILL.md is Markdown with embedded
  Claude Code instructions.
- No automated tests — validation is manual invocation per quickstart.
- Commit after each phase completion.
