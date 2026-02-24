# Feature Specification: rkit:headlines

**Feature Branch**: `013-eos-headlines`
**Created**: 2026-02-24
**Status**: Draft
**Skill**: `/rkit:headlines`

## Overview

Manage EOS headlines (People & Customer Headlines) for a team directly from the CLI. Headlines are short status updates shared during Level 10 meetings. They are only available for teams using the EOS management framework.

The skill supports listing active headlines, creating new ones, editing headline text or expiration, and archiving (soft-deleting) headlines. It follows the same team-scoped pattern as `rkit:weekly`.

## Assumptions

- The team must be using the EOS framework (`framework = 'eos'`). The API returns 422 for non-EOS teams and the skill should surface this clearly.
- Headlines auto-expire. The API does **not** compute a default expiration — the client must send `expires_at`. The skill will default to 7 days from today if the user doesn't specify one, since the V2 API doesn't have access to the team's weekly meeting schedule.
- The user's `default_team_id` from config is used as the team context, same as `rkit:weekly`.
- Soft-delete (archive) sets `expires_at` to today. A recently-created headline may still appear in subsequent GET calls for up to 7 days after archiving due to the "created within 7 days" visibility rule. The skill should warn the user about this.

## User Scenarios & Testing

### US1 — View Headlines (Priority: P1)

User wants to see the current active headlines for their EOS team.

**Why this priority**: This is the most fundamental operation — users need to see what headlines exist before they can manage them. Delivers immediate read-only value.

**Independent Test**: Can be fully tested by running `/rkit:headlines` and verifying the table of active headlines is displayed with all expected fields.

**Invocation**:
- `/rkit:headlines` — list headlines for default team
- `/rkit:headlines --team {id}` — list headlines for a specific team

**Acceptance Scenarios**:

1. **Given** team 908 is an EOS team with 3 active headlines, **When** `/rkit:headlines`, **Then** a table shows all 3 headlines with ID, text, creator name, expires date, and created date
2. **Given** team 908 has no active headlines, **When** `/rkit:headlines`, **Then** "No active headlines for {team_name}."
3. **Given** team 908 is not an EOS team, **When** `/rkit:headlines`, **Then** "Headlines are only available for teams using the EOS framework."
4. **Given** no config exists, **When** `/rkit:headlines`, **Then** "Config not found. Run `/rkit:setup` first."

---

### US2 — Add Headline (Priority: P1)

User wants to create a new headline for their EOS team.

**Why this priority**: Creating headlines is core functionality — without it, the skill only reads. Paired with US1, this forms the MVP.

**Independent Test**: Can be tested by running `/rkit:headlines add "New client signed"` and verifying the headline appears in a subsequent list.

**Invocation**:
- `/rkit:headlines add "headline text"` — create headline with default 7-day expiration
- `/rkit:headlines add "headline text" --expires {YYYY-MM-DD}` — create with explicit expiration

**Acceptance Scenarios**:

1. **Given** team 908 is an EOS team, **When** `/rkit:headlines add "New client signed"`, **Then** user is asked to confirm, headline is created with `expires_at` defaulting to 7 days from today, and confirmation shows the new headline ID and text
2. **Given** `/rkit:headlines add "Lease renewed" --expires 2026-03-15`, **Then** headline is created with `expires_at = 2026-03-15`
3. **Given** user provides empty text, **Then** "Headline text cannot be empty."
4. **Given** team is not EOS, **Then** "Headlines are only available for teams using the EOS framework."

---

### US3 — Archive Headline (Priority: P2)

User wants to remove/archive a headline from the current list.

**Why this priority**: Removing outdated headlines is the next most common action after viewing and adding. This completes the basic lifecycle.

**Independent Test**: Can be tested by running `/rkit:headlines remove {id}` and verifying the headline disappears from the list.

**Invocation**:
- `/rkit:headlines remove {headline_id}` — archive the headline

**Acceptance Scenarios**:

1. **Given** headline 201 exists and the user is the creator, **When** `/rkit:headlines remove 201`, **Then** user is asked to confirm, headline is archived (expires_at set to today), confirmation shown
2. **Given** headline 201 was created today and just archived, **When** user views headlines, **Then** the headline may still appear (created within 7 days). The skill warns: "Note: recently-created headlines may still appear for up to 7 days after archiving."
3. **Given** headline 201 does not exist, **Then** "Headline 201 not found."
4. **Given** user is neither the creator nor a team admin, **Then** "You do not have permission to archive this headline."

---

### US4 — Update Headline (Priority: P3)

User wants to edit the text or expiration date of an existing headline.

**Why this priority**: Editing is less frequent than viewing, creating, or archiving. Nice to have but not essential for MVP.

**Independent Test**: Can be tested by running `/rkit:headlines update {id} --text "new text"` and verifying the change.

**Invocation**:
- `/rkit:headlines update {headline_id} --text "new text"` — update text only
- `/rkit:headlines update {headline_id} --expires {YYYY-MM-DD}` — update expiration only
- `/rkit:headlines update {headline_id} --text "new text" --expires {YYYY-MM-DD}` — update both

**Acceptance Scenarios**:

1. **Given** headline 201 exists and user is the creator, **When** `/rkit:headlines update 201 --text "Updated text"`, **Then** user is asked to confirm, headline text is updated, confirmation shown with updated headline
2. **Given** `/rkit:headlines update 201 --expires 2026-03-20`, **Then** only expiration is updated, text unchanged
3. **Given** no `--text` or `--expires` provided, **Then** "Provide at least one of --text or --expires to update."
4. **Given** user is neither creator nor team admin, **Then** "You do not have permission to update this headline."
5. **Given** headline does not exist, **Then** "Headline {id} not found."

---

### Edge Cases

- Team is not EOS → "Headlines are only available for teams using the EOS framework."
- No active headlines → "No active headlines for {team_name}."
- Headline not found (404) → "Headline {id} not found."
- No config → "Config not found. Run `/rkit:setup` first."
- api.sh not found → "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- Permission denied (403) on update/archive → show the API's error message ("You do not have permission to...")
- Empty or whitespace-only headline text → "Headline text cannot be empty."
- Invalid expires_at date format → "Expiration date must be in YYYY-MM-DD format."
- More than 100 headlines (pagination) → show first page with "(showing {per_page} of {total})"
- Recently-archived headline still visible → warn user about 7-day visibility window
- Network error → "Network error. Check your connection."
- Unauthorized (401) → "Unauthorized (401). Run `/rkit:setup` to update your token."

## Requirements

### Functional Requirements

- **FR-001**: Skill MUST list active headlines for an EOS team, showing ID, text, creator name, expiration date, and creation date
- **FR-002**: Skill MUST create headlines via `POST /teams/{id}/headlines` with `text` and optional `expires_at`
- **FR-003**: If no `expires_at` is provided on create, skill MUST default to 7 days from today (YYYY-MM-DD format)
- **FR-004**: Skill MUST archive headlines via `DELETE /teams/{id}/headlines/{headline_id}` (soft delete)
- **FR-005**: Skill MUST update headlines via `PATCH /teams/{id}/headlines/{headline_id}` with at least one of `text` or `expires_at`
- **FR-006**: Skill MUST use config for auth (token from `~/.config/resultkit/config.json`)
- **FR-007**: Skill MUST resolve team ID using `default_team_id` from config or `--team` flag
- **FR-008**: Skill MUST confirm with user before any write operation (POST, PATCH, DELETE)
- **FR-009**: Skill MUST display 403 permission errors clearly when user lacks update/archive rights
- **FR-010**: Skill MUST handle the EOS framework gate — surface 422 errors from non-EOS teams with a clear message
- **FR-011**: Skill MUST show headline IDs in all output so users can reference them for update/remove
- **FR-012**: Skill MUST warn user about the 7-day visibility window when archiving a recently-created headline

### Key Entities

- **Headline**: A short status update belonging to an EOS team. Key attributes: ID, text, creator (user), expiration date, creation timestamp. Active if created within 7 days OR expiration is in the future.
- **Team**: The EOS team context. Headlines are scoped to a team and require `framework = 'eos'`.
- **Creator**: The user who created the headline. Only creators and team admins can update/archive.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can view all active team headlines in under 5 seconds from invocation
- **SC-002**: Users can create a new headline in a single command invocation (plus confirmation)
- **SC-003**: Users can archive a headline in a single command invocation (plus confirmation)
- **SC-004**: All error states (non-EOS team, missing config, permission denied, not found) produce clear, actionable messages
- **SC-005**: The skill follows the same interaction patterns as existing rkit skills (rkit:weekly, rkit:board) — users familiar with those skills can use rkit:headlines without learning new conventions
