# Feature Specification: Daily Update API v2 — Tier 1 Backend Gap Coverage

**Feature Branch**: `040-result-feed-tier1-gh110`
**Created**: 2026-04-27
**Status**: Draft
**GitHub Issue**: #110 — [API Change] 077 — Daily Update Tier 1 Backend Gaps
**Issue URL**: https://github.com/w3mg/resultkit-skills/issues/110
**Input**: User description: "Update rkit skills to match new result-feed API contracts: breaking section shape change, 8 new endpoints, 2 changed endpoints"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Daily Update with Notes & Attachments (Priority: P1)

A user runs `/rkit:today` to view their daily check-in. The skill must correctly parse the new section shape (`{ items, notes, attachments }`) instead of the old flat array. If notes or attachments exist on a section, they are displayed alongside the items.

**Why this priority**: This is the **breaking change** — existing skills will fail to display items until the section parsing is updated from `.done` (array) to `.done.items` (object property).

**Independent Test**: Run `/rkit:today` and verify all three sections (done/next/blocked) display their items correctly, plus any notes or attachments.

**Acceptance Scenarios**:

1. **Given** a user has a result-feed for today with items in done/next/blocked, **When** they run `/rkit:today`, **Then** all items display correctly under each section header.
2. **Given** a section has notes text, **When** the feed is displayed, **Then** the notes appear under the section's items.
3. **Given** a section has attachments, **When** the feed is displayed, **Then** each attachment's filename is shown.
4. **Given** a section has no notes or attachments, **When** the feed is displayed, **Then** only items are shown (no empty notes/attachments placeholders).

---

### User Story 2 - Update Section Notes & Attachments (Priority: P2)

A user wants to add or update free-text notes on a section of their daily update (e.g., add a note to "done" explaining what was shipped). The skill calls `PUT /api/v2/result-feed/:date/:section` with the notes and/or attachment IDs.

**Why this priority**: Notes and attachments are the primary new capability added to the daily update. Users need to be able to write them, not just read them.

**Independent Test**: User adds a note to the "done" section and verifies it appears on the next `/rkit:today` view.

**Acceptance Scenarios**:

1. **Given** a user has a result-feed for today, **When** they update the "done" section with notes text, **Then** the API returns success and the notes appear on the next read.
2. **Given** a section has existing notes, **When** the user sets notes to null, **Then** the notes are cleared.

---

### User Story 3 - View Team Member's Daily Update (Priority: P2)

A team lead views a specific team member's daily update using the team-feed detail endpoint. This shows the full report for one user on one date, including the `is_quiet` flag.

**Why this priority**: Team-feed detail is a new read-only view that complements the existing team-feed list. It enables drill-down from the team board.

**Independent Test**: User runs a command to view a teammate's check-in for a given date and sees the full done/next/blocked report.

**Acceptance Scenarios**:

1. **Given** a team member has a report for the requested date, **When** the team lead requests it, **Then** the full report is displayed with all sections.
2. **Given** the report was shared to a different team context, **When** displayed, **Then** a "quiet" indicator is shown.
3. **Given** no report exists for that user/date, **When** requested, **Then** a clear "no report found" message is shown.

---

### User Story 4 - React to a Check-in (High-Five) (Priority: P3)

A user gives a "high-five" reaction to a teammate's daily update. Toggling it again removes the reaction.

**Why this priority**: Social engagement feature — valuable but not core workflow.

**Independent Test**: User reacts to a report, sees updated count, reacts again to toggle it off.

**Acceptance Scenarios**:

1. **Given** a result-feed report exists, **When** the user reacts, **Then** the high-five count increments and `user_has_reacted` is true.
2. **Given** the user has already reacted, **When** they react again, **Then** the reaction is removed and count decrements.

---

### User Story 5 - Comment on a Check-in (Priority: P3)

A user reads and posts comments on a teammate's daily update.

**Why this priority**: Enables async conversation around check-ins — important for remote teams but not a daily-driver feature.

**Independent Test**: User lists comments on a report, posts a new comment, and sees it in the list.

**Acceptance Scenarios**:

1. **Given** a result-feed report has comments, **When** the user lists them, **Then** all comments are displayed with body, author, and timestamp.
2. **Given** a user writes a comment, **When** submitted, **Then** the comment is created and confirmed.
3. **Given** comment body is empty, **When** submitted, **Then** a validation error is returned.

---

### User Story 6 - Push Daily Update to Slack/Discord (Priority: P3)

A user shares their daily update to their team's Slack or Discord channel via webhook. The skill checks if the team has a webhook configured before attempting.

**Why this priority**: Sharing to chat is a convenience feature gated by team configuration.

**Independent Test**: User pushes their check-in to Slack and sees a success/failure message.

**Acceptance Scenarios**:

1. **Given** the team has a Slack webhook, **When** the user pushes, **Then** the update is sent and success is confirmed.
2. **Given** the team has no webhook configured, **When** the user pushes, **Then** a clear error explains no webhook is set up.
3. **Given** the webhook call fails, **When** the push returns 502, **Then** the user sees a "webhook delivery failed" message.

---

### User Story 7 - Set Group Context (Priority: P3)

A user sets their active group context (which team they're sharing to) via the skill. This is used by the share modal flow.

**Why this priority**: Supporting feature for the share flow.

**Independent Test**: User sets their group context and confirms it via a subsequent context read.

**Acceptance Scenarios**:

1. **Given** a valid group ID, **When** the user sets group context, **Then** success is returned.

---

### Edge Cases

- What happens when the result-feed for a date has no items in any section but has notes? → Display the notes with empty item lists.
- What happens when a user tries to push to Slack for a team they're not a member of? → 403 error, display "not a team member" message.
- What happens when attachment_ids reference IDs the user doesn't own? → API filters to owned IDs only; skill shows whatever the API returns.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `rkit:result-feed` skill (and any other skill that reads result-feed section data) MUST parse the new object shape (`section.items`, `section.notes`, `section.attachments`) instead of treating sections as flat arrays. Note: `rkit:today` is not affected — it uses `/day-plans/` endpoints, not `/result-feed/`.
- **FR-002**: The `rkit:result-feed` skill MUST display section notes when present (non-null).
- **FR-003**: The `rkit:result-feed` skill MUST display attachment filenames when attachments are present.
- **FR-004**: The `rkit:result-feed` skill MUST parse the new section shape for team-feed entries.
- **FR-005**: Skills MUST support `PUT /api/v2/result-feed/:date/:section` for updating section notes and attachment IDs.
- **FR-006**: Skills MUST support `POST /api/v2/result-feed/:date/push-to-slack` and `push-to-discord` for webhook sharing.
- **FR-007**: Skills MUST support `POST /api/v2/result-feed/:date/react` for toggling high-five reactions.
- **FR-008**: Skills MUST support `GET` and `POST /api/v2/result-feed/:date/comments` for reading and adding comments.
- **FR-009**: Skills MUST support `GET /api/v2/teams/:id/result-feed/:date/:user_id` for viewing a specific user's report.
- **FR-010**: Skills MUST support `POST /api/v2/users/me/group-context` for setting active group context.
- **FR-011**: The `api-reference.md` MUST be updated to document all new and changed endpoints with accurate request/response shapes.
- **FR-012**: Team display output MUST surface `has_slack_webhook` and `has_discord_webhook` booleans when present in team data.

### Key Entities

- **ResultFeed**: A user's daily check-in containing three sections (done/next/blocked), each now an object with `items` (array), `notes` (string|null), and `attachments` (array of `{ id, filename, url }`).
- **Comment**: A text note left on a result-feed report — has `id`, `body`, `user_id`, `created_at`.
- **Reaction**: A high-five toggle on a report — tracked as `high_five_count` and `user_has_reacted`.
- **GroupContext**: The user's active team for sharing — set via `group_id`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their daily update with all items correctly displayed after the section shape change — zero regression from the breaking change.
- **SC-002**: Users can add and clear notes on any section of their daily update in a single command.
- **SC-003**: Users can view a specific teammate's full daily report by user and date.
- **SC-004**: Users can react to and comment on teammates' daily updates.
- **SC-005**: Users can push their daily update to Slack or Discord with clear success/failure feedback.
- **SC-006**: All 8 new endpoints and 2 changed endpoints are documented in api-reference.md with accurate contracts.

## Assumptions

- The `rkit:today` and `rkit:result-feed` skills are the only two skills that parse result-feed response data. Other skills reference result-feed endpoints but don't parse the section shape.
- Attachment upload is handled outside these skills (the API accepts existing attachment IDs). Skills only need to pass IDs and display metadata.
- The `POST /api/v2/users/me/group-context` endpoint mirrors `PATCH /api/v2/users/me/team-context` — no need to deprecate the old endpoint.
- Webhook configuration (Slack/Discord URLs) is managed outside these skills — skills only trigger the push.
