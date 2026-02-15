# Feature Specification: rkit:setup

**Feature Branch**: `001-setup`
**Created**: 2026-02-14
**Status**: Draft
**Input**: First-run configuration skill for the rkit skill suite

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time Setup (Priority: P1)

A user has never used any rkit skill before. They invoke `/rkit:setup`
and walk through guided configuration so that all other rkit skills
can function.

**Why this priority**: Every other rkit skill depends on configuration
existing. Without setup, nothing works.

**Independent Test**: Invoke `/rkit:setup` with no prior config file.
User should end with a valid config and see their account details.

**Acceptance Scenarios**:

1. **Given** no config file exists, **When** user runs `/rkit:setup`,
   **Then** user is guided through providing a token, selecting a
   default team, and a config file is created.
2. **Given** an invalid token is provided, **When** token verification
   fails, **Then** user sees a clear error and is asked to provide a
   correct token.
3. **Given** user has multiple teams, **When** teams are listed,
   **Then** each team shows its ID, name, and management framework.
4. **Given** token is valid and team is selected, **When** setup
   completes, **Then** user sees their name, email, and chosen team
   as confirmation.

---

### User Story 2 - Reconfigure Existing Setup (Priority: P2)

A user already has a working config but wants to change their token,
default team, or API base URL.

**Why this priority**: Users rotate tokens and switch teams. They
MUST NOT have to delete their config and start over.

**Independent Test**: Invoke `/rkit:setup` with an existing config.
User should see current settings and be able to update selectively.

**Acceptance Scenarios**:

1. **Given** a config file exists, **When** user runs `/rkit:setup`,
   **Then** current settings are displayed with the token masked
   (e.g., `rm_...xxxx`).
2. **Given** user chooses to update their token, **When** a new token
   is provided, **Then** the token is verified before saving.
3. **Given** user chooses to update their default team, **When** teams
   are listed, **Then** current default team is highlighted and user
   can pick a different one.

---

### User Story 3 - Environment Variable Fallback (Priority: P3)

A user has a `RESULTKIT_TOKEN` environment variable set. Setup detects
it automatically and offers to use it instead of manual entry.

**Why this priority**: Power users and CI-like environments benefit
from env var support, but manual entry covers the common case.

**Independent Test**: Set `RESULTKIT_TOKEN` env var, run `/rkit:setup`
with no existing config. User should be offered the env var token.

**Acceptance Scenarios**:

1. **Given** `RESULTKIT_TOKEN` is set and no config exists, **When**
   user runs `/rkit:setup`, **Then** skill offers to use the env var
   token instead of prompting for manual input.
2. **Given** `RESULTKIT_TOKEN` is set and config exists, **When** user
   runs `/rkit:setup`, **Then** env var is NOT silently used — user
   still sees current config and chooses what to update.

---

### Edge Cases

- User has no teams → display a message explaining they need at least
  one team, skip team selection, set default team to empty.
- Config directory cannot be created → report filesystem error with
  the path that failed.
- Token works but team listing fails → save the token, warn about the
  team fetch failure, allow retry.
- Config file exists but is corrupted/malformed → treat as missing
  config and offer to recreate it (with confirmation).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Config file MUST be stored at
  `~/.config/resultkit/config.json`.
- **FR-002**: Config MUST contain three fields: API token, default
  team ID, and API base URL.
- **FR-003**: Token MUST be verified against the API before saving.
- **FR-004**: API base URL MUST default to
  `https://api.resultmaps.com/api/v2` if not specified by the user.
- **FR-005**: Existing config MUST NOT be overwritten without user
  confirmation.
- **FR-006**: Token MUST be displayed in masked form when showing
  existing configuration (e.g., first 3 + last 4 characters).
- **FR-007**: Setup MUST create the config directory if it does not
  exist.

### Shared Infrastructure

This feature also covers the shared API caller used by all rkit skills:

- **FR-008**: A shared script MUST exist that all skills use to make
  authenticated API calls.
- **FR-009**: The shared script MUST read credentials from the config
  file.
- **FR-010**: The shared script MUST return structured output with
  HTTP status and response body.
- **FR-011**: If config is missing, the shared script MUST return a
  clear "no config" indicator rather than failing silently.

### Key Entities

- **Config**: Stores authentication token, default team preference,
  and API base URL. One per user, persisted to disk.
- **User Account**: The authenticated identity returned by token
  verification. Has name, email, and team memberships.
- **Team**: An organizational unit the user belongs to. Has ID, name,
  and management framework type.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can complete first-time setup in under
  2 minutes with a valid token.
- **SC-002**: After setup completes, any other rkit skill can execute
  without additional configuration.
- **SC-003**: An invalid token is rejected with a clear error message
  within 5 seconds.
- **SC-004**: Reconfiguration preserves unchanged settings — only the
  field the user chose to update is modified.
- **SC-005**: The shared API caller is reusable by all rkit skills
  without skill-specific configuration.

## Assumptions

- Users obtain their API token from the ResultMaps web application
  independently (setup does not handle account creation).
- The config file is stored in plaintext, consistent with the
  project's existing token storage pattern.
- Only one config profile per user is needed (no multi-profile
  support).
