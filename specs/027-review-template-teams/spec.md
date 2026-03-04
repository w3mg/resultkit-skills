# Feature Specification: Review Template Team Ownership & Sharing

**Feature Branch**: `027-review-template-teams`
**Created**: 2026-03-04
**Status**: Complete
**Input**: GitHub Issue #17 — API Change 008: Review Template Team Ownership & Sharing

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Templates with Team Context (Priority: P1)

A team admin browsing available review templates can see which team owns each template, helping them understand visibility and editability at a glance.

**Why this priority**: This is the baseline — every template interaction now involves team context. Reading templates correctly is prerequisite to all other flows.

**Independent Test**: Run the review create flow and select a template — each listed template shows its owning team name (or a dash if null).

**Acceptance Scenarios**:

1. **Given** a user runs a template list action, **When** the API returns templates, **Then** each template row shows `owning_team.name` (e.g., "Engineering") or "—" if `owning_team` is null.
2. **Given** `owning_team` is null on a template, **When** the skill displays it, **Then** no error occurs and the field is shown as "—".

---

### User Story 2 - Create Template with Owning Team (Priority: P2)

A team admin creating a new review template can specify which team owns the template, or omit it to default to their current team context.

**Why this priority**: Without this, admins cannot properly assign ownership when creating templates, breaking the team-scoping model.

**Independent Test**: Create a new template specifying a team ID — the API call includes `owning_team_id` and the response shows the correct owning team.

**Acceptance Scenarios**:

1. **Given** the user creates a template with a team ID, **When** the skill sends the POST, **Then** the request body includes `owning_team_id` and the response shows `owning_team: { id, name }`.
2. **Given** the user creates a template without specifying a team, **When** the skill sends the POST, **Then** `owning_team_id` is omitted and the API applies the default.
3. **Given** a 403 response (user not admin on owning team), **When** creating a template, **Then** the skill shows "Admin on the owning team required."

---

### User Story 3 - Update Template Team Sharing (Priority: P3)

A team admin editing a review template can manage which other teams the template is shared with, using a replace-all model (full list sent each time).

**Why this priority**: Sharing is additive functionality; templates still work without it, but admins need it to control cross-team visibility.

**Independent Test**: Update a template with a list of shared team IDs — the API response shows `shared_with_teams` containing those teams.

**Acceptance Scenarios**:

1. **Given** the user provides team IDs to share with, **When** the skill sends the PATCH, **Then** the request body includes `shared_with_team_ids` array.
2. **Given** the user passes an empty list for sharing, **When** the skill sends the PATCH, **Then** `shared_with_team_ids: []` is sent to remove all sharing.
3. **Given** the user tries to change `owning_team_id` on PATCH, **When** the API returns a 400 error, **Then** the skill displays "Cannot change owning team after creation."
4. **Given** a successful PATCH response, **When** rendered, **Then** both `owning_team` and `shared_with_teams` are shown.

---

### Edge Cases

- `owning_team` is null for legacy templates — display gracefully, no crash.
- `shared_with_teams` may be an empty array — display "None" or "—".
- User sends `owning_team_id` on PATCH — catch the 400 and show the API's error message.
- Non-admin user attempts create/update/delete — catch 403 with a clear permissions message.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST display `owning_team.name` (or "—" for null) in all review template list outputs.
- **FR-002**: The skill MUST include `owning_team_id` in POST `/review-templates` requests when the user provides a team ID.
- **FR-003**: The skill MUST include `shared_with_team_ids` in PATCH `/review-templates/:id` requests when the user provides sharing targets (including empty array to clear all sharing).
- **FR-004**: The skill MUST display `owning_team` and `shared_with_teams` in template detail responses (GET detail, POST, and PATCH responses).
- **FR-005**: The skill MUST handle a 400 response to PATCH containing `owning_team_id` with the user-readable message "Cannot change owning team after creation."
- **FR-006**: The skill MUST update `api-reference.md` to document the new fields and behavior changes for all four review template endpoints (GET, POST, PATCH, DELETE).
- **FR-007**: The skill MUST handle 403 on create/update/delete with a message indicating admin-on-owning-team permission is required.

### Key Entities

- **Review Template**: Has an optional `owning_team: { id, name }` (null for legacy templates). Visibility is team-scoped for non-admins.
- **Shared Teams**: A template may have `shared_with_teams: [{ id, name }, ...]` representing teams that can see and use the template. Replace-all semantics on update.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All review template list outputs correctly show the owning team name or a null-safe placeholder without errors.
- **SC-002**: Creating a template with an explicit `owning_team_id` succeeds and returns the owning team in the response.
- **SC-003**: Patching shared teams with a full list replaces the sharing list as expected by the API.
- **SC-004**: Attempting to change `owning_team_id` via PATCH displays a clear, user-readable error rather than a raw API response.
- **SC-005**: The `api-reference.md` accurately documents all new fields and behavior changes so future skill updates reference it correctly.

## Assumptions

- The `rkit:reviews` skill is the primary skill handling review templates via `/review-templates` endpoints.
- Template selection currently occurs in the review create flow; any admin template management commands are also in that skill.
- `owning_team_id` on POST is optional; the skill only sends it when the user explicitly specifies a team.
- The replace-all semantics for `shared_with_team_ids` are surfaced to the user when prompting for sharing updates.
- Account admins see all templates regardless of team scope — no skill-side filtering needed.
