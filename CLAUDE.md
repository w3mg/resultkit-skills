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
- `scripts/install.sh` — Legacy install (deprecated)

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

## Active Technologies
- Bash 5.x (api.sh, helper scripts), Markdown + Claude Code runtime, curl, jq
- JSON config at `~/.config/resultkit/config.json`
