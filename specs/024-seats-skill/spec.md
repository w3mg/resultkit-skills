# Feature Specification: rkit:seats Skill

**Feature Branch**: `024-seats-skill`
**Created**: 2026-03-04
**Status**: Draft
**Input**: User description: "Add rkit:seats skill for managing seats data"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Accountability Chart (Priority: P1)

A user wants to see their team's accountability chart — all seats and their hierarchy — directly from the CLI. They type `/rkit:seats` (or `/rkit:seats --team 345`) and see a formatted tree showing each seat, who owns it, and the reporting structure. This is the most common use case: getting a quick overview of who sits where.

**Why this priority**: Viewing the org chart is the foundational action. Every other seat operation (editing, searching, drilling in) starts from knowing the chart structure. This delivers immediate value as a read-only reference tool.

**Independent Test**: Can be fully tested by running `/rkit:seats` against a team with a populated accountability chart. Delivers a visual tree of the organization.

**Acceptance Scenarios**:

1. **Given** a configured team with seats, **When** user runs `/rkit:seats`, **Then** display a hierarchical tree showing seat name, owner name (or "Vacant"), and seat ID for every seat.
2. **Given** a configured team, **When** user runs `/rkit:seats --team 123`, **Then** display the chart for team 123 instead of the default team.
3. **Given** a team with no seats, **When** user runs `/rkit:seats`, **Then** display a message indicating the team has no accountability chart yet.

---

### User Story 2 - View Seat Details (Priority: P2)

A user wants to drill into a specific seat to see its full details: accountabilities, notes, aligned measures and goals, links, and direct reports. They type `/rkit:seats 11` to view seat ID 11.

**Why this priority**: After seeing the chart, the next natural action is inspecting a specific seat. This provides the detailed context needed before making any changes.

**Independent Test**: Can be tested by running `/rkit:seats {id}` for a known seat. Delivers a complete detail view of that seat.

**Acceptance Scenarios**:

1. **Given** a valid seat ID, **When** user runs `/rkit:seats 11`, **Then** display seat name, owner, accountabilities (as plain text, HTML stripped), notes, aligned measures, aligned goals, links, and direct reports.
2. **Given** an invalid seat ID, **When** user runs `/rkit:seats 99999`, **Then** display a clear "Seat not found" error.

---

### User Story 3 - Create and Update Seats (Priority: P3)

A user wants to add a new seat to the chart or update an existing seat's details. For creation, they specify a name and optional parent seat. For updates, they specify a seat ID and the fields to change (name, accountabilities, notes, owner, associated team).

**Why this priority**: After viewing the chart, users need to manage it — adding new roles as the org grows or updating seat details when responsibilities change.

**Independent Test**: Can be tested by creating a new seat, verifying it appears in the chart, then updating its fields and confirming changes.

**Acceptance Scenarios**:

1. **Given** a valid team, **When** user runs `/rkit:seats create "VP Engineering" --parent 11`, **Then** confirm the action, create the seat under seat 11, and display the new seat details with its ID.
2. **Given** a valid seat, **When** user runs `/rkit:seats update 42 --name "VP of Engineering"`, **Then** confirm the action, update the seat name, and display the updated seat.
3. **Given** a valid seat, **When** user runs `/rkit:seats update 42 --owner 5`, **Then** confirm the action, assign user 5 to the seat, and display updated details.
4. **Given** a seat that is the root, **When** user attempts to create another root seat (no parent), **Then** display an error that the team already has a root seat.

---

### User Story 4 - Delete, Move, and Restore Seats (Priority: P4)

A user wants to reorganize the chart by moving seats to different parents, archiving seats that are no longer needed, or restoring previously archived seats.

**Why this priority**: Structural operations are less frequent but essential for maintaining the chart as the organization evolves.

**Independent Test**: Can be tested by moving a seat to a new parent and verifying the chart reflects the change; deleting a seat and confirming removal; restoring an archived seat.

**Acceptance Scenarios**:

1. **Given** a non-root seat, **When** user runs `/rkit:seats move 42 --parent 15`, **Then** confirm the action, move the seat, and display updated details.
2. **Given** a root seat, **When** user runs `/rkit:seats move 11 --parent 15`, **Then** display an error that root seats cannot be moved.
3. **Given** a valid seat, **When** user runs `/rkit:seats delete 42`, **Then** confirm the action and archive the seat.
4. **Given** an archived seat, **When** user runs `/rkit:seats restore 42`, **Then** confirm the action and restore the seat.

---

### User Story 5 - Manage Seat Sub-Resources (Priority: P5)

A user wants to align measures (KPIs) or goals (rocks) to a seat, add external links, or remove these alignments. This connects the accountability chart to the team's performance tracking.

**Why this priority**: Sub-resource management is an advanced operation that builds on top of the core seat functionality. Most users will manage these through the web UI, but CLI access enables quick bulk operations.

**Independent Test**: Can be tested by aligning a measure to a seat, verifying it appears in the seat detail view, then removing it.

**Acceptance Scenarios**:

1. **Given** a valid seat and measure, **When** user runs `/rkit:seats align-measure 42 --measure 793`, **Then** confirm the action, align the measure, and display updated measures list.
2. **Given** a valid seat and goal, **When** user runs `/rkit:seats align-goal 42 --goal 7315`, **Then** confirm the action, align the goal, and display updated goals list.
3. **Given** a valid seat, **When** user runs `/rkit:seats add-link 42 --url "https://example.com" --title "Wiki"`, **Then** confirm the action, create the link, and display updated links list.
4. **Given** a seat with aligned measures, **When** user runs `/rkit:seats remove-measure 42 --measure 793`, **Then** confirm the action and remove the alignment.

---

### Edge Cases

- What happens when the user has no config file? Suggest running `/rkit:setup`.
- What happens when the team has no seats at all? Display a helpful empty-state message suggesting seat creation.
- What happens when `accountabilities` contains complex HTML (tables, nested lists)? Strip HTML to readable plain text.
- What happens when the seat tree is very deep (10+ levels)? Render with indentation, capping display depth at a readable level.
- What happens when a seat has no owner (`seat_owner` is null)? Display as "Vacant".

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the full accountability chart as a hierarchical tree with seat name, owner, and ID.
- **FR-002**: System MUST resolve the team ID from `--team` flag, falling back to `default_team_id` in config.
- **FR-003**: System MUST display single seat details including name, owner, accountabilities (HTML stripped to plain text), notes, measures, goals, links, and direct reports.
- **FR-004**: System MUST require user confirmation before any write operation (create, update, delete, move, restore, align, remove).
- **FR-005**: System MUST display entity IDs in all output for follow-up reference.
- **FR-006**: System MUST support creating seats with a name and optional parent seat.
- **FR-007**: System MUST support updating seat fields: name, accountabilities, notes, owner, and associated team.
- **FR-008**: System MUST support moving a seat to a new parent within the same team.
- **FR-009**: System MUST support deleting (archiving) and restoring seats.
- **FR-010**: System MUST support aligning and removing measures, goals, and links on seats.
- **FR-011**: System MUST translate framework terminology (e.g., "accountability chart" for EOS, "org chart" for generic use) per the team's framework setting.
- **FR-012**: System MUST handle API errors gracefully with status code and actionable fix message.

### Key Entities

- **Seat**: A position in the accountability chart. Has a name, optional owner (user), accountabilities (HTML text), notes, parent seat, associated team, and aligned measures/goals/links. Forms a recursive tree through parent-child relationships.
- **Measure**: A KPI or metric aligned to a seat. Has id, name, and description.
- **Goal**: A quarterly goal or rock aligned to a seat. Has id, name, and description.
- **Link**: An external URL attached to a seat. Has id, title, and url.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their full accountability chart in under 5 seconds from command entry.
- **SC-002**: Users can drill into any seat's details with a single command using the seat ID.
- **SC-003**: All write operations (create, update, delete, move) complete successfully with user confirmation and display the result.
- **SC-004**: 100% of seat operations available in the web UI are accessible through the CLI skill.
- **SC-005**: Vacant seats are clearly identifiable in both tree and detail views.

## Assumptions

- The user has already run `/rkit:setup` and has a valid config with API token and default team ID.
- The API supports full CRUD on seats (POST, PATCH, DELETE) plus move and restore operations.
- HTML in `accountabilities` can be safely stripped to plain text using sed without losing meaning.
- The team's seat tree is finite and can be fetched in a single API call (`GET /teams/{id}/seats`).
- Measures and goals already exist in the system; the seats skill only aligns/removes them, not creates them.
