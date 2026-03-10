# Feature Specification: Strategy API Phase 2 Update

**Feature Branch**: `032-strategy-api-phase2-26`
**Created**: 2026-03-08
**Status**: Draft
**Input**: User description: "GitHub Issue #26: [API Change] 012 — Team Strategy API Phase 2"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Delete Strategy Object with Correct Semantics (Priority: P1)

A user asks Claude to remove (unlink) a strategy object from its parent via an rkit skill. The skill uses the updated DELETE endpoint with the required `parent_id` and `parent_type` body fields. By default the object is unlinked; if the user asks to also archive it, `also_archive: true` is added.

**Why this priority**: The DELETE behavior is a breaking change — without this fix, deleting would fail (missing required body fields) or produce unintended results.

**Independent Test**: Issue a delete strategy command via an rkit skill and confirm the API call includes `parent_id`, `parent_type` in the body and no `?action=` query param.

**Acceptance Scenarios**:

1. **Given** a user asks to remove a strategy goal from its parent, **When** the skill calls DELETE, **Then** the request body includes `parent_id` and `parent_type`, and the object is unlinked (not archived).
2. **Given** a user asks to delete and archive a strategy goal, **When** the skill calls DELETE, **Then** `also_archive: true` is included in the body.
3. **Given** a skill previously sent `?action=archive` or `?action=unlink`, **When** updated, **Then** no `?action=` query parameter is sent.

---

### User Story 2 - Create Strategy Object Without Specifying Type (Priority: P2)

A user asks Claude to add a new strategy item or goal. The skill calls POST without sending `object_type` in the body (type is inferred by the API). For OKR/4DX root-level result areas, the skill sends `is_focus_area: true`.

**Why this priority**: Sending `object_type` may now cause errors or be silently ignored; removing it ensures correctness. The `is_focus_area` field unlocks a new capability.

**Independent Test**: Issue a create strategy command and confirm the POST body omits `object_type` and (where applicable) includes `is_focus_area`.

**Acceptance Scenarios**:

1. **Given** a user asks to add a strategy item under a parent, **When** the skill calls POST, **Then** `object_type` is absent from the request body.
2. **Given** a user asks to create a top-level OKR result area, **When** the skill calls POST, **Then** `is_focus_area: true` is included in the body.

---

### User Story 3 - Align Strategy Object Using Team-less Route (Priority: P3)

A user asks Claude to align (link) a strategy object to a parent. The skill uses `PUT /api/v2/strategy/align` (team-less) without a `link_type` field, relying on server-side auto-detection.

**Why this priority**: The old `link_type` field has been removed; using team-less routes is the preferred path going forward.

**Independent Test**: Issue an align command and confirm the PUT call goes to `/api/v2/strategy/align` with `object_id`, `object_type`, `parent_id`, `parent_type` in the body — no `link_type`.

**Acceptance Scenarios**:

1. **Given** a user asks to align a goal to a parent, **When** the skill calls PUT, **Then** the request goes to `/api/v2/strategy/align` with no `link_type` field.

---

### User Story 4 - View 4DX Strategy Hierarchy (Priority: P4)

A user asks Claude to show their team strategy board. When the team uses the 4DX framework, the GET response includes a 4-level hierarchy (Focus Area > WIG > Leading Indicator > Action). The skill renders this correctly without sending `?cascade=true`.

**Why this priority**: 4DX support is additive, but incorrect `cascade` param removal is required to avoid API errors.

**Independent Test**: Fetch strategy for a 4DX team and confirm no `?cascade=` param is sent; confirm `action` node type and 4-level tree are handled gracefully.

**Acceptance Scenarios**:

1. **Given** a user fetches strategy, **When** the skill calls GET, **Then** no `?cascade=` query parameter is included.
2. **Given** the team uses 4DX framework, **When** the response includes `object_type: 'action'` nodes, **Then** the skill displays them without errors.
3. **Given** a node has `inherited: true`, **When** displayed, **Then** the skill either notes inheritance or omits edit options.

---

### Edge Cases

- What happens when a user tries to delete a strategy object without knowing its `parent_id`? The skill should surface this requirement clearly.
- How does the skill handle `object_type: 'action'` for 4DX leaf nodes if the display logic only knows `Goal` and `Item`? Graceful fallback required.
- If a team switches from EOS/OKR to 4DX, existing strategy objects may now appear in a different hierarchy depth — no skill-side fix needed, but display should not break.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skills MUST NOT send `?cascade=true` or any `cascade` parameter when calling `GET /api/v2/teams/:id/strategy`.
- **FR-002**: Skills MUST NOT include `object_type` in the body when calling `POST /api/v2/teams/:id/strategy`.
- **FR-003**: Skills MUST include `is_focus_area: true` in POST body when creating a root-level OKR or 4DX result area.
- **FR-004**: Skills MUST NOT include `link_type` in the body when calling PUT strategy alignment endpoints.
- **FR-005**: Skills MUST prefer `PUT /api/v2/strategy/align` (team-less) for aligning strategy objects. Team-scoped equivalents remain valid but are deprecated going forward.
- **FR-006**: Skills MUST include `parent_id` and `parent_type` in the body when calling DELETE strategy endpoints.
- **FR-007**: Skills MUST NOT send `?action=` query parameter on DELETE calls.
- **FR-008**: Skills MUST default to unlink (no `also_archive`) on DELETE; only include `also_archive: true` when the user explicitly requests archiving.
- **FR-009**: Skills MUST handle `object_type: 'action'` in GET responses without errors (4DX leaf nodes).
- **FR-010**: Skills MUST handle `inherited: true` on strategy nodes without errors; inherited nodes MUST display an `[inherited]` label and MUST NOT offer edit or mutate actions (create, update, delete, align) for those nodes.

### Key Entities

- **Strategy Node**: A node in the strategy tree — type is `Goal` or `Item` (EOS/OKR) or includes `action` (4DX). May carry `inherited` and `inherited_from` metadata.
- **Strategy Alignment**: The parent-child relationship between two strategy nodes. Now auto-detected server-side from `object_type`/`parent_type` pair.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All strategy-related rkit skill calls conform to the Phase 2 API contract with zero breaking-change violations.
- **SC-002**: DELETE operations default to unlink behavior; archive requires explicit user intent — no accidental data loss.
- **SC-003**: Skills handle 4DX framework responses (including `action` node type and 4-level hierarchy) without runtime errors.
- **SC-004**: No deprecated parameters (`cascade`, `object_type` in POST body, `link_type`, `?action=`) appear in any skill API call after this update.

## Assumptions

- The rkit skills do not currently expose a dedicated "strategy" skill; this update applies to any skill (e.g., `rkit:board`, `rkit:today`, or a future strategy skill) that calls strategy endpoints.
- The `PATCH /api/v2/teams/:id/strategy` endpoint is unchanged in behavior; no updates needed there beyond documentation.
- Team-less routes (`PUT /api/v2/strategy/align`, `PATCH /api/v2/strategy/{type}/{id}`, `DELETE /api/v2/strategy/{type}/{id}`) are available and preferred going forward, but the team-scoped equivalents remain valid.
- Skills do not need to render 4DX hierarchy visually differently from EOS/OKR; a flat list or simple tree is acceptable as long as no errors occur.
