# Research: Fix Plugin Install Failure

**Branch**: `001-fix-plugin-install` | **Date**: 2026-03-08

## Finding 1: Root Cause Identified

**Decision**: The `source` format in `marketplace.json` is wrong.

**Evidence**: Comparing our `marketplace.json` against the installed `claude-plugins-official` marketplace reveals two valid source formats:

| Format | When Used | Example |
|--------|-----------|---------|
| `"./plugins/plugin-name"` (relative path string) | Plugin lives as a subdirectory of the marketplace repo | `"source": "./plugins/typescript-lsp"` |
| `{ "source": "url", "url": "https://github.com/owner/repo.git" }` | Plugin lives in an external repo | `"source": { "source": "url", "url": "https://github.com/figma/mcp-server-guide.git" }` |

**Our current (broken) format**:
```json
"source": {
  "source": "github",
  "repo": "w3mg/resultkit-skills"
}
```

`"source": "github"` with a `"repo"` field is **not a recognized format** in the working plugin system. There is no example of this pattern in any working plugin. This causes the install system to fail when attempting the GitHub download/cache step.

**Rationale**: Since the `rkit` plugin lives in the root of the `w3mg/resultkit-skills` GitHub repo (not as a subdirectory of another repo), the correct format is the URL format used by external plugins.

**Alternatives Considered**:
- Add `"path": "."` to existing source object — rejected: `"source": "github"` is not recognized regardless of additional fields
- Restructure repo into `plugins/rkit/` subdirectory — rejected: overly complex, requires repo reorganization; URL format achieves same result with one line change
- Report as Claude Code platform bug — rejected: the issue is in our configuration, not in Claude Code

## Finding 2: Correct Fix

**Decision**: Change `marketplace.json` plugins source from the unrecognized `github` format to the `url` format.

**Before**:
```json
"source": {
  "source": "github",
  "repo": "w3mg/resultkit-skills"
}
```

**After**:
```json
"source": {
  "source": "url",
  "url": "https://github.com/w3mg/resultkit-skills.git"
}
```

**Rationale**: This matches exactly how figma, atlassian, Notion, slack, vercel, and other external-repo plugins are registered in the official Anthropic marketplace. The `.git` suffix is consistent with all URL-format source entries.

## Finding 3: plugin.json Is Not the Problem

**Decision**: `plugin.json` requires no changes.

**Rationale**: The marketplace add step (which reads `marketplace.json`) succeeds. The failure is at install time when the system tries to fetch the plugin source referenced in `marketplace.json`. `plugin.json` is only read after the plugin files are fetched, so it cannot be the cause of the pre-download failure.

## Finding 4: No $schema in Our marketplace.json

**Decision**: Add `$schema` field to match the official format standard.

**Evidence**: The working `claude-plugins-official/marketplace.json` has:
```json
"$schema": "https://anthropic.com/claude-code/marketplace.schema.json"
```
Our `marketplace.json` is missing this. While likely not causing the install failure, it should be added for correctness and future validation.
