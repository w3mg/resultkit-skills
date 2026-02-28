# Feature Specification: Update Skills to Reflect Latest Endpoints

**Feature Branch**: `017-update-skill-endpoints`
**Created**: 2026-02-28
**Status**: Draft
**Input**: User description: "Update skills to ensure latest L10, headline, and meeting endpoints are reflected"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View and Manage L10 Parked Items (Priority: P1)

A user working with an EOS team wants to view parked items on the L10 board and park items from other sections. Currently the `rkit:level10` skill has no parked section support, so users must fall back to `/rkit:weekly` for parking lot operations.

**Why this priority**: Parked items are a core L10 board section. Without them, the L10 skill is incomplete — users cannot manage their full L10 workflow in one place.

**Independent Test**: Can be fully tested by running `/rkit:level10` and seeing a Parked section, and running `/rkit:level10 parked` or `/rkit:level10 move {id} parked` to view/park items.

**Acceptance Scenarios**:

1. **Given** an EOS team with parked items, **When** user runs `/rkit:level10`, **Then** the board displays a Parked section with items listed (ID, name, creator, due).
2. **Given** an EOS team, **When** user runs `/rkit:level10 parked`, **Then** only the parked section is displayed.
3. **Given** an item in to-dos, **When** user runs `/rkit:level10 move {item_id} parked`, **Then** the item is moved to the parking lot via `PUT /teams/{id}/l10/parked/{item_id}`.

---

### User Story 2 - View L10 Done Items (Priority: P1)

A user wants to view recently completed items on the L10 board. Currently the L10 skill fetches to-dos, issues, and headlines — but not done items.

**Why this priority**: Done items are a standard L10 board section. Users need to see what was completed to track progress during their Level 10 meeting.

**Independent Test**: Can be tested by running `/rkit:level10` and seeing a Done section, and `/rkit:level10 done` to view only done items.

**Acceptance Scenarios**:

1. **Given** an EOS team with completed items, **When** user runs `/rkit:level10`, **Then** the board displays a Done section (7-day default filter).
2. **Given** an EOS team, **When** user runs `/rkit:level10 done`, **Then** only the done section is displayed.

---

### User Story 3 - Remove Items from L10 Board (Priority: P2)

A user wants to remove an item from the L10 board without deleting it. Currently the L10 skill has no remove flow. The `DELETE /teams/{id}/l10/items/{item_id}` endpoint exists but is not wired into the skill.

**Why this priority**: Removing items from the board (setting on_weekly=false) is essential for board hygiene. Without it, users must use `/rkit:weekly remove` as a workaround.

**Independent Test**: Can be tested by running `/rkit:level10 remove {item_id}` and verifying the item is removed from the L10 board but still exists.

**Acceptance Scenarios**:

1. **Given** an item on the L10 board, **When** user runs `/rkit:level10 remove {item_id}`, **Then** the item is removed from the board via `DELETE /teams/{id}/l10/items/{item_id}` and the user is told the item still exists.
2. **Given** an item not on the L10 board, **When** user runs `/rkit:level10 remove {item_id}`, **Then** an appropriate error is shown.

---

### User Story 4 - Use L10-Specific Routes for All L10 Operations (Priority: P2)

The L10 skill should consistently use L10-specific API routes (`/l10/todos`, `/l10/done`, `/l10/issues`, `/l10/parked`, `/l10/items`) for all operations rather than falling back to generic routes. This ensures consistent behavior and terminology.

**Why this priority**: Consistency in route usage reduces confusion and aligns with the EOS-specific intent of the L10 skill. The L10 PUT routes exist for todos, done, issues, and parked.

**Independent Test**: Can be tested by verifying that all API calls in the L10 skill use `/l10/` prefixed routes for EOS teams.

**Acceptance Scenarios**:

1. **Given** the L10 skill's "Mark Done" flow, **When** executed, **Then** it uses `PUT /teams/{id}/l10/done/{item_id}` instead of `PUT /teams/{id}/items/done/{item_id}`.
2. **Given** the L10 skill's "Move Item" flow, **When** moving to todos, **Then** it uses `PUT /teams/{id}/l10/todos/{item_id}`.
3. **Given** the L10 skill's "Move Item" flow, **When** moving to issues, **Then** it uses `PUT /teams/{id}/l10/issues/{item_id}`.

---

### User Story 5 - Weekly Skill Uses L10 Routes for All EOS Columns (Priority: P3)

The weekly skill's L10 Route Selection table only maps EOS routes for `next` and `blocked`. The L10 routes also exist for `done` and `parked` and should be used for EOS teams.

**Why this priority**: Lower priority since the generic routes work identically — this is a consistency improvement rather than a functional gap.

**Independent Test**: Can be tested by running `/rkit:weekly done` and `/rkit:weekly parked` on an EOS team and verifying the L10 routes are used.

**Acceptance Scenarios**:

1. **Given** an EOS team, **When** user views the done column, **Then** the weekly skill uses `GET /teams/{id}/l10/done` instead of `GET /teams/{id}/items/done`.
2. **Given** an EOS team, **When** user views the parked column, **Then** the weekly skill uses `GET /teams/{id}/l10/parked` instead of `GET /teams/{id}/items/parked`.

---

### Edge Cases

- What happens when parked section is empty? Display "(empty)" consistent with other sections.
- What happens when user tries to park an already-parked item? "Item is already in Parked."
- What happens when user tries to remove an item not on the L10 board? Show "Item {id} is not on the Level 10 board."
- What happens when done section exceeds the returned count? Show overflow indicator consistent with other sections.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `rkit:level10` skill MUST display a Parked section when viewing the full L10 board, fetched via `GET /teams/{id}/l10/parked`.
- **FR-002**: The `rkit:level10` skill MUST display a Done section when viewing the full L10 board, fetched via `GET /teams/{id}/l10/done`.
- **FR-003**: The `rkit:level10` skill MUST support `parked` and `done` as single-section view arguments.
- **FR-004**: The `rkit:level10` skill MUST support a `move {item_id} parked` flow using `PUT /teams/{id}/l10/parked/{item_id}`.
- **FR-005**: The `rkit:level10` skill MUST support a `remove {item_id}` flow using `DELETE /teams/{id}/l10/items/{item_id}`.
- **FR-006**: The `rkit:level10` skill MUST use L10-specific routes (`/l10/todos`, `/l10/done`, `/l10/issues`, `/l10/parked`) for all PUT operations instead of generic routes.
- **FR-007**: The `rkit:weekly` skill MUST use L10 routes for done and parked columns when the team framework is EOS.
- **FR-008**: All new flows MUST follow existing confirmation, error handling, and display patterns established in the current skills.

### Key Entities

- **L10 Board Sections**: todos (next), done, issues (blocked), parked, headlines — five sections total for a complete L10 view.
- **Item**: The core entity moved between sections. Key fields: id, name, creator, due, status, on_weekly.
- **Headline**: Team-level announcement. Key fields: id, text, creator, expires_at.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view all five L10 board sections (to-dos, done, issues, parked, headlines) from a single `/rkit:level10` invocation.
- **SC-002**: Users can park items and remove items from the L10 board without switching to `/rkit:weekly`.
- **SC-003**: All L10 skill operations use L10-specific API routes consistently.
- **SC-004**: The weekly skill uses L10 routes for all four columns on EOS teams.
- **SC-005**: No existing functionality is broken — all current flows (create todo, create issue, create headline, mark done, move, archive/update headline) continue to work identically.

## Assumptions

- The L10 PUT routes (`/l10/todos/{id}`, `/l10/done/{id}`, `/l10/issues/{id}`, `/l10/parked/{id}`) are functionally identical to their generic counterparts — they are aliases.
- The `DELETE /teams/{id}/l10/items/{item_id}` route is an alias for `DELETE /teams/{id}/items/{item_id}`.
- Headlines and 1on1 skills already fully cover their respective endpoints and do not need changes.
- The meeting endpoints listed in the input are already fully covered by the `rkit:1on1` skill.
- The `level10-workspace` directory is a WIP and is out of scope for this spec.

## Scope Boundary

**In scope**: `rkit:level10` and `rkit:weekly` skill updates only.

**Out of scope**: `rkit:headlines` (already complete), `rkit:1on1` (already complete), `rkit:board`, `rkit:today`, `rkit:result-feed`, `rkit:setup`, `rkit:teams`, `rkit:projects`, `level10-workspace` (WIP).
