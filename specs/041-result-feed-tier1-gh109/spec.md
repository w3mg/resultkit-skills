# Feature Specification: Result Feed API 077 Tier 1 Update

**Feature Branch**: `041-result-feed-tier1-gh109`
**Created**: 2026-04-28
**Status**: Draft
**GitHub Issue**: #109 — [API Change] Daily Update (Result Feed) Tier 1 Backend Gaps
**Issue URL**: https://github.com/w3mg/resultkit-skills/issues/109

## Summary

API 077 shipped changes and new endpoints for the result-feed feature. The `rkit:result-feed` skill and `api-reference.md` must be updated to reflect the current API. Several endpoints were renamed or changed response shapes; new endpoints for file upload and GET reactions were added; the `review` section was introduced; and the push-to-slack/discord body parameter changed from `team_id` to `group_context_id`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — React to a Teammate's Check-In (Priority: P1)

A user says "high-five pat's check-in from today" and the skill correctly toggles the reaction on the report belonging to user pat, using the current API endpoint and response shape.

**Why this priority**: The react endpoint was renamed (`/react` → `/reactions`) and the response shape changed. The skill currently uses the wrong endpoint and parses the wrong field names — this is a breaking functional regression.

**Independent Test**: Run `react_to_report` with a valid date and verify the API call uses `/result-feed/{date}/reactions` and the result displays `reacted: true/false` and `count: N`.

**Acceptance Scenarios**:

1. **Given** a user requests a high-five on today's check-in, **When** the skill executes, **Then** it calls `POST /result-feed/{date}/reactions` (not `/react`) and displays the reaction state and count from `body.data.reacted` and `body.data.count`.
2. **Given** the skill shows the reaction result, **When** the user reacts again, **Then** `reacted` toggles to `false` and `count` decrements.
3. **Given** a user wants to see the reaction state without toggling, **When** they ask "show reactions on {date}'s check-in", **Then** the skill calls `GET /result-feed/{date}/reactions?user_id=N` and displays `reacted` and `count`.

---

### User Story 2 — Use the Review Section (Priority: P2)

A user adds an item to the `review` section or asks to see what's in review. The skill recognizes `review` as a valid section name alongside `done`, `next`, and `blocked`.

**Why this priority**: API 077 added `review` as a valid section for PUT `/result-feed/{date}/{section}/{item_id}` and for section metadata updates. The skill currently rejects `review` as an invalid section.

**Independent Test**: Ask "add item 42 to review section" — the skill should successfully call the appropriate endpoint without an error about invalid section.

**Acceptance Scenarios**:

1. **Given** a user says "add item 42 to review", **When** the skill processes the request, **Then** it routes to the section item endpoint with `section=review`.
2. **Given** a user asks to update notes on the review section, **When** the skill processes the request, **Then** the `update_section_meta` flow accepts `review` as a valid section.
3. **Given** a check-in is displayed, **When** the `review` section has items, **Then** they are shown in the output.

---

### User Story 3 — Upload a File Attachment (Priority: P3)

A user wants to attach a file to their check-in section. The skill guides them through the upload flow and returns the document ID they can add to a section.

**Why this priority**: The file upload endpoint (`POST /result-feed/{date}/attachments`) is new in API 077 and not yet documented or surfaced in the skill.

**Independent Test**: Ask "attach a file to my check-in" — the skill should explain the upload flow and call `POST /result-feed/{date}/attachments` with multipart/form-data.

**Acceptance Scenarios**:

1. **Given** a user wants to add an attachment, **When** they trigger the upload flow, **Then** the skill calls `POST /result-feed/{date}/attachments` and returns the document ID.
2. **Given** the upload exceeds 4.5 MB, **When** the API returns 413, **Then** the skill displays "File too large — maximum 4.5 MB."
3. **Given** no file is provided, **When** the API returns 400, **Then** the skill displays a clear error.

---

### User Story 4 — Push Check-In to Slack or Discord (Priority: P2)

A user pushes their check-in to Slack. The API call uses `group_context_id` in the request body (not `team_id`).

**Why this priority**: The skill currently sends `team_id` in the push-to-slack body, but the API 077 requires `group_context_id`. The push will fail silently if the wrong param is sent.

**Independent Test**: Push a check-in to Slack — verify the request body contains `group_context_id`, not `team_id`.

**Acceptance Scenarios**:

1. **Given** a user says "push to Slack", **When** the skill executes, **Then** the POST body contains `group_context_id` (not `team_id`).
2. **Given** the team has no Slack webhook, **When** the API returns 422, **Then** the skill shows the appropriate error.

---

### Edge Cases

- Calling `GET /result-feed/{date}/reactions` without a `user_id` — treat as current user (default behavior).
- `review` section with no items, notes, or attachments — display "None." consistent with other sections.
- File upload larger than 4.5 MB → 413 error.
- `POST /result-feed/{date}/reactions` with `user_id` pointing to another user's report — toggle reaction on that user's report.

---

## Requirements *(mandatory)*

### Functional Requirements

**api-reference.md changes:**

- **FR-001**: The `POST /result-feed/{date}/react` entry MUST be updated to `POST /result-feed/{date}/reactions` with body `{ user_id }` (targets whose report to react to) and response shape `{ data: { reacted: boolean, count: integer } }`.
- **FR-002**: A new `GET /result-feed/{date}/reactions` entry MUST be added with param `?user_id=N` and response `{ data: { reacted: boolean, count: integer } }`.
- **FR-003**: The `PUT /result-feed/{date}/{section}/{item_id}` entry MUST note that the body optionally accepts `notes` (string) and `attachment_ids` (array of integers). Valid sections MUST include `review`.
- **FR-004**: A new `POST /result-feed/{date}/attachments` entry MUST be added: multipart/form-data with `file` field, max 4.5 MB, returns `{ data: { id, filename, content_type, filesize } }`. Errors: 400 (missing file), 413 (oversized).
- **FR-005**: The push-to-slack and push-to-discord entries MUST use `group_context_id` (not `team_id`) in their request body descriptions.
- **FR-006**: The comments response shape MUST use `comment` as the text field name (not `body`) to match the API: `{ id, comment, user_id, created_at }`.
- **FR-007**: The `review` section MUST be added to the valid section list wherever `done`, `next`, `blocked` are listed.
- **FR-008**: The reaction-related glossary/lookup table entries MUST be updated to use `/result-feed/{date}/reactions`.

**rkit:result-feed SKILL.md changes:**

- **FR-009**: The `react_to_report` flow MUST call `POST /result-feed/{date}/reactions` (not `/react`).
- **FR-010**: The `react_to_report` response handler MUST read `body.data.reacted` and `body.data.count` (not `high_five_count`/`user_has_reacted`).
- **FR-011**: A new `get_reactions` flow MUST be added: `GET /result-feed/{date}/reactions?user_id=N`.
- **FR-012**: The routing table MUST include a trigger for viewing reaction state (e.g., "show reactions", "reaction count").
- **FR-013**: The `update_section_meta` flow MUST accept `review` as a valid section.
- **FR-014**: The routing table trigger for section notes MUST include `review` (e.g., "set notes on review").
- **FR-015**: A new `upload_attachment` flow MUST be added for `POST /result-feed/{date}/attachments`.
- **FR-016**: The routing table MUST include triggers for the file upload flow (e.g., "upload attachment", "attach file", "add file to check-in").
- **FR-017**: The `push_to_slack` and `push_to_discord` flows MUST use `group_context_id` in the POST body.
- **FR-018**: The Schemas section MUST be updated to include `review` in `TeamResultFeed` and list the reactions response shape.

**Sync:**

- **FR-019**: After updating master `api-reference.md` and the skill, `/sync-plugin` MUST be run to propagate changes to all skill copies.

### Key Entities

- **ResultFeedSection**: `{ items: Item[], notes: string|null, attachments: Attachment[] }` — valid section names: `done`, `review`, `next`, `blocked`.
- **Reaction**: `{ reacted: boolean, count: integer }` — returned by both GET and POST `/reactions`.
- **Attachment**: `{ id, filename, content_type, filesize }` — returned by `POST /attachments` upload.

## Assumptions

- The `/react` endpoint (old path) is no longer supported; `/reactions` is the current path. This assumption is based on the API 077 handoff document.
- Comments list response uses `comment` (not `body`) as the text field — consistent with the POST create response in API 077.
- The `review` section follows the same `{ items, notes, attachments }` structure as other sections.
- `group_context_id` in the push-to-slack/discord body refers to the team's group ID (same value as `default_team_id` in config).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All result-feed skill operations that interact with the reactions feature (toggle, view) complete without errors against the live API.
- **SC-002**: A user can add an item to the `review` section via the skill without receiving a validation error.
- **SC-003**: Pushing a check-in to Slack/Discord succeeds when a webhook is configured (no request body field errors).
- **SC-004**: The `api-reference.md` contains no references to `/result-feed/{date}/react` (old path) or `high_five_count` / `user_has_reacted` (old field names).
- **SC-005**: After running `/sync-plugin`, all skill copies in `skills/*/references/api-reference.md` reflect the same updated content as the master.
