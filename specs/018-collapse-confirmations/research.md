# Research: Collapse Redundant Confirmations

**Branch**: `018-collapse-confirmations` | **Date**: 2026-03-01

## Decision 1: Claude Code `allowed-tools` Frontmatter Syntax

**Decision**: Use `allowed-tools` (hyphenated) in SKILL.md frontmatter to pre-approve specific tools and scoped Bash patterns.

**Rationale**: Claude Code's skill runtime reads `allowed-tools` from frontmatter and auto-approves matching tool calls without user prompts. Supports wildcards: `Bash(scripts/api.sh *)` matches any invocation starting with that prefix.

**Key syntax rules**:
- Comma-separated list or YAML list
- Bash patterns: `Bash(command *)` — space before `*` enforces word boundary
- `Bash(ls *)` matches `ls -la` but NOT `lsof`
- Multiple patterns allowed: `Bash(scripts/api.sh *)`, `Bash(jq *)`
- Read-only tools: `Read`, `Glob`, `Grep` — no risk, should be universally allowed

**Alternatives considered**:
- Blanket `Bash` — rejected per clarification (security concern)
- Global permission rules in settings.json — rejected (per-user, not per-skill)

## Decision 2: Bash Command Patterns Per Skill Category

**Decision**: Three skill categories with distinct Bash patterns.

### Category A: API Skills (11 skills)
Skills: 1on1, board, braindump, headlines, projects, level10, result-feed, result-update, weekly, today, teams

Common patterns:
- `Bash(scripts/api.sh *)` — all API calls go through shared script
- `Bash(jq *)` — JSON response parsing

Additional per-skill:
- Skills using `date`: braindump, result-update, today → add `Bash(date *)`

### Category B: Setup (1 skill)
- `Bash(curl *)` — direct API calls before config exists
- `Bash(jq *)` — JSON parsing
- `Bash(mkdir -p *)` — config directory creation

### Category C: Reference (1 skill)
- concepts — no Bash needed, remove from allowed-tools entirely

**Rationale**: Audit of all 13 SKILL.md files confirmed these are the only Bash commands used. Scoping to exact patterns prevents unintended command execution while eliminating permission prompts for expected operations.

**Alternatives considered**:
- Per-skill unique patterns — rejected (too granular, same commands across all API skills)
- Adding `Bash(cat *)`, `Bash(sed *)` for setup — rejected (setup should use Write tool for file creation)

## Decision 3: Confirmation Audit Findings

**Decision**: Most existing confirmations are **distinct** (separate user decisions), not redundant sequential. The primary changes are:

1. **Frontmatter expansion** — biggest friction reduction (adds Glob, Grep, scopes Bash)
2. **rkit:board Remove flow** — only clear sequential redundancy (remove + optional add to day plan = 2 prompts for 1 intent)
3. **Instruction standardization** — ensure all skills batch related API calls under one confirmation summary

**Audit totals** (current state):

| Skill          | Write Confirmations | Sequential? | Action Needed |
|----------------|--------------------:|:-----------:|---------------|
| rkit:1on1      | 4                   | No          | Frontmatter only |
| rkit:board     | 5                   | **Yes (1)** | Collapse remove+add flow |
| rkit:braindump | 0                   | No          | Frontmatter only |
| rkit:concepts  | 0                   | N/A         | No changes |
| rkit:headlines | 3                   | No          | Frontmatter only |
| rkit:projects  | 2                   | No          | Frontmatter only |
| rkit:level10   | 8                   | No          | Frontmatter only |
| rkit:result-feed | 0                 | No          | Frontmatter only |
| rkit:setup     | 1                   | No          | Frontmatter + Write tool migration |
| rkit:teams     | 0                   | No          | Frontmatter only |
| rkit:result-update | 4               | No          | Frontmatter only |
| rkit:weekly    | 3                   | No          | Frontmatter only |
| rkit:today     | 5                   | No          | Frontmatter only |

**Rationale**: The original issue cited setup's "team selection + config write" as redundant. The audit confirms most skills follow good practice — one confirmation per write action. The biggest win is eliminating system-level permission prompts via frontmatter.

**Alternatives considered**:
- Removing all AskUserQuestion confirmations — rejected (clarification: keep one per mutating batch)
- Adding batch confirmation patterns to all skills — rejected (most already have single confirmations per action)

## Decision 4: Constitution Impact

**Decision**: Principle IV ("Confirm Writes") needs a minor amendment to codify the "one confirmation per batch" pattern and reference scoped `allowed-tools`.

**Current text**: "POST/PUT/PATCH/DELETE MUST describe the action and ask for confirmation before executing."

**Proposed amendment**: Add clarification that sequential mutations for one intent can be batched under a single confirmation, and that `allowed-tools` frontmatter must use scoped Bash patterns.

**Rationale**: The constitution is the governing document. Changes to confirmation behavior must be reflected there to maintain compliance.
