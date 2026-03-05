# Feature Specification: V2 Seat API Integration

**Feature Branch**: `029-v2-seat-api`
**Created**: 2026-03-05
**Status**: Draft
**Input**: GitHub Issue #19 — API Change Handoff: V2 Seat API

## Overview

The ResultMaps V2 API now has a complete seat management API. This feature updates the `api-reference.md` with all new seat endpoints and ensures the `rkit:seats` skill is fully wired to the finalized V2 API, including any endpoint paths, request fields, or response shapes that differ from what was assumed during spec 024.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Team Accountability Chart (Priority: P1)

A user wants to see the full recursive accountability chart for their team. They run `/rkit:seats` and get a tree showing every seat, its owner, and its position in the hierarchy.

**Why this priority**: Reading the chart is the most common seat operation and is the entry point for all other seat actions. It depends only on `GET /teams/{id}/seats`, which is the tree endpoint.

**Independent Test**: Run `/rkit:seats` against a team with a multi-level seat tree. Verify every seat appears with correct indentation, owner name (or "Vacant"), and seat ID.

**Acceptance Scenarios**:

1. **Given** a team with seats, **When** user runs `/rkit:seats`, **Then** display a hierarchical tree with seat name, owner (or "Vacant"), and ID for each seat.
2. **Given** a team with no seats, **When** user runs `/rkit:seats`, **Then** display an empty-state message explaining how to create the first seat.
3. **Given** the `--include-archived` flag, **When** user runs `/rkit:seats --include-archived`, **Then** include archived seats in the tree, visually distinguished from active seats.
4. **Given** a `--team` flag, **When** user runs `/rkit:seats --team 123`, **Then** show the chart for that team rather than the configured default.

---

### User Story 2 - Inspect a Specific Seat (Priority: P2)

A user wants full details on a seat — accountabilities, notes, aligned measures, goals, links, and direct reports. They run `/rkit:seats 42`.

**Why this priority**: Seat detail is the second most common read operation. It uses `GET /seats/{id}` and delivers complete context before making any changes.

**Independent Test**: Run `/rkit:seats 42` for a seat that has an owner, at least one measure, one goal, and one link. Verify all fields appear.

**Acceptance Scenarios**:

1. **Given** a valid seat ID, **When** user runs `/rkit:seats 42`, **Then** display name, owner, accountabilities (HTML stripped), notes, measures list, goals list, links list, and direct reports list.
2. **Given** an invalid seat ID, **When** user runs `/rkit:seats 99999`, **Then** display a clear error message.
3. **Given** a seat with no sub-resources, **When** user views it, **Then** each empty section displays a "none" indicator rather than an error.

---

### User Story 3 - Create and Update Seats (Priority: P3)

A user adds a new role to the chart or edits an existing seat's details.

**Why this priority**: The create and update operations are the primary write paths. Create uses `POST /seats` and update uses `PATCH /seats/{id}`.

**Independent Test**: Create a child seat under an existing root, then update its name and owner. Verify both operations reflect in the chart.

**Acceptance Scenarios**:

1. **Given** a team with a root seat, **When** user runs `/rkit:seats create "VP Engineering" --parent 11`, **Then** confirm, create the seat under seat 11, and display the new seat with its assigned ID.
2. **Given** no existing root seat, **When** user runs `/rkit:seats create "CEO" --team 10`, **Then** confirm and create the root seat for team 10 using `group_id`.
3. **Given** a valid seat, **When** user runs `/rkit:seats update 42 --name "CTO"`, **Then** confirm, patch the seat name, and display updated details.
4. **Given** a valid seat, **When** user runs `/rkit:seats update 42 --owner 5`, **Then** confirm, assign the owner, and display updated details noting that measures and goals may have been reassigned to the new owner.
5. **Given** a team with an existing root seat, **When** user attempts to create a second root seat, **Then** display an error that only one root seat is allowed per team.

---

### User Story 4 - Move, Archive, and Restore Seats (Priority: P4)

A user reorganizes the chart by moving a seat to a new parent, archiving a role that's been eliminated, or restoring one that was archived by mistake.

**Why this priority**: Structural operations are less frequent but critical for keeping the chart accurate as the org evolves.

**Independent Test**: Move a leaf seat to a different parent, archive it, and then restore it. Verify the chart reflects each change.

**Acceptance Scenarios**:

1. **Given** a non-root seat, **When** user runs `/rkit:seats move 42 --parent 15`, **Then** confirm and move the seat, displaying the seat under its new parent.
2. **Given** a valid seat with children, **When** user runs `/rkit:seats delete 42`, **Then** confirm, archive the seat and all descendants, and confirm in output that archiving is recursive.
3. **Given** an archived seat, **When** user runs `/rkit:seats restore 42`, **Then** confirm and restore only that seat (note in output that descendants remain archived).
4. **Given** a root seat, **When** user attempts to move it, **Then** display an error — root seats cannot be moved.

---

### User Story 5 - Manage Measures, Goals, and Links on a Seat (Priority: P5)

A user aligns a measure or goal to a seat, adds an external link, or removes any of these sub-resources.

**Why this priority**: Sub-resource management connects the accountability chart to performance tracking. It is less common than seat CRUD but completes the skill.

**Independent Test**: Align a measure and a goal to a seat, add a link, then remove each one. Verify the seat detail view reflects every change.

**Acceptance Scenarios**:

1. **Given** a valid seat and measure, **When** user runs `/rkit:seats align-measure 42 --measure 793`, **Then** confirm and align the measure, displaying the updated measures list.
2. **Given** a valid seat and goal, **When** user runs `/rkit:seats align-goal 42 --goal 7315`, **Then** confirm and align the goal.
3. **Given** a valid seat, **When** user runs `/rkit:seats add-link 42 --url "https://docs.example.com" --title "Strategy Doc"`, **Then** confirm and add the link; if title is omitted, default it to the URL.
4. **Given** an aligned measure, **When** user runs `/rkit:seats remove-measure 42 --measure 793`, **Then** confirm and remove the alignment.
5. **Given** an aligned goal, **When** user runs `/rkit:seats remove-goal 42 --goal 7315`, **Then** confirm and remove the alignment.
6. **Given** a link, **When** user runs `/rkit:seats remove-link 42 --link 1`, **Then** confirm and delete the link.

---

### Edge Cases

- What happens when `accountabilities` contains nested HTML? Strip tags to readable plain text.
- What happens when the seat tree is deeply nested (10+ levels)? Render with indentation without truncating.
- What happens when a seat owner changes? The output must mention that aligned measures and goals have been reassigned to the new owner.
- What happens when the user tries to restore a seat whose parent is also archived? Display a warning that the parent is still archived.
- What happens when the user archives the root seat? The API recursively archives all descendants — the confirmation message must warn that this seat AND all descendants will be archived (the 204 no-content response does not enumerate affected seats).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `api-reference.md` MUST document all V2 seat endpoints: `GET /teams/{id}/seats`, `POST /seats`, `GET /seats/{id}`, `PATCH /seats/{id}`, `DELETE /seats/{id}`, `PUT /seats/{id}/restore`, `PUT /seats/{id}/move`, plus all measure/goal/link sub-resource endpoints.
- **FR-002**: The rkit:seats skill MUST use `GET /teams/{id}/seats` to fetch the full recursive tree.
- **FR-003**: The skill MUST support `--include-archived` on chart view, passing `include_archived=true` as a query parameter.
- **FR-004**: Root seat creation MUST use `group_id`; child seat creation MUST use `parent_id`. Both are mutually exclusive.
- **FR-005**: Owner assignment MUST use the `accountability_owner_id` field.
- **FR-006**: All write operations MUST require user confirmation before executing.
- **FR-007**: All output MUST display entity IDs to enable follow-up commands.
- **FR-008**: Archive confirmation MUST warn that the seat AND all its descendants will be archived. (The DELETE endpoint returns 204 no content — individual seat names cannot be listed from the response.)
- **FR-009**: Restore output MUST note that only the target seat is restored; children remain archived.
- **FR-010**: Owner update output MUST note that aligned measures and goals have been reassigned to the new owner.
- **FR-011**: The `accountabilities` field MUST be stripped of HTML before display.
- **FR-012**: Team resolution MUST use `--team` flag if provided, otherwise fall back to `default_team_id` in config.
- **FR-013**: API errors MUST be displayed with status code and an actionable resolution message.
- **FR-014**: The skill MUST apply framework-aware terminology: EOS teams → "Accountability Chart"; other frameworks → "Org Chart".

### Key Entities

- **Seat**: Named position in the team hierarchy. Has id, name, description, notes, parent_id (null for root), owner (user or null), team, associated_team, measures, goals, links, and children. Tree endpoint children are full Seat objects; detail endpoint children are SeatSummary.
- **SeatSummary**: Lightweight seat reference (id, name, parent_id, owner) used in the `children` array of detail responses.
- **Measure**: KPI aligned to a seat. Has id, name, description.
- **Goal**: Rock or quarterly goal aligned to a seat. Has id, name, description.
- **Link**: External URL on a seat. Has id, title, url. Title defaults to URL when not provided.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `api-reference.md` documents all 17 V2 seat endpoints with correct method, path, parameters, and response shape. (7 core: tree, detail, create, update, delete, move, restore; 10 sub-resource: list/align/remove for measures and goals, list/add/update/remove for links.)
- **SC-002**: Users can view the full accountability chart with a single command in under 5 seconds.
- **SC-003**: All seat CRUD operations (create, read, update, archive, restore, move) succeed end-to-end via the skill with confirmation and result output.
- **SC-004**: All sub-resource operations (align/remove measure, align/remove goal, add/update/remove link) succeed end-to-end via the skill.
- **SC-005**: Archived seats are visually distinguishable in the chart when `--include-archived` is used.
- **SC-006**: 100% of V2 seat API endpoints specified in the API change handoff are reachable through the skill.

## Assumptions

- The user has a valid config with API token and default team ID from a prior `/rkit:setup`.
- Measures and goals are pre-existing; the seats skill only aligns/removes them, not creates them.
- The full seat tree can be fetched in a single API call and rendered in one pass.
- HTML stripping on `accountabilities` is safe for CLI display — no meaningful structure is lost.
- Spec 024 design conventions (confirmation prompts, output format, flag style) are preserved; this spec extends them to match the finalized V2 API.
