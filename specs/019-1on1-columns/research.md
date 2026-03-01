# Research: 1:1 Columns

## R1: Meetings API Team Filtering

**Decision**: The `GET /meetings` endpoint supports filtering by team ID. Use this to scope the 1:1 list to a specific team.

**Rationale**: The user confirmed that meetings are associated with teams and can be filtered by team ID. The original 1on1 spec (011) documented this as a known limitation with backlog item 210978 to add `team_id` filtering. That work has since been completed.

**Alternatives considered**:
- Client-side filtering by team member IDs (fetch team members, match against person1/person2) — this was the approach in the existing skill's `--team` flow. Rejected because server-side filtering is simpler and more reliable.

**Verification needed**: The exact mechanism (query param `?team_id=X` or another approach) must be verified against the live API during implementation. The api-reference.md does not yet document a `team_id` param on `GET /meetings`. Steps:
1. Call `GET /meetings?team_id=TEAM_ID` and check if it filters
2. If not, inspect meeting objects for a team field and filter client-side
3. Update api-reference.md with the finding

## R2: Existing Skill Already Implements US2

**Decision**: The existing `rkit:1on1` skill already implements the "View Columns" flow (US2). The detail view (`GET /meetings/{id}`) returns `next`, `done`, and `blocked` arrays, and the skill renders them as column tables.

**Rationale**: No changes needed to the column view. The implementation work for this feature is concentrated on US1 (team-scoped list).

**Alternatives considered**: None — the existing implementation matches the spec requirements.

## R3: Skill Modification Scope

**Decision**: This feature modifies the existing `skills/1on1/SKILL.md` file. No new skill is created.

**Rationale**: The changes are:
1. Update the "List One-on-Ones" flow to add team ID filtering (fetch team detail, then pass team_id to meetings endpoint or filter client-side)
2. Update the display to show team name in header when filtered
3. Add "no team configured" fallback hint

**Alternatives considered**:
- Creating a separate skill — rejected, this is a natural extension of the existing 1on1 skill.
