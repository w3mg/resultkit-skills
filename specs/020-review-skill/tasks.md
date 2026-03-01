# Tasks: Review Skill

**Input**: Design documents from `/specs/020-review-skill/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/reviews-api.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: Create skill directory structure and copy shared files

- [X] T001 Create skill directory structure: `skills/reviews/SKILL.md`, `skills/reviews/scripts/`, `skills/reviews/references/`
- [X] T002 Copy shared files: `scripts/api.sh` → `skills/reviews/scripts/api.sh`, `api-reference.md` → `skills/reviews/references/api-reference.md`

---

## Phase 2: Foundational

**Purpose**: Write SKILL.md skeleton with frontmatter, shared sections, and argument parsing that all flows depend on

**⚠️ CRITICAL**: No flow implementation can begin until this phase is complete

- [X] T003 Write SKILL.md frontmatter (name: `rkit:reviews`, description, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion`) and Current State section (config check, api.sh path resolution) in `skills/reviews/SKILL.md`
- [X] T004 Write Rules section (confirm writes, show IDs, concise output, direct execution), Error Handling section (NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403, 404, 422), and Team ID Resolution section (3-tier: --team flag > default_team_id > no filter) in `skills/reviews/SKILL.md`
- [X] T005 Write Argument Parsing table mapping all commands to flows in `skills/reviews/SKILL.md`: *(no args)* → List Reviews, `{id}` → View Review Detail, `{id} assess` → Assess Review, `{id} draft` → Draft Assessment, `{id} sign-off` → Sign Off, `create` → Create Review, `{id} void` → Void Review, `{id} archive` → Archive Review, `values` → List Core Values, `rate {user_id}` → Rate Core Values, `--team {id}` → override team ID

**Checkpoint**: SKILL.md skeleton ready — flow implementation can begin

---

## Phase 3: User Story 1 — View My Reviews (Priority: P1) 🎯 MVP

**Goal**: Users can list their reviews and drill into full detail with assessment visibility rules

**Independent Test**: Run `/rkit:reviews` to see review list table, then `/rkit:reviews {id}` to see detail with assessments, ratings, action items, and attachments

- [X] T006 [US1] Write Flow: List Reviews in `skills/reviews/SKILL.md` — call `GET /reviews?per_page=50`, display table with columns: ID, Reviewee, Reviewer, Status, Period (start_date – end_date). Show "No reviews found." if empty. Use `first_name last_name` for names (fall back to `login`).
- [X] T007 [US1] Write Flow: View Review Detail in `skills/reviews/SKILL.md` — call `GET /reviews/{id}`, display header (reviewee & reviewer names, status, template name, period), then sections: Self Assessment (responses table with prompt description + response_value/score), Reviewer Assessment (same format, note: API omits for reviewees until signed_off), Core Values Ratings (table: value name, score, rater), Action Items (table: ID, title, assignee), Attachments (list: filename). Empty sections show "(none)". Handle 404.

**Checkpoint**: US1 complete — list and detail views work independently

---

## Phase 4: User Story 2 — Submit Assessment (Priority: P2)

**Goal**: Users can draft and submit assessments by walking through template prompts with answer-type-appropriate input handling

**Independent Test**: Run `/rkit:reviews {id} assess` and complete the prompted flow. Run `/rkit:reviews {id} draft` to save partial progress.

- [X] T008 [US2] Write Flow: Assess Review in `skills/reviews/SKILL.md` — fetch review detail (`GET /reviews/{id}`), verify status is `in_progress`, prompt user via AskUserQuestion "Are you the reviewee (self-assessment) or the reviewer?" to determine `respondent_type`. If review has a template, fetch template detail (`GET /review-templates/{template_id}`) and walk through each prompt using AskUserQuestion: range → options from answer_meta_data, text/textarea → free-form, boolean → Yes/No, multiple → options from answer_meta_data. If review has no template (template is null), prompt for a single free-form text response. After all prompts, optionally prompt for core values ratings (fetch `GET /core-values`, score each). Show summary of all responses, confirm, then `POST /reviews/{id}/submit-assessment` with AssessmentSubmitRequest body.
- [X] T009 [US2] Write Flow: Draft Assessment in `skills/reviews/SKILL.md` — same prompt walk-through as assess flow, but on confirmation call `PUT /reviews/{id}/draft-assessment` instead of submit. Note in output that draft does not advance review state. If existing draft exists (check `self_assessment.is_draft` or `reviewer_assessment.is_draft` in review detail), pre-populate responses as defaults.

**Checkpoint**: US2 complete — assess and draft flows work, template prompts handled per answer type

---

## Phase 5: User Story 3 — Review Lifecycle Actions (Priority: P3)

**Goal**: Reviewers can sign off, admins can create, void, and archive reviews

**Independent Test**: Run `/rkit:reviews {id} sign-off` on an assessed review. Run `/rkit:reviews create` to create a new review.

- [X] T010 [US3] Write Flow: Sign Off Review in `skills/reviews/SKILL.md` — fetch review detail, verify status is `assessed`, prompt for initials via AskUserQuestion, confirm action, call `POST /reviews/{id}/sign-off` with `{"initials": "XX"}`. Show success with new status. Handle 403 ("You must be the reviewer to sign off.").
- [X] T011 [US3] Write Flow: Create Review in `skills/reviews/SKILL.md` — prompt for reviewee user ID, reviewer user ID, fetch templates (`GET /review-templates?per_page=50`), display template table (ID, name, prompt_count), prompt for template selection, optionally prompt for start_date and end_date, confirm all details, call `POST /reviews` with body. Show created review ID and status. Handle 403 ("Admin/people-ops permissions required.").
- [X] T012 [P] [US3] Write Flow: Void Review in `skills/reviews/SKILL.md` — fetch review detail, show current status, prompt for reason via AskUserQuestion, confirm action, call `PUT /reviews/{id}/void` with `{"reason": "..."}`. Show success. Handle 403 ("Admin/people-ops permissions required.").
- [X] T013 [P] [US3] Write Flow: Archive Review in `skills/reviews/SKILL.md` — fetch review detail, show current status/reviewee/reviewer, confirm action ("Archive review {id}? This removes it from the default review list."), call `DELETE /reviews/{id}`. Show success. Handle 403 ("Admin/people-ops permissions required.").

**Checkpoint**: US3 complete — full lifecycle (create → sign-off, void, archive) works

---

## Phase 6: User Story 4 — Core Values Ratings (Priority: P4)

**Goal**: Users can view core values and submit standalone ratings for team members

**Independent Test**: Run `/rkit:reviews values` to list core values, then `/rkit:reviews rate {user_id}` to submit ratings.

- [X] T014 [P] [US4] Write Flow: List Core Values in `skills/reviews/SKILL.md` — call `GET /core-values`, display table with columns: ID, Name, Description. Show "No core values defined for your organization." if empty.
- [X] T015 [US4] Write Flow: Rate Core Values in `skills/reviews/SKILL.md` — fetch core values (`GET /core-values`), for each value prompt for score via AskUserQuestion (numeric options), show summary table (value name, score), confirm, call `POST /core-values-ratings` with `{"subject_id": user_id, "ratings": [...]}`. Show success.

**Checkpoint**: US4 complete — core values listing and standalone rating work

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Sync shared files, bump version, finalize

- [X] T016 Add Edge Cases section to `skills/reviews/SKILL.md` — document handling for: no-template reviews (show fields without template prompts), existing draft pre-population, status validation messages for each flow
- [X] T017 Run `/sync-plugin` to copy updated api.sh and api-reference.md to all skills including reviews
- [X] T018 Bump version in `.claude-plugin/plugin.json` and `gemini-extension.json`
- [X] T019 Set spec status to Complete in `specs/020-review-skill/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational
- **US2 (Phase 4)**: Depends on Foundational (uses template fetch, independent of US1)
- **US3 (Phase 5)**: Depends on Foundational (uses template fetch for create, independent of US1/US2)
- **US4 (Phase 6)**: Depends on Foundational (independent of US1/US2/US3)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: No dependencies on other stories
- **US2 (P2)**: No dependencies on other stories (assess flow fetches its own review detail)
- **US3 (P3)**: No dependencies on other stories
- **US4 (P4)**: No dependencies on other stories

### Within Each User Story

- Flows writing to the same SKILL.md file must be sequential within a story
- T012 and T013 (void/archive) are parallel — different flows, no shared state

### Parallel Opportunities

- T012 [P] and T013 [P] (void and archive flows) can run in parallel
- T014 [P] (list core values) can run in parallel with T015 prep work
- All 4 user stories CAN run in parallel after Foundational, but since they share SKILL.md, sequential is safest

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T005)
3. Complete Phase 3: US1 — View Reviews (T006–T007)
4. **STOP and VALIDATE**: List reviews and view detail work correctly
5. Continue to US2–US4

### Incremental Delivery

1. Setup + Foundational → Skill skeleton ready
2. US1: List + Detail → Core read operations (MVP)
3. US2: Assess + Draft → Primary write workflow
4. US3: Sign-off + Create + Void + Archive → Full lifecycle
5. US4: Core Values → Supporting feature
6. Polish → Sync, version bump, finalize

## Notes

- All flows are written as sections in a single `skills/reviews/SKILL.md` file
- Follow the exact patterns from existing skills (1on1, board) for frontmatter, Current State, Error Handling
- Each flow follows the pattern: fetch data → validate state → collect input → confirm → execute → display result
- Assessment answer types map to AskUserQuestion: range→options, text/textarea→free-form, boolean→Yes/No, multiple→options
