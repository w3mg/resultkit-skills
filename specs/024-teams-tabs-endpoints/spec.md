# Feature Specification: Teams Tabs API Endpoints

**Feature Branch**: `024-teams-tabs-endpoints`
**Created**: 2026-03-03
**Status**: Complete
**Input**: GitHub Issue #15: [API Change] Change Handoff: Teams Tabs API Endpoints (029)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Document New Team Endpoints (Priority: P1)

The api-reference.md is updated to document all new team endpoints: activity logs, labels, integrations, member role change, and logo upload. This ensures other skills and developers can discover and use these endpoints.

**Why this priority**: Documentation is the foundation. All other stories and future skills depend on accurate API reference documentation.

**Independent Test**: Read api-reference.md and verify all new endpoints appear in the Teams section with correct params, response shapes, field descriptions, and user phrases in the glossary.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer reads the Teams section, **Then** they find activity log, label, integration, member role change, and logo upload endpoints documented with params, response shapes, and error codes.
2. **Given** the api-reference.md glossary, **When** a developer searches for team-related phrases, **Then** they find entries for activity logs, labels, integrations, role changes, and logo upload.

---

### User Story 2 - Change Team Member Roles (Priority: P2)

A team admin wants to promote a member to admin or demote an admin to member directly from the CLI. They specify the team, user, and target role, confirm the change, and see the updated role.

**Why this priority**: Role management is the most commonly needed admin action from the CLI. It extends the existing member management in the teams skill.

**Independent Test**: Run the role change command with a team ID, user ID, and target role. Verify confirmation prompt, and the result displays the updated member with their new role.

**Acceptance Scenarios**:

1. **Given** a team admin, **When** they change a member's role to admin, **Then** they are asked to confirm, and on success they see the user's name, ID, and new role.
2. **Given** a non-admin user, **When** they attempt to change a role, **Then** they see "Access denied (403). Only team admins can change roles."
3. **Given** no arguments, **When** they invoke the role command, **Then** they see a usage message explaining the required arguments.

---

### User Story 3 - View Team Activity Logs (Priority: P3)

A user wants to see recent membership changes for a team — who was added, removed, or had their role changed. They specify a team (or use the default) and see a chronological list of activity entries.

**Why this priority**: Activity logs provide transparency into team changes. Useful for auditing but less frequently needed than role management.

**Independent Test**: Run the activity logs command for a team. Verify a table of activity entries appears showing action, target user, actor, and timestamp.

**Acceptance Scenarios**:

1. **Given** a team member, **When** they view activity logs for their team, **Then** they see a paginated list showing action type, target user, actor, and date.
2. **Given** a team with no activity, **When** they view activity logs, **Then** they see "No activity logs found for team {id}."
3. **Given** a user who is not a team member, **When** they view activity logs, **Then** they see an appropriate error (403 or 404).

---

### Edge Cases

- What happens when a non-admin tries to change a role? Show "Access denied (403). Only team admins can change roles."
- What happens when the target user is not a member of the team? Show the error from the API response (404 or 422).
- What happens when activity logs span multiple pages? Paginate and show page count.
- What happens when a user tries to change their own role? Show the API's response (may be allowed or forbidden depending on server rules).
- What happens when the team has no activity? Show "No activity logs found for team {id}."
- What happens when an invalid role is provided? Show "Invalid role. Use 'admin' or 'member'."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The api-reference.md MUST be updated with all new team endpoints: activity logs (GET), labels (GET/POST/PATCH/DELETE), integrations (GET/POST/PATCH/DELETE), member role change (PATCH, placed alongside existing member endpoints), and logo upload (POST).
- **FR-002**: The api-reference.md glossary MUST include user phrases for all new endpoints.
- **FR-004**: Users MUST be able to change a team member's role (admin or member) via the teams skill with confirmation before execution.
- **FR-005**: The role change result MUST display the user's name, ID, and new role.
- **FR-006**: Users MUST be able to view team activity logs showing membership changes with action, target user, actor, and timestamp.
- **FR-007**: The skill MUST handle standard error responses (401, 403, 404, 422) with clear messages for all new operations.

### Key Entities

- **Activity Log Entry**: A record of a membership change — includes action type, target user, acting user, details, and timestamp.
- **Label**: A team-scoped tag with a name and color. Admin-only for writes.
- **Integration**: A team-scoped webhook configuration with type, name, URL, and enabled status. Admin-only.
- **Role Change**: A modification to a team member's role (admin or member). Admin-only.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 11 new endpoints are documented in api-reference.md with correct params, response shapes, and user phrases.
- **SC-002**: Team admins can change member roles from the CLI in a single command with one confirmation.
- **SC-003**: Users can view team activity logs as a formatted, paginated table of membership changes.
- **SC-004**: All new skill operations handle errors gracefully with actionable messages.

## Assumptions

- All new endpoints are already live in the API.
- Activity logs, role change, and log viewing are added as new flows to the existing `rkit:teams` skill, since they are team-scoped operations.
- Labels and integrations are documented in api-reference.md but are NOT given skill flows in this iteration — they are better managed from the web UI and have weaker CLI use cases.
- Logo upload is documented in api-reference.md but is NOT given a skill flow — multipart file uploads are outside the typical CLI skill pattern.
- The `rkit:teams` skill changes from "read-only" to supporting limited write operations (role change requires confirmation per constitution).
- Existing `PUT /teams/{id}/members` and `DELETE /teams/{id}/members/{user_id}` endpoints now write audit log entries but have no response changes — no skill modifications needed for this.
