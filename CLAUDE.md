# ResultKit v1

Spec-driven skill suite for interacting with the ResultMaps V2 API as a user.

## Project Purpose

This project contains **specs and source files** for the `rkit:*` skill namespace — global Claude Code skills for daily planning, team boards, meetings, and item management via the ResultMaps API.

Skills are developed here and distributed as a Claude Code plugin.

## Installation (for users)

```bash
# Add the marketplace
/plugin marketplace add w3mg/resultkit-skills

# Install the plugin
/plugin install rkit@resultkit

# Run first-time setup
/rkit:setup
```

Update to latest: `/plugin marketplace update`

## Structure

- `.claude-plugin/` — Claude Code plugin manifest and marketplace config
- `gemini-extension.json` — Gemini CLI extension manifest
- `constitution.md` — Core principles governing all rkit skills
- `api-reference.md` — Master API endpoint summary (source of truth)
- `scripts/api.sh` — Master API caller script (source of truth)
- `specs/` — Spec-kit-inspired feature specs (one per skill)
- `skills/` — Plugin skills (SKILL.md + scripts + references)
- `.specify/commands/` — Dev-only commands (speckit, next-issue, ship-it, close-issue) — symlinked into `.claude/commands/` at session start, never distributed via plugin
- `scripts/install.sh` — Legacy install (deprecated)

## Developer Setup

Dev-only commands (`/speckit:*`, `/next-issue`, `/ship-it`, `/close-issue`) are stored in `.specify/commands/` and symlinked into `.claude/commands/` automatically on session start via `.claude/hooks/setup-symlinks.sh`. The symlinks are gitignored so they never appear in the plugin distribution.

**Speckit source**: All `speckit:*` skills are provided by the `example-skills@anthropic-agent-skills` plugin — not by this repo. Do NOT re-add `.claude/commands/speckit/` to the repo. If speckit commands are missing in a dev session, ensure `example-skills@anthropic-agent-skills` is installed.

**See [`docs/dev-setup.md`](docs/dev-setup.md)** for full details on: how the symlinks work, how to add new dev-only commands, and how the plugin distribution boundary is maintained.

## Skill Namespace

All skills use the `rkit:` prefix: `/rkit:setup`, `/rkit:today`, `/rkit:board`, etc.

## Config Location

`~/.config/resultkit/config.json` — stores API token, default team, API base URL.

## Response Style

- Be concise. No filler.
- Questions get answers, not actions.

## Mandatory: Verify Before Writing Skills

**NEVER write or modify API-related skill logic based on assumptions.** Before changing any skill that calls the API:

1. **Read `api-reference.md`** for the endpoint's documented params, statuses, and response shape.
2. **Call the actual API** with `scripts/api.sh` to verify real behavior — field names, status values, whether query params actually filter, response structure.
3. **Check real data** — look at what the API actually returns, not what you think it returns.

Do not invent status values, field names, or filtering behavior. If the reference is incomplete, test the API first and update the reference.

## Shared Files

Master copies of shared files live at the repo root. Each skill gets its own copy for plugin self-containment. **Never edit the copies inside `skills/*/` directly.**

| Master file | Copied to | Purpose |
|-------------|-----------|---------|
| `scripts/api.sh` | `skills/*/scripts/api.sh` | API caller script |
| `api-reference.md` | `skills/*/references/api-reference.md` | API endpoint reference |

After editing a master file, run `/sync-plugin` to copy it to all skills and bump the plugin version.

## Commit & Push Checklist

**When asked to commit, commit and push, or ship code, ALWAYS do ALL of these steps automatically — no asking, no skipping:**

1. **Bump version** in `.claude-plugin/plugin.json` (patch bump unless told otherwise)
2. **Stage all changed files** including the version bump
3. **Commit** with a descriptive message
4. **`git pull --rebase origin main`** to sync with remote
5. **`git push origin main`**
6. **Print update instructions**: tell the user to run `/plugin marketplace update`

Never do these piecemeal. Never forget the version bump. One shot, every time.

## Active Technologies
- Bash 5.x (api.sh, helper scripts), Markdown + Claude Code runtime, curl, jq
- JSON config at `~/.config/resultkit/config.json`
- Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime) + curl, jq, `scripts/api.sh` (shared API caller) (014-result-feed-skill)
- `~/.config/resultkit/config.json` (user config with token + default_team_id) (014-result-feed-skill)
- Bash 5.x (api.sh helper), Markdown (SKILL.md — Claude Code skill runtime) + curl, jq, `scripts/api.sh` (shared API caller) (017-update-skill-endpoints)
- N/A (all data via ResultMaps V2 API) (017-update-skill-endpoints)
- Markdown (SKILL.md skill format) + Bash 5.x (api.sh) + Claude Code skill runtime, `allowed-tools` frontmatter (018-collapse-confirmations)
- N/A (fire-and-forget API call) (021-password-reset)
- Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime) + `scripts/api.sh` (shared API caller), curl, jq (022-teams-envelope-fix)
- Bash 5.x + Markdown (Claude Code skill format) + `scripts/api.sh` (shared API caller), `jq`, `curl` (026-users-mgmt-api)
- N/A — all data via ResultMaps V2 API (026-users-mgmt-api)
- Bash 5.x (embedded scripts in SKILL.md), Markdown (Claude Code skill runtime) + `scripts/api.sh` (shared API caller), `jq`, `curl` (027-review-template-teams)
- Bash 5.x (scripts), Markdown (Claude Code skill runtime) + `scripts/api.sh` (shared API caller), `jq`, `curl` (029-v2-seat-api)
- `~/.config/resultkit/config.json` (read-only at skill runtime) (029-v2-seat-api)
- Bash 5.x, Markdown (Claude Code skill runtime) + `scripts/api.sh` (shared API caller), `jq`, `curl` (030-seats-field-renames)
- Bash 5.x + Markdown (Claude Code skill runtime) + `scripts/api.sh` (shared API caller), `jq`, `curl` (001-scorecard-skill)
- Bash 5.x + jq, curl, `scripts/api.sh` (shared API caller) (001-fix-measure-history)
- JSON (configuration file) + Claude Code plugin system (Claude Code production) (001-fix-plugin-install)
- Bash 5.x, JSON (plugin manifest), Markdown (Claude Code skill format) + Claude Code plugin system, `.claude-plugin/plugin.json` manifest (031-remove-speckit)

## Recent Changes
- 014-result-feed-skill: Added Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime) + curl, jq, `scripts/api.sh` (shared API caller)
