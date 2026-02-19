# Feature Specification: Board Summary View

**Feature Branch**: `010-board-summary-view`
**Created**: 2026-02-18
**Status**: Draft
**Input**: User description: "Modify the rkit:board View Board flow so that instead of immediately fetching and displaying all items for every column, it first shows a summary of the top-level children (columns) with their name, ID, and total item count, then asks the user if they want the full breakdown for one specific column or all columns."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Board Summary (Priority: P1)

User runs `/rkit:board` and sees a quick overview of all columns with item counts before deciding whether to drill in.

**Why this priority**: This is the core change — every board view starts here now. Without it, no other story matters.

**Independent Test**: Run `/rkit:board {id}` against a board with multiple columns. Verify the summary table appears with column names, IDs, and item counts. No item-level detail should appear yet.

**Acceptance Scenarios**:

1. **Given** a board with 3 columns (Backlog: 12 items, In Progress: 5 items, Done: 0 items), **When** user runs `/rkit:board`, **Then** a summary table is displayed showing each column's name, ID, and total item count
2. **Given** a board with columns, **When** the summary is displayed, **Then** no individual item details (name, status, due) are shown yet
3. **Given** a board with more than 10 columns, **When** the summary is displayed, **Then** only the first 10 columns appear with a note indicating how many more exist

---

### User Story 2 - Drill Into One Column (Priority: P1)

After seeing the summary, user chooses to view full item details for a single column.

**Why this priority**: Equally critical — without the drill-in, the summary alone provides no actionable detail.

**Independent Test**: After the summary displays, select a single column. Verify only that column's items appear with full detail (ID, name, status, due).

**Acceptance Scenarios**:

1. **Given** the board summary is displayed, **When** user chooses to view one specific column, **Then** full item details for only that column are shown
2. **Given** the user picks a column by number from the summary, **Then** the correct column's items are displayed
3. **Given** the chosen column has no items, **Then** "(empty)" is shown

---

### User Story 3 - Drill Into All Columns (Priority: P2)

After seeing the summary, user chooses to view full item details for all columns at once.

**Why this priority**: Useful but secondary — most users will want one column at a time. This supports power users who want the full picture.

**Independent Test**: After the summary displays, select "all columns". Verify all columns' items are shown with full detail.

**Acceptance Scenarios**:

1. **Given** the board summary is displayed, **When** user chooses to view all columns, **Then** full item details for every column are shown
2. **Given** one column has more than 50 items, **Then** first 50 are shown with a note showing the total count

---

### User Story 4 - Skip Detail (Priority: P3)

After seeing the summary, user decides they have what they need and opts out of drilling in.

**Why this priority**: Nice to have — the summary alone may be sufficient for quick checks.

**Independent Test**: After the summary displays, choose "none". Verify no additional data is fetched or shown.

**Acceptance Scenarios**:

1. **Given** the board summary is displayed, **When** user chooses "none", **Then** no additional item details are fetched or displayed

---

### Edge Cases

- Board has zero columns → "No children found for item {id}."
- A column has zero items → summary shows 0 in the item count
- Board has exactly 10 columns → all shown, no overflow message
- Board has 11+ columns → first 10 shown, overflow note displayed
- Column with >50 items → count in summary reflects true total; detail view shows first 50 with overflow note

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: View Board flow MUST first display a summary table of top-level children (columns) showing each column's name, ID, and total item count
- **FR-002**: Summary MUST NOT display individual item details (name, status, due date)
- **FR-003**: After displaying the summary, the system MUST ask the user whether they want to view details for one column, all columns, or none
- **FR-004**: When user selects one column, the system MUST display full item details for only that column (ID, name, status, due)
- **FR-005**: When user selects all columns, the system MUST display full item details for every column
- **FR-006**: When user selects none, the system MUST end the flow without fetching item details
- **FR-007**: The summary MUST respect the existing 10-column cap and overflow messaging
- **FR-008**: Detail views MUST respect existing per_page=50 pagination and overflow messaging
- **FR-009**: This change applies only to the View Board flow; View Single Column, Move, Add, and Remove flows remain unchanged

### Key Entities

- **Board**: The root item whose children form columns
- **Column**: A direct child of the board item; displayed in the summary with its name, ID, and child count
- **Item**: A child of a column; displayed in detail view with ID, name, status, due date

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users see the board summary (column names, IDs, item counts) before any item-level detail loads
- **SC-002**: Users can choose to view one column, all columns, or none after seeing the summary
- **SC-003**: Selecting a single column displays only that column's items, not all columns
- **SC-004**: All existing board flows (single column view, move, add, remove) continue working without change
