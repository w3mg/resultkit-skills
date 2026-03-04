# Implementation Plan: Extend rkit:profile with Measurables, Rocks, Feedback, Progress, and Integrations

**Branch**: `026-users-mgmt-api` | **Date**: 2026-03-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/026-users-mgmt-api/spec.md`

## Summary

Extend `skills/profile/SKILL.md` with 5 new subcommand flows: `measurables`, `rocks`, `feedback`, `progress`, and `integrations`. All endpoints are already documented in `api-reference.md`. No new scripts, no new skills — pure SKILL.md additions following existing rkit:profile patterns.

## Technical Context

**Language/Version**: Bash 5.x + Markdown (Claude Code skill format)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual — invoke subcommands via `/rkit:profile` and verify output shape
**Target Platform**: Claude Code skill runtime (any directory)
**Project Type**: Single skill extension
**Performance Goals**: N/A (API pass-through)
**Constraints**: Match existing rkit:profile output style; no new config fields required
**Scale/Scope**: Personal user commands; pagination required for rocks and feedback

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ PASS | Extending SKILL.md — no binary or standalone CLI |
| II. Self-Contained | ✅ PASS | No new external dependencies; works from any directory |
| III. Config-Driven | ✅ PASS | Uses existing `~/.config/resultkit/config.json` |
| IV. Confirm Writes | ✅ PASS | `integrations set` confirms; all GET flows execute immediately |
| V. Show IDs | ✅ PASS | Rock IDs, measurable IDs, feedback IDs included in output |
| VI. Framework-Aware | ⚠️ SCOPED | Constitution VI requires framework translation per team.framework field. This feature explicitly scopes out framework terminology mapping (spec Assumptions, last bullet). All flows display "Rock" universally. Framework mapping is deferred to a follow-up issue — not a violation of this feature's scope. |
| VII. Direct Execution | ✅ PASS | All API calls via `scripts/api.sh` Bash tool — no Task agents |
| VIII. Graceful Degradation | ✅ PASS | Standard error patterns: NO_CONFIG, 401, 403, 404 |
| IX. Concise Output | ✅ PASS | Tables for lists; labeled key-value for dashboard data |

**Post-design re-check**: No violations. ✅ All clear.

## Project Structure

### Documentation (this feature)

```text
specs/026-users-mgmt-api/
├── plan.md              # This file
├── research.md          # Phase 0 output ✅
├── data-model.md        # Phase 1 output ✅
├── quickstart.md        # Phase 1 output ✅
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit:tasks — not yet created)
```

### Source Code

```text
skills/profile/
├── SKILL.md             # PRIMARY CHANGE — add 5 new flow sections + update Argument Parsing table
└── scripts/
    └── api.sh           # No changes needed
```

**Structure Decision**: Single-file change. All logic lives in `skills/profile/SKILL.md`. The api.sh shared script is unchanged. No new files in the skills directory.

## Implementation Phases

### Phase 1: Argument Parsing Table Update

Update the Argument Parsing table in `skills/profile/SKILL.md` to add rows for all 5 new subcommands and their variants. This is the routing table Claude Code uses to dispatch flows.

New rows to add:

| Input | Behavior |
|-------|----------|
| `measurables` | Show scorecard metrics for current user |
| `measurables {user_id}` | Show scorecard metrics for another user (must share a team) |
| `rocks` | Show quarterly rocks for current user |
| `rocks {year}` | Show rocks for a specific year |
| `rocks {user_id}` | Show rocks for another user (must share a team) |
| `feedback given` | Show High5s given by current user |
| `feedback received` | Show High5s received by current user |
| `feedback {user_id} given\|received` | Show feedback for another user |
| `progress` | Show personal progress dashboard |
| `progress {period}` | Progress filtered to period: week, month, or quarter |
| `integrations` | Show current third-party integration selections |
| `integrations set {category} {value}` | Update an integration selection (with confirmation) |

### Phase 2: Flow — Measurables

**Trigger**: `measurables` or `measurables {user_id}`

Steps:
1. Resolve `api.sh` path and config (same as Stats Step 1 pattern).
2. Extract `USER_ID` from args (`me` if not provided).
3. Call `GET /users/${USER_ID}/measurables`.
4. Handle errors: NO_CONFIG, NO_TOKEN, CURL_FAILED, 401, 403 (team-sharing), 404.
5. On 200: display table with ID, Name, Target, Latest value, On Track (✓/✗).
6. Footer: `{N} measurables`.

### Phase 3: Flow — Rocks

**Trigger**: `rocks`, `rocks {year}`, or `rocks {user_id}`

Steps:
1. Resolve `api.sh` and config.
2. Parse args: if arg is 4-digit year → set `YEAR` param; if numeric non-year → `USER_ID`; default `USER_ID=me`.
3. Paginated fetch: `GET /users/${USER_ID}/rocks?per_page=100&page=${PAGE}` (append `&year=${YEAR}` if provided).
4. Handle errors: same pattern.
5. On 200: display table with ID, Name, Status (humanized), Due date, Milestones (completed/total), Team name.
6. Footer: `{N} rocks`.

**Status labels**: `on_track` → "On Track", `off_track` → "Off Track", `completed` → "Done", `dropped` → "Dropped".

### Phase 4: Flow — Feedback

**Trigger**: `feedback given`, `feedback received`, or `feedback {user_id} given|received`

Steps:
1. Resolve `api.sh` and config.
2. Parse `DIRECTION` ("given" or "received") and optional `USER_ID` from args.
3. If direction missing: use `AskUserQuestion` to prompt "given" or "received".
4. Paginated fetch: `GET /users/${USER_ID}/feedback?direction=${DIRECTION}&per_page=100&page=${PAGE}`.
5. Handle errors: same pattern (403 = team-sharing).
6. On 200: display table with ID, From/To (depending on direction), Message (truncated at 60 chars), Date.
7. Footer: `{N} items`.

### Phase 5: Flow — Progress

**Trigger**: `progress` or `progress {period}`

Steps:
1. Resolve `api.sh` and config.
2. Extract optional `PERIOD` (week/month/quarter) from args.
3. Call `GET /users/me/progress` (append `?period=${PERIOD}` if provided).
4. Handle errors: NO_CONFIG, NO_TOKEN, CURL_FAILED, 401. *(403/404 not applicable — endpoint is always `/users/me/progress`; no `{user_id}` param, so access denied and not-found scenarios cannot occur.)*
5. On 200: display two sections:
   - **Strategy**: rocks_realized_all_time, milestones_realized_all_time, milestones_realized_this_quarter (labeled key-value)
   - **Practice Streak**: current_streak, longest_streak, all_time (labeled key-value)
   - **Practice Scorecard**: day-by-day table (day_name + ✓/✗ for `completed`)

### Phase 6: Flow — View Integrations

**Trigger**: `integrations`

Steps:
1. Resolve `api.sh` and config.
2. Call `GET /users/me/integrations`.
3. Handle errors: same pattern.
4. On 200: display three rows (one per category) with current selection and available options.

### Phase 7: Flow — Update Integrations

**Trigger**: `integrations set {category} {value}`

Steps:
1. Resolve `api.sh` and config.
2. Validate `{category}` is one of: `task_management`, `sales_revops`, `team_communication`. If not, show error with valid list and stop.
3. Validate `{value}` is present. If missing, show usage hint and stop.
4. Translate `none` or `null` → JSON `null` in body.
5. Fetch current integrations (`GET`) to show the diff.
6. Use `AskUserQuestion` to confirm: `Update {category}: '{current}' → '{new}'?`
7. On confirm: `PATCH /users/me/integrations` with body `{"{category}": "{value_or_null}"}`.
8. Handle errors: 401, 422.
9. On 200: "Integrations updated."
