# Tasks: Teams Tabs API Endpoints

**Input**: Design documents from `/specs/024-teams-tabs-endpoints/`
**Prerequisites**: plan.md, spec.md, research.md, contracts/teams-new-endpoints-api.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. Two existing files edited in-place; no new files created.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Exact file paths included in descriptions

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: Update the argument parsing table in skills/teams/SKILL.md for both new commands. Both `role` and `logs` entries live in the same table, so they are added together before US2/US3 flows are written.

- [X] T001 Add `role {user_id} {role} [team_id]` and `logs [team_id]` entries to the argument parsing table in skills/teams/SKILL.md

**Checkpoint**: Argument parsing table complete — US2 and US3 flows can now be implemented independently.

---

## Phase 2: User Story 1 - Document New Team Endpoints (Priority: P1) 🎯 MVP

**Goal**: Add all 12 new endpoints to the Teams section of api-reference.md, plus glossary entries for every new concept.

**Independent Test**: Read api-reference.md — verify Teams section includes activity logs, labels, integrations, member role change, and logo upload endpoints, each with params, response shapes, and error codes. Verify glossary has entries for all new user phrases.

### Implementation for User Story 1

- [X] T002 [US1] Add GET /teams/{id}/activity-logs to the Team Members subsection of api-reference.md (params, ActivityLogEntry fields, error codes)
- [X] T003 [US1] Add GET/POST/PATCH/DELETE /teams/{id}/labels to a new Team Labels subsection of api-reference.md (Label fields, admin-only write note)
- [X] T004 [US1] Add GET/POST/PATCH/DELETE /teams/{id}/integrations to a new Team Integrations subsection of api-reference.md (Integration fields, upsert semantics, admin-only note)
- [X] T005 [US1] Add PATCH /teams/{id}/members/{user_id} to the Team Members subsection of api-reference.md (role change: body, response fields, error codes)
- [X] T006 [US1] Add POST /teams/{id}/logo to the Teams section of api-reference.md (multipart/form-data, admin-only, web-UI-only note)
- [X] T007 [US1] Add glossary entries for all new team concepts to api-reference.md: activity logs, team labels, team integrations, role change, logo upload

**Checkpoint**: API reference fully documents all 12 new endpoints.

---

## Phase 3: User Story 2 - Change Team Member Roles (Priority: P2)

**Goal**: Add a `role` flow to skills/teams/SKILL.md so team admins can change a member's role with confirmation.

**Independent Test**: Run `/rkit:teams role 42 admin` — verify confirmation prompt shows member name, current role, and new role; result displays updated role. Verify 403 on non-admin attempt.

### Implementation for User Story 2

- [X] T008 [US2] Write the Role Change flow in skills/teams/SKILL.md (resolve team ID → fetch member to get current role → confirm with name/current/new role → PATCH /teams/{team_id}/members/{user_id} → display result showing user name, user ID, and new role)
- [X] T009 [US2] Add error handling for 401, 403, 404, 422 responses in the Role Change flow in skills/teams/SKILL.md, and add client-side validation for invalid role values

**Checkpoint**: Role change command functional — team admins can promote/demote members from CLI.

---

## Phase 4: User Story 3 - View Team Activity Logs (Priority: P3)

**Goal**: Add a `logs` flow to skills/teams/SKILL.md so users can see recent membership changes for a team.

**Independent Test**: Run `/rkit:teams logs` — verify a table of activity log entries appears showing action, target user, actor, and date. Verify 403 on non-member access.

### Implementation for User Story 3

- [X] T010 [US3] Write the Activity Logs flow in skills/teams/SKILL.md (resolve team ID → GET /teams/{team_id}/activity-logs → display table with action, target user, actor, date → handle pagination)
- [X] T011 [US3] Add error handling for 401, 403, 404 responses in the Activity Logs flow in skills/teams/SKILL.md

**Checkpoint**: Activity logs command functional — users can view membership history from CLI.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, mark spec complete.

- [X] T012 Invoke the sync-plugin skill (/sync-plugin) to copy the updated api-reference.md to all skills/*/references/ and api.sh to all skills/*/scripts/ directories
- [X] T013 Bump version in .claude-plugin/plugin.json and gemini-extension.json
- [X] T014 Set spec status to Complete in specs/024-teams-tabs-endpoints/spec.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — start immediately. Blocks US2 and US3.
- **US1 (Phase 2)**: Depends on nothing — runs in parallel with Foundational.
- **US2 (Phase 3)**: Depends on T001 (Foundational) completion.
- **US3 (Phase 4)**: Depends on T001 (Foundational) completion. Independent of US2.
- **Polish (Phase 5)**: Depends on US1, US2, and US3 completion.

### User Story Dependencies

- **T001 (Foundational)**: No dependencies
- **US1 (T002–T007)**: T002–T006 are parallelizable (different sections of same file); T007 depends on T002–T006 (adds glossary after all endpoints are added)
- **US2 (T008–T009)**: Sequential (same file, same flow section)
- **US3 (T010–T011)**: Sequential (same file, same flow section)

### Parallel Opportunities

- T001 (SKILL.md) and T002–T006 (api-reference.md) operate on different files and can run in parallel
- T002–T006 touch different sections of api-reference.md but MUST be executed sequentially (same file; an LLM cannot safely parallelize writes to the same file)
- After T001: US2 (T008–T009) and US3 (T010–T011) operate on the same SKILL.md file and MUST be executed sequentially — complete US2 before starting US3

---

## Execution Order: Foundational + US1

```bash
# T001 and T002–T006 operate on different files and can start together:
Track A: T001                              (skills/teams/SKILL.md — argument parsing)
Track B: T002 → T003 → T004 → T005 → T006 → T007  (api-reference.md — sequential, same file)

# Then sequential (same SKILL.md file — complete US2 before US3):
T008 → T009   (US2 - SKILL.md role change flow)
T010 → T011   (US3 - SKILL.md activity logs flow)
T012 → T013 → T014  (Polish)
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Foundational (T001) and US1 (T002–T007)
2. **STOP and VALIDATE**: Verify all 12 endpoints in api-reference.md
3. Continue to US2 and US3

### Incremental Delivery

1. Foundational + US1 → API reference complete → discoverable
2. US2 → Role change command → admin workflow enabled
3. US3 → Activity logs → audit visibility enabled
4. Polish → synced, versioned, spec marked complete

---

## Notes

- No new files created — two existing files edited in-place
- skills/teams/SKILL.md currently has only 2 flows (List Teams, List Members) — both new flows extend it
- US1 tasks T002–T006 all touch api-reference.md and MUST be executed sequentially by an LLM (single-file writes); a human team could parallelize across branches
- Role change (PATCH) requires confirmation per constitution; activity logs (GET) do not
- Labels, integrations, and logo upload are reference-only (no skill flows)
