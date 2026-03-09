# Quickstart: Strategy Skill (rkit:strategy)

**Branch**: `001-strategy-skill` | **Date**: 2026-03-09

## Prerequisites

- `~/.config/resultkit/config.json` with valid `api_token` and `default_team_id`
- Claude Code with rkit plugin installed

## Usage

### View Strategy Tree

```
/rkit:strategy
/rkit:strategy year=2025
/rkit:strategy year=All
/rkit:strategy quarter=2
```

### Create Strategy Object

```
/rkit:strategy create "New Annual Goal"
/rkit:strategy create "Improve Onboarding" under "Annual Goal"
/rkit:strategy create "Revenue Focus Area" --focus-area
/rkit:strategy create "Q1 Rock" under "Annual Goal" due=2026-03-31 assignees="Patrick"
```

### Update Strategy Object

```
/rkit:strategy update "Improve Onboarding" status=complete
/rkit:strategy update "Q1 Rock" name="Q1 Rock: Partner Launch" due=2026-06-30
```

### Align (Link) Object to Parent

```
/rkit:strategy align "Unlinked Rock" under "Annual Goal"
```

### Detach Object from Parent

```
/rkit:strategy detach "Old Rock" from "Annual Goal"
/rkit:strategy detach "Old Rock" from "Annual Goal" --archive
```

## Example Output (View)

```
Strategy for Patricks [EOS] Team (eos) — 2026 Q1

🟢 Yearly Goal: Hit $10M ARR (#6520, due 2026-12-31)
  🟢 Rock: Improve onboarding (#6528, due 2026-03-31, → Patrick A.)
    ⚪ Milestone: Reduce time to first value (#153685, due 2026-03-31)
    ⚪ Milestone: Automate welcome sequence (#153686, due 2026-03-31)
  🟡 Rock: Launch partner program (#6529, due 2026-03-31)

Unaligned:
  🟢 Rock: Internal tooling cleanup (#7281, due 2026-03-31)
```

## Implementation Files

| File | Purpose |
|------|---------|
| `skills/strategy/SKILL.md` | Skill entry point |
| `skills/strategy/scripts/api.sh` | Shared API caller (copied from master) |
| `skills/strategy/references/api-reference.md` | API reference (copied from master) |
