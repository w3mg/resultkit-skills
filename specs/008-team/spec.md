# Feature Specification: rkit:team

**Created**: 2026-02-14
**Status**: Draft
**Skill**: `/rkit:team`

## Overview

List user's teams and switch the default team stored in config. Many rkit skills (board, status, add) need a team context — this skill manages which team is active.

## User Scenarios

### US1 — List Teams (P1)

User wants to see all their teams.

**Flow**:
1. Read config for token
2. Call `GET /users/me` to get user ID
3. Call `GET /users/{id}/teams` to list teams
4. Display table: ID, name, framework, and mark which is the current default

**Acceptance**:
- **Given** user has 3 teams, **When** `/rkit:team` is invoked with no args, **Then** all 3 teams are displayed with the default marked
- **Given** config has `default_team_id: 5`, **When** teams are listed, **Then** team 5 shows a marker (e.g., `*` or `(default)`)

### US2 — Switch Default Team (P2)

User wants to change their default team.

**Flow**:
1. List teams (as in US1)
2. User specifies team by ID or name
3. Update `default_team_id` in config
4. Confirm the switch

**Invocation patterns**:
- `/rkit:team` → list teams
- `/rkit:team switch` or `/rkit:team set <id>` → switch default
- `/rkit:team 5` → shorthand to switch to team ID 5

**Acceptance**:
- **Given** user runs `/rkit:team set 7`, **When** team 7 exists in their teams list, **Then** config is updated and confirmation shown
- **Given** user runs `/rkit:team set 999`, **When** team 999 is not in their teams list, **Then** error shown with valid team options

### US3 — Show Current Team Detail (P3)

User wants to see details about their current default team.

**Flow**:
1. Read `default_team_id` from config
2. Call `GET /teams/{id}` to get detail (includes members)
3. Display team name, framework, member list

**Acceptance**:
- **Given** default team is set, **When** `/rkit:team info` is invoked, **Then** team detail with members is displayed

## Requirements

- **FR-001**: MUST read and write `default_team_id` in `~/.config/resultkit/config.json`
- **FR-002**: MUST validate that selected team ID exists in user's teams before saving
- **FR-003**: MUST show framework type for each team (EOS, OKR, etc.)
- **FR-004**: MUST mark the current default team in list output

## Edge Cases

- No config exists → prompt to run `/rkit:setup`
- User has only one team → still list it, note it's the only option
- Team name contains special characters → handle display gracefully
