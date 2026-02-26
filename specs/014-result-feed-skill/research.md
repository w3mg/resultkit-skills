# Research: rkit:result-feed Skill

**Date**: 2026-02-26

## Research Tasks

### 1. Result Feed API Endpoint Behavior

**Decision**: Use the V2 API endpoints as documented in the OpenAPI spec at `~/projects/resultmaps-api2/openapi/openapi-v2.yaml`.

**Rationale**: The OpenAPI spec is the source of truth and has been verified against the actual route implementations in the resultmaps-api2 codebase. All 6 endpoints are implemented with tests.

**Alternatives considered**: None — this is the only API available.

**Key findings**:
- `GET /result-feeds/{date}` — accepts `today` or `YYYY-MM-DD`, auto-creates empty report
- `POST /result-feeds/{date}/{section}` — creates new Task, body: `{ "name": "..." }`
- `PUT /result-feeds/{date}/{section}/{item_id}` — adds existing item, idempotent
- `DELETE /result-feeds/{date}/{section}/{item_id}` — removes from section, 204 response
- `POST /result-feeds/{date}/submit` — finalizes, optional body: `{ "team_id": N, "item_ids": [...] }`
- `GET /teams/{id}/result-feeds` — paginated team check-ins, requires membership
- Section URL names: `done`, `next`, `issues` (NOT `blocked`)
- ResultFeed schema: `{ id, date, is_completed, done: Item[], next: Item[], issues: Item[] }`
- TeamResultFeed adds: `{ user: { id, login, first_name, last_name } }`
- Submit validation: 422 if done or next is empty
- Submit is idempotent on already-completed feeds
- No separate share endpoint — sharing is folded into submit via optional body params

### 2. Existing Skill Pattern Analysis

**Decision**: Follow the `skills/today/SKILL.md` pattern exactly.

**Rationale**: All rkit skills use the same structure. Consistency reduces maintenance burden and user confusion.

**Alternatives considered**: Custom script-heavy approach — rejected because it contradicts Constitution Principle I (Claude Code Skill Format).

**Key patterns extracted from `skills/today/SKILL.md`**:
- Frontmatter: `name`, `description`, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash, Read, AskUserQuestion`
- Current State block: config check via inline `!` bash, api.sh path resolution with fallback chain
- Rules section: interpret first, confirm writes, show IDs, concise output, direct execution
- Tool Routing Table: trigger phrases → intent → tool/flow name
- Flow definitions: step-by-step with bash code blocks showing api.sh calls
- Date Resolution table: natural language → YYYY-MM-DD or `today`
- Schemas section: example JSON for key response types
- Error Handling table: status codes → user-facing messages
- References: link to api-reference.md

### 3. api-reference.md Update Strategy

**Decision**: Add a `## Result Feeds` section to `api-reference.md` between the existing `## Day Plans` and `## Meetings` sections (logical grouping — result feeds are daily-oriented like day plans). Add glossary entries for result feed terminology.

**Rationale**: The api-reference.md is the master endpoint reference used by all skills. It must include Result Feeds before the skill can reference it. Placement after Day Plans groups daily-oriented features together.

**Alternatives considered**: Separate reference file — rejected because all skills share one api-reference.md and existing skills reference it.

**Key content to add**:
- Endpoint table (6 endpoints) with Method, Path, Description, User Phrases, Web URL columns
- Response field documentation for ResultFeed and TeamResultFeed
- Submit request body documentation
- Section name mapping note (issues = blocked internally)
- Glossary entries: "check-in", "90-second practice", "result feed", "daily report" → Result Feed endpoints

### 4. Plugin File Sync

**Decision**: After updating master `api-reference.md`, run `/sync-plugin` to copy to all skill directories and bump plugin version.

**Rationale**: Per CLAUDE.md shared files workflow — master copies live at repo root, each skill gets its own copy. Never edit copies inside `skills/*/` directly.

**Alternatives considered**: None — this is the mandatory workflow.

### 5. Submit + Team Sharing Flow

**Decision**: Submit always includes team sharing. Use `default_team_id` from config. Display team name in confirmation. Allow override via explicit team specification.

**Rationale**: Per clarification session — the user confirmed this is the desired behavior. The submit endpoint supports optional `team_id` and `item_ids` in the request body.

**Implementation detail**: The submit flow must:
1. Read `default_team_id` from config
2. If missing, prompt user to specify a team
3. Fetch team name via `GET /teams/{id}` for display in confirmation
4. Include `{ "team_id": N }` in the submit request body
5. User can override by saying "submit to team 42"

### 6. API Deployment Status

**Decision**: Build the skill now against the documented API contract. Note in the skill that the API must be deployed before use.

**Rationale**: The API code is fully implemented and tested in the resultmaps-api2 codebase. Building the skill now allows immediate use once deployed. The api_base in config is user-configurable, so local testing is possible.

**Alternatives considered**: Wait for deployment — rejected because the skill development is independent of deployment timing.
