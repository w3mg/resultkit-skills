# Implementation Plan: rkit:setup

**Branch**: `001-setup` | **Date**: 2026-02-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-setup/spec.md`

## Summary

First-run configuration skill and shared API infrastructure for the
rkit skill suite. Creates `~/.config/resultkit/config.json` via guided
setup, verifies token against the ResultMaps API, and provides the
shared `api.sh` script that all other rkit skills depend on.

## Technical Context

**Language/Version**: Bash 5.x (api.sh, helper scripts), Markdown
(SKILL.md entry point)
**Primary Dependencies**: Claude Code runtime, curl, jq
**Storage**: JSON file at `~/.config/resultkit/config.json`
**Testing**: Manual invocation via `/rkit:setup` in Claude Code
**Target Platform**: Claude Code on macOS/Linux
**Project Type**: Single project (skill suite)
**Performance Goals**: Setup completes in < 2 minutes; API calls
return within 5 seconds
**Constraints**: No external runtimes, no package managers, POSIX-
compatible paths
**Scale/Scope**: Single-user config, 1 skill + 1 shared script

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1
design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | ✅ Pass | SKILL.md entry point, Bash support script |
| II | Self-Contained | ✅ Pass | No project context needed, works from any directory |
| III | Config-Driven | ✅ Pass | This skill creates the config file |
| IV | Confirm Writes | ✅ Pass | Confirms before writing config |
| V | Show IDs | ✅ Pass | Team IDs shown in selection list |
| VI | Framework-Aware | ✅ Pass | Team framework type displayed during selection |
| VII | Direct Execution | ✅ Pass | Bash tool + api.sh for all API calls |
| VIII | Graceful Degradation | ✅ Pass | Handles invalid tokens, no teams, filesystem errors |
| IX | Concise Output | ✅ Pass | Clean table/summary output |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-setup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── get-users-me.md
│   └── get-users-id-teams.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
skills/rkit/setup/
├── SKILL.md              # Skill entry point (Claude Code format)
└── references/
    └── api-reference.md  # Symlink or copy of API reference

scripts/
└── api.sh                # Shared API caller for all rkit skills
```

**Structure Decision**: Skill files follow the Claude Code skill
convention (`SKILL.md` + references). The shared `api.sh` lives at
repo root under `scripts/` so all skills can reference a single
install path. The install script copies both to `~/.claude/skills/`.

## Complexity Tracking

No constitution violations — section intentionally empty.
