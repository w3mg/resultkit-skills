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

- `.claude-plugin/` — Plugin manifest and marketplace config
- `constitution.md` — Core principles governing all rkit skills
- `api-reference.md` — V2 API endpoint summary
- `specs/` — Spec-kit-inspired feature specs (one per skill)
- `skills/` — Plugin skills (SKILL.md + scripts + references)
- `scripts/install.sh` — Legacy install (deprecated)

## Skill Namespace

All skills use the `rkit:` prefix: `/rkit:setup`, `/rkit:today`, `/rkit:board`, etc.

## Config Location

`~/.config/resultkit/config.json` — stores API token, default team, API base URL.

## Response Style

- Be concise. No filler.
- Questions get answers, not actions.

## Active Technologies
- Bash 5.x (api.sh, helper scripts), Markdown + Claude Code runtime, curl, jq (001-setup)
- JSON file at `~/.config/resultkit/config.json` (001-setup)
- Bash 5.x (api.sh), Markdown + Claude Code runtime + curl, jq, shared `scripts/api.sh` (002-today)
- N/A — reads from ResultMaps API; config at `~/.config/resultkit/config.json` (002-today)
- `~/.config/resultkit/config.json` (auth + `default_board_id`) (003-board)

## Recent Changes
- 001-setup: Added Bash 5.x (api.sh, helper scripts), Markdown + Claude Code runtime, curl, jq
