---
description: Sync shared files across all rkit plugin skills. Copies master api.sh and api-reference.md to each skill, then bumps the plugin version.
---

## Sync Plugin

Perform the following steps in order:

### 1. Sync api.sh

The master copy is `scripts/api.sh` at the repo root. Copy it into every skill's `scripts/` folder and make executable:

```bash
for skill in skills/*/; do
  mkdir -p "$skill/scripts"
  cp scripts/api.sh "$skill/scripts/api.sh"
  chmod +x "$skill/scripts/api.sh"
done
```

Report which skills were updated.

### 2. Sync api-reference.md

The master copy is `api-reference.md` at the repo root. Copy it into each skill that has a `references/api-reference.md`:

```bash
for skill in skills/*/; do
  if [ -f "$skill/references/api-reference.md" ]; then
    cp api-reference.md "$skill/references/api-reference.md"
  fi
done
```

Report which skills received the updated reference.

### 3. Bump version in all manifests

Read `.claude-plugin/plugin.json`. Increment the patch version (e.g. `1.0.0` -> `1.0.1`). If the user provided an argument, use it as the new version instead:

```text
$ARGUMENTS
```

If `$ARGUMENTS` is a valid semver string, use it. Otherwise auto-increment the patch.

Update the `version` field in **both** manifest files to the same version:
- `.claude-plugin/plugin.json` (Claude Code)
- `gemini-extension.json` (Gemini CLI)

### 4. Report

Print a summary:

- Files synced (api.sh count, api-reference.md count)
- New version (applied to both manifests)
- Reminder: commit and push to publish the update
