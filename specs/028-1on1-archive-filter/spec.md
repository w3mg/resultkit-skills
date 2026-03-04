# Feature Specification: 1on1 Skill — Filter Archived Items from Output

**Feature Branch**: `028-1on1-archive-filter`
**Created**: 2026-03-04
**Status**: Complete
**Input**: GitHub Issue #18 — 1on1: skill output doesn't match website view

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View One-on-One Without Stale Archived Items (Priority: P1)

A user viewing a 1:1 meeting detail sees only active items in the Next, Done, and Blocked columns — matching what they see on the ResultMaps website — rather than a cluttered list that includes old archived items.

**Why this priority**: This is the core bug. The skill is unusable for 1:1s with long histories because archived items dominate the output (62 items shown vs. the handful that are actually relevant). Everything else depends on this fix.

**Independent Test**: Run `/rkit:1on1 14` and verify the item count in each column matches the website view. No items with archived status should appear in the output.

**Acceptance Scenarios**:

1. **Given** a 1:1 meeting with a mix of active and archived items in the Next column, **When** the user views the meeting detail, **Then** only non-archived items are shown in each column.
2. **Given** all items in a column are archived, **When** the user views the meeting detail, **Then** that column shows "(empty)" rather than a list of archived items.
3. **Given** a 1:1 meeting with no archived items at all, **When** the user views the meeting detail, **Then** the output is identical to the current behavior.

---

### User Story 2 - View Single Column Without Archived Items (Priority: P2)

A user viewing a single column of a 1:1 (e.g., `/rkit:1on1 14 next`) sees only active items, consistent with the full meeting detail view and the website.

**Why this priority**: The single-column view has the same underlying problem. A user who narrows to "next" to reduce noise still sees all archived items, defeating the purpose of the focused view.

**Independent Test**: Run `/rkit:1on1 14 next` and verify item count and content matches the Next section from the website and from the full detail view.

**Acceptance Scenarios**:

1. **Given** a 1:1 column that contains archived items, **When** the user views that single column, **Then** only non-archived items are displayed.
2. **Given** a 1:1 column where all items are archived, **When** the user views that column, **Then** "(empty)" is shown.

---

### Edge Cases

- A 1:1 where every item in every column is archived — all three columns show "(empty)".
- A 1:1 with zero items (already empty before filtering) — behavior unchanged, still shows "(empty)".
- An item returned by the API with a null or missing `status` field — treat as active; do not filter it out.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST exclude items with `status: "archived"` from the Next, Done, and Blocked columns in the View One-on-One Detail flow.
- **FR-002**: The skill MUST ensure items with `status: "archived"` do not appear in the View Single Column flow. (The `GET /meetings/{id}/items/{section}` endpoint excludes archived items by API default; no client-side filtering is needed for this flow.)
- **FR-003**: The skill MUST display "(empty)" for any column that contains zero non-archived items, rather than populating it with archived items.
- **FR-004**: The skill MUST NOT filter out items with any status other than `"archived"` (active statuses such as `next`, `done`, `blocked`, `not_started`, `parked`, `draft` must always be shown).
- **FR-005**: The skill MUST preserve all existing display rules — column item count in the header, and per-item ID, name, creator, and due date — for non-archived items.

### Key Entities

- **Meeting Item**: An item belonging to a 1:1 meeting column. Has a `status` field (`"next"`, `"done"`, `"blocked"`, `"archived"`, etc.). Items with `status: "archived"` are hidden from all output.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The item count shown in the Next column for meeting #14 via `/rkit:1on1 14` matches the count on the ResultMaps website (zero archived items included).
- **SC-002**: The Next column output from `/rkit:1on1 14` (full detail) and `/rkit:1on1 14 next` (single column) show identical item sets — no discrepancy between the two views.
- **SC-003**: A 1:1 where all items are archived renders all three columns as "(empty)" — no items are surfaced.

## Assumptions

- The API returns a `status` field on every item in the meeting columns. The fix filters client-side by excluding items where `status == "archived"`.
- If the meeting items endpoints support an `include_archived=false` query parameter, using it server-side is preferred and produces the same user-visible result.
- The website's definition of "active" items is equivalent to "not archived" — no other status values are hidden on the website side.
- This fix applies to both the View Detail flow and the View Single Column flow. Other flows (move, add, remove) are not affected.
