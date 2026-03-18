# Feature Specification: Goals, Rocks & Milestones API Migration

**Feature Branch**: `038-goals-rocks-api-40`
**Created**: 2026-03-18
**Status**: Draft
**Input**: GitHub Issue #40 — API Change Handoff: Goals, Rocks & Milestones API (EOS)

## Clarifications

### Session 2026-03-18

- Q: Are entity field names `goal_type` and `progress_color` correct? → A: No. Curl testing confirmed: `goal_type` → `type` (values: `"yearly_goal"`, `"rock"`, `"milestone"`), `progress_color` → `color`. Milestones do NOT include `updated_at`.
- Q: Does an MCP tool exist for the renamed `GET /teams/{id}/targets` read endpoint? → A: No. There is no MCP tool for the read-only targets endpoint. The old `get_team_strategy` tool was removed, not renamed.
- Q: Are milestone year/quarter filters reliable? → A: Known bug — `GET /teams/:id/milestones?year=&quarter=` returns incorrect results. Workaround: use `parent_id` filter instead.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update API Reference for New Endpoints (Priority: P1)

As a skill maintainer, I need the master `api-reference.md` to accurately document the 14 new goals/rocks/milestones endpoints and reflect the removal of the 7 old strategy mutation endpoints, so all skills have correct API documentation.

**Why this priority**: The API reference is the single source of truth for all skills. Every other change depends on this being correct first.

**Independent Test**: Can be verified by reading api-reference.md and confirming it lists all 14 new endpoints (goals: GET/POST list+create, PATCH/DELETE by id; rocks: GET/POST list+create, PUT align, PATCH/DELETE by id; milestones: GET/POST list+create, PUT align, PATCH/DELETE by id), the renamed `GET /teams/{id}/targets` endpoint, and none of the 7 removed strategy mutation endpoints.

**Acceptance Scenarios**:

1. **Given** the current api-reference.md documents `GET /teams/{id}/strategy`, **When** the migration is complete, **Then** that endpoint is renamed to `GET /teams/{id}/targets`
2. **Given** the current api-reference.md documents 7 strategy mutation endpoints, **When** the migration is complete, **Then** none of these endpoints appear in the reference
3. **Given** the API now has 14 new endpoints for goals, rocks, and milestones, **When** the migration is complete, **Then** all 14 endpoints are documented with correct paths, methods, query parameters, request bodies, and response shapes
4. **Given** the new endpoints are EOS-only, **When** the migration is complete, **Then** the documentation notes that these endpoints return 422 for non-EOS teams

---

### User Story 2 - Update Strategy Skill to Use New Endpoints (Priority: P1)

As a user running `/rkit:strategy`, I need the skill to call the new typed endpoints (goals, rocks, milestones) instead of the removed generic strategy mutation endpoints, so that create, update, align, and delete operations continue to work.

**Why this priority**: The strategy skill will be completely broken if it still calls the removed endpoints. This is equally critical as the API reference update.

**Independent Test**: Can be tested by running each strategy operation (view, create goal, create rock, create milestone, update, align, delete) and confirming they succeed against the live API.

**Acceptance Scenarios**:

1. **Given** a user runs `/rkit:strategy` to view the strategy tree, **When** the skill fetches data, **Then** it calls `GET /teams/{id}/targets` (not `/strategy`)
2. **Given** a user creates a yearly goal, **When** the skill processes the request, **Then** it calls `POST /teams/{id}/goals` with `name`, `achieve_by`, and optional `assignee_ids`
3. **Given** a user creates a quarterly rock, **When** the skill processes the request, **Then** it calls `POST /teams/{id}/rocks` with `name`, optional `parent_id`, and optional quarter/year
4. **Given** a user creates a milestone, **When** the skill processes the request, **Then** it calls `POST /teams/{id}/milestones` with `name`, `parent_id`, and optional `due`
5. **Given** a user aligns a rock to a goal, **When** the skill processes the request, **Then** it calls `PUT /rocks/{id}` with `{ "parent_id": <goal_id> }` (not `PUT /strategy/align`)
6. **Given** a user aligns a milestone to a rock, **When** the skill processes the request, **Then** it calls `PUT /milestones/{id}` with `{ "parent_id": <rock_id> }`
7. **Given** a user updates a goal/rock/milestone, **When** the skill processes the request, **Then** it calls `PATCH /goals/{id}`, `PATCH /rocks/{id}`, or `PATCH /milestones/{id}` respectively
8. **Given** a user deletes (archives) a goal/rock/milestone, **When** the skill processes the request, **Then** it calls `DELETE /goals/{id}`, `DELETE /rocks/{id}`, or `DELETE /milestones/{id}` respectively

---

### User Story 3 - Sync Updated References to All Skills (Priority: P2)

As a plugin maintainer, I need the updated api-reference.md synced to all skill directories so every skill has current documentation.

**Why this priority**: Important for consistency but lower than the functional changes since skills reference the master copy at build time.

**Independent Test**: After running `/sync-plugin`, verify that every `skills/*/references/api-reference.md` matches the master `api-reference.md`.

**Acceptance Scenarios**:

1. **Given** the master api-reference.md has been updated, **When** `/sync-plugin` is run, **Then** all copies under `skills/*/references/` are identical to the master
2. **Given** the plugin version is at X.Y.Z, **When** the sync is complete, **Then** the plugin version has been bumped

---

### User Story 4 - Update User Phrase Mappings (Priority: P2)

As a user giving natural-language commands about goals, rocks, and milestones, I need the API reference phrase mappings updated so the strategy skill can correctly interpret my requests.

**Why this priority**: Natural language interpretation relies on phrase mappings. Without updates, users saying "create a rock" or "add a milestone" may not be routed correctly.

**Independent Test**: Search api-reference.md for phrase/synonym entries and confirm they cover goals, rocks, and milestones terminology.

**Acceptance Scenarios**:

1. **Given** a user says "create a yearly goal", **When** the skill interprets the request, **Then** it matches to the `POST /teams/{id}/goals` endpoint
2. **Given** a user says "add a rock" or "create a quarterly rock", **When** the skill interprets the request, **Then** it matches to the `POST /teams/{id}/rocks` endpoint
3. **Given** a user says "add a milestone", **When** the skill interprets the request, **Then** it matches to the `POST /teams/{id}/milestones` endpoint
4. **Given** a user says "align rock to goal" or "link rock to goal", **When** the skill interprets the request, **Then** it matches to `PUT /rocks/{id}`

---

### Edge Cases

- What happens when a user runs a strategy mutation against a non-EOS team? The skill should surface the 422 error message clearly: "This endpoint is only available for EOS teams."
- What happens when a user tries to align a rock without specifying a parent goal? The skill should prompt for the goal ID or show available goals.
- What happens when a user uses old terminology like "create a strategy node"? The skill should still understand the intent and route to the correct typed endpoint.
- What happens when `GET /teams/{id}/targets` returns a different response shape than the old `GET /teams/{id}/strategy`? The skill's display logic must handle the new shape.
- What happens when a user lists milestones filtered by year/quarter? Known bug: the V2 API returns incorrect results for `?year=&quarter=` filters. The skill MUST use `?parent_id=ROCK_ID` filter as the workaround, which returns correct results.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST rename the documented strategy read endpoint from `GET /teams/{id}/strategy` to `GET /teams/{id}/targets` in api-reference.md
- **FR-002**: System MUST remove all 7 strategy mutation endpoints from api-reference.md
- **FR-003**: System MUST add all 14 new endpoints to api-reference.md with correct paths, methods, query parameters, request/response shapes, and status codes
- **FR-004**: System MUST update the strategy skill to call `GET /teams/{id}/targets` for tree retrieval
- **FR-005**: System MUST update the strategy skill to use `POST /teams/{id}/goals`, `POST /teams/{id}/rocks`, `POST /teams/{id}/milestones` for creation instead of `POST /teams/{id}/strategy`
- **FR-006**: System MUST update the strategy skill to use `PUT /rocks/{id}` and `PUT /milestones/{id}` for alignment instead of `PUT /strategy/align`
- **FR-007**: System MUST update the strategy skill to use `PATCH /goals/{id}`, `PATCH /rocks/{id}`, `PATCH /milestones/{id}` for updates instead of `PATCH /strategy/{objectType}/{objectId}`
- **FR-008**: System MUST update the strategy skill to use `DELETE /goals/{id}`, `DELETE /rocks/{id}`, `DELETE /milestones/{id}` for archival instead of `DELETE /strategy/{objectType}/{objectId}`
- **FR-009**: System MUST document the EOS-only restriction (422 response) for all new endpoints
- **FR-010**: System MUST update user phrase mappings in api-reference.md to cover goals, rocks, and milestones terminology
- **FR-011**: System MUST sync the updated api-reference.md to all skill directories via `/sync-plugin`
- **FR-012**: System MUST remove any references to the `get_team_strategy` MCP tool from documentation (no replacement MCP tool exists for the read-only targets endpoint)
- **FR-013**: System MUST use `parent_id` filter (not year/quarter) when listing milestones in the strategy skill, due to a known API bug with year/quarter milestone filtering

### Key Entities

- **Goal**: A yearly objective for an EOS team. Key attributes: name, description, status, type (`"yearly_goal"`), achieve_by, color, is_visible_to_team, assignees, creator, created_at, updated_at
- **Rock**: A quarterly priority aligned to a yearly goal. Key attributes: name, description, status, type (`"rock"`), achieve_by, color, is_visible_to_team, parent_id (goal), persist_until_cleared, assignees, creator, created_at, updated_at
- **Milestone**: A specific deliverable aligned to a rock. Key attributes: name, description, status, type (`"milestone"`), due, color, parent_id (rock), assignees, creator, created_at (no updated_at)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 7 removed strategy mutation endpoints are absent from api-reference.md and all skill copies
- **SC-002**: All 14 new endpoints are documented in api-reference.md with correct field names (`type` not `goal_type`, `color` not `progress_color`) matching curl-verified response shapes
- **SC-003**: The strategy skill successfully creates goals, rocks, and milestones using the new typed endpoints
- **SC-004**: The strategy skill successfully aligns rocks to goals and milestones to rocks using the new PUT endpoints
- **SC-005**: The strategy skill successfully retrieves the strategy tree using `GET /teams/{id}/targets`
- **SC-006**: Users receive a clear error message when attempting strategy operations on non-EOS teams
- **SC-007**: All `skills/*/references/api-reference.md` copies match the master after sync

## Assumptions

- The `GET /teams/{id}/targets` response shape is identical or compatible with the old `GET /teams/{id}/strategy` response, since the handoff only mentions a rename, not a schema change.
- The strategy skill's display/tree-rendering logic does not need changes beyond the endpoint URLs, since the read endpoint was only renamed.
- DELETE operations now archive directly (no more `also_archive` flag). To unlink without archiving, use PATCH to set `parent_id: null`. The old single-endpoint approach (`DELETE /strategy/{type}/{id}` with `also_archive` boolean) is replaced by two methods: PATCH (unlink) and DELETE (archive).
- The `skills/profile/SKILL.md` progress metrics (`strategy.rocks_realized_all_time`, etc.) are unaffected since they come from a different endpoint.
