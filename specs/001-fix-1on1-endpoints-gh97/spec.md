# Feature Specification: Fix 1on1 Skill API Endpoints

**Feature Branch**: `001-fix-1on1-endpoints-gh97`  
**Created**: 2026-04-22  
**Status**: Draft  
**GitHub Issue**: #97 — rkit:1on1 — wrong API endpoints and response shapes  
**Issue URL**: https://github.com/w3mg/resultkit-skills/issues/97

## User Scenarios & Testing *(mandatory)*

### User Story 1 - List One-on-Ones (Priority: P1)

A user runs `/rkit:1on1` and sees a list of their one-on-one meetings. Currently this fails silently with a 404 because the skill calls a non-existent `/meetings` endpoint.

**Why this priority**: Listing meetings is the entry point to all 1on1 functionality. Nothing else works until this is fixed.

**Independent Test**: Run `/rkit:1on1` — a table of one-on-one meetings appears instead of an error.

**Acceptance Scenarios**:

1. **Given** a configured rkit install, **When** the user runs `/rkit:1on1` with no args, **Then** a table of one-on-one meetings is displayed with ID, participant name, and date.
2. **Given** a default team is configured, **When** the user runs `/rkit:1on1`, **Then** meetings are filtered to that team and the team name appears in the heading.
3. **Given** no one-on-ones exist, **When** the user runs `/rkit:1on1`, **Then** a "No one-on-ones found" message is shown.

---

### User Story 2 - View One-on-One Detail (Priority: P1)

A user runs `/rkit:1on1 {id}` and sees the meeting detail with items grouped into columns. Currently this fails with a 404.

**Why this priority**: Viewing meeting detail is the core use case after listing.

**Independent Test**: Run `/rkit:1on1 {id}` — three columns (Next, Done, Blocked) display with their items.

**Acceptance Scenarios**:

1. **Given** a valid meeting ID, **When** the user runs `/rkit:1on1 {id}`, **Then** the meeting is displayed with items grouped under Next, Done, and Blocked columns.
2. **Given** the meeting response nests persons under `persons.person1` / `persons.person2`, **When** the detail is rendered, **Then** participant names are correctly extracted and shown.
3. **Given** the detail response nests items under `items.done`, `items.issues`, and `items.next`, **When** columns are rendered, **Then** `items.issues` maps to the Blocked column.

---

### User Story 3 - Add Items to a Meeting (Priority: P2)

A user adds a new item or attaches an existing item to a one-on-one. Currently these calls fail with a 404.

**Why this priority**: Core write operation. Blocked by the endpoint path bug.

**Independent Test**: Run `/rkit:1on1 {id} add "text"` — item is created and confirmed in the meeting.

**Acceptance Scenarios**:

1. **Given** a valid meeting ID, **When** the user adds a new item by text, **Then** the item is created via the correct `/1-on-1/{id}/items` endpoint and confirmation is shown.
2. **Given** a valid meeting ID and existing item ID, **When** the user attaches the item, **Then** the attach call succeeds and confirmation is shown.
3. **Given** a valid meeting ID and item ID, **When** the user removes an item, **Then** the item is detached and confirmation is shown.

---

### User Story 4 - View Single Column (Priority: P2)

A user runs `/rkit:1on1 {id} next` (or `done`/`blocked`) to see items in one column only.

**Why this priority**: Secondary navigation within a meeting, currently broken.

**Independent Test**: Run `/rkit:1on1 {id} next` — only next items display.

**Acceptance Scenarios**:

1. **Given** a valid meeting ID, **When** the user requests a single column, **Then** only items for that column are shown.
2. **Given** the API uses different status values than the skill currently assumes, **When** the column endpoint is called, **Then** the correct status mapping is applied.

---

### Edge Cases

- What happens when a meeting has items where `status == "archived"`? — filter them out before display, show "(empty)" if a column is all-archived.
- What if `persons.person1.first_name` and `persons.person1.last_name` are empty? — fall back to `login`.
- What if the PUT/DELETE item-attachment endpoints differ from the old `/meetings/` equivalents? — verify against real API; document confirmed behavior.
- What if the team has no one-on-ones? — show "No one-on-ones found for {team_name}."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST call `GET /1-on-1` (not `/meetings`) to list one-on-one meetings.
- **FR-002**: The skill MUST use `group_id` (not `team_id`) as the filter parameter when scoping to a team.
- **FR-003**: The skill MUST call `GET /1-on-1/{id}` (not `/meetings/{id}`) to fetch meeting detail.
- **FR-004**: The skill MUST read participant names from the nested `persons.person1` / `persons.person2` object, not from top-level fields.
- **FR-005**: The skill MUST read items from `items.done`, `items.issues`, and `items.next` on the detail response. `items.issues` maps to the Blocked column.
- **FR-006**: The skill MUST call `POST /1-on-1/{id}/items` to create new items in a meeting.
- **FR-007**: The skill MUST use the verified endpoints for attaching and detaching existing items — verified against the real API before implementation.
- **FR-008**: The skill MUST use correct status values when communicating with the API (e.g., `active` for "next", `realized` for "done") wherever status values are sent or filtered.
- **FR-009**: The `api-reference.md` (root master and skill copy) MUST be updated to document the real `/1-on-1` endpoints, replacing all stale `/meetings` references for one-on-one flows.
- **FR-010**: The skill MUST continue to exclude archived items (where `status == "archived"`) before display.

### Key Entities

- **One-on-One Meeting**: A meeting between two participants. Key fields: `id`, `type` (`one_on_one`), `date`, `human_name`, `persons` (nested: `person1`, `person2`), `can_edit`, `can_view`, `can_edit_notes`.
- **Meeting Item**: An agenda item. Key fields: `id`, `name`, `status` (`active`, `realized`, `blocked`, `archived`), `creator`, `due_date`.
- **Persons**: Nested object `{ person1: { id, login, first_name, last_name }, person2: { ... } }`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `/rkit:1on1` returns a list of meetings instead of a 404 error on every configured install.
- **SC-002**: Running `/rkit:1on1 {id}` displays the correct three-column view with participant names resolved correctly from the nested persons structure.
- **SC-003**: All write operations (add item, remove item) complete successfully without 404 errors.
- **SC-004**: The `api-reference.md` (root and skill copy) accurately reflects the real `/1-on-1` endpoint paths, parameters, and response shapes — no stale `/meetings` references remain for one-on-one flows.

## Assumptions

- `PUT /1-on-1/{id}/items/{item_id}` and `DELETE /1-on-1/{id}/items/{item_id}` exist and behave equivalently to the old `/meetings/` endpoints — must be verified before implementation.
- Single-column view uses a status filter on `GET /1-on-1/{id}/items` (e.g., `?status=active`) rather than a separate section path.
- Moving items between columns continues to use `PATCH /items/{id}` with updated status values (`active`/`realized`/`blocked`), not a meeting-specific endpoint.
- The `skills/1on1/scripts/api.sh` is identical to the root `scripts/api.sh` with no 1on1-specific overrides — only a copy update is needed there.
