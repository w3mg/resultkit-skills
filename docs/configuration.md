# Configuration

## ResultKit Config

ResultKit uses its own config file, separate from any agent's settings:

```
~/.config/resultkit/config.json
```

```json
{
  "api_token": "<bearer-token>",
  "default_team_id": 123,
  "api_base": "https://api.resultmaps.com/api/v2"
}
```

This file is created by `rkit:setup` and read by all other skills via `scripts/api.sh`. It is **agent-agnostic** — the same config file works across Claude Code, Codex CLI, and Gemini CLI. Users only need to run setup once.

## Agent Settings Files (Not Used by ResultKit)

Each agent has its own settings file with its own schema. These are **completely different formats** and are **not interchangeable**. ResultKit does not read or write any of these files.

| Agent | Settings location | Format |
|-------|-------------------|--------|
| Claude Code | `~/.claude/settings.json` | Flat JSON — permissions, plugins, env vars |
| Codex CLI | `~/.codex/config.toml` | TOML — model, MCP servers, preferences |
| Gemini CLI | `~/.gemini/settings.json` | Nested JSON — categories for model, tools, MCP, UI |

### Claude Code settings.json (excerpt)

```json
{
  "permissions": { "allow": ["Bash", "Read"] },
  "enabledPlugins": { "rkit@resultkit": true },
  "env": { "RESULTKIT_TOKEN": "..." }
}
```

### Codex CLI config.toml (excerpt)

```toml
[model]
name = "o4-mini"

[mcp.servers.example]
command = "npx"
args = ["example-server"]
```

### Gemini CLI settings.json (excerpt)

```json
{
  "model": { "name": "gemini-2.5-pro" },
  "tools": { "shell": { "enableInteractiveShell": true } },
  "mcpServers": {
    "example": { "command": "npx", "args": ["example-server"] }
  }
}
```

## Why This Doesn't Affect ResultKit

ResultKit skills read config via bash:

```bash
jq -r '.api_token' ~/.config/resultkit/config.json
```

This works identically on all three agents because:

1. **Agent-independent path** — `~/.config/resultkit/` follows the XDG convention and doesn't overlap with any agent's config directory
2. **Bash is universal** — all three agents support running bash commands from skills
3. **No agent API needed** — skills read a plain JSON file with `jq`, no agent-specific APIs involved
4. **One setup, works everywhere** — a user who runs `rkit:setup` on Claude Code can immediately use the skills on Codex CLI or Gemini CLI without reconfiguring
