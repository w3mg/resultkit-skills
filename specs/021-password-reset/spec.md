# Feature Specification: Password Reset Skill

**Feature Branch**: `021-password-reset`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #10: [API Change] Password Reset API — V2 Endpoint Handoff

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin Triggers Password Reset (Priority: P1)

An admin user runs `/rkit:password-reset {user_id}` to send a password reset email to a user in their account. The skill confirms the action, calls the API, and reports success.

**Why this priority**: This is the only practical CLI use case. The "complete reset" endpoint (PUT /passwords) is unauthenticated and token-based — users complete it via the email link in a browser, not from the CLI.

**Independent Test**: Run `/rkit:password-reset 42` to trigger a password reset email for user 42. Verify the confirmation prompt and success message.

**Acceptance Scenarios**:

1. **Given** an admin user, **When** they run `/rkit:password-reset {user_id}`, **Then** they are asked to confirm, and a password reset email is sent to the user.
2. **Given** a non-admin user, **When** they run `/rkit:password-reset {user_id}`, **Then** they see "Admin access required."
3. **Given** no user ID provided, **When** they run `/rkit:password-reset`, **Then** they see a usage message prompting for a user ID.
4. **Given** a user ID that doesn't exist or has no email, **When** they trigger a reset, **Then** the API's 422 validation error is shown.

---

### User Story 2 - Update API Reference (Priority: P2)

The api-reference.md is updated to document both new password endpoints (POST /passwords/reset and PUT /passwords) so other skills and developers can discover them.

**Why this priority**: Documentation completeness. Both endpoints should be in the API reference even though only one is used by the skill.

**Independent Test**: Read api-reference.md and verify both password endpoints are documented with correct params, methods, and user phrases.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer reads it, **Then** they find `POST /passwords/reset` documented with body params, auth requirements, and user phrases.
2. **Given** the api-reference.md, **When** a developer reads it, **Then** they find `PUT /passwords` documented with body params, auth note (unauthenticated), and user phrases.

---

### Edge Cases

- What happens when the user provides no user ID? Show usage: `/rkit:password-reset {user_id}`
- What happens when the caller is not an admin? Show "Admin access required." (403)
- What happens when the user has no email address? Show the API's 422 validation error.
- What happens when the user ID doesn't belong to the admin's account? Show the API's 422 validation error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST allow admins to trigger a password reset email for a given user ID via a single command.
- **FR-002**: Skill MUST confirm the action before calling the API (write operation).
- **FR-003**: Skill MUST handle 403 (not admin) with a clear "Admin access required." message.
- **FR-004**: Skill MUST handle all standard error responses (401, 403, 422) per the shared error handling pattern.
- **FR-005**: The api-reference.md MUST be updated with both password endpoints (POST /passwords/reset and PUT /passwords).

### Key Entities

- **Password Reset Request**: An admin-initiated action that sends a reset email to a user. Requires `user_id`. No persistent entity — fire-and-forget.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An admin can trigger a password reset in a single command invocation with one confirmation.
- **SC-002**: Both password endpoints are documented in api-reference.md with correct params and user phrases.
- **SC-003**: Non-admin users see a clear, actionable error message.

## Assumptions

- The password reset API endpoints are already live.
- The skill follows the same patterns as other rkit skills: SKILL.md entry point, api.sh for API calls, scoped Bash patterns in frontmatter.
- The PUT /passwords endpoint (complete reset) is intentionally excluded from the skill — users complete resets via the email link in their browser.
- The skill is minimal: one command, one API call, one confirmation.
