# Feature Specification: Update Result-Feed Skill for Tier 1 Backend API Changes

**Feature Branch**: `042-result-feed-tier1-gh109`  
**Created**: 2026-04-28  
**Status**: Draft  
**GitHub Issue**: #109 — [API Change] Daily Update (Result Feed) Tier 1 Backend Gaps  
**Issue URL**: https://github.com/w3mg/resultkit-skills/issues/109  
**Input**: User description: "Update result-feed skill for Tier 1 backend API changes"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fix Breaking Section Shape in Result Feed Display (Priority: P1)

A user runs `/rkit:result-feed` or `/rkit:today` to view their daily check-in. The API now returns sections as structured objects (`{ items, notes, attachments }`) instead of flat arrays. Any skill code still reading sections as flat arrays will break. All section parsing must use `.items` to access the item array, and display `notes` and `attachments` when present.

**Why this priority**: This is a breaking change — existing skill functionality will fail without this fix.

**Independent Test**: Run `/rkit:result-feed` and verify items display correctly, section notes appear below items when non-null, and attachments render as file links.

**Acceptance Scenarios**:

1. **Given** a submitted daily update with notes on the "done" section, **When** the user views their check-in, **Then** items display correctly AND notes appear below the item list.
2. **Given** a section with attachments, **When** the user views that section, **Then** attachments display as `filename (content_type, size)` entries.
3. **Given** a section with null notes and empty attachments, **When** the user views it, **Then** only items are shown (no "Notes: none" clutter).

---

### User Story 2 - Add Review Section Support (Priority: P1)

The API now returns a fourth section, `review`, alongside `done`, `next`, and `blocked`. Items in review are awaiting manager sign-off. Users need to see this section when viewing check-ins and be able to add/move items to it.

**Why this priority**: Without review section support, users cannot see or manage items awaiting review — a core workflow gap.

**Independent Test**: Run `/rkit:result-feed` on a check-in with items in the review section and verify they display correctly.

**Acceptance Scenarios**:

1. **Given** a daily update with items in the `review` section, **When** the user views the check-in, **Then** a "Review" section displays between "Done" and "Next" with those items.
2. **Given** the user wants to move an item to review, **When** they use the PUT endpoint with section `review`, **Then** the item appears in the review section.

---

### User Story 3 - Update Section Notes and Attachments (Priority: P2)

A user wants to add notes or attach files to a specific section of their check-in. The PUT endpoint now accepts `notes` and `attachment_ids` in the request body.

**Why this priority**: Enhances the existing section update flow with new metadata capabilities.

**Independent Test**: Use the skill to add notes to the "done" section and verify they persist.

**Acceptance Scenarios**:

1. **Given** a user editing the "done" section, **When** they provide notes text, **Then** the PUT request includes `notes` in the body and the API confirms the update.
2. **Given** a user attaching files, **When** they provide attachment IDs, **Then** the PUT request includes `attachment_ids` and attachments appear on next GET.

---

### User Story 4 - View Team Member's Daily Update (Priority: P2)

A user wants to view a specific teammate's daily update on the team feed. The new `GET /teams/:id/result-feed/:date/:user_id` endpoint returns the full breakdown with all four sections, notes, and attachments.

**Why this priority**: Enables team leads to review individual check-ins in detail.

**Independent Test**: Request a specific teammate's report and verify all sections, notes, and attachments display.

**Acceptance Scenarios**:

1. **Given** a team member has submitted their check-in, **When** the user requests their report, **Then** all four sections display with items, notes, and attachments.
2. **Given** the requesting user is not a member of the team, **When** they request the report, **Then** a clear "not a team member" error displays.
3. **Given** no report exists for the requested date, **When** the user requests it, **Then** a "no report found" message displays.

---

### User Story 5 - React to and Comment on Check-ins (Priority: P3)

A user wants to give a teammate a "high-five" reaction or post a comment on their check-in to acknowledge good work or ask a follow-up question.

**Why this priority**: Social features that increase engagement but don't block core workflows.

**Independent Test**: React to a teammate's report and verify the reaction count updates; post a comment and verify it appears in the comment list.

**Acceptance Scenarios**:

1. **Given** a teammate's submitted check-in, **When** the user high-fives it, **Then** the response shows `reacted: true` and the updated count.
2. **Given** the user has already reacted, **When** they high-five again, **Then** the reaction is removed (`reacted: false`) and count decrements.
3. **Given** a teammate's check-in, **When** the user posts a comment with text, **Then** the comment is created and returns the comment object.
4. **Given** the user tries to post an empty comment, **When** they submit, **Then** a validation error is shown.

---

### User Story 6 - Push Daily Update to Slack or Discord (Priority: P3)

After submitting a check-in, a user wants to share it to their team's Slack or Discord channel. The skill checks webhook availability and sends the report.

**Why this priority**: Sharing is optional and depends on team webhook configuration.

**Independent Test**: Push a submitted check-in to Slack and verify the success response.

**Acceptance Scenarios**:

1. **Given** a team with a Slack webhook and a submitted check-in, **When** the user pushes to Slack, **Then** the response shows `pushed: true`.
2. **Given** a team without a Slack webhook, **When** the user tries to push, **Then** a clear "no Slack webhook configured" message displays.
3. **Given** a check-in that hasn't been submitted, **When** the user tries to push, **Then** a "report not submitted" error displays.

---

### User Story 7 - Document All New and Changed Endpoints (Priority: P1)

The master `api-reference.md` must be updated with all 8 new endpoints and 2 changed endpoints from this API handoff, and synced to all skills via `/sync-plugin`.

**Why this priority**: Documentation is the source of truth for all skill development. Without accurate docs, future skill changes will be built on wrong assumptions.

**Independent Test**: Read `api-reference.md` and verify all new endpoints are documented with correct request/response shapes.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer looks up any of the 8 new endpoints, **Then** the endpoint is documented with verb, path, params, and response shape.
2. **Given** the changed GET and PUT result-feed endpoints, **When** a developer reads the docs, **Then** the new structured section shape and `review` section are documented.
3. **Given** `/sync-plugin` has been run, **When** checking any skill's `references/api-reference.md`, **Then** it matches the master copy.

---

### Edge Cases

- Section with items but null notes and empty attachments — display items only, no noise.
- Team with neither Slack nor Discord webhooks — both push actions should report "not configured" clearly.
- Reaction on own report vs. teammate's report — `user_id` param controls whose report.
- File upload exceeding 4.5 MB — clear error message about size limit.
- Comment with only whitespace — should be rejected (422 from API).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST parse result-feed GET responses using the new structured section shape (`section.items`, `section.notes`, `section.attachments`) instead of flat arrays.
- **FR-002**: Skill MUST display section notes (when non-null) below the item list in each section.
- **FR-003**: Skill MUST display section attachments as file entries showing filename, content type, and size.
- **FR-004**: Skill MUST support the `review` section in all flows that display or modify sections (view, update, team feed).
- **FR-005**: Skill MUST support PUT requests with optional `notes` and `attachment_ids` in the body for section updates.
- **FR-006**: Skill MUST support `POST /result-feed/:date/push-to-slack` and `POST /result-feed/:date/push-to-discord` with `group_context_id` and optional `exclude_item_ids`.
- **FR-007**: Skill MUST support `POST /result-feed/:date/reactions` (toggle) and `GET /result-feed/:date/reactions` (read) with `user_id` parameter.
- **FR-008**: Skill MUST support `POST /result-feed/:date/comments` (create, with body validation) and `GET /result-feed/:date/comments` (list) with `user_id` parameter.
- **FR-009**: Skill MUST support `GET /teams/:id/result-feed/:date/:user_id` for viewing a specific team member's full daily update.
- **FR-010**: Skill MUST surface `has_slack_webhook` and `has_discord_webhook` from team responses to conditionally enable push actions.
- **FR-011**: Master `api-reference.md` MUST be updated with all 8 new endpoints and 2 changed endpoints, then synced to all skills.
- **FR-012**: Skill MUST support `POST /result-feed/:date/attachments` for file upload (multipart/form-data, max 4.5 MB).

### Key Entities

- **ResultFeedSection**: Structured object containing `items` (array), `notes` (string|null), and `attachments` (array of `{ id, filename, content_type, size }`).
- **Reaction**: Toggle state with `reacted` (boolean) and `count` (integer) for high-five interactions.
- **Comment**: User-generated text on a report with `id`, `comment` (body text), `user_id`, and `created_at`.
- **TeamWebhookFlags**: Boolean fields `has_slack_webhook` and `has_discord_webhook` on team objects.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their daily check-in with all four sections (done, review, next, blocked) displaying items correctly — zero regression from the section shape change.
- **SC-002**: Section notes and attachments display inline when present, with no visual noise when absent.
- **SC-003**: Users can view any teammate's full daily report by specifying user and date.
- **SC-004**: Users can react to and comment on teammate check-ins with immediate feedback on action success.
- **SC-005**: Users can push submitted check-ins to Slack or Discord with clear success/failure messaging.
- **SC-006**: All 8 new and 2 changed endpoints are documented in `api-reference.md` with correct request/response shapes and synced to all skills.

## Assumptions

- The `rkit:result-feed` skill (SKILL.md) already has partial implementations for many of these flows from spec 040/issue #110. This spec covers ensuring completeness and correctness against the full API handoff.
- Attachment upload via multipart/form-data may be limited by the Bash/curl execution model in skills — document the capability but accept CLI limitations for binary file uploads.
- The `review` section uses the same display pattern as done/next/blocked.
- `POST /result-feed/:date/submit` side effects (ObjectMeta upsert, daily recurrence rollover) are server-side and require no skill changes.
