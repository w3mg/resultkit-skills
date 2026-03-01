# Feature Specification: Bulk Move Items

**Feature Branch**: `023-bulk-move-items`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #14: [API Change] API Change Handoff: Bulk Move Items

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bulk Move Items Under a Parent (Priority: P1)

A user wants to reorganize their item hierarchy by moving multiple items under a single target parent in one operation. They provide a list of item IDs and a destination parent ID, confirm the action, and receive a summary of how many items were moved successfully and which (if any) failed.

**Why this priority**: This is the core and only user-facing action. Without it, users must move items one at a time, which is impractical for large reorganizations.

**Independent Test**: Run the bulk-move command with a list of item IDs and a parent ID. Verify confirmation prompt shows the planned operation, and the result displays moved/failed counts with per-item error details.

**Acceptance Scenarios**:

1. **Given** a user with several items, **When** they bulk-move items 1, 2, 3 under parent 100, **Then** they are asked to confirm, and on success they see "Moved 3 items under #100. 0 failed."
2. **Given** a mix of accessible and inaccessible items, **When** they bulk-move, **Then** the result shows partial success: "Moved 2 items under #100. 1 failed." with a table listing each failed item and its reason.
3. **Given** no item IDs provided, **When** they invoke bulk-move, **Then** they see a usage message explaining the required arguments.

---

### User Story 2 - Update API Reference (Priority: P2)

The api-reference.md is updated to document the new `PATCH /items/bulk-move` endpoint so other skills and developers can discover it.

**Why this priority**: Documentation completeness. The endpoint should be discoverable in the API reference.

**Independent Test**: Read api-reference.md and verify the bulk-move endpoint is documented with correct params, response format, and user phrases.

**Acceptance Scenarios**:

1. **Given** the api-reference.md, **When** a developer reads the Items section, **Then** they find `PATCH /items/bulk-move` documented with body params (`item_ids`, `parent_id`), response shape (`moved`, `failed`, `errors`), and user phrases.

---

### Edge Cases

- What happens when no item IDs are provided? Show usage message with required arguments.
- What happens when the target parent doesn't exist? Show "Parent item not found (404)."
- What happens when the user doesn't have access to the target parent? Show "Access denied to parent item (403)."
- What happens when an item in the list can't be found? The item appears in the errors list with reason "not_found"; other items still move.
- What happens when an item in the list can't be edited by the user? The item appears in the errors list with reason "forbidden"; other items still move.
- What happens when the target parent is in the item list? That item is rejected with reason "self_reference"; other items still move.
- What happens when all items fail? Show "Moved 0 items under #100. 5 failed." with the full error table.
- What happens when items are already under the target parent? They are silently counted as moved (no-op).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to move multiple items under a target parent in a single command invocation.
- **FR-002**: The skill MUST confirm the bulk-move action before executing (write operation).
- **FR-003**: The skill MUST display the count of successfully moved items and failed items after execution.
- **FR-004**: When items fail individually, the skill MUST display a table listing each failed item ID and its failure reason.
- **FR-005**: The skill MUST handle all standard error responses (401, 403, 404, 422) with clear messages.
- **FR-006**: The api-reference.md MUST be updated with the new bulk-move endpoint, including body params, response shape, error responses, and user phrases.
- **FR-007**: The skill MUST warn the user that moved items are removed from all weekly boards.

### Key Entities

- **Bulk Move Request**: A list of item IDs and a target parent ID. No persistent entity — fire-and-forget.
- **Bulk Move Result**: A summary with moved count, failed count, and per-item error details (ID + reason).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can move up to 1000 items under a target parent in a single command invocation with one confirmation.
- **SC-002**: Partial failures are clearly reported with per-item error details so users know which items need attention.
- **SC-003**: The bulk-move endpoint is documented in api-reference.md with correct params and user phrases.

## Assumptions

- The `PATCH /items/bulk-move` endpoint is already live in the API.
- The bulk-move operation is added as a new flow to the existing `rkit:board` skill, since it already handles item hierarchy operations (view, move, add, remove).
- The confirmation prompt warns that moved items will be removed from all weekly boards.
- Per-item error reasons are displayed as-is from the API response: `not_found`, `forbidden`, `self_reference`.
- No framework-specific terminology mapping is needed for this command — it operates on item IDs directly.
