# Feature Specification: Extend rkit:profile with Measurables, Rocks, Feedback, Progress, and Integrations

**Feature Branch**: `026-users-mgmt-api`
**Created**: 2026-03-04
**Status**: Draft
**Input**: GitHub Issue #16 — API Change Handoff: Users Management API (030)

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Personal Progress Dashboard (Priority: P1)

A user wants a quick snapshot of their personal performance: strategy metrics, practice streaks, and milestone progress. They run `/rkit:profile progress` and see a formatted dashboard with their current period's stats.

**Why this priority**: High-demand daily use case. Users check this more than any other profile stat.

**Independent Test**: Run `/rkit:profile progress` and verify a formatted progress report is displayed with strategy and practice scorecard sections.

**Acceptance Scenarios**:

1. **Given** a configured user, **When** they run `/rkit:profile progress`, **Then** the skill displays strategy metrics (rocks realized, milestones) and practice scorecard (day-by-day streak, totals).
2. **Given** a configured user, **When** they run `/rkit:profile progress week`, **Then** results are filtered to the weekly period.
3. **Given** a network error, **When** the user runs `/rkit:profile progress`, **Then** a clear error message is shown and execution stops.

---

### User Story 2 — View Measurables / Scorecard (Priority: P2)

A user wants to see their scorecard metrics. They run `/rkit:profile measurables` and see their KPIs with periodic data. They can also check another user's measurables (if they share a team).

**Why this priority**: Core accountability tool — measurables are reviewed in every L10 meeting.

**Independent Test**: Run `/rkit:profile measurables` and verify a table of measurable names, values, and periods is shown.

**Acceptance Scenarios**:

1. **Given** a configured user, **When** they run `/rkit:profile measurables`, **Then** the skill displays their scorecard metrics with period data.
2. **Given** a configured user, **When** they run `/rkit:profile measurables {user_id}`, **Then** the skill displays that user's metrics (if they share a team).
3. **Given** `{user_id}` does not share a team, **When** the user requests their measurables, **Then** a 403 error is shown explaining the team-sharing requirement.

---

### User Story 3 — View Rocks / Quarterly Goals (Priority: P2)

A user wants to see their quarterly rocks with milestone progress. They run `/rkit:profile rocks` and see a list of rocks with completion status.

**Why this priority**: Rocks are reviewed every L10. Users need quick access to status.

**Independent Test**: Run `/rkit:profile rocks` and verify rocks are listed with completion status and milestone counts.

**Acceptance Scenarios**:

1. **Given** a configured user, **When** they run `/rkit:profile rocks`, **Then** a list of rocks with milestone progress is displayed.
2. **Given** a year argument, **When** the user runs `/rkit:profile rocks {year}`, **Then** rocks for that year are shown.
3. **Given** `{user_id}` is provided, **When** the user runs `/rkit:profile rocks {user_id}`, **Then** that user's rocks are shown (team-sharing required).

---

### User Story 4 — View Feedback / High5s (Priority: P3)

A user wants to see feedback they gave or received. They run `/rkit:profile feedback given` or `/rkit:profile feedback received`.

**Why this priority**: Useful for reviews and culture tracking but not a daily use case.

**Independent Test**: Run `/rkit:profile feedback received` and verify a list of received High5s is displayed with sender and message.

**Acceptance Scenarios**:

1. **Given** a configured user, **When** they run `/rkit:profile feedback received`, **Then** a list of received feedback items is displayed with sender and message.
2. **Given** a configured user, **When** they run `/rkit:profile feedback given`, **Then** a list of given feedback items is displayed with recipient and message.
3. **Given** no direction is specified, **When** the user runs `/rkit:profile feedback`, **Then** the skill prompts to choose "given" or "received".
4. **Given** `{user_id}` is specified, **When** the user requests feedback, **Then** that user's feedback is shown (team-sharing required).

---

### User Story 5 — View and Update Integrations (Priority: P3)

A user wants to see or change their third-party app integrations (task management, sales/revops, team communication). They run `/rkit:profile integrations` to view current selections and `/rkit:profile integrations set {category} {value}` to update.

**Why this priority**: Infrequent but useful for users who want to configure integrations without leaving the CLI.

**Independent Test**: Run `/rkit:profile integrations` and verify current integration selections are displayed across all three categories.

**Acceptance Scenarios**:

1. **Given** a configured user, **When** they run `/rkit:profile integrations`, **Then** the three integration categories (task_management, sales_revops, team_communication) and their current values are displayed.
2. **Given** a configured user, **When** they run `/rkit:profile integrations set task_management asana`, **Then** confirmation is requested and, upon approval, the integration is updated.
3. **Given** the user sets a category to `none` or `null`, **When** they confirm, **Then** the integration is disconnected.
4. **Given** an invalid category name, **When** the user tries to set it, **Then** an error lists valid categories.

---

### Edge Cases

- What happens when `{user_id}` doesn't exist? → 404 response shown.
- What happens when the user doesn't share a team with `{user_id}`? → 403 with clear explanation of the team-sharing requirement.
- What happens when feedback direction is omitted? → Prompt user for "given" or "received".
- What happens when an invalid period is passed to progress? → API returns error; show it to the user.
- What happens when integrations set is called without a category or value? → Show usage hint and stop.
- What happens when rocks or measurables returns an empty list? → Show "{N} rocks found" with zero and stop gracefully.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: rkit:profile MUST accept `measurables` subcommand and display the current user's scorecard metrics with periodic data.
- **FR-002**: rkit:profile MUST accept `measurables {user_id}` and display that user's scorecard (enforcing team-sharing permission with clear 403 messaging).
- **FR-003**: rkit:profile MUST accept `rocks` subcommand and display the current user's quarterly rocks with milestone progress.
- **FR-004**: rkit:profile MUST accept `rocks {user_id}` and `rocks {year}` variants.
- **FR-005**: rkit:profile MUST accept `feedback given` and `feedback received` subcommands and display paginated results.
- **FR-006**: rkit:profile MUST prompt for direction if `feedback` is called without "given" or "received".
- **FR-007**: rkit:profile MUST accept `feedback {user_id} given|received` to view another user's feedback (team-sharing enforced).
- **FR-008**: rkit:profile MUST accept `progress` subcommand and display strategy metrics and practice scorecard.
- **FR-009**: rkit:profile MUST accept optional `progress {period}` argument (week, month, quarter).
- **FR-010**: rkit:profile MUST accept `integrations` subcommand and display all three integration category selections.
- **FR-011**: rkit:profile MUST accept `integrations set {category} {value}` and update the integration after confirmation.
- **FR-012**: The `integrations set` command MUST require user confirmation before executing the write.
- **FR-013**: All new subcommands MUST follow existing error-handling patterns: NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403, 404.
- **FR-014**: The Argument Parsing table in SKILL.md MUST be updated to include all 5 new subcommands and their variants.

### Key Entities

- **Measurable**: A scorecard metric with a name, goal, actual value, and periodic data entries.
- **Rock**: A quarterly goal with a title, status (on-track/off-track/done), and associated milestones.
- **Feedback / High5**: A recognition item with direction (given/received), sender/recipient, message, and timestamp.
- **PersonalProgress**: Aggregate of strategy metrics, practice scorecard (daily completion array), and streak totals.
- **UserIntegrations**: Three integration category slots (task_management, sales_revops, team_communication) with string values or null.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 5 new subcommands (`measurables`, `rocks`, `feedback`, `progress`, `integrations`) are reachable from `/rkit:profile` with no extra setup.
- **SC-002**: Users can view their own measurables, rocks, feedback, and progress in a single command with no follow-up interaction needed.
- **SC-003**: All new subcommands handle the same error conditions as existing flows (no_config, no_token, curl_failed, 401, 403, 404) with matching messaging style.
- **SC-004**: The `integrations set` command never mutates data without explicit user confirmation.

## Assumptions

- `api-reference.md` already documents all 14 endpoints from the handoff (verified in codebase).
- rkit:profile already implements stats, prefs, password, accounts, and account member management — this feature adds only the 5 missing flows.
- `check-login` is excluded from this feature's scope — it is a low-level API utility not needed as a user-facing rkit:profile subcommand.
- Pagination for rocks and feedback follows the existing `per_page=100` loop pattern used in account members.
- Framework terminology mapping (EOS rocks vs. other frameworks) is out of scope for this iteration.
