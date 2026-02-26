# Feature Specification: Add rkit:result-feed Skill

**Feature Branch**: `014-result-feed-skill`
**Created**: 2026-02-26
**Status**: Draft
**Input**: User description: "Add rkit:result-feed skill for daily result feed (90-second practice) management"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Today's Check-In (Priority: P1)

A user invokes `/rkit:result-feed` with no arguments to see their current daily check-in report. The skill fetches today's result feed and displays three sections — Done, Next, and Issues — each listing items with their IDs and names. If no check-in exists for today, the API auto-creates an empty one.

**Why this priority**: Viewing the current check-in is the most fundamental operation — every other action (adding items, submitting) depends on the user first seeing where they stand.

**Independent Test**: Can be fully tested by invoking the skill with no arguments and verifying it displays a structured report with Done/Next/Issues sections, item counts, and completion status.

**Acceptance Scenarios**:

1. **Given** a user with a configured rkit setup, **When** they run `/rkit:result-feed`, **Then** the skill displays today's check-in with Done, Next, and Issues sections, each showing item IDs and names, plus a completion status indicator.
2. **Given** a user who has not started a check-in today, **When** they run `/rkit:result-feed`, **Then** the skill displays an empty check-in with zero items in each section and a hint on how to add items.
3. **Given** a user who specifies a date (e.g., "yesterday" or "2026-02-25"), **When** they run `/rkit:result-feed`, **Then** the skill displays the check-in for that date.

---

### User Story 2 - Add Items to Check-In Sections (Priority: P1)

A user adds items to their daily check-in. They can create a brand-new task and place it in a section (Done, Next, or Issues), or attach an existing item by ID to a section. Adding an item triggers the appropriate status side-effect on the item itself.

**Why this priority**: Building the check-in by populating sections is the core workflow — without it, the check-in is empty and cannot be submitted.

**Independent Test**: Can be tested by creating a new item in a section and verifying it appears in the check-in, and by attaching an existing item ID and verifying it appears.

**Acceptance Scenarios**:

1. **Given** a user viewing today's check-in, **When** they add a new item with a name to the "done" section, **Then** a new Task is created, added to the Done section, and the updated check-in is displayed.
2. **Given** a user with an existing item (ID 415), **When** they attach it to the "next" section, **Then** the item appears in the Next section of today's check-in.
3. **Given** a user who adds an item to "issues", **When** the operation completes, **Then** the item is added to the Issues section.
4. **Given** a user who tries to add an item they cannot view, **When** the API responds with 404, **Then** the skill displays an appropriate error.

---

### User Story 3 - Submit Check-In (Priority: P2)

A user finalizes their daily check-in by submitting it. Submission requires at least one item in both the Done and Next sections. Submit always shares with the user's default team — the confirmation message displays which team will receive the check-in. The user can specify a different team to override the default.

**Why this priority**: Submission is the culmination of the check-in workflow — it finalizes the report and optionally makes it visible to the team.

**Independent Test**: Can be tested by submitting a check-in that has items in Done and Next, verifying the completion status changes, and confirming the default team is shown in the confirmation message.

**Acceptance Scenarios**:

1. **Given** a check-in with items in both Done and Next, **When** the user submits it, **Then** the confirmation message displays the default team name, and upon confirmation the check-in is marked as completed, shared with that team, and the updated report is displayed.
2. **Given** a check-in missing items in the Done or Next section, **When** the user tries to submit, **Then** the skill displays a validation error explaining which sections need items.
3. **Given** a user who specifies a different team, **When** they submit with that team ID, **Then** the check-in is submitted and shared with the specified team instead of the default.
4. **Given** an already-submitted check-in, **When** the user submits again, **Then** the operation is idempotent and returns the already-completed report without error.
5. **Given** a user with no default_team_id configured, **When** they submit, **Then** the skill prompts them to specify a team.

---

### User Story 4 - Remove Items from Check-In (Priority: P2)

A user removes an item from a check-in section. The item itself is not deleted and its status is not reverted — it is simply detached from that section of the report.

**Why this priority**: Users need the ability to correct mistakes or reorganize their check-in before submitting.

**Independent Test**: Can be tested by removing an item from a section and verifying it no longer appears in the check-in, while confirming the item still exists.

**Acceptance Scenarios**:

1. **Given** a check-in with item 415 in the Done section, **When** the user removes item 415 from Done, **Then** item 415 no longer appears in the Done section.
2. **Given** a user tries to remove an item that is not in the specified section, **When** the API returns 404, **Then** the skill displays "Item not found in that section."

---

### User Story 5 - View Team Check-Ins (Priority: P3)

A user views completed check-ins shared by their team members. The skill fetches the team's result feed — a paginated list of submitted and shared check-ins in reverse date order, each showing the team member's name and their full Done/Next/Issues items in ItemSimple format (ID + name).

**Why this priority**: Team visibility is a valuable feature but depends on individual check-ins being built and submitted first.

**Independent Test**: Can be tested by invoking the team view and verifying a list of team members' check-ins is displayed with user names, dates, and all items per section showing ID and name.

**Acceptance Scenarios**:

1. **Given** a user who is a member of a team, **When** they request the team's check-ins, **Then** a list of completed, shared check-ins is displayed with each member's name, date, and all items per section in ItemSimple format (ID + name).
2. **Given** a user who is not a member of a team, **When** they request that team's check-ins, **Then** a "Team not found" error is displayed.
3. **Given** a team with many check-ins, **When** the user views the list, **Then** results are paginated and the user can see page info.

---

### Edge Cases

- What happens when the user has no rkit config? Skill displays "Config not found. Run `/rkit:setup` first."
- What happens when the api.sh script is not found? Skill displays install instructions.
- What happens when the API returns 401 Unauthorized? Skill displays "Unauthorized. Run `/rkit:setup` to update your token."
- What happens when the user provides an invalid date format? Skill displays "Invalid date format. Use YYYY-MM-DD."
- What happens when adding an item that is already in the section? Operation is idempotent — API returns 200, item remains in section.
- What happens when the user provides an invalid section name? Skill displays an error. Valid sections are: done, next, issues.
- What happens when submitting with a team_id the user doesn't belong to? API returns 404, skill displays "Team not found."
- What happens when submitting with no default_team_id configured? Skill prompts the user to specify a team before proceeding.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST display the user's result feed for today (or a specified date), showing Done, Next, and Issues sections with item IDs, names, and a completion status indicator.
- **FR-002**: Skill MUST allow creating a new task item and adding it to a specified section (done, next, or issues) of the check-in.
- **FR-003**: Skill MUST allow attaching an existing item (by ID) to a specified section of the check-in.
- **FR-004**: Skill MUST allow removing an item from a specified section without deleting the item or reverting its status.
- **FR-005**: Skill MUST allow submitting (finalizing) the check-in, which requires at least one item in both Done and Next sections.
- **FR-006**: Skill MUST always share the check-in with a team during submission. The default team is read from `default_team_id` in config. The confirmation message MUST display which team the check-in will be shared with. The user can specify a different team to override the default. If no default team is configured, the skill MUST prompt for a team.
- **FR-007**: Skill MUST display team members' completed and shared check-ins in reverse date order, paginated, showing all items per section in ItemSimple format (ID + name).
- **FR-008**: Skill MUST use the URL section names "done", "next", and "issues" — never "blocked" in API calls.
- **FR-009**: Skill MUST confirm all write operations (POST, PUT, DELETE) before executing them.
- **FR-010**: Skill MUST resolve natural-language dates ("today", "tomorrow", "yesterday", "Monday", "2026-02-25") to YYYY-MM-DD format or the literal "today".
- **FR-011**: Skill MUST display item IDs in all output so users can reference them in follow-up commands.
- **FR-012**: The api-reference.md MUST be updated with Result Feeds endpoint documentation before the skill is built.
- **FR-013**: Skill MUST follow existing rkit skill patterns: SKILL.md frontmatter, Current State block, Tool Routing Table, flow-based execution, standard error handling.

### Key Entities

- **Result Feed (Check-In)**: A daily report containing three sections (Done, Next, Issues), each holding a list of items. Has a date, completion status, and optional team sharing. One per user per day.
- **Section**: One of three categories within a check-in — Done (completed work), Next (upcoming work), Issues (blocked items). URL names: "done", "next", "issues".
- **Item**: A task or action item that can be placed in a check-in section. Has an ID, name, status, and other metadata. Items exist independently of check-ins.
- **Team Result Feed**: A check-in that has been submitted and shared with a team. Includes the user who created it. Visible to all team members.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their daily check-in status in a single command invocation with no additional prompts.
- **SC-002**: Users can add a new item to any check-in section in two steps or fewer (command + confirmation).
- **SC-003**: Users can complete the full check-in workflow (view, add items, submit) without leaving the CLI.
- **SC-004**: Team check-ins are viewable with member names and full item details (ID + name) per section, enabling daily standup preparation in under 30 seconds.
- **SC-005**: All six API endpoints (view, create item, attach item, remove item, submit, team view) are accessible through intuitive natural-language trigger phrases.
- **SC-006**: The skill correctly handles all error states (no config, unauthorized, invalid date, validation errors) with actionable user messages.

## Clarifications

### Session 2026-02-26

- Q: When submitting, should the skill prompt for team sharing, auto-share, or only share when explicitly requested? → A: Submit always shares with the default team from config. The confirmation message displays which team the check-in will be shared with. The user can specify a different team to override the default.
- Q: How much detail should team view show for each member's check-in? → A: Show all report items in ItemSimple mode (ID + name) for every section of every member's check-in. Full detail, not counts.

## Assumptions

- The ResultMaps V2 API result-feed endpoints are functional and match the documented OpenAPI spec at `~/projects/resultmaps-api2/openapi/openapi-v2.yaml`, even though they have not yet been deployed to the production Vercel environment.
- The skill will follow the same plugin distribution pattern as existing rkit skills (SKILL.md + scripts/api.sh + references/api-reference.md).
- The "today" date literal is resolved server-side based on the user's timezone setting, so the skill does not need to compute the user's local date.
- Team sharing during submission uses the same submit endpoint with optional body parameters, not a separate share endpoint.
- The default team for team check-in viewing will be read from `default_team_id` in the user's rkit config, with a prompt if not configured.
