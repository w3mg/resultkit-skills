# Feature Specification: Strategy Skill (rkit:strategy)

**Feature Branch**: `001-strategy-skill`
**Created**: 2026-03-09
**Status**: Draft
**Input**: User description: "rkit:strategy - Manage a team's strategy tree via the ResultMaps V2 API. Related to the new strategy endpoints: GET /teams/{id}/strategy, POST /teams/{id}/strategy, PATCH /strategy/{objectType}/{objectId}, DELETE /strategy/{objectType}/{objectId}, PUT /strategy/align."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Team Strategy Tree (Priority: P1)

A user runs `/rkit:strategy` to see their default team's full strategy tree — goals, rocks, objectives, key results, and milestones — displayed as a readable hierarchy.

**Why this priority**: Core read operation. Users need to see what exists before they can create, update, or align anything. The most common use case.

**Independent Test**: Run `/rkit:strategy` with a configured team; the nested strategy tree is displayed with object names, statuses, assignees, due dates, and object types. Unaligned items are listed separately.

**Acceptance Scenarios**:

1. **Given** the user has a default team configured, **When** they run `/rkit:strategy`, **Then** the strategy tree for the current year/quarter is displayed as a nested hierarchy showing name, status, object_type, assignees, and due date for each node.
2. **Given** the team has unaligned objects, **When** the user views the tree, **Then** unaligned items are shown in a separate section below the main tree.
3. **Given** the user specifies `year=2025` or `quarter=2`, **When** the command runs, **Then** only goals matching that time filter are shown.
4. **Given** the user specifies `year=All`, **When** the command runs, **Then** all goals across all years are shown.
5. **Given** the team has no strategy objects, **When** the user runs `/rkit:strategy`, **Then** a friendly empty-state message is shown.
6. **Given** the tree contains inherited nodes from a parent team, **When** displayed, **Then** inherited nodes are visually marked as inherited with the source team name and flagged as read-only.

---

### User Story 2 - Create a Strategy Object (Priority: P2)

A user creates a new goal, rock, objective, key result, focus area, or milestone in their team's strategy tree.

**Why this priority**: Adding new strategy objects is the primary write operation after viewing. Users need to build out their strategy tree.

**Independent Test**: User creates a rock under a yearly goal; the new object appears in the tree on the next view.

**Acceptance Scenarios**:

1. **Given** the user specifies a name and parent, **When** they run e.g. `/rkit:strategy create "Improve onboarding" under "Annual Goal"`, **Then** the object is created as a child of the parent and a confirmation with the new id and object_type is shown.
2. **Given** the user specifies only a name with no parent, **When** creating, **Then** a root-level object is created (yearly_goal for EOS, objective for OKR).
3. **Given** the user adds optional fields (description, due, assignees, status), **When** creating, **Then** all specified fields are set on the new object.
4. **Given** an OKR team user specifies `is_focus_area`, **When** creating at root level, **Then** a focus_area (result area) is created instead of an objective.
5. **Given** the user provides a parent name that matches multiple objects, **When** creating, **Then** a disambiguation list is shown.

---

### User Story 3 - Update a Strategy Object (Priority: P3)

A user updates the name, description, status, due date, or assignees of an existing strategy object.

**Why this priority**: Maintaining strategy objects (marking complete, renaming, reassigning) is a regular workflow.

**Independent Test**: User updates a rock's status to "complete"; the change is reflected on the next tree view.

**Acceptance Scenarios**:

1. **Given** a strategy object exists, **When** the user runs e.g. `/rkit:strategy update "Improve onboarding" status=complete`, **Then** the object is updated and a confirmation is shown.
2. **Given** the user updates assignees, **When** the update is sent, **Then** the full assignee list is replaced (not appended).
3. **Given** the user targets an inherited (read-only) node, **When** updating, **Then** a clear error is shown explaining the node is inherited and read-only.
4. **Given** the user provides a name that matches multiple objects, **When** updating, **Then** a disambiguation list is shown.

---

### User Story 4 - Align (Link) a Strategy Object (Priority: P4)

A user links an unaligned or existing object to a parent in the strategy tree.

**Why this priority**: Alignment is less frequent but essential for organizing the tree structure.

**Independent Test**: User aligns an unaligned rock to a yearly goal; the rock moves from the unaligned section into the tree under that goal.

**Acceptance Scenarios**:

1. **Given** an unaligned object exists, **When** the user runs e.g. `/rkit:strategy align "New Rock" under "Annual Goal"`, **Then** the object is linked to the parent and moves out of the unaligned list.
2. **Given** the user references objects by name, **When** aligning, **Then** the skill resolves names to ids and object_types automatically.
3. **Given** ambiguous names, **When** aligning, **Then** disambiguation lists are shown for both object and parent.

---

### User Story 5 - Detach (Remove) a Strategy Object (Priority: P5)

A user detaches an object from its parent in the strategy tree, optionally archiving it.

**Why this priority**: Cleanup operation; least frequent but necessary for tree maintenance.

**Independent Test**: User detaches a rock from a goal; the rock moves to the unaligned section. With `--archive`, the rock is also archived.

**Acceptance Scenarios**:

1. **Given** a child object is linked to a parent, **When** the user runs e.g. `/rkit:strategy detach "New Rock" from "Annual Goal"`, **Then** the link is removed and the object is preserved (appears in unaligned).
2. **Given** the user specifies `--archive`, **When** detaching, **Then** the object is also archived after unlinking.
3. **Given** the object has only one parent link, **When** detaching, **Then** it moves to the unaligned list.

---

### Edge Cases

- What happens when a team has no strategy objects? Show a friendly empty state.
- What happens when an object name matches multiple objects? Show a disambiguation list with id, type, status, and parent context.
- What if the user references an object that is inherited? Block edits with a clear message.
- What if the API returns 403 (not authorized)? Show a permissions error.
- What if the team uses a framework not explicitly handled (e.g., SRT, V2MOM)? The API auto-detects framework — the skill should work generically with whatever object_types the API returns.
- What if `year` or `quarter` filters return no results? Show "No strategy objects found for [year] Q[quarter]."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST display the team's strategy tree as a nested hierarchy when invoked with no subcommand, showing name, object_type, status, assignees, due date, and inherited flag for each node.
- **FR-002**: The skill MUST show unaligned objects in a separate section below the main tree.
- **FR-003**: The skill MUST support `year` and `quarter` filter parameters on the tree view (default: current year/quarter; `All` for everything).
- **FR-004**: The skill MUST support a `create <name>` subcommand to create a new strategy object, with optional `parent`, `description`, `due`, `assignees`, `status`, and `is_focus_area` parameters.
- **FR-005**: The skill MUST support an `update <name>` subcommand to modify one or more fields (name, description, status, due, assignees) of an existing object.
- **FR-006**: The skill MUST support an `align <object-name> under <parent-name>` subcommand to link an object to a parent.
- **FR-007**: The skill MUST support a `detach <object-name> from <parent-name>` subcommand to unlink an object, with optional `--archive` flag.
- **FR-008**: The skill MUST resolve object references by name (case-insensitive), disambiguating when multiple matches exist.
- **FR-009**: The skill MUST visually mark inherited nodes as read-only with their source team name.
- **FR-010**: The skill MUST block edit/delete operations on inherited nodes with a clear error message.
- **FR-011**: The skill MUST adapt its display labels to the team's framework (e.g., "Yearly Goals" for EOS, "Objectives" for OKR).
- **FR-012**: The skill MUST surface API error messages (403, 404, 422) clearly without raw traces.

### Key Entities

- **StrategyNode**: A node in the strategy tree. Fields: id, name, description, status, object_type (yearly_goal | rock | focus_area | objective | key_result | milestone | action), type, color, assignees, creator, due, children, inherited, inherited_from.
- **StrategyAssignee**: A user assigned to a strategy node. Fields: id, first_name, last_name.
- **Team**: The organizational group owning the strategy. Identified by `default_team_id` in user config. Has a `framework` (eos, okr, 4dx) that determines the tree structure.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can view their team's full strategy tree (all levels, including unaligned items) in a single command with no additional steps.
- **SC-002**: A user can create a new strategy object at any level of the tree in one command, with confirmation returned promptly.
- **SC-003**: A user can update, align, or detach strategy objects by name without needing to look up object IDs or object_types manually.
- **SC-004**: All five API operations (view, create, update, align, detach) are accessible from the skill with clear, consistent natural-language syntax.
- **SC-005**: Error messages for invalid operations (inherited node edits, ambiguous names, missing parents) are human-readable and actionable.

## Assumptions

- The user's `~/.config/resultkit/config.json` has a valid `default_team_id` and API token; the skill will error clearly if not configured.
- Object name resolution uses case-insensitive substring match against the flattened tree returned by `GET /teams/{id}/strategy`.
- The tree display uses indentation (2 spaces per level) with status indicators and framework-aware labels.
- Assignee resolution for create/update is by user ID (the skill can look up IDs from the team members list if names are provided).
- The `object_type` and `parent_type` values required by the API are resolved automatically by the skill from the tree — users never need to specify them directly.
