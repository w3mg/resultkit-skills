# Feature Specification: Rebuild Skills with Skill Creator & L10 Route Coverage

**Feature Branch**: `016-rebuild-l10-skills`
**Created**: 2026-02-28
**Status**: Draft
**Input**: User description: "Ensure skills are all built using Skill Creator, and that the new level 10 related API routes are addressed correctly by the skills. This likely needs a new branch."

## Clarifications

### Session 2026-02-28

- Q: Should `rkit:level10` support operations beyond what the L10 API routes offer (move, mark done, update/archive headlines)? → A: Yes — full L10 workflow. Use generic routes as fallback for operations L10 endpoints don't support. All constitution rules (confirm writes, show IDs, etc.) still apply.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Dedicated L10 Skill for EOS Teams (Priority: P1)

A user on an EOS team wants to manage their Level 10 meeting artifacts (to-dos, issues, headlines) through a dedicated skill that speaks native L10 terminology and uses the L10-specific API routes (`/teams/{id}/l10/todos`, `/teams/{id}/l10/issues`, `/teams/{id}/l10/headlines`).

**Why this priority**: The L10 API routes exist in the API but no skill currently uses them directly. This is the primary new functionality gap. A dedicated `rkit:level10` skill provides EOS users a natural entry point that matches their vocabulary ("L10 to-dos" vs "weekly next items").

**Independent Test**: Can be fully tested by invoking `/rkit:level10` against an EOS team and verifying it lists to-dos, issues, and headlines using the L10 routes. Delivers direct value by giving EOS users a skill that matches their mental model.

**Acceptance Scenarios**:

1. **Given** an EOS team exists and the user has config set up, **When** the user invokes `/rkit:level10` with no args, **Then** the skill displays L10 to-dos, issues, and headlines using framework-appropriate terminology.
2. **Given** an EOS team exists, **When** the user invokes `/rkit:level10 add todo "Review Q1 plan"`, **Then** a new item is created via `POST /teams/{id}/l10/todos` with status=next and a 7-day due date.
3. **Given** an EOS team exists, **When** the user invokes `/rkit:level10 add issue "Cash flow concern"`, **Then** a new item is created via `POST /teams/{id}/l10/issues` with status=blocked.
4. **Given** an EOS team exists, **When** the user invokes `/rkit:level10 add headline "New client signed"`, **Then** a new headline is created via `POST /teams/{id}/l10/headlines`.
5. **Given** a non-EOS team, **When** the user invokes `/rkit:level10`, **Then** the skill shows an error: "Level 10 is only available for teams using the EOS framework."
6. **Given** an EOS team with an existing to-do, **When** the user invokes `/rkit:level10 done {item_id}`, **Then** the item is moved to done via the generic route (`PUT /teams/{id}/items/done/{item_id}`) with write confirmation.
7. **Given** an EOS team with an existing to-do, **When** the user invokes `/rkit:level10 move {item_id} issues`, **Then** the item is moved to issues/blocked via the generic route with write confirmation.
8. **Given** an EOS team with an existing headline, **When** the user invokes `/rkit:level10 remove headline {id}`, **Then** the headline is archived via the generic route (`DELETE /teams/{id}/headlines/{id}`) with write confirmation.

---

### User Story 2 - Rebuild All Skills via Skill Creator (Priority: P2)

A plugin maintainer wants all 11 existing skills to be rebuilt/validated through the `/skill-creator` tool to ensure consistent structure, quality, and adherence to the constitution (Section X mandate). Skills that were hand-written or modified outside Skill Creator need to be run through it.

**Why this priority**: Constitution Section X requires all skills be authored via Skill Creator. Ensuring compliance brings consistency, enables eval-based quality verification, and establishes the pattern for future skills. This is maintenance/quality work rather than new user-facing functionality.

**Independent Test**: Can be tested by running `/skill-creator` evals against each skill and verifying they pass quality benchmarks. Delivers value by ensuring all skills meet the same structural and behavioral standards.

**Acceptance Scenarios**:

1. **Given** each of the 11 existing skills, **When** the skill is processed through Skill Creator, **Then** it produces a SKILL.md that passes Skill Creator's built-in evals.
2. **Given** a rebuilt skill, **When** the user invokes it with the same inputs as before, **Then** it produces equivalent output (no regressions in behavior).
3. **Given** the full set of rebuilt skills, **When** all SKILL.md files are inspected, **Then** they share a consistent structure (frontmatter, Current State, Rules, Argument Parsing, Error Handling, Flows, Edge Cases, References).

---

### User Story 3 - L10 Route Awareness in Existing Skills (Priority: P3)

An EOS user invoking `rkit:weekly` on an EOS team wants the skill to use L10 routes where appropriate, providing a seamless EOS experience. The `rkit:headlines` skill should also leverage L10 headline routes for EOS teams.

**Why this priority**: The existing `rkit:weekly` skill already handles EOS terminology mapping via the Framework Terminology table, so it partially serves EOS users. Using the dedicated L10 routes is an enhancement rather than a blocker — the generic routes return the same data.

**Independent Test**: Can be tested by invoking `/rkit:weekly` on an EOS team and verifying it uses `/teams/{id}/l10/todos` instead of `/teams/{id}/items/next` (observable via API call patterns). Delivers value by using the API routes designed for EOS teams.

**Acceptance Scenarios**:

1. **Given** an EOS team, **When** `/rkit:weekly` fetches the "To-Do" column, **Then** it uses `GET /teams/{id}/l10/todos` rather than `GET /teams/{id}/items/next`.
2. **Given** an EOS team, **When** `/rkit:weekly` fetches the "Issues" column, **Then** it uses `GET /teams/{id}/l10/issues` rather than `GET /teams/{id}/items/blocked`.
3. **Given** a non-EOS team, **When** `/rkit:weekly` fetches columns, **Then** it continues to use the generic `/teams/{id}/items/{section}` routes.

---

### Edge Cases

- What happens when Skill Creator rebuilds a skill and introduces structural changes that alter behavior? Each skill must be regression-tested against known inputs.
- How does the system handle a user who has no EOS teams invoking `/rkit:level10`? Clear error message directing them to `/rkit:weekly`.
- What if the L10 routes return a different response shape than the generic routes? Per the API reference, they are aliases — same data, same structure.
- What if a skill's eval score decreases after rebuild? The rebuild should be iterated until eval scores meet or exceed the original.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new `rkit:level10` skill MUST exist that uses the L10-specific API routes (`/teams/{id}/l10/todos`, `/teams/{id}/l10/issues`, `/teams/{id}/l10/headlines`) for viewing and creating L10 artifacts.
- **FR-002**: The `rkit:level10` skill MUST support viewing all three L10 sections (to-dos, issues, headlines) in a single invocation with no arguments.
- **FR-003**: The `rkit:level10` skill MUST support creating new to-dos, issues, and headlines via subcommands (`add todo`, `add issue`, `add headline`).
- **FR-011**: The `rkit:level10` skill MUST support the full L10 workflow including move (to-do to issue, issue to to-do), mark done, and archive/update headlines, falling back to generic API routes where L10-specific routes do not exist.
- **FR-012**: All write operations in `rkit:level10` (create, move, done, archive, update) MUST follow constitution rules: describe the action and ask for confirmation before executing.
- **FR-004**: The `rkit:level10` skill MUST reject non-EOS teams with a clear error message.
- **FR-005**: All 11 existing skills MUST be processed through Skill Creator to ensure consistent structure and quality.
- **FR-006**: Rebuilt skills MUST maintain behavioral equivalence with their pre-rebuild versions (no regressions).
- **FR-007**: The `rkit:weekly` skill SHOULD use L10-specific routes when the team framework is EOS.
- **FR-008**: The `rkit:headlines` skill SHOULD use L10 headline routes when the team framework is EOS.
- **FR-009**: All skills (new and rebuilt) MUST comply with all constitution principles (config-driven, confirm writes, show IDs, framework-aware, direct execution, concise output).
- **FR-010**: The `rkit:level10` skill MUST be registered in the plugin manifest and distributed via the plugin system.

### Key Entities

- **L10 To-Do**: An Item with status=next, created via the L10 todos endpoint. Functionally identical to a "next" item on the weekly board but accessed through EOS-specific terminology and routes.
- **L10 Issue**: An Item with status=blocked, created via the L10 issues endpoint. Represents an IDS (Identify, Discuss, Solve) item in EOS methodology.
- **L10 Headline**: A Headline created via the L10 headlines endpoint. Team-level announcement with auto-expiration.
- **Skill (SKILL.md)**: The atomic unit of plugin functionality. A Markdown file with frontmatter, declarative flows, and embedded bash for API calls.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new `rkit:level10` skill exists and successfully lists to-dos, issues, and headlines for an EOS team in a single invocation.
- **SC-002**: All 12 skills (11 existing + 1 new) pass Skill Creator eval benchmarks.
- **SC-003**: No existing skill regressions — each rebuilt skill handles the same inputs and produces equivalent outputs as before the rebuild.
- **SC-004**: 100% of L10 API routes (`GET`/`POST` for todos, issues, headlines) are covered by at least one skill.
- **SC-005**: Users can complete an end-to-end L10 workflow (view board, add to-do, add issue, add headline, mark done, move item, archive headline) without leaving `rkit:level10`.

## Assumptions

- L10 API routes are aliases that return the same data shape as their generic counterparts (confirmed in api-reference.md).
- Skill Creator is available and functional for rebuilding all skills.
- The plugin manifest already supports adding new skills by adding directories under `skills/`.
- The existing `skills/level10/` directory structure (with empty `references/` and `scripts/` dirs) was scaffolded in preparation for this work.
- "Rebuild via Skill Creator" means running each skill through the `/skill-creator` workflow, not rewriting from scratch. Existing logic is preserved; structure and quality are standardized.

## Scope Boundaries

**In scope**:
- New `rkit:level10` skill with full L10 route coverage
- Processing all 11 existing skills through Skill Creator
- Updating `rkit:weekly` and `rkit:headlines` to prefer L10 routes for EOS teams
- Plugin manifest and shared file updates

**Out of scope**:
- New API endpoints or server-side changes
- Changes to the constitution or api-reference.md
- Adding skills for APIs not currently in the reference (e.g., scorecard, KPIs)
- Gemini extension updates (separate concern)
