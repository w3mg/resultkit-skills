# Tasks: Review Template Team Ownership & Sharing

**Input**: Design documents from `specs/027-review-template-teams/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup

**Purpose**: Confirm working state before making changes.

- [X] T001 Read `skills/reviews/SKILL.md` in full to establish baseline before edits

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Cross-cutting changes that all user stories depend on — must complete before US phases.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 Update review templates section in `api-reference.md` (master): add `owning_team_id?` to POST body, `shared_with_team_ids?` to PATCH body, note `owning_team_id` rejected on PATCH, update auth notes to "Admin on owning team" for POST/PATCH/DELETE, add team-scoped visibility note to GET, update ReviewTemplateListItem fields to include `owning_team: { id, name } | null`, update ReviewTemplateDetail fields to include `owning_team` and `shared_with_teams`
- [X] T003 Update Error Handling section in `skills/reviews/SKILL.md`: add `status: 400` on template PATCH handler ("Cannot change owning team after creation"), update `status: 403` for template create/update/delete to say "Admin on the owning team required."
- [X] T004 Update Argument Parsing table in `skills/reviews/SKILL.md`: add `templates` / `templates list`, `templates create`, `templates {id} update`, `templates {id} delete` rows

**Checkpoint**: api-reference.md updated, error handling extended, routing table updated — ready for user story implementation.

---

## Phase 3: User Story 1 — View Templates with Team Context (Priority: P1) 🎯 MVP

**Goal**: Every template listing shows the owning team name so users understand visibility at a glance.

**Independent Test**: Run `/rkit:reviews` → `create` → reach template selection step → confirm the template table has an "Owning Team" column showing team names or "—".

- [X] T005 [US1] Update template selection table in Flow: Create Review → Step 1 in `skills/reviews/SKILL.md`: add `Owning Team` column; display `owning_team.name` or "—" if null
- [X] T006 [US1] Add new "Flow: List Templates" section to `skills/reviews/SKILL.md`: fetch `GET /review-templates?per_page=50`, display table with columns ID / Name / Prompts / Owning Team (null → "—"), show count, empty → "No templates found."

**Checkpoint**: Template listings show owning team. User Story 1 independently testable.

---

## Phase 4: User Story 2 — Create Template with Owning Team (Priority: P2)

**Goal**: Admin can create a review template and optionally assign it to an owning team.

**Independent Test**: Run `/rkit:reviews templates create`, provide a name and team ID → confirm the POST body includes `owning_team_id` and the response shows `owning_team: { id, name }` and `shared_with_teams: []`.

- [X] T007 [US2] Add new "Flow: Create Template" section to `skills/reviews/SKILL.md`: prompt for name (required), target_role (optional), reviewer_instructions (optional), owning_team_id (optional — blank = omit); confirm then POST to `/review-templates` with only provided fields; display response showing `owning_team` and `shared_with_teams`; handle 403 → "Admin on the owning team required."

**Checkpoint**: Template creation works with optional owning team. User Story 2 independently testable.

---

## Phase 5: User Story 3 — Manage Template Sharing & Deletion (Priority: P3)

**Goal**: Admin can manage which teams a template is shared with (US3), and delete templates (FR-007).

**Independent Test**: Run `/rkit:reviews templates {id} update`, provide shared team IDs → confirm PATCH body includes `shared_with_team_ids` array and response shows `shared_with_teams`. Run with "none" → confirm `shared_with_team_ids: []` sent.

- [X] T008 [US3] Add new "Flow: Update Template" section to `skills/reviews/SKILL.md`: fetch GET `/review-templates/{id}` to show current values; prompt for name, target_role, reviewer_instructions (blank = keep); prompt for shared_with_team_ids as comma-separated IDs ("none" = `[]`, blank = omit); confirm then PATCH; handle 400 → "Cannot change owning team after creation"; handle 403 → "Admin on the owning team required."; display `owning_team` and `shared_with_teams` from response
- [X] T009 [FR-007] Add new "Flow: Delete Template" section to `skills/reviews/SKILL.md`: fetch GET `/review-templates/{id}` to show name and owning team; confirm "Delete template #{id} '{name}' (Owning team: {name|"—"})? This is permanent."; DELETE `/review-templates/{id}`; handle 403 → "Admin on the owning team required."

**Checkpoint**: Template sharing and deletion work correctly. All three user stories independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files and finalize the change.

- [X] T010 Copy updated `api-reference.md` to `skills/reviews/references/api-reference.md` (do NOT run /sync-plugin — that bumps plugin version and copies to ALL skills; just copy this file manually — intentional exception to the normal sync-plugin workflow: only the reviews skill needs this update; full sync deferred until all relevant skills adopt these endpoints)
- [X] T011 Confirm the Edge Cases section in `skills/reviews/SKILL.md` covers: null `owning_team` (display "—"), empty `shared_with_teams` (display "—" or "None"), 400 on owning_team_id in PATCH, 403 on template admin actions; add any missing cases if absent

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **User Stories (Phases 3–5)**: All depend on Phase 2 completion; can proceed in priority order
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends on Phase 2 only — no other story dependencies
- **US2 (P2)**: Depends on Phase 2 only — independent of US1
- **US3 (P3)**: Depends on Phase 2 only — independent of US1 and US2

### Parallel Opportunities

- T005 and T006 (within US1 phase) affect different sections of SKILL.md — sequential to avoid edit conflicts
- T008 and T009 (within Phase 5) target different sections of SKILL.md — sequential to avoid edit conflicts

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (read SKILL.md)
2. Complete Phase 2: Foundational (api-reference.md, error handling, routing table)
3. Complete Phase 3: US1 (template list + owning team column)
4. **STOP and VALIDATE**: Template table shows owning team in Create Review flow
5. Continue to US2 and US3 for full coverage

### Incremental Delivery

1. Phase 2 complete → api-reference.md accurate, routing documented
2. US1 complete → template listings show team context (visible in Create Review flow)
3. US2 complete → admins can create templates with team ownership
4. US3 complete → admins can manage sharing and delete templates
5. Phase 6 → files synced, edge cases verified

---

## Notes

- All edits target `skills/reviews/SKILL.md` — edit sequentially to avoid conflicts
- Master `api-reference.md` at repo root is the source of truth; copy to `skills/reviews/references/` in T010
- No test tasks generated (not requested in spec)
