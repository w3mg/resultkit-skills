# Developer Setup

This document covers the local development environment for contributors to `resultkit-skills`.

## Prerequisites

- Claude Code CLI installed
- `jq` installed (`apt-get install jq` or `brew install jq`)
- Git access to `w3mg/resultkit-skills`

## First-time setup

Clone the repo and open it with Claude Code. On the first session start, a hook automatically creates the required symlinks:

```
.claude/commands/speckit     → .specify/commands/speckit/
.claude/commands/next-issue.md → .specify/commands/next-issue.md
```

These symlinks are gitignored — they live only on your machine and are never committed or distributed via the plugin.

If you need to trigger setup manually (e.g., after a fresh clone before starting a session):

```bash
.claude/hooks/setup-symlinks.sh <<< '{"cwd":"'$(pwd)'"}'
```

## Dev-only commands

Some commands are intentionally excluded from the plugin distribution. They live in `.specify/commands/` and are symlinked into `.claude/commands/` on session start.

| Command | Source | Purpose |
|---------|--------|---------|
| `/speckit:specify` | `.specify/commands/speckit/specify.md` | Create feature spec |
| `/speckit:plan` | `.specify/commands/speckit/plan.md` | Generate implementation plan |
| `/speckit:tasks` | `.specify/commands/speckit/tasks.md` | Generate task list |
| `/speckit:clarify` | `.specify/commands/speckit/clarify.md` | Clarify spec ambiguities |
| `/speckit:implement` | `.specify/commands/speckit/implement.md` | Execute tasks |
| `/speckit:analyze` | `.specify/commands/speckit/analyze.md` | Cross-artifact analysis |
| `/speckit:checklist` | `.specify/commands/speckit/checklist.md` | Generate checklist |
| `/speckit:constitution` | `.specify/commands/speckit/constitution.md` | Manage constitution |
| `/speckit:taskstoissues` | `.specify/commands/speckit/taskstoissues.md` | Convert tasks to GitHub issues |
| `/next-issue` | `.specify/commands/next-issue.md` | Pull oldest open issue → speckit |

These commands stay in `.specify/commands/` (not `.claude/commands/`) so they are:
- Not auto-loaded by Claude Code when scanning for project commands (`.claude/` only)
- Not bundled into the plugin cache when the plugin is installed from GitHub
- Symlinked into `.claude/commands/` at dev time only, via the session hook

## How the plugin distribution boundary works

The rkit plugin is distributed by cloning `w3mg/resultkit-skills` from GitHub. Because:

1. The symlinks (`speckit`, `next-issue.md`) are gitignored, they don't exist in the cloned repo
2. The plugin system loads commands from `.claude/commands/` — but finds only `ship-it.md`, `sync-plugin.md`, `close-issue.md` (which are harmless to plugin users)
3. Plugin users never see speckit or next-issue

If you add a new dev-only command, follow this pattern:
1. Put the `.md` file in `.specify/commands/` (or `.specify/commands/<namespace>/`)
2. Add a symlink entry to `.claude/hooks/setup-symlinks.sh`
3. Add the symlink path to `.gitignore`

## Hook: setup-symlinks.sh

**Location**: `.claude/hooks/setup-symlinks.sh`
**Trigger**: `SessionStart` → `startup` (configured in `.claude/settings.json`)

The script is idempotent:
- Valid symlink already exists → skips
- Broken symlink exists → removes and recreates
- Target missing → prints a warning to stderr

To add a new symlink to the hook, edit `.claude/hooks/setup-symlinks.sh` and add a call to either:

```bash
# For a directory symlink
setup_dir_symlink  "$PROJECT_DIR/.claude/commands/<name>"  "$PROJECT_DIR/.specify/commands/<name>"

# For a file symlink
setup_file_symlink "$PROJECT_DIR/.claude/commands/<name>.md"  "$PROJECT_DIR/.specify/commands/<name>.md"
```

## Speckit templates

The speckit workflow uses repo-specific templates and scripts located in `.specify/`:

```
.specify/
├── commands/          # Dev-only command source files (symlinked at dev time)
│   ├── speckit/       # All speckit commands
│   └── next-issue.md
├── memory/
│   └── constitution.md   # Project constitution (speckit uses this)
├── scripts/           # Speckit helper scripts
│   └── bash/
└── templates/         # Spec, plan, tasks templates
```

Do not move or rename `.specify/` — the speckit commands reference it by convention.
