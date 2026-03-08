# Research: Remove Speckit from Plugin Distribution

**Branch**: `031-remove-speckit` | **Date**: 2026-03-08

## Finding 1: How the plugin system loads commands

**Decision**: The Claude Code plugin system loads commands from a **top-level `commands/` directory** at the plugin root (by convention), not from `.claude/commands/`.

**Evidence**:
- Official plugins (e.g., `commit-commands`, `pr-review-toolkit`) have a `commands/` directory at the top level of their repo — no `.claude/` prefix
- The rkit plugin is the exception: it uses `.claude/commands/` because that's where Claude Code reads project-level commands when a developer works inside the repo
- When rkit is installed as a plugin, the full repo is copied to `~/.claude/plugins/cache/resultkit/rkit/<version>/`, and Claude Code scans that directory for `.claude/` subdirectories, loading `.claude/commands/` as plugin-level commands

**Root cause**: The rkit repo conflates **repo-level dev tooling** (`.claude/commands/`) with **plugin-distributed commands**. There is no separation today.

## Finding 2: No .pluginignore mechanism found

**Decision**: There is no `.pluginignore` (or equivalent) mechanism in the Claude Code plugin system.

**Evidence**: No `.pluginignore` file found in any installed plugin cache or marketplace directory. All official plugins rely on convention-based directory structure rather than exclusion rules.

**Implication**: We cannot exclude specific files/directories from plugin distribution via an ignore file. The fix must be structural.

## Finding 3: plugin.json `"skills"` field as a discovery override

**Decision**: The `"skills": "./skills/"` field in the rkit `plugin.json` likely restricts skills discovery to the top-level `skills/` directory, preventing `.claude/skills/` from being loaded as plugin-level skills.

**Evidence**:
- Official plugins have no `"skills"` field in `plugin.json` — discovery is purely convention-based
- The rkit plugin has `.claude/skills/` in its cache directory, but only `skills/` content is loaded as `rkit:*` skills
- This suggests `"skills": "./skills/"` overrides the default discovery path

**Hypothesis**: Adding `"commands": "./commands/"` to `plugin.json` (pointing to an empty or intentional directory) would similarly redirect commands discovery away from `.claude/commands/`.

## Finding 4: Official plugin.json schema is minimal

**Decision**: Official `plugin.json` only contains `name`, `description`, and `author`. The rkit plugin has additional non-standard fields (`version`, `repository`, `license`, `skills`) that may be custom extensions interpreted by the plugin system.

**Alternatives Considered**:
- `"commands": false` to disable commands loading — unknown if supported; `"commands": "./commands/"` is more consistent with `"skills"` convention
- Move dev commands to `.dev/commands/` — devs would lose automatic project-level loading; rejected as too disruptive
- Separate speckit plugin install for devs — viable but changes dev onboarding; `"commands"` field approach is simpler if supported

## Finding 5: Scope includes all dev-only commands, not just speckit

**Decision**: The fix must exclude all of the following from plugin distribution:
- `.claude/commands/speckit/` (all speckit workflow commands)
- `.claude/commands/ship-it.md`
- `.claude/commands/sync-plugin.md`
- `.claude/commands/next-issue.md`
- `.claude/commands/close-issue.md`

**Evidence**: All five are present in the installed plugin cache (confirmed at `~/.claude/plugins/cache/resultkit/rkit/1.2.38/.claude/commands/`). None are relevant to rkit plugin end-users.

## Finding 6: plugin.json "commands" field is additive-only — confirmed via official docs

**Decision**: The `plugin.json` approach will NOT work.

**Evidence** (from https://code.claude.com/docs/en/plugins-reference):
> "Custom paths supplement default directories — they don't replace them."
> "If `commands/` exists, it's loaded in addition to custom command paths."

Adding `"commands": "./commands/"` would ADD a new commands directory on top of whatever defaults are already loaded. There is no `exclude` field, no `.pluginignore`, and no way to suppress a directory via manifest configuration.

**Conclusion**: The plugin.json manifest approach is a dead end. The fix must be structural.

## Recommended Fix

**Remove `.claude/commands/speckit/` from the repo entirely.**

Speckit is already available to developers as Claude Code skills via the installed `example-skills@anthropic-agent-skills` plugin. The repo-local copy in `.claude/commands/speckit/` is redundant. Deleting it:
- Eliminates speckit from the plugin distribution (no more leaked commands)
- Has zero impact on dev workflow (speckit continues working via the plugin)
- Requires no plugin system changes, no manifest changes, no developer setup steps

The `.specify/` directory (templates, constitution, scripts) remains untouched — that's what makes speckit work for this repo's workflow.

**Other dev commands** (`ship-it`, `sync-plugin`, `next-issue`, `close-issue`) stay in `.claude/commands/` — they are repo-specific and have no standalone alternative. They remain in the plugin bundle but are out of scope for this fix.
