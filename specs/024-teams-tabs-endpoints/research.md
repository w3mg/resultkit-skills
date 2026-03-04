# Research: Teams Tabs API Endpoints

**Branch**: `024-teams-tabs-endpoints` | **Date**: 2026-03-03

## Finding 1: Teams Skill Is the Right Home

**Decision**: Add role change and activity logs flows to `skills/teams/SKILL.md`.

**Rationale**: The teams skill already handles team listing and member listing. Role change is a member management operation (extends existing member flow). Activity logs are team-level read data. Both belong with team operations, not in a separate skill.

**Alternatives considered**:
- New standalone skill for admin operations — rejected, too narrow. Admin operations are team-scoped.
- Add to the board skill — rejected, board handles item hierarchy, not team management.

## Finding 2: Labels and Integrations Are Reference-Only

**Decision**: Document labels and integrations in api-reference.md but do NOT add skill flows.

**Rationale**: Labels are organizational metadata (color + name tags) used primarily in the web UI for filtering. Integrations are webhook configurations with URLs — managing these from the CLI has limited value vs. the web UI. Neither has a strong conversational/CLI use case that the existing skill pattern supports well.

**Alternatives considered**:
- Add CRUD flows for labels in teams skill — rejected, low CLI value, adds significant complexity for four endpoints.
- Add CRUD flows for integrations — rejected, webhook management (URLs, tokens) is better handled in web UI with proper form fields.

## Finding 3: Logo Upload Is Reference-Only

**Decision**: Document logo upload in api-reference.md only. No skill flow.

**Rationale**: Logo upload requires multipart/form-data with a file attachment. The api.sh script and Claude Code skill runtime are not optimized for binary file uploads from the CLI. This is firmly a web UI feature.

**Alternatives considered**:
- Add logo upload via curl directly — rejected, out of scope for the skill pattern and user experience.

## Finding 4: Role Change Needs Confirmation

**Decision**: Role change (PATCH) requires a confirmation prompt per Constitution Principle IV.

**Rationale**: PATCH is a write operation. Demoting an admin could lock the user out of admin-only features. The confirmation must show the member's name, current role, and new role before executing.

## Finding 5: Activity Logs Are Read-Only

**Decision**: Activity logs (GET) execute without confirmation.

**Rationale**: GET requests execute immediately per Constitution Principle IV. Activity logs show past events — no state changes, no confirmation needed.

## Finding 6: Teams Skill Allowed-Tools Unchanged

**Decision**: The `allowed-tools` frontmatter in skills/teams/SKILL.md does NOT need updating.

**Rationale**: Both new flows use the same tools as existing flows: `Bash(scripts/api.sh *)`, `Bash(jq *)`, `AskUserQuestion`. The role change confirmation uses AskUserQuestion (already permitted). No new tools required.

## Finding 7: Role Change Extends Member Argument Parsing

**Decision**: Add `role {user_id} {role} [{team_id}]` and `logs [{team_id}]` as new argument patterns in the teams skill parsing table.

**Rationale**: The existing patterns are `members` and `members {team_id}`. The new patterns follow the same convention. Keeping them in the same skill maintains a coherent team management surface.
