# Implementation Plan: Remove Speckit from Plugin Distribution

**Branch**: `031-remove-speckit` | **Date**: 2026-03-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/031-remove-speckit/spec.md`

## Summary

Plugin users who install rkit receive `speckit:*` commands because `.claude/commands/speckit/` lives in the repo and gets bundled into the plugin cache. The `plugin.json` `"commands"` field was investigated and confirmed to be additive-only (cannot exclude directories). The fix is to delete `.claude/commands/speckit/` from the repo. Speckit continues to work for developers via the already-installed `example-skills@anthropic-agent-skills` plugin. No other files change.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill format)
**Primary Dependencies**: Claude Code plugin system, `example-skills@anthropic-agent-skills` (provides speckit skills)
**Storage**: N/A
**Testing**: Manual — verify speckit works after removing `.claude/commands/speckit/`
**Target Platform**: Claude Code (Linux, macOS)
**Project Type**: File deletion + CLAUDE.md doc update
**Performance Goals**: N/A
**Constraints**: `.specify/` directory must remain intact; dev speckit workflow must continue via plugin
**Scale/Scope**: One directory deleted, one doc updated

## Constitution Check

This feature deletes a directory of developer tooling and updates documentation. No `rkit:*` skills are added or modified. All constitution principles are N/A.

| Principle | Status |
|-----------|--------|
| I–IX | ✅ N/A — no skill changes |

## Project Structure

### Documentation (this feature)

```text
specs/031-remove-speckit/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 complete
├── tasks.md             # Phase 2 output (/speckit:tasks command)
└── checklists/          # Generated checklists
```

### Source Changes

```text
.claude/commands/speckit/    ← DELETE entire directory (9 files)
CLAUDE.md                    ← Add note: speckit sourced from example-skills plugin
```

Everything else unchanged. `.specify/`, `skills/`, `.claude/commands/` (other commands) all stay.

## Phase 0: Research (Complete)

See [research.md](research.md).

**Key findings**:
1. Plugin loads `.claude/commands/speckit/` into the plugin cache, exposing it to all plugin users
2. `plugin.json` `"commands"` field is additive-only — confirmed via official docs. Cannot exclude directories.
3. No `.pluginignore` mechanism exists
4. Speckit is already available via `example-skills@anthropic-agent-skills` — the repo copy is redundant
5. Deleting `.claude/commands/speckit/` is the only working fix

## Phase 1: Design

### Change 1 — Delete `.claude/commands/speckit/`

Remove all 9 files:
- `.claude/commands/speckit/analyze.md`
- `.claude/commands/speckit/checklist.md`
- `.claude/commands/speckit/clarify.md`
- `.claude/commands/speckit/constitution.md`
- `.claude/commands/speckit/implement.md`
- `.claude/commands/speckit/plan.md`
- `.claude/commands/speckit/specify.md`
- `.claude/commands/speckit/tasks.md`
- `.claude/commands/speckit/taskstoissues.md`

**Rationale**: These are redundant wrappers — speckit skills are already provided by the `example-skills@anthropic-agent-skills` plugin. Removing them eliminates the plugin distribution leak with zero workflow impact.

### Change 2 — Update CLAUDE.md

Add a note in the dev tooling section documenting that speckit is sourced from `example-skills@anthropic-agent-skills`, not from the repo. Ensures future contributors know not to re-add `.claude/commands/speckit/`.

### Verification

After merging and running `/plugin marketplace update`:

1. In a terminal NOT inside the resultkit-skills repo, confirm no `speckit:*` commands appear from the rkit plugin
2. Inside the repo, confirm `/speckit:specify` still works (via `example-skills` plugin)
3. Run `/next-issue` and confirm the speckit handoff works correctly
4. Confirm `.specify/templates/`, `.specify/memory/constitution.md`, and `.specify/scripts/` are untouched
