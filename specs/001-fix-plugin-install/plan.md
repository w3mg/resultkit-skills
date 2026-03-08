# Implementation Plan: Fix Plugin Install Failure

**Branch**: `001-fix-plugin-install` | **Date**: 2026-03-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-fix-plugin-install/spec.md`

## Summary

The `/plugin install rkit@resultkit` command fails because `marketplace.json` uses an unrecognized `{ "source": "github", "repo": "..." }` source format. The Claude Code plugin system only recognizes relative paths (`"./plugins/name"`) for in-repo plugins and `{ "source": "url", "url": "https://...git" }` for external repos. Changing the source format to the URL pattern (matching figma, slack, Notion, and other external plugins in the official marketplace) will resolve the install failure. This is a one-file, one-field change.

## Technical Context

**Language/Version**: JSON (configuration file)
**Primary Dependencies**: Claude Code plugin system (Claude Code production)
**Storage**: N/A
**Testing**: Manual — run `/plugin install rkit@resultkit` on a clean environment
**Target Platform**: Claude Code (all platforms — macOS, Linux)
**Performance Goals**: N/A — install is a one-time operation
**Constraints**: Change must be backward-compatible with users who applied the manual workaround
**Scale/Scope**: 1 file changed, 1 field updated

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This feature modifies plugin configuration only — no skills are changed.

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | No skill files changed |
| II. Self-Contained | PASS | No skill dependencies change |
| III. Config-Driven | PASS | No hardcoded values introduced |
| IV. Confirm Writes | N/A | No skill behavior changes |
| V. Show IDs | N/A | No skill behavior changes |
| VI. Framework-Aware | N/A | No skill behavior changes |
| VII. Direct Execution | N/A | No skill behavior changes |
| VIII. Graceful Degradation | N/A | No skill behavior changes |
| IX. Concise Output | N/A | No skill behavior changes |

**Constitution Check Result**: PASS — all applicable principles satisfied.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-plugin-install/
├── plan.md              # This file
├── research.md          # Phase 0 output ✅
├── data-model.md        # N/A — no data model (config change only)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
.claude-plugin/
├── marketplace.json     # CHANGE: update plugins[0].source format
└── plugin.json          # NO CHANGE required
```

No new files. No new directories. One field in one file.

## Implementation Design

### The Change

**File**: `.claude-plugin/marketplace.json`

**Before** (broken — unrecognized format):
```json
{
  "name": "rkit",
  "source": {
    "source": "github",
    "repo": "w3mg/resultkit-skills"
  },
  "description": "Daily planning, team boards, and item management via ResultMaps API"
}
```

**After** (correct — matches external plugin pattern):
```json
{
  "name": "rkit",
  "source": {
    "source": "url",
    "url": "https://github.com/w3mg/resultkit-skills.git"
  },
  "description": "Daily planning, team boards, and item management via ResultMaps API"
}
```

Additionally, add `$schema` to the top-level marketplace.json object to match the official format.

### Why This Works

The Claude Code plugin install system recognizes two source formats:
1. **Relative path string** (`"./plugins/name"`) — for plugins that are subdirectories of the marketplace repo
2. **URL object** (`{ "source": "url", "url": "https://....git" }`) — for plugins in external repos

Our plugin lives in its own repo (`w3mg/resultkit-skills`), so format #2 is correct. Format #2 is used by figma, atlassian, Notion, slack, vercel, and every other external repo in the official Anthropic marketplace.

### Backward Compatibility

Users who applied the manual workaround (copying files and editing `installed_plugins.json`) will not be broken. When they run `/plugin marketplace update`, the system will fetch the updated marketplace.json, see the corrected source, and be able to update their install via the official path. Their existing manually-installed version remains functional until they choose to update.

## Quickstart: Verifying the Fix

```bash
# 1. On a clean machine (or after removing existing install):
# Remove existing plugin state if needed:
# rm -rf ~/.claude/plugins/cache/resultkit
# Remove rkit@resultkit from ~/.claude/plugins/installed_plugins.json

# 2. Add marketplace (or re-add):
/plugin marketplace add w3mg/resultkit-skills

# 3. Install plugin:
/plugin install rkit@resultkit

# 4. Verify:
ls ~/.claude/plugins/cache/resultkit/rkit/
# Should show: <version>/

# 5. Check installed_plugins.json:
cat ~/.claude/plugins/installed_plugins.json | jq '."rkit@resultkit"'
# Should show entry with installPath, version, gitCommitSha

# 6. Start new Claude Code session and run:
/rkit:today
# Should work without errors
```

## Complexity Tracking

No constitution violations. No complexity justification needed.
