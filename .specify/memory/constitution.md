<!--
Sync Impact Report
==================
Version change: 1.0.0 → 1.1.0
Bump rationale: MINOR — new principle added (I. Claude Code Skill
Format), existing principles renumbered II–IX.

Modified principles:
  - I. Self-Contained → II. Self-Contained (renumbered)
  - II. Config-Driven → III. Config-Driven (renumbered)
  - III. Confirm Writes → IV. Confirm Writes (renumbered)
  - IV. Show IDs → V. Show IDs (renumbered)
  - V. Framework-Aware → VI. Framework-Aware (renumbered)
  - VI. Direct Execution → VII. Direct Execution (renumbered)
  - VII. Graceful Degradation → VIII. Graceful Degradation (renumbered)
  - VIII. Concise Output → IX. Concise Output (renumbered)

Added principles:
  - I. Claude Code Skill Format (NEW)

Added sections: (none)
Removed sections: (none)

Templates requiring updates:
  - .specify/templates/plan-template.md ✅ compatible
  - .specify/templates/spec-template.md ✅ compatible
  - .specify/templates/tasks-template.md ✅ compatible

Follow-up TODOs: none
-->

# ResultKit v1 Constitution

Core principles governing all `rkit:*` skills. Every skill MUST comply.

## Core Principles

### I. Claude Code Skill Format

Every rkit skill MUST be built as a Claude Code skill following
Anthropic's skill authoring format. Each skill is a `SKILL.md` file
installed to `~/.claude/skills/` and invoked via the `/rkit:*`
namespace.

- Skills MUST use `SKILL.md` as the entry point.
- Skills MUST be authored for the Claude Code agent runtime — no
  standalone CLI binaries, no external runtimes.
- Skill behavior is defined declaratively in Markdown with embedded
  tool-use instructions that Claude Code executes.
- Reference scripts (e.g., `api.sh`) are permitted as supporting
  files but MUST NOT replace the skill entry point.

### II. Self-Contained

Each skill works without requiring any project context, other skills,
or the `rm-api-v2` project-level skill. A user MUST be able to invoke
any `rkit:*` skill from any directory.

- Skills MUST NOT assume a working directory or repo structure.
- Skills MUST NOT depend on other `rkit:*` skills being installed.
- The only external dependency is `~/.config/resultkit/config.json`.

### III. Config-Driven

Auth and defaults live in `~/.config/resultkit/config.json`. Values
MUST NOT be hardcoded. Structure:

```json
{
  "api_token": "<bearer-token>",
  "default_team_id": "<int>",
  "api_base": "https://api.resultmaps.com"
}
```

If config is missing or invalid, the skill MUST prompt the user to
run `/rkit:setup`.

### IV. Confirm Writes

- **GET requests** execute immediately without confirmation.
- **POST/PUT/PATCH/DELETE** MUST describe the action and ask for
  confirmation before executing.

### V. Show IDs

Every response that references an entity (item, team, user, meeting)
MUST include its numeric ID so users can reference it in follow-up
commands.

### VI. Framework-Aware

Skills MUST translate management-framework terminology (EOS, OKR, 4DX,
V2MOM, SRT) into correct API concepts using the team's `framework`
field. Example: "rocks" maps to items with status context in EOS teams.

### VII. Direct Execution

Skills MUST use the Bash tool directly for all API calls via the shared
`scripts/api.sh` script. No Task agents or subagents.

### VIII. Graceful Degradation

- Missing config → suggest `/rkit:setup`
- Missing default team → list teams and ask user to pick
- API errors → show status code, error message, and actionable fix
- 401 → prompt for new token

### IX. Concise Output

Format responses as clean tables or short summaries. No verbose prose.
Show what matters: names, statuses, IDs, dates.

## API Constraints

- **Base URL**: `https://api.resultmaps.com` (configurable via
  `api_base` in config).
- **Auth**: Bearer token in `Authorization` header.
- **Pagination**: All list endpoints return
  `{ data: [...], meta: { page, per_page, total, total_pages } }`.
  Skills MUST handle pagination when results may exceed one page.
- **Status values**: `not_started`, `next`, `parked`, `blocked`,
  `done`, `archived`, `draft`.
- **Error codes**: 401 (invalid token), 403 (not authorized),
  404 (not found), 422 (validation error).

## Skill Development Workflow

- Each skill has a spec in `specs/NNN-name/spec.md`.
- Built skill source files go in `skills/rkit/`.
- The shared API script lives at `scripts/api.sh`.
- Skills are deployed to `~/.claude/skills/` via `scripts/install.sh`.
- All skills use the `rkit:` namespace prefix.

## Governance

This constitution supersedes all other practices for `rkit:*` skills.

- **Amendments** require updating this file, incrementing the version,
  and propagating changes to dependent templates and specs.
- **Versioning** follows semantic versioning:
  - MAJOR: Principle removal or backward-incompatible redefinition.
  - MINOR: New principle or materially expanded guidance.
  - PATCH: Clarifications, wording, non-semantic refinements.
- **Compliance**: Every spec and skill MUST be reviewed against these
  principles before merge. The plan-template Constitution Check gate
  enforces this.

**Version**: 1.1.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-14
