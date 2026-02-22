# Agent Compatibility

ResultKit skills work across multiple AI coding agents. All three use the same `SKILL.md` format, so the skill content is portable — only the distribution and installation mechanisms differ.

## Comparison

| | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|
| **Skill format** | `SKILL.md` | `SKILL.md` | `SKILL.md` |
| **Distribution** | Plugin marketplace | Manual copy | Extensions gallery (399+) |
| **Install command** | `/plugin install` | manual `cp` | `gemini extensions install <url>` |
| **Skill location** | `~/.claude/skills/` | `~/.agents/skills/` | `~/.gemini/skills/` |
| **Context file** | `CLAUDE.md` | — | `GEMINI.md` |
| **MCP support** | Yes | Yes | Yes |
| **Config format** | JSON | TOML | JSON |
| **Manifest file** | `.claude-plugin/plugin.json` | None | `gemini-extension.json` (root) |
| **Skill discovery** | Explicit path in manifest | Directory scan | Auto-discovery |

## Manifest Files

Each agent that supports packaged distribution requires its own manifest. These are **independent files with different schemas** — they don't conflict and can coexist in the same repo.

| File | Agent | Purpose |
|------|-------|---------|
| `.claude-plugin/plugin.json` | Claude Code | Plugin name, version, skill path, author |
| `.claude-plugin/marketplace.json` | Claude Code | Marketplace catalog for distribution |
| `gemini-extension.json` | Gemini CLI | Extension name, version, description |
| *(none required)* | Codex CLI | No manifest — skills discovered by directory scan |

Both Claude Code and Gemini CLI discover skills from the same `skills/` directory, so a single set of skill files serves all three agents.

## Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is Anthropic's CLI agent. It has a native plugin system with marketplace support.

**How ResultKit is distributed:** As a plugin via a custom marketplace hosted in this repo (`.claude-plugin/marketplace.json`). The plugin name `rkit` provides the `rkit:` namespace prefix automatically.

**Install:**

```
/plugin marketplace add w3mg/resultkit-skills
/plugin install rkit@resultkit
```

**Update:**

```
/plugin marketplace update
```

**Skill invocation:** `/rkit:today`, `/rkit:board`, etc.

**Key details:**
- Plugin manifest at `.claude-plugin/plugin.json` controls versioning — bump `version` for users to receive updates
- Skills are cached to `~/.claude/plugins/cache/` when installed from marketplace
- Local dev testing via `claude --plugin-dir /path/to/resultkit-skills`
- Supports hooks, agents, MCP servers, and custom commands bundled in plugins

## OpenAI Codex CLI

[Codex CLI](https://github.com/openai/codex) is OpenAI's open-source terminal agent. It uses the same `SKILL.md` format but has no plugin marketplace.

**How ResultKit is distributed:** Manual git clone and copy to the skills directory.

**Install:**

```bash
git clone https://github.com/w3mg/resultkit-skills.git
mkdir -p ~/.agents/skills
cp -r resultkit-skills/skills/* ~/.agents/skills/
```

**Update:**

```bash
cd resultkit-skills && git pull
cp -r skills/* ~/.agents/skills/
```

**Skill invocation:** `$rkit:today`, `$rkit:board`, etc.

**Key details:**
- No marketplace or auto-update mechanism
- Skills are discovered by scanning `~/.agents/skills/` and `.agents/skills/` (project-level)
- Codex auto-selects skills based on task matching with the skill description
- Supports MCP servers via `~/.codex/config.toml`

## Google Gemini CLI

[Gemini CLI](https://github.com/google-gemini/gemini-cli) is Google's terminal agent. It has an extensions gallery and supports `SKILL.md` skills.

**How ResultKit is distributed:** As an installable extension via GitHub URL, or manual copy.

**Install (extension):**

```bash
gemini extensions install https://github.com/w3mg/resultkit-skills
```

**Install (manual):**

```bash
git clone https://github.com/w3mg/resultkit-skills.git
mkdir -p ~/.gemini/skills
cp -r resultkit-skills/skills/* ~/.gemini/skills/
```

**Update:**

```bash
cd resultkit-skills && git pull
cp -r skills/* ~/.gemini/skills/
```

**Skill invocation:** `rkit:today`, `rkit:board`, etc.

**Key details:**
- Extensions gallery at [geminicli.com/extensions](https://geminicli.com/extensions/) with 399+ extensions
- Skills discovered at workspace (`.gemini/skills`), user (`~/.gemini/skills`), and extension levels
- Gemini activates skills via an `activate_skill` tool when it detects a matching task
- Supports MCP servers (stdio, SSE, HTTP) via `~/.gemini/settings.json`
- Extensions can bundle skills, MCP servers, custom commands (`.toml`), hooks, and themes

## Path Resolution

Each skill's `SKILL.md` includes a path resolver that searches for `api.sh` across all supported agent locations:

```bash
for p in \
  "$HOME/.claude/plugins/"*/rkit/skills/<name>/scripts/api.sh \
  "$HOME/.claude/skills/rkit:<name>/scripts/api.sh" \
  "$HOME/.agents/skills/<name>/scripts/api.sh" \
  "$HOME/.gemini/skills/<name>/scripts/api.sh" \
  "scripts/api.sh"; \
do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"
```

Search order:
1. **Claude Code plugin cache** — `~/.claude/plugins/*/rkit/skills/`
2. **Claude Code manual install** — `~/.claude/skills/rkit:*/`
3. **Codex CLI** — `~/.agents/skills/`
4. **Gemini CLI** — `~/.gemini/skills/`
5. **Local dev** — `scripts/api.sh` (repo root)

## Shared Configuration

All agents use the same ResultKit config file regardless of which agent is running:

```
~/.config/resultkit/config.json
```

This means a user only needs to run `rkit:setup` once — the token and team config works across all three agents.
