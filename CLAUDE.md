# ResultKit v1

Spec-driven skill suite for interacting with the ResultMaps V2 API as a user.

## Project Purpose

This project contains **specs and source files** for the `rkit:*` skill namespace — global Claude Code skills for daily planning, team boards, meetings, and item management via the ResultMaps API.

Skills are developed here, then installed globally to `~/.claude/skills/`.

## Structure

- `constitution.md` — Core principles governing all rkit skills
- `api-reference.md` — V2 API endpoint summary
- `specs/` — Spec-kit-inspired feature specs (one per skill)
- `skills/rkit/` — Built skill source files (SKILL.md + scripts + references)
- `scripts/install.sh` — Deploy skills to `~/.claude/skills/`

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

## Recent Changes
- 001-setup: Added Bash 5.x (api.sh, helper scripts), Markdown + Claude Code runtime, curl, jq
