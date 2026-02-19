# Research: rkit:setup

**Phase**: 0 — Outline & Research
**Date**: 2026-02-14

## Decision Log

### D1: Skill Entry Point Format

**Decision**: Use `SKILL.md` as the sole entry point per Anthropic's
Claude Code skill authoring format.

**Rationale**: Constitution Principle I mandates Claude Code skill
format. The SKILL.md file contains declarative Markdown with embedded
tool-use instructions. Claude Code reads it and executes accordingly.

**Alternatives considered**:
- Standalone Bash script → rejected (violates Principle I)
- Python CLI → rejected (adds runtime dependency, violates Principle I)

### D2: Shared API Script Design

**Decision**: Single `scripts/api.sh` that accepts
`METHOD PATH [BODY]` and returns structured JSON output.

**Rationale**: Constitution Principle VII (Direct Execution) requires
Bash tool + api.sh. A single shared script avoids duplication across
skills and provides consistent error handling.

**Output format**:
```json
{ "status": 200, "body": { ... } }
```
Error format:
```json
{ "status": 0, "error": "NO_CONFIG" }
```

**Alternatives considered**:
- Per-skill inline curl → rejected (duplication, inconsistent error
  handling)
- Python wrapper → rejected (external runtime dependency)

### D3: Config File Format

**Decision**: Plain JSON at `~/.config/resultkit/config.json` with
three fields: `api_token`, `default_team_id`, `api_base`.

**Rationale**: Constitution Principle III defines this exactly. JSON
is readable by both Bash (via jq) and the SKILL.md instructions.
Plaintext token storage matches existing project patterns.

**Alternatives considered**:
- YAML → rejected (no native Bash parser)
- Environment variables only → rejected (not persistent across
  sessions, violates config-driven principle)
- Encrypted token → rejected (adds complexity, not required by spec
  assumptions)

### D4: Token Verification Endpoint

**Decision**: Use `GET /users/me` to verify tokens. Returns user
profile including name, email, and ID needed for team listing.

**Rationale**: This is the standard identity endpoint. A successful
200 confirms the token is valid.

### D5: Team Listing Endpoint

**Decision**: Use `GET /teams` to list the authenticated user's teams.
Returns a flat array (no pagination), default team first.

**Rationale**: `GET /teams` is scoped to the authenticated user's
memberships. No user ID parameter needed.

## No Unresolved Items

All technical decisions are determined by the constitution and API
reference. No NEEDS CLARIFICATION items remain.
