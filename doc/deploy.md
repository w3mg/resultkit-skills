# Deploy Skills

Sync `api-reference.md` to all skill directories and install skills to the local machine.

## Usage

```bash
bash scripts/deploy.sh
```

## What it does

1. Copies `api-reference.md` into each skill's `references/` directory
2. Runs `scripts/install.sh` to deploy all skills to `~/.claude/skills/`

## When to run

- After updating `api-reference.md` (via sync-api workflow or manual edit)
- After modifying any skill SKILL.md or script
- After adding a new skill under `skills/rkit/`
