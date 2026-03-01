# Quickstart: Collapse Redundant Confirmations

## What's changing

Two things across all 13 `rkit:*` skills:

1. **Frontmatter `allowed-tools`** — replace blanket `Bash` with scoped `Bash(command *)` patterns; add `Glob` and `Grep`
2. **Instruction-level confirmations** — collapse sequential AskUserQuestion calls that serve one intent into a single prompt

Plus one constitution amendment (Principle IV).

## Implementation order

1. Amend constitution Principle IV
2. Update frontmatter in all 13 SKILL.md files (mechanical, per-category)
3. Collapse rkit:board's Remove flow (only sequential redundancy found)
4. Standardize confirmation instruction wording across all skills
5. Sync shared files via `/sync-plugin`
6. Manual smoke test each skill

## Frontmatter reference

Copy-paste the correct `allowed-tools` line per category:

**API skills + date** (braindump, result-update, today):
```
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Bash(date *), Read, Glob, Grep, AskUserQuestion
```

**API skills, no date** (1on1, board, headlines, projects, level10, result-feed, teams, weekly):
```
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion
```

**Setup**:
```
allowed-tools: Bash(curl *), Bash(jq *), Bash(mkdir -p *), Read, Glob, Grep, Write, AskUserQuestion
```

**Concepts (reference only)**:
```
allowed-tools: Read, Glob, Grep
```

## Verification

After each skill update, run it and verify:
- No system-level permission prompts for Bash/Read/Glob/Grep
- Mutating actions still show exactly one confirmation
- Decline aborts the full sequence
