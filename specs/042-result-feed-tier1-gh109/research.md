# Research: Update Result-Feed Skill for Tier 1 Backend API Changes

**Date**: 2026-04-28

## Findings

### 1. Reactions Endpoint Path and Response Shape

**Decision**: Use `POST /result-feed/:date/reactions` (not `/react`) with response fields `reacted` (boolean) and `count` (integer).

**Rationale**: The API handoff document explicitly specifies this path and response shape. The existing SKILL.md and api-reference.md used pre-release field names (`/react`, `high_five_count`, `user_has_reacted`) that were updated in the final API.

**Alternatives considered**: Keep old path — rejected because API will only respond on the new path.

### 2. Push Body Parameter

**Decision**: Use `group_context_id` (not `team_id`) in the push-to-slack and push-to-discord request bodies.

**Rationale**: API handoff specifies `group_context_id`. The API maps group contexts to teams internally.

**Alternatives considered**: None — must match API contract.

### 3. Attachment Schema

**Decision**: Use `{ id, filename, content_type, size }` for attachment objects in result-feed sections.

**Rationale**: API handoff specifies this shape. The old `{ id, filename, url }` was from initial design; the final API returns content type and size instead of a direct URL.

**Alternatives considered**: None — must match API response.

### 4. Review Section Placement

**Decision**: Display `review` between `done` and `next` in the section order: Done → Review → Next → Blocked.

**Rationale**: Review items are "done but awaiting sign-off" — logically sits between completed work and upcoming work. This matches the API handoff's section ordering in response examples.

**Alternatives considered**: Place after blocked — rejected because review is closer to done than to blocked in workflow terms.

### 5. File Upload via Skill

**Decision**: Document the `POST /result-feed/:date/attachments` endpoint in api-reference.md and add a minimal upload flow to the skill, but note the practical limitation that binary file uploads via `curl` in a CLI skill may require the user to provide a local file path.

**Rationale**: The endpoint exists and should be accessible. Claude Code can execute `curl -F "file=@/path/to/file"` via Bash.

**Alternatives considered**: Skip file upload entirely — rejected because the endpoint is part of the Tier 1 API surface.

### 6. Comment Response Field Name

**Decision**: The API returns `comment` (not `body`) as the text field in comment objects. Display should reference this field.

**Rationale**: API handoff response example shows `{ id, comment, user_id, created_at }`.

**Alternatives considered**: None — must match API response.

### 7. GET Reactions Endpoint

**Decision**: Add `GET /result-feed/:date/reactions?user_id=N` support. Merge into existing react flow — after toggling, display the current state. Also allow querying without toggling.

**Rationale**: API provides both GET (read) and POST (toggle) for reactions. Users may want to check reaction state without toggling.

**Alternatives considered**: Add separate routing table entry — accepted, add "show reactions" trigger mapping to a read-only GET call.
