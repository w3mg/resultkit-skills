# Feature Specification: V2 Seat API Field Renames

**Feature Branch**: `030-seats-field-renames`
**Created**: 2026-03-05
**Status**: Draft
**GitHub Issue**: #20 — API Change Handoff: V2 Seat API Enhancements

## Overview

The ResultMaps V2 Seat API has been updated with breaking field renames for both input (create/update requests) and output (all seat responses). The `rkit:seats` skill must be updated to use the new field names — old names return 422 errors from the API. This is a compatibility fix, not a new feature.

## User Scenarios & Testing

### User Story 1 - Create a Seat Without Errors (Priority: P1)

A user asks the seats skill to create a new seat for their accountability chart. The skill sends the correct field names to the API and the seat is created successfully.

**Why this priority**: Creating seats is broken with the old field names — the API now returns 422 errors. This is the most visible breakage.

**Independent Test**: Run `/rkit:seats create CEO` on a team with a seats chart. The seat should be created without error.

**Acceptance Scenarios**:

1. **Given** a user with a configured team, **When** they ask to create a root seat, **Then** the skill sends `team_id` (not `group_id`) and the seat is created successfully.
2. **Given** a user creating a seat with an owner, **When** they specify the owner, **Then** the skill sends `seat_owner_id` (not `accountability_owner_id`) and the seat is created.
3. **Given** a user creating a seat with accountabilities text, **When** they provide the description, **Then** the skill sends `accountabilities` (not `description`) and the seat is created.

---

### User Story 2 - View Seat Details With Correct Fields (Priority: P2)

A user views their accountability chart or a specific seat. The skill reads the updated response fields and displays seat owner, parent info, and accountabilities correctly.

**Why this priority**: The display is broken if the skill looks for old field names — owner and accountabilities will show as empty/null.

**Independent Test**: Run `/rkit:seats` to view the org chart. Seat owners and positions should display correctly.

**Acceptance Scenarios**:

1. **Given** a seat with an owner, **When** the skill reads the seat detail, **Then** it reads `seat_owner` (not `owner`) to display the owner's name.
2. **Given** a seat with a parent, **When** displaying seat info, **Then** the skill reads `parent.name` (not `parent_id`) to show the parent seat name.
3. **Given** a seat with accountabilities content, **When** displaying details, **Then** the skill reads `accountabilities` (not `description`) for the seat's responsibilities text.
4. **Given** a seat with children, **When** displaying children, **Then** the skill handles children as `{ id, name }` objects only (no `parent_id` or `owner` on children).

---

### User Story 3 - Update a Seat Without Errors (Priority: P3)

A user asks the skill to update a seat's owner or accountabilities. The skill sends the correct new field names and the update succeeds.

**Why this priority**: Updates are broken with old field names, but less frequent than creates/views.

**Independent Test**: Ask to reassign a seat owner. The change should succeed with no API errors.

**Acceptance Scenarios**:

1. **Given** an existing seat, **When** a user updates the seat owner, **Then** the skill sends `seat_owner_id` (not `accountability_owner_id`).
2. **Given** an existing seat, **When** a user updates accountabilities text, **Then** the skill sends `accountabilities` (not `description`).

---

### Edge Cases

- What happens if a user's seat data was previously cached with old field names? (Not applicable — no caching in the skill.)
- What if a restore or move operation returns a seat response? The renamed output fields must be handled in those responses too.

## Requirements

### Functional Requirements

- **FR-001**: The skill MUST use `team_id` (not `group_id`) when creating a root seat.
- **FR-002**: The skill MUST use `seat_owner_id` (not `accountability_owner_id`) when setting a seat owner on create or update.
- **FR-003**: The skill MUST use `accountabilities` (not `description`) when setting seat responsibilities on create or update.
- **FR-004**: The skill MUST read `seat_owner` (not `owner`) from all seat responses to display the owner.
- **FR-005**: The skill MUST read `accountabilities` (not `description`) from all seat responses to display responsibilities.
- **FR-006**: The skill MUST read `parent` as an object (`{ id, name }`) rather than `parent_id` as an integer from all seat responses.
- **FR-007**: The skill MUST handle children in seat detail responses as `{ id, name }` only, without expecting `parent_id` or `owner` fields on children.
- **FR-008**: The `api-reference.md` reference file MUST be updated to document the new field names for all seat endpoints.

### Key Entities

- **Seat (response)**: `{ id, name, accountabilities, notes, parent: {id, name}|null, seat_owner: UserSimple|null, team, children: [{id, name}], measures, goals, links }`
- **Create Seat (request)**: `{ name, team_id, parent_id?, seat_owner_id?, accountabilities?, notes? }`
- **Update Seat (request)**: `{ name?, seat_owner_id?, accountabilities?, notes? }`

## Success Criteria

### Measurable Outcomes

- **SC-001**: All seat create operations succeed without 422 API errors.
- **SC-002**: All seat update operations succeed without 422 API errors.
- **SC-003**: Seat owner names display correctly in the accountability chart and seat detail views.
- **SC-004**: Seat parent information displays correctly (by name, not raw ID) in seat detail views.
- **SC-005**: Seat accountabilities content displays correctly wherever seat details are shown.
- **SC-006**: No references to old field names (`group_id`, `accountability_owner_id`, `description` for seats, `owner` for seat owner, `parent_id` on seat responses) remain in the seats skill or api-reference.md.

## Assumptions

- The API change is already live — old field names return 422 errors now.
- Only the `skills/seats/` skill and `api-reference.md` (plus its copy in `skills/seats/references/`) need updating; no other skills use seat endpoints.
- The tree endpoint (`GET /teams/:id/seats`) uses the same renamed output fields on tree nodes.
- Restore (`PUT /seats/:id/restore`) and move (`PUT /seats/:id/move`) responses also use the renamed fields.

## Out of Scope

- No new seat functionality is being added.
- OpenAPI tag reorganization (Seats / Seat Measures / Seat Goals / Seat Links) does not affect the skill's behavior.
- No changes to measure, goal, or link sub-resource endpoints.
