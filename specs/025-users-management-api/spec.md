# Feature Specification: Users Management API Endpoints

**Feature Branch**: `025-users-management-api`
**Created**: 2026-03-04
**Status**: Draft
**Input**: GitHub Issue #16: [API Change] API Change Handoff: Users Management API (030)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Document All New User Endpoints (Priority: P1)

The api-reference.md is updated to document all 14 new user management endpoints: profile stats, measurables, rocks, feedback, preferences (GET/PATCH), login availability check, accounts, account members (GET/DELETE), password change, personal progress, and integrations (GET/PATCH). This ensures all skills and developers can discover and use these endpoints.

**Why this priority**: Documentation is the foundation. All subsequent skill work depends on accurate, complete API reference documentation. Other rkit skills that eventually surface this data must be able to look up the correct endpoint shapes.

**Independent Test**: Read api-reference.md and verify all 14 new endpoints appear in a Users section with correct params, response field names, key behaviors (e.g. notification boolean inversion), and user-facing glossary phrases.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer reads the Users section, **Then** they find all 14 new endpoints documented with HTTP method, path, params, response shapes, and notable behaviors (permission rules, inverted booleans, `"me"` alias support).
2. **Given** the api-reference.md glossary, **When** a developer searches for user-related phrases (e.g. "my stats", "change password", "update preferences"), **Then** they find matching entries.
3. **Given** the profile endpoints (`stats`, `measurables`, `rocks`, `feedback`), **When** documented, **Then** the reference notes that `{id}` accepts both a numeric user ID and the literal string `"me"`, and that team-sharing permission is required for other users.

---

### User Story 2 - View My Profile Summary (Priority: P2)

A user wants to see a summary of their own activity: wins given/received, goals aspired/realized, and actions completed. They run a single command and see their stats at a glance.

**Why this priority**: Personal performance stats are high-value for daily planning workflows. This is a read-only, self-serve use case with no permission complexity for self-access.

**Independent Test**: Run the profile/stats command for `me`. Verify it returns wins given, wins received, goals aspired, goals realized, and actions done in a formatted summary.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they request their own stats, **Then** they see wins given, wins received, goals aspired, goals realized, and actions done.
2. **Given** a user with no activity, **When** they request stats, **Then** they see all values as 0 rather than an error.
3. **Given** a user requesting another user's stats, **When** they share a team with that user, **Then** they see that user's stats.
4. **Given** a user requesting another user's stats, **When** they do NOT share a team with that user, **Then** they see a "Access denied — you must share a team with this user" error.

---

### User Story 3 - View and Update My Preferences (Priority: P3)

A user wants to view their current preferences (timezone, notification settings, startup view, preferred team) and optionally update one or more fields without affecting the rest.

**Why this priority**: Preferences management is a common self-service operation. The partial-update design means the skill can expose targeted updates (e.g., "turn off morning digest") without requiring full-form workflows.

**Independent Test**: Run the preferences view command and verify profile fields, notification settings, and startup view are displayed. Run an update command to toggle one notification setting, and verify only that field changes.

**Acceptance Scenarios**:

1. **Given** a user, **When** they view their preferences, **Then** they see login, name, email, timezone, notification toggles, update frequency, startup view, preferred team, and Slack username.
2. **Given** a user, **When** they update a single preference (e.g., turn off end-of-day digest), **Then** only that field changes and all others are preserved.
3. **Given** a user, **When** they update their preferred team, **Then** the preferred team ID is updated and reflected in a subsequent view.

---

### User Story 4 - Change My Password (Priority: P4)

A user wants to change their account password from the CLI. They provide their current password and a new password (with confirmation), and get success or an error.

**Why this priority**: Account security management should be accessible from the CLI for power users. It's a relatively simple, well-defined flow.

**Independent Test**: Run the password change command with correct current password and matching new passwords. Verify success. Run again with wrong current password — verify error.

**Acceptance Scenarios**:

1. **Given** a user with an existing password, **When** they provide the correct current password and matching new passwords, **Then** they see a success confirmation.
2. **Given** a user, **When** they provide an incorrect current password, **Then** they see an error "Current password is incorrect."
3. **Given** a user, **When** new password and confirmation do not match, **Then** they see "Password confirmation does not match."
4. **Given** an OAuth user with no existing password, **When** they set a new password without providing current_password, **Then** they see a success confirmation.

---

### User Story 5 - View Account Members (Priority: P5)

An account owner wants to see a list of all members on their account. They run a command and see a table of users with their roles and ownership status.

**Why this priority**: Account-level member visibility is an admin/owner use case. Less common than team management but important for account governance.

**Independent Test**: Run the account members command. Verify a table of users appears with name, email, role/ownership, and whether they are the account owner.

**Acceptance Scenarios**:

1. **Given** an account owner, **When** they list account members, **Then** they see a table with each member's name, email, and ownership status.
2. **Given** an account owner, **When** they remove a non-owner member, **Then** they are asked to confirm and see success on confirmation.
3. **Given** an account owner, **When** they attempt to remove the account owner, **Then** they see "Cannot remove the account owner."
4. **Given** a non-owner, **When** they attempt to remove a member, **Then** they see "Access denied — only account owners can remove members."

---

### Edge Cases

- What happens when `{id}` is `"me"` vs a numeric ID? Profile endpoints accept both; skill defaults to `"me"` when no user is specified.
- What happens when the target user does not share a team with the requester? Profile endpoints return 403; show "Access denied — you must share a team with this user."
- What happens when partial preference update omits all fields? Show a usage error before calling the API.
- What happens when password confirmation does not match? Show error without making the API call.
- What happens when an OAuth user tries to change password without providing current_password? The API allows it; the skill should omit the field rather than requiring it.
- What happens when login check finds the username is taken? Show "That login is already taken."
- What happens when account member removal is attempted on the owner user? Show "Cannot remove the account owner."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The api-reference.md MUST be updated with all 14 new user management endpoints, including HTTP method, path, required/optional params, response field names, and key behavioral notes.
- **FR-002**: The api-reference.md glossary MUST include user-facing phrases for all new endpoints (e.g., "my stats", "my wins", "change password", "update notifications", "account members").
- **FR-003**: The api-reference.md MUST note the `"me"` alias for profile endpoints and the team-sharing permission requirement.
- **FR-004**: The api-reference.md MUST document the notification boolean inversion behavior (API returns the logical value, not the raw DB value).
- **FR-005**: Users MUST be able to view their own profile stats (wins, goals, actions) via the skill.
- **FR-006**: Users MUST be able to view another user's profile stats when they share a team with that user.
- **FR-007**: Users MUST be able to view their current preferences (profile fields, notifications, startup view, preferred team).
- **FR-008**: Users MUST be able to partially update their preferences — only specified fields change.
- **FR-009**: Users MUST be able to change their account password with current password verification.
- **FR-010**: OAuth users without an existing password MUST be able to set a password without providing current_password.
- **FR-011**: Users MUST be able to list members of their account.
- **FR-012**: Account owners MUST be able to remove non-owner account members with a confirmation step.
- **FR-013**: The skill MUST handle standard error responses (401, 403, 404, 422) with clear, actionable messages for all new operations.

### Key Entities

- **User Stats**: Aggregate counts for a user — wins given, wins received, goals aspired, goals realized, actions done. Read-only, team-permission-gated for other users.
- **User Preferences**: A merged profile including login, name, email, timezone, notification toggles, update frequency, startup view, preferred team ID, and Slack username. Partially updatable.
- **Account Member**: A user associated with an account, with an ownership flag. Account owners can remove non-owner members.
- **User Measurables**: A user's scorecard data with periodic measurable values (documented in api-reference.md; no skill flow in this iteration).
- **User Rocks**: A user's rocks/goals with milestone progress (documented in api-reference.md; no skill flow in this iteration — use rkit:board for rock management).
- **User Feedback**: Feedback given and received by a user (documented in api-reference.md; no skill flow in this iteration).
- **Integrations**: A user's integration/webhook selections. Documented in api-reference.md; no skill flow in this iteration.
- **Progress Dashboard**: Aggregated personal progress data. Documented in api-reference.md; no skill flow in this iteration.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 14 new endpoints are documented in api-reference.md with correct params, response field names, behavioral notes, and glossary phrases.
- **SC-002**: Users can retrieve their personal stats summary in a single command.
- **SC-003**: Users can view their full preferences profile and update individual fields without replacing the full record.
- **SC-004**: Users can change their account password with one command, receiving clear success or error feedback.
- **SC-005**: Account owners can list and remove account members with one confirmation step.
- **SC-006**: All new skill operations handle permission errors, not-found errors, and validation errors gracefully with actionable messages.

## Assumptions

- All 14 new endpoints are already live in the API.
- Profile endpoints (`stats`, `measurables`, `rocks`, `feedback`) accept `"me"` as the user ID, defaulting to `"me"` when no user is specified in the skill.
- User measurables, rocks, feedback, integrations, and progress dashboard endpoints are documented in api-reference.md but NOT given dedicated skill flows in this iteration — rock/goal management is handled by `rkit:board`, and the others have limited CLI use cases compared to their web UI counterparts.
- Login availability check (`/users/check-login`) is documented but not exposed as a standalone skill command — it is an internal/utility endpoint primarily useful for registration flows.
- Preferences and password change are added to a new or extended skill (likely `rkit:profile` or extended `rkit:setup`). The exact skill placement is a planning decision.
- Account member management (list + remove) is added as a new flow, not part of the existing `rkit:teams` skill since accounts are a different scope than teams.
- Framework terminology mapping (rocks vs goals vs milestones based on team framework type) is deferred — it requires reading the team's framework type and applying terminology rules that need separate spec work.
