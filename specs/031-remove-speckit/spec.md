# Feature Specification: Remove Speckit from Plugin Distribution

**Feature Branch**: `031-remove-speckit`
**Created**: 2026-03-08
**Status**: Draft
**Input**: GitHub Issue #25 — The rkit plugin installs speckit at plugin level, and it shouldn't.

## Background

The rkit plugin repository contains speckit slash commands (`.claude/commands/speckit/`) used during development. When the plugin is distributed and installed, these commands are bundled into the plugin cache, making `speckit:*` commands available to all plugin users globally — even though speckit is unrelated to ResultMaps.

Speckit is already available to developers as a proper Claude Code skill via the `example-skills@anthropic-agent-skills` plugin. The repo-level copy in `.claude/commands/speckit/` is redundant and harmful: it leaks into the plugin distribution. The fix is to remove `.claude/commands/speckit/` from the repo entirely. The `.specify/` directory (templates, scripts, constitution) stays — that's the repo-specific customization that makes speckit work for this workflow.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Plugin install has no speckit (Priority: P1)

A user installs the rkit plugin to get ResultMaps daily planning skills. After installation, only `rkit:*` commands appear. No `speckit:*` commands are registered.

**Why this priority**: This is the core problem. Every rkit plugin install currently pollutes users' command namespace with unrelated development tooling.

**Independent Test**: Fresh install of the rkit plugin into a user environment with no pre-existing speckit installation. Verify no `speckit:*` commands are available after install.

**Acceptance Scenarios**:

1. **Given** a user has no speckit installed, **When** they install the rkit plugin, **Then** no `speckit:*` commands appear in their command list
2. **Given** the rkit plugin is installed, **When** a user lists available slash commands, **Then** only `rkit:*` commands from the plugin are present (along with any other plugins they have)
3. **Given** the rkit plugin is installed, **When** a user types `/speckit`, **Then** no command matches (unless they have speckit installed separately)

---

### User Story 2 - Dev workflow continues via plugin skill (Priority: P2)

A developer working inside the resultkit-skills repository continues to have full access to speckit for feature spec-writing, planning, and task generation — sourced from the `example-skills@anthropic-agent-skills` plugin rather than the local `.claude/commands/speckit/` directory.

**Why this priority**: The fix must not break the existing development workflow. The `.specify/` templates, scripts, and constitution remain in the repo; only the redundant command wrappers are removed.

**Independent Test**: With `.claude/commands/speckit/` removed, open the resultkit-skills repo and verify `/speckit:specify` and other speckit skills still function via the installed plugin.

**Acceptance Scenarios**:

1. **Given** `.claude/commands/speckit/` has been removed, **When** a developer types `/speckit:specify`, **Then** speckit runs normally from the `example-skills` plugin
2. **Given** a developer runs `/next-issue`, **When** speckit is invoked as part of that workflow, **Then** it executes correctly via the plugin-sourced skill

---

### Edge Cases

- What if a user has speckit installed separately from another plugin? The rkit change has no effect on their installation.
- What if a developer does not have `example-skills@anthropic-agent-skills` installed? They must install it to use speckit. This is a prerequisite, not a regression — the repo-local copy was always a workaround, not the authoritative source.
- Other dev-only commands (`ship-it`, `sync-plugin`, `next-issue`, `close-issue`) remain in `.claude/commands/` — they are repo-specific and have no standalone plugin alternative. They continue to be bundled in the plugin distribution but are harmless to end users (they reference repo-specific workflows that don't apply outside the repo). This is out of scope for this fix.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `.claude/commands/speckit/` directory MUST be removed from the repo
- **FR-002**: The `.specify/` directory (templates, scripts, constitution) MUST remain in the repo unchanged
- **FR-003**: The rkit plugin distribution MUST continue to include all `rkit:*` skills under `skills/`
- **FR-004**: All speckit functionality MUST remain available to developers via the `example-skills@anthropic-agent-skills` plugin
- **FR-005**: CLAUDE.md MUST be updated to document that speckit is sourced from the `example-skills` plugin, not the repo

### Assumptions

- The `example-skills@anthropic-agent-skills` plugin is already installed and provides all `speckit:*` skills
- The `.specify/` templates, scripts, and constitution are what give speckit its repo-specific behavior — those stay, only the command wrappers are removed
- The `plugin.json` `"commands"` field was investigated and confirmed to be additive-only (supplements defaults, does not replace them); structural removal is the only working fix

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After publishing the fix, a fresh rkit plugin install results in zero `speckit:*` commands sourced from the rkit plugin
- **SC-002**: All speckit workflows (`/speckit:specify`, `/speckit:plan`, `/speckit:tasks`, etc.) continue to work for developers via the `example-skills@anthropic-agent-skills` plugin
- **SC-003**: The `.specify/` directory (templates, constitution, scripts) is intact and speckit uses repo-specific templates as before
- **SC-004**: The repo has no `.claude/commands/speckit/` directory post-merge
