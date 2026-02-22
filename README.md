# ResultKit Skills

Claude Code skills for the [ResultMaps](https://resultmaps.com) V2 API. Manage your day plans, team boards, weekly meetings, and items directly from the command line.

## What's Included

| Skill | Description |
|-------|-------------|
| `/rkit:setup` | First-run configuration. Sets up API token, default team, and base URL. |
| `/rkit:today` | View and manage your daily plan. Add, complete, and remove items. |
| `/rkit:board` | View any item as a board. Columns are children, items are grandchildren. |
| `/rkit:weekly` | Team weekly board with framework-aware terminology (EOS, OKR, 4DX, etc.). |
| `/rkit:braindump` | Parse unstructured text (meeting notes, emails, dictation) into organized action items. |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A ResultMaps account with an API token ([get one here](https://resultmaps.com))
- `curl` and `jq` available in your shell

## Installation

### Plugin install (recommended)

```
/plugin marketplace add w3mg/resultkit-skills
/plugin install rkit@resultkit
```

Then run `/rkit:setup` to configure your API token and default team.

### Update to latest

```
/plugin marketplace update
```

### Legacy install (deprecated)

```bash
git clone https://github.com/w3mg/resultkit-skills.git
cd resultkit-skills
bash scripts/install.sh
```

## Quick Start

```
/rkit:setup          # Configure token + team (first time only)
/rkit:today           # Show today's day plan
/rkit:today add       # Add a new item to today
/rkit:board           # View your default board
/rkit:weekly          # View team weekly board
/rkit:braindump       # Paste meeting notes, get structured items
```

## Configuration

All config lives in `~/.config/resultkit/config.json`:

```json
{
  "api_token": "<your-bearer-token>",
  "default_team_id": 123,
  "api_base": "https://api.resultmaps.com/api/v2"
}
```

Run `/rkit:setup` to create or update this file.

---

## Maintainer Guide

### Repository Structure

```
.claude-plugin/
  plugin.json            # Plugin manifest (name, version, metadata)
  marketplace.json       # Marketplace catalog for distribution
skills/
  setup/                 # /rkit:setup skill
    SKILL.md
    scripts/api.sh       # Copy of shared api.sh
    references/
  today/                 # /rkit:today skill
  board/                 # /rkit:board skill
  weekly/                # /rkit:weekly skill
  braindump/             # /rkit:braindump skill
scripts/
  api.sh                 # Source of truth for the API caller
  deploy.sh              # Deployment script
  fetch-openapi.sh       # Fetch latest OpenAPI spec
  install.sh             # Legacy installer (deprecated)
specs/                   # Spec-Kit feature specs (one per skill)
constitution.md          # Core principles all skills must follow
api-reference.md         # V2 API endpoint summary
```

### How the plugin works

The plugin name is `rkit` (set in `.claude-plugin/plugin.json`). Claude Code automatically namespaces skills by combining the plugin name with the skill folder name:

- `skills/today/SKILL.md` becomes `/rkit:today`
- `skills/board/SKILL.md` becomes `/rkit:board`

Users install via the marketplace defined in `.claude-plugin/marketplace.json`, which points to this GitHub repo as the source.

### Updating api.sh

`scripts/api.sh` is the source of truth. Each skill has its own copy at `skills/*/scripts/api.sh` because plugins must be self-contained (no path traversal outside the plugin root).

After editing `scripts/api.sh`, sync it to all skills:

```bash
for skill in skills/*/; do
  cp scripts/api.sh "$skill/scripts/api.sh"
  chmod +x "$skill/scripts/api.sh"
done
```

### Releasing a new version

1. Make your changes to skill files, api.sh, etc.
2. Sync api.sh to all skills (see above).
3. Bump the `version` in `.claude-plugin/plugin.json`. Users won't receive updates without a version bump.
4. Commit and push to `main`.
5. Users run `/plugin marketplace update` to get the new version.

### Adding a new skill

1. Create `skills/<name>/SKILL.md` with the standard frontmatter:
   ```yaml
   ---
   name: rkit:<name>
   description: What it does.
   disable-model-invocation: true
   user-invocable: true
   allowed-tools: Bash, Read, AskUserQuestion
   ---
   ```
2. Add a `scripts/` folder and copy `api.sh` into it.
3. Add a `references/` folder if the skill needs reference docs.
4. Add the api.sh path resolver to the Current State section:
   ```
   - api.sh: !`for p in "$HOME/.claude/plugins/"*/rkit/skills/<name>/scripts/api.sh "$HOME/.claude/skills/rkit:<name>/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"`
   ```
5. Follow the principles in `constitution.md`.
6. Bump the version in `plugin.json` and push.

### Testing locally

Run Claude Code with the plugin loaded directly from the repo:

```bash
claude --plugin-dir /path/to/resultkit-skills
```

Skills will be available as `/rkit:setup`, `/rkit:today`, etc. without needing to install from the marketplace.

### Syncing the API reference

Use the project skill `/rkit-sync-api-doc` to compare the live OpenAPI spec against `api-reference.md` and update it. Then copy the updated reference to each skill that includes it:

```bash
for skill in setup today board weekly; do
  cp api-reference.md "skills/$skill/references/api-reference.md"
done
```

## License

MIT
