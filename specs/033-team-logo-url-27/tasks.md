---

description: "Task list template for feature implementation"
---

# Tasks: Team Logo URL Support

**Input**: Design documents from `/specs/033-team-logo-url-27/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. Phase 2 (api-reference.md) is foundational and must complete before skill phases.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Single project — files at repo root:

```text
api-reference.md                      ← master API reference
skills/teams/SKILL.md                 ← teams skill
skills/teams/references/api-reference.md  ← synced copy (via /sync-plugin)
```

---

## Phase 1: Setup (API Verification)

**Purpose**: Confirm live API matches the documented contracts before writing any code.

- [x] T001 Call `GET /teams` via `scripts/api.sh` and confirm `logo_url` field is present in team objects (null or string)
- [x] T002 [P] Call `POST /teams/{id}/logo` with JSON body `{"logo_url":"https://cdn.filestackcontent.com/test"}` via `scripts/api.sh` and confirm 200 or 403 response shape
- [x] T003 [P] Call `DELETE /teams/{id}/logo` via `scripts/api.sh` and confirm endpoint exists (200 or 403 response, not 404)

---

## Phase 2: Foundational (Update api-reference.md)

**Purpose**: Update the master API reference before skill changes — skills reference this doc.

**⚠️ CRITICAL**: Phases 3–5 can begin after this phase is complete.

- [x] T004 Add `logo_url` (string | null) to the team response fields description in `api-reference.md` for both `GET /teams` (list) and `GET /teams/{id}` (detail) response shapes
- [x] T005 Add `POST /teams/{id}/logo` endpoint row to the Teams endpoint table in `api-reference.md` (JSON body, Filestack CDN URL validation, upsert, admin-only)
- [x] T006 Add `DELETE /teams/{id}/logo` endpoint row to the Teams endpoint table in `api-reference.md` (removes logo, idempotent, admin-only)

**Checkpoint**: `api-reference.md` fully documents all 4 logo-related endpoint changes — ready for skill updates.

---

## Phase 3: User Story 1 — View Team Logo in Skill Output (Priority: P1) 🎯 MVP

**Goal**: Team list output includes `logo_url` when set on a team.

**Independent Test**: Run `/rkit:teams` and confirm the output table includes a Logo column with the handle (e.g. `abc123handle`) for teams with a logo and "—" for teams without one.

### Implementation for User Story 1

- [x] T007 [US1] Add `Logo` column to the team list table in `skills/teams/SKILL.md` (Flow: List Teams → Step 3 display format): show Filestack handle (last path segment of `logo_url`) or "—" if null

**Checkpoint**: `/rkit:teams` output shows logo status. US1 is independently testable.

---

## Phase 4: User Story 2 — Set Team Logo via Skill (Priority: P2)

**Goal**: Admin users can set a team's Filestack CDN logo URL via a natural language command.

**Independent Test**: Run `/rkit:teams logo set {team_id} {filestack_url}` as an admin — skill confirms the action, asks for confirmation, executes `POST /teams/{id}/logo`, and confirms the new logo URL.

### Implementation for User Story 2

- [x] T008 [US2] Add `logo set {url} [team_id]` argument pattern to the Argument Parsing table in `skills/teams/SKILL.md`
- [x] T009 [US2] Add `## Flow: Set Logo` section to `skills/teams/SKILL.md` with steps: (1) resolve team ID from args or default config, (2) validate URL arg present, (3) show confirmation with team name+ID and URL, (4) execute `POST /teams/TEAM_ID/logo` with JSON body `{"logo_url":"URL"}`, (5) handle 200/403/422/404 responses; **also update `allowed-tools` frontmatter** to include scoped `Bash(scripts/api.sh *)` pattern if not already present (Constitution IV)
- [x] T010 [US2] Add set-logo edge cases to the Edge Cases section in `skills/teams/SKILL.md`: missing URL arg, non-Filestack URL (422), not admin (403), team not found (404)

**Checkpoint**: `/rkit:teams logo set` works for admins. US2 independently testable.

---

## Phase 5: User Story 3 — Remove Team Logo via Skill (Priority: P3)

**Goal**: Admin users can remove a team's logo URL via a natural language command.

**Independent Test**: Run `/rkit:teams logo remove {team_id}` as an admin — skill asks for confirmation, executes `DELETE /teams/{id}/logo`, and confirms the logo is cleared.

### Implementation for User Story 3

- [x] T011 [US3] Add `logo remove [team_id]` argument pattern to the Argument Parsing table in `skills/teams/SKILL.md` (after T008 completes)
- [x] T012 [US3] Add `## Flow: Remove Logo` section to `skills/teams/SKILL.md` with steps: (1) resolve team ID from args or default config, (2) show confirmation with team name+ID, (3) execute `DELETE /teams/TEAM_ID/logo`, (4) handle 200/403/404 responses
- [x] T013 [US3] Add remove-logo edge cases to the Edge Cases section in `skills/teams/SKILL.md`: not admin (403), team not found (404), no logo set (still 200 — idempotent) (after T010 completes)

**Checkpoint**: All three user stories functional. Full logo management available.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, validate end-to-end, finalize.

- [x] T014 Run `/sync-plugin` to copy updated `api-reference.md` to all skill `references/` directories and bump the plugin patch version in `.claude-plugin/plugin.json`
- [x] T015 [P] Validate all changes with live API calls per `specs/033-team-logo-url-27/quickstart.md` test commands
- [x] T016 Commit all changes on branch `033-team-logo-url-27` with a descriptive message

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: No dependencies on Phase 1 — can run in parallel with verification
- **US1 (Phase 3)**: Depends on Phase 2 complete
- **US2 (Phase 4)**: Depends on Phase 2 complete; can run after Phase 3 (same file)
- **US3 (Phase 5)**: Depends on Phase 4 complete (shares Argument Parsing and Edge Cases sections in same file)
- **Polish (Phase 6)**: Depends on Phases 3–5 complete

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2 — no story dependencies
- **US2 (P2)**: Independent after Phase 2 — no story dependencies (but edits same file as US1 tasks)
- **US3 (P3)**: Depends on US2 completing T008 and T010 first (appends to same table sections in SKILL.md)

### Within Each User Story

- T008 → T009 → T010 (US2: argument parsing, then flow, then edge cases)
- T011 → T012 → T013 (US3: same pattern, same file sections — must follow US2 edits)

### Parallel Opportunities

- T002 and T003 (Phase 1) can run in parallel
- T005 and T006 (Phase 2) are sequential (same table in api-reference.md)
- T015 (Phase 6) can run in parallel with T014

---

## Parallel Example: Phase 1

```bash
# Launch verification tasks together:
Task: "Call POST /teams/{id}/logo and confirm response"   # T002
Task: "Call DELETE /teams/{id}/logo and confirm endpoint" # T003
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: API Verification
2. Complete Phase 2: Update api-reference.md (CRITICAL — foundational)
3. Complete Phase 3: User Story 1 (logo display in team list)
4. **STOP and VALIDATE**: Run `/rkit:teams` and confirm logo column appears
5. If validating only P1, run `/sync-plugin` + commit

### Incremental Delivery

1. Phase 1 + 2 → API reference accurate ✓
2. Phase 3 (US1) → Logo visibility in team list ✓
3. Phase 4 (US2) → Admin can set logo ✓
4. Phase 5 (US3) → Admin can remove logo ✓
5. Phase 6 → Plugin synced and shipped ✓

### Single Developer Strategy

Work sequentially: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6.
All phases edit different sections or files until US3 (which extends US2's edits).

---

## Notes

- [P] tasks = different files or independent operations, no shared dependencies
- [Story] label maps each task to its user story for traceability
- US3 tasks depend on US2 completing T008/T010 first — do not reorder
- After all skill changes, `/sync-plugin` is mandatory to propagate `api-reference.md` to skill reference copies
- Commit after each phase or logical group
- `logo_url` display: show only the Filestack handle (last path segment), not the full URL — keeps table readable
