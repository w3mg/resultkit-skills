# Tasks: Password Reset Skill

**Input**: Design documents from `/specs/021-password-reset/`
**Prerequisites**: plan.md, spec.md, research.md, contracts/password-api.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: Create skill directory structure and copy shared files

- [X] T001 Create skill directory structure: `skills/password-reset/SKILL.md`, `skills/password-reset/scripts/`, `skills/password-reset/references/`
- [X] T002 Copy shared files: `scripts/api.sh` → `skills/password-reset/scripts/api.sh`, `api-reference.md` → `skills/password-reset/references/api-reference.md`

---

## Phase 2: Foundational

**Purpose**: Write SKILL.md skeleton with frontmatter and shared sections

- [X] T003 Write SKILL.md frontmatter (name: `rkit:password-reset`, description, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion`), Current State section, Rules section, and Error Handling section (NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 "Admin access required.", 422) in `skills/password-reset/SKILL.md`
- [X] T004 Write Argument Parsing section in `skills/password-reset/SKILL.md`: `{user_id}` → Trigger Password Reset, *(no args)* → show usage message

**Checkpoint**: SKILL.md skeleton ready

---

## Phase 3: User Story 1 — Admin Triggers Password Reset (Priority: P1) 🎯 MVP

**Goal**: Admins can trigger a password reset email for a user with one command

**Independent Test**: Run `/rkit:password-reset 42` to trigger a reset. Verify confirmation prompt and success message.

- [X] T005 [US1] Write Flow: Trigger Password Reset in `skills/password-reset/SKILL.md` — validate user_id is provided (show usage if missing), show confirmation prompt "Send password reset email to user #{user_id}?", on confirm call `POST /passwords/reset` with `{"user_id": ID}`, show "Password reset email sent to user #{user_id}." on success. Handle 403 → "Admin access required.", 422 → show validation error. Add Edge Cases section and References.

**Checkpoint**: US1 complete — admin can trigger password reset

---

## Phase 4: User Story 2 — Update API Reference (Priority: P2)

**Goal**: Both password endpoints documented in api-reference.md

**Independent Test**: Read api-reference.md and verify Passwords section exists with both endpoints.

- [X] T006 [US2] Add Passwords section to `api-reference.md` (root) with both endpoints: `POST /passwords/reset` (admin auth, body: user_id, user phrases: "reset password", "send password reset") and `PUT /passwords` (unauthenticated, body: token + password, user phrases: "set new password", "complete password reset"). Include field descriptions and note PUT is unauthenticated.

**Checkpoint**: US2 complete — API reference updated

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, finalize

- [X] T007 Run `/sync-plugin` to copy updated api.sh and api-reference.md to all skills including password-reset
- [X] T008 Bump version in `.claude-plugin/plugin.json` and `gemini-extension.json`
- [X] T009 Set spec status to Complete in `specs/021-password-reset/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup
- **US1 (Phase 3)**: Depends on Foundational
- **US2 (Phase 4)**: No dependency on US1 (different file: api-reference.md vs SKILL.md)
- **Polish (Phase 5)**: Depends on US1 and US2

### Parallel Opportunities

- US1 and US2 could run in parallel (different files) but sequential is fine for this size

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T004)
3. Complete Phase 3: US1 — Trigger Reset (T005)
4. **STOP and VALIDATE**: Admin can trigger password reset
5. Continue to US2, Polish

### Incremental Delivery

1. Setup + Foundational → Skill skeleton ready
2. US1: Trigger Reset → Admin functionality (MVP)
3. US2: API Reference → Documentation completeness
4. Polish → Sync, version bump, finalize

## Notes

- This is the simplest possible rkit skill: one flow, one API call, one confirmation
- Follow exact patterns from existing skills (1on1, reviews) for frontmatter and error handling
- PUT /passwords is documented in api-reference.md but NOT implemented in the skill
