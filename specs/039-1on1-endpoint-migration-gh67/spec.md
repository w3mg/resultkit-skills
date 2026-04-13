# Feature Specification: Update rkit:1on1 Skill to New API Endpoints

**Feature Branch**: `039-1on1-endpoint-migration-gh67`
**Created**: 2026-04-13
**Status**: Draft
**GitHub Issue**: #67 — [API Change] Change Handoff: 1-on-1 Meeting REST Endpoints
**Issue URL**: https://github.com/w3mg/resultkit-skills/issues/67

## User Scenarios & Testing *(mandatory)*

### User Story 1 - List, View, and Manage 1:1 Meetings (Priority: P1)

A user invokes `/rkit:1on1` to list their one-on-one meetings, view a specific meeting's agenda, add or remove items, and move items between columns (next / done / blocked). All of these flows currently call `/meetings/...` endpoints, which are now deleted server-side and return errors.

**Why this priority**: This is the core functionality of the skill. Without the endpoint fix, the skill is completely broken for all users.

**Independent Test**: Run `/rkit:1on1` with no args — it should list one-on-ones without error. Then run `/rkit:1on1 {id}` — it should show the meeting detail with items grouped by column.

**Acceptance Scenarios**:

1. **Given** a configured rkit account, **When** a user runs `/rkit:1on1`, **Then** the skill lists their one-on-one meetings using the `/1-on-1` endpoint without error.
2. **Given** a valid meeting ID, **When** a user runs `/rkit:1on1 {id}`, **Then** the skill fetches detail from `/1-on-1/{id}` and displays next/done/blocked columns.
3. **Given** a valid meeting ID and item text, **When** a user runs `/rkit:1on1 {id} add "text"`, **Then** the skill posts to `/1-on-1/{id}/items` and confirms creation.
4. **Given** a valid meeting ID and item ID, **When** a user runs `/rkit:1on1 {id} add {item_id}`, **Then** the skill puts to `/1-on-1/{id}/items/{item_id}` and confirms attachment.
5. **Given** a valid meeting ID and item ID, **When** a user runs `/rkit:1on1 {id} remove {item_id}`, **Then** the skill deletes from `/1-on-1/{id}/items/{item_id}` and confirms removal.
6. **Given** a valid meeting ID and column name, **When** a user runs `/rkit:1on1 {id} next` (or `done`/`blocked`), **Then** the skill fetches from `/1-on-1/{id}/items/{section}` and displays the column.
7. **Given** a valid meeting ID, item ID, and target column, **When** a user runs `/rkit:1on1 {id} move {item_id} {column}`, **Then** the item status is updated and the user is informed.

---

### User Story 2 - Save Notes to a 1:1 Meeting (Priority: P2)

A user wants to capture notes during a one-on-one meeting by running `/rkit:1on1 {id} notes "text"`. This uses the new `PUT /1-on-1/{id}/notes` endpoint.

**Why this priority**: Notes are a key use case for 1:1 meetings. This is the highest-priority new endpoint from the API handoff.

**Independent Test**: Run `/rkit:1on1 {id} notes "Discussion about Q2 goals"` — the skill should save the notes and confirm success.

**Acceptance Scenarios**:

1. **Given** a valid meeting ID and note text, **When** a user runs `/rkit:1on1 {id} notes "text"`, **Then** the skill puts to `/1-on-1/{id}/notes` and confirms the save.
2. **Given** note text containing special characters, **When** the user saves notes, **Then** the text is preserved exactly as entered.
3. **Given** an invalid meeting ID, **When** the user attempts to save notes, **Then** the skill reports a 404 error.

---

### User Story 3 - View Done Items with Date Filter (Priority: P3)

A user wants to see done items from a 1:1 meeting, optionally filtered by a date range, using the new `GET /1-on-1/{id}/done` endpoint.

**Why this priority**: Secondary value-add. The existing detail view shows done items, but this dedicated endpoint adds date filtering for longer-running meetings.

**Independent Test**: Run `/rkit:1on1 {id} done` — it should show done items from the dedicated done endpoint.

**Acceptance Scenarios**:

1. **Given** a valid meeting ID, **When** a user runs `/rkit:1on1 {id} done`, **Then** the skill fetches from `/1-on-1/{id}/done` and displays done items.
2. **Given** a valid meeting ID and a date string, **When** a user runs `/rkit:1on1 {id} done --since 2026-01-01`, **Then** the skill passes the date param and returns filtered results.

---

### Edge Cases

- What happens when the API returns 404 for a meeting ID? → Skill reports "Meeting {id} not found."
- What happens when the user has no one-on-ones? → Skill reports "No one-on-ones found."
- What happens when all items in a column are archived? → Column shows "(empty)" after filtering.
- What happens when the user provides an empty notes string? → Skill warns and does not submit.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST use `/1-on-1` (not `/meetings`) for all list, detail, item creation, item attachment, and item removal calls.
- **FR-002**: The skill MUST use `/1-on-1/{id}/items/{section}` (not `/meetings/{id}/items/{section}`) for single-column views.
- **FR-003**: The skill MUST support saving notes via `PUT /1-on-1/{id}/notes` when the user provides note content.
- **FR-004**: The skill MUST confirm before saving notes (write operation).
- **FR-005**: The `api-reference.md` master file MUST be updated to replace the `/meetings` endpoint section with `/1-on-1` endpoints, including all new endpoints from the API handoff.
- **FR-006**: All skill copies of `api-reference.md` in `skills/*/references/` MUST be synced from the master file after the update.
- **FR-007**: The plugin version MUST be bumped after all changes.
- **FR-008**: No skill file in the repository MUST reference the deprecated `/meetings/*` paths in skill logic or API reference documentation after this feature ships.

### Key Entities

- **One-on-One Meeting**: A 1:1 session between two users. Identified by `id`. Contains `persons` (person1, person2), `date`, `notes`, and `items` grouped as done/next/blocked arrays.
- **Meeting Item**: An agenda item in a 1:1. Fields: `id`, `name`, `status` (next/done/blocked), `creator`, `due_date`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All existing `/rkit:1on1` flows (list, detail, add, remove, move, view column) work without API errors after the endpoint rename.
- **SC-002**: Users can save notes to a 1:1 meeting via a single command invocation.
- **SC-003**: The `api-reference.md` documents all `/1-on-1/*` endpoints, including the 14 new endpoints introduced in the API handoff.
- **SC-004**: Zero references to `/meetings/*` remain in any active skill file or API reference after the feature ships.

## Assumptions

- The response shape for `GET /1-on-1/{id}` is equivalent to the old `GET /meetings/{id}` for fields the skill uses (`persons`, `items.done`, `items.next`, `items.blocked`, `notes`).
- The `GET /1-on-1?team_id=...` list endpoint returns the same envelope shape as the old `/meetings` list.
- The new `POST /1-on-1/{id}/items`, `PUT /1-on-1/{id}/items/{item_id}`, and `DELETE /1-on-1/{id}/items/{item_id}` endpoints behave identically to the old `/meetings/{id}/items/*` equivalents.
- Notes are saved as plain text (or HTML sanitized server-side); the skill does not need to handle sanitization.
- Notes-lock, align/unalign, assistants, attachments, goals, measures, and set-positions endpoints are out of scope for this feature.
