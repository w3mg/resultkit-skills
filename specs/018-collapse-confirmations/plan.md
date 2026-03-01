# Implementation Plan: Collapse Redundant Confirmations

**Branch**: `018-collapse-confirmations` | **Date**: 2026-03-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/018-collapse-confirmations/spec.md`

## Summary

Reduce user-facing confirmation friction in all `rkit:*` skills by: (1) replacing blanket `Bash` with scoped `Bash(command *)` patterns in `allowed-tools` frontmatter, (2) adding `Glob` and `Grep` to all skills' `allowed-tools`, and (3) collapsing sequential `AskUserQuestion` confirmations where multiple prompts serve a single intent. The constitution's "Confirm Writes" principle (IV) will be amended to codify the "one confirmation per mutating batch" pattern.

## Technical Context

**Language/Version**: Markdown (SKILL.md skill format) + Bash 5.x (api.sh)
**Primary Dependencies**: Claude Code skill runtime, `allowed-tools` frontmatter
**Storage**: N/A
**Testing**: Manual invocation of each skill to verify prompt reduction
**Target Platform**: Claude Code CLI (any OS)
**Project Type**: Single (plugin skill files)
**Performance Goals**: N/A
**Constraints**: Must comply with constitution; must not remove confirmations for genuinely distinct decisions
**Scale/Scope**: 13 SKILL.md files + 1 constitution file

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Changes are to SKILL.md frontmatter and instructions — no format change |
| II. Self-Contained | PASS | No new inter-skill dependencies |
| III. Config-Driven | PASS | No config changes |
| IV. Confirm Writes | **AMEND** | Must update to codify "one confirmation per mutating batch" and scoped `allowed-tools` |
| V. Show IDs | PASS | No change to output format |
| VI. Framework-Aware | PASS | No change to framework handling |
| VII. Direct Execution | PASS | Still uses Bash + api.sh directly |
| VIII. Graceful Degradation | PASS | No change to error handling |
| IX. Concise Output | PASS | No change to output format |

**Gate result**: PASS with one amendment required (Principle IV). Amendment is part of the deliverable, not a blocker.

## Project Structure

### Documentation (this feature)

```text
specs/018-collapse-confirmations/
├── plan.md              # This file
├── research.md          # Phase 0 output (complete)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/
├── 1on1/SKILL.md          # Frontmatter update
├── board/SKILL.md          # Frontmatter update + collapse remove flow
├── braindump/SKILL.md      # Frontmatter update
├── concepts/SKILL.md       # Frontmatter update (minimal)
├── headlines/SKILL.md      # Frontmatter update
├── projects/SKILL.md       # Frontmatter update
├── level10/SKILL.md        # Frontmatter update
├── result-feed/SKILL.md    # Frontmatter update
├── setup/SKILL.md          # Frontmatter update (unique patterns)
├── teams/SKILL.md          # Frontmatter update
├── result-update/SKILL.md  # Frontmatter update
├── weekly/SKILL.md         # Frontmatter update
└── today/SKILL.md          # Frontmatter update

.specify/memory/
└── constitution.md         # Principle IV amendment
```

**Structure Decision**: No new files created. All changes are edits to existing SKILL.md frontmatter/instructions and the constitution.

## Frontmatter Design

### Scoped `allowed-tools` per skill category

**Category A — API skills using `date`** (braindump, result-update, today):
```yaml
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Bash(date *), Read, Glob, Grep, AskUserQuestion
```

**Category B — API skills without `date`** (1on1, board, headlines, projects, level10, result-feed, teams, weekly):
```yaml
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion
```

**Category C — Setup** (unique commands, needs Write + AskUserQuestion for config write confirmation):
```yaml
allowed-tools: Bash(curl *), Bash(jq *), Bash(mkdir -p *), Read, Glob, Grep, Write, AskUserQuestion
```

**Category D — Reference** (concepts):
```yaml
allowed-tools: Read, Glob, Grep
```

### Changes from current state

| Change | Before | After | Impact |
|--------|--------|-------|--------|
| Bash scoping | `Bash` (blanket) | `Bash(scripts/api.sh *)`, `Bash(jq *)`, etc. | Security improvement |
| Glob added | Not present | `Glob` | Eliminates file-find permission prompts |
| Grep added | Not present | `Grep` | Eliminates content-search permission prompts |
| Setup patterns | `Bash` (blanket) | `Bash(curl *)`, `Bash(jq *)`, `Bash(mkdir -p *)` | Scoped to actual commands |
| Concepts | No allowed-tools | `Read, Glob, Grep` | Enables reference lookups |

## Instruction Changes

### rkit:board — Collapse Remove Flow

**Current**: Remove option 1 has 2 sequential confirmations (remove from projects → add to day plan).

**New**: Single confirmation summarizing both actions:
> "Remove {item_name} from all projects and add to your day plan?"

If user confirms, execute both. If user declines, abort both.

### All skills — Standardize Confirmation Pattern

Ensure every skill's "Confirm writes" rule follows this pattern:
> Before any mutating API call (POST/PUT/PATCH/DELETE), summarize all planned changes in a single prompt. If the user's command implies multiple related mutations, batch them under one confirmation.

### Constitution Amendment (Principle IV)

**Current**:
> POST/PUT/PATCH/DELETE MUST describe the action and ask for confirmation before executing.

**Amended**:
> POST/PUT/PATCH/DELETE MUST describe the action and ask for confirmation before executing. When multiple mutations serve a single user intent (e.g., remove + re-parent), they MUST be batched under one confirmation prompt — no redundant sequential confirmations. Skills MUST use scoped `Bash(command *)` patterns in `allowed-tools` frontmatter rather than blanket `Bash`.

## Complexity Tracking

No constitution violations to justify. The Principle IV amendment is additive (clarification, not contradiction).
