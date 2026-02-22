---
name: plugin-dev
description: >
  Developer tool for working on Claude Code plugin codebases. Handles the full
  plugin lifecycle: validate manifests, sync shared files, bump versions, publish,
  check cache state, diagnose loading issues, and scaffold new skills. Use when
  working on plugin development, debugging why a skill isn't loading, publishing
  updates, creating new skills, or checking deployment status.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Plugin Dev

Developer skill for Claude Code plugin codebases. Operates on the **current repo** — not end-user skills.

## Key Knowledge

### How Claude Code plugins work

- Plugins are directories with `.claude-plugin/plugin.json` at the root.
- `plugin.json` defines `name` (namespace prefix), `version`, and component paths (`skills`, `commands`, `agents`, etc.).
- Skills live in `skills/<name>/SKILL.md`. The folder name becomes the skill name, prefixed by the plugin namespace (e.g. `skills/today/` in plugin `rkit` → `/rkit:today`).
- Marketplaces are git repos with `.claude-plugin/marketplace.json` listing plugins and their sources.
- **Caching**: When installed, plugins are copied to `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`. They are NOT used in-place.
- **Version gating**: The cache is keyed by the `version` field in `plugin.json`. If you change code but don't bump the version, existing users will NOT see updates. This is the #1 cause of "my changes aren't showing up".
- **Update flow**: `claude plugin update <plugin>` or `/plugin marketplace update` pulls the latest from the source, but only creates a new cache entry if the version changed.
- Installed plugins are tracked in `~/.claude/plugins/installed_plugins.json` (v2 schema).
- Known marketplaces are tracked in `~/.claude/plugins/known_marketplaces.json`.

### Plugin manifest schema (.claude-plugin/plugin.json)

Required: `name` (kebab-case).
Optional: `version`, `description`, `author` (`name`, `email`, `url`), `homepage`, `repository`, `license`, `keywords`.
Component paths: `skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`, `outputStyles`.
All paths relative to plugin root, start with `./`. Custom paths supplement defaults, don't replace.

### Marketplace schema (.claude-plugin/marketplace.json)

Required: `name` (kebab-case), `owner` (`name` required), `plugins` array.
Each plugin entry: `name`, `source` (string path or object with `source`, `repo`, `ref`, `sha`).
Optional per-plugin: `description`, `version`, `strict`, `category`, `tags`.
Plugin sources: relative path (`"./plugins/x"`), github (`{"source":"github","repo":"owner/repo"}`), url, npm, pip.

### CLI commands

```
claude plugin validate .          # Validate manifests
claude plugin install <p>         # Install (--scope user|project|local)
claude plugin uninstall <p>       # Remove
claude plugin update <p>          # Update to latest version
claude plugin enable <p>          # Enable disabled plugin
claude plugin disable <p>         # Disable without removing
claude plugin marketplace add <source>
claude plugin marketplace update
```

### Common failure modes

1. **Version not bumped** → cache still serves old version. Fix: bump version, push, update.
2. **SKILL.md missing from cache** → file not committed/pushed before update. Fix: verify git status, push, bump, update.
3. **Components inside .claude-plugin/** → only `plugin.json` goes there. Skills, commands, agents go at plugin root.
4. **Path traversal** → installed plugins can't reference `../` outside their dir. Use symlinks if needed.
5. **Plugin not in installed_plugins.json** → marketplace is registered but plugin was never `plugin install`-ed.
6. **Strict mode conflict** → both marketplace entry and plugin.json define components with `strict: true` (default).

## Commands

Based on `$ARGUMENTS`, run the matching command. If no argument or ambiguous, show the menu.

### Menu (no arguments)

> **Plugin Dev** — what do you need?
> 1. **validate** — Check manifests and structure
> 2. **publish** — Sync, bump, commit, push
> 3. **status** — Compare repo vs cache vs installed
> 4. **diagnose** — Debug why a skill isn't loading
> 5. **scaffold** — Create a new skill skeleton
> 6. **info** — Show plugin metadata and structure

---

### 1. validate

Run validation and structural checks:

```bash
claude plugin validate .
```

Then manually verify:
- `.claude-plugin/plugin.json` exists and has valid JSON with `name` field
- `.claude-plugin/marketplace.json` exists (if this is also a marketplace)
- Every `skills/*/` directory has a `SKILL.md`
- No component directories inside `.claude-plugin/` (only `plugin.json` goes there)
- All script files referenced by skills are executable (`chmod +x`)
- `version` field exists and is valid semver

Report all findings as a checklist.

### 2. publish

Full publish flow. Takes an optional version argument (e.g. `publish 1.2.0`).

**Step 2a: Pre-flight checks**
- Verify clean git status (warn if uncommitted changes)
- Read current version from `.claude-plugin/plugin.json`
- Validate manifests (run validate command above)

**Step 2b: Sync shared files**
Run `/sync-plugin` logic:
- Copy master `scripts/api.sh` to all `skills/*/scripts/`
- Copy master `api-reference.md` to all `skills/*/references/` that have one
- Report what was synced

**Step 2c: Bump version**
- If explicit version provided, use it
- Otherwise increment patch (e.g. `1.1.0` → `1.1.1`)
- Update version in ALL manifest files:
  - `.claude-plugin/plugin.json`
  - `gemini-extension.json` (if exists)

**Step 2d: Commit and push**
Present summary and ask for confirmation:
> **Ready to publish v{version}:**
> - {N} files synced
> - Version: {old} → {new}
> - Files to commit: {list}
>
> Proceed?

On confirmation:
```bash
git add -A
git commit -m "Publish plugin v{version}"
git push
```

**Step 2e: Post-publish**
> Published **v{version}**. Users can update with:
> ```
> /plugin marketplace update
> claude plugin update rkit@resultkit
> ```

### 3. status

Compare three states: source repo, plugin cache, and installed_plugins.

```bash
# Source version
jq -r '.version' .claude-plugin/plugin.json

# Cache versions
ls ~/.claude/plugins/cache/resultkit/rkit/ 2>/dev/null || echo "No cache"

# Cache version contents (latest)
LATEST=$(ls -t ~/.claude/plugins/cache/resultkit/rkit/ 2>/dev/null | head -1)
if [ -n "$LATEST" ]; then
  jq -r '.version' ~/.claude/plugins/cache/resultkit/rkit/$LATEST/.claude-plugin/plugin.json
fi

# Installed state
jq '.plugins' ~/.claude/plugins/installed_plugins.json 2>/dev/null

# Marketplace state
jq '.version' ~/.claude/plugins/marketplaces/resultkit/.claude-plugin/plugin.json 2>/dev/null
```

For each skill in source, check if SKILL.md exists in the latest cache version:

```bash
for skill in skills/*/; do
  name=$(basename "$skill")
  cached="$HOME/.claude/plugins/cache/resultkit/rkit/$LATEST/skills/$name/SKILL.md"
  if [ -f "$cached" ]; then
    echo "✓ $name"
  else
    echo "✗ $name — MISSING from cache"
  fi
done
```

Present as a status table:

| Property | Source | Cache | Installed |
|----------|--------|-------|-----------|
| Version | {x} | {y} | {z} |
| Skills | {n} | {m} | — |
| Missing | — | {list} | — |

Flag any mismatches.

### 4. diagnose

Interactive troubleshooting. Ask which skill is broken, then check:

1. **Is the marketplace registered?**
   ```bash
   jq '.resultkit' ~/.claude/plugins/known_marketplaces.json
   ```

2. **Is the plugin installed?**
   ```bash
   jq '.plugins["rkit@resultkit"]' ~/.claude/plugins/installed_plugins.json
   ```
   If not installed, that's the problem. Tell user to run:
   ```
   claude plugin install rkit@resultkit
   ```

3. **What version is cached?**
   ```bash
   ls ~/.claude/plugins/cache/resultkit/rkit/
   ```

4. **Does SKILL.md exist in cache for the broken skill?**
   ```bash
   ls ~/.claude/plugins/cache/resultkit/rkit/*/skills/{skill_name}/SKILL.md
   ```

5. **Does the source repo have the skill committed and pushed?**
   ```bash
   git log --oneline -3 -- skills/{skill_name}/SKILL.md
   git diff HEAD -- skills/{skill_name}/SKILL.md
   ```

6. **Is the cached version stale?**
   Compare cache version vs source version. If source is newer, tell user to:
   ```
   claude plugin update rkit@resultkit
   ```

7. **Is there an orphaned cache?**
   ```bash
   ls ~/.claude/plugins/cache/resultkit/rkit/
   # Look for .orphaned_at files
   find ~/.claude/plugins/cache/resultkit/rkit/ -name ".orphaned_at"
   ```

Report findings and provide the fix.

### 5. scaffold

Create a new skill skeleton. Takes a skill name argument (e.g. `scaffold meeting`).

Ask for:
- Skill name (if not provided)
- One-line description

Then create:

```
skills/{name}/
├── SKILL.md
├── scripts/
│   └── api.sh          (copied from master)
└── references/
    └── api-reference.md (copied from master)
```

SKILL.md template:

```markdown
---
name: rkit:{name}
description: {description}
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Write
---

# rkit:{name}

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ]; then echo "OK"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/{name}/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/{name}/scripts/api.sh "$HOME/.claude/skills/rkit:{name}/scripts/api.sh" "$HOME/.agents/skills/{name}/scripts/api.sh" "$HOME/.gemini/skills/{name}/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes**: Before any mutating API call, describe what will happen and confirm.
- **Show IDs**: Always include entity IDs in output.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls. Never use Task agents or subagents.

## Flow

TODO: Define the skill flow.

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
```

After creating, report what was created and remind to:
1. Define the flow in SKILL.md
2. Run `publish` when ready

### 6. info

Show plugin metadata:

```bash
echo "=== Plugin Manifest ==="
cat .claude-plugin/plugin.json

echo "=== Marketplace Manifest ==="
cat .claude-plugin/marketplace.json

echo "=== Skills ==="
for s in skills/*/SKILL.md; do
  name=$(basename $(dirname "$s"))
  desc=$(grep -A1 "^description:" "$s" | tail -1 | sed 's/^  //')
  echo "  $name: $desc"
done

echo "=== Git Status ==="
git log --oneline -1
git status --short
```

## Adapting to Other Plugin Repos

This skill is written for the `rkit` plugin in the `resultkit` marketplace. To adapt for another plugin, update:
- Marketplace name in cache paths (`resultkit` → your marketplace name)
- Plugin name in cache paths (`rkit` → your plugin name)
- Shared file paths (api.sh, api-reference.md) to match your project
- SKILL.md template to match your project conventions
- The gemini-extension.json bump (remove if not applicable)
