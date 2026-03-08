# Feature Specification: Fix Plugin Install Failure

**Feature Branch**: `001-fix-plugin-install`
**Created**: 2026-03-08
**Status**: Draft
**Input**: GitHub Issue #24: [Bug] /plugin install rkit@resultkit fails during GitHub cache step

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fresh Plugin Install Succeeds (Priority: P1)

A new user discovers the ResultKit plugin, adds the marketplace, and runs `/plugin install rkit@resultkit`. The command completes successfully, the plugin is cached, and skills are immediately available in their Claude Code session.

**Why this priority**: This is the primary installation path and currently completely broken. No user can install the plugin without the manual workaround. This is the blocker.

**Independent Test**: Can be fully tested by running `/plugin marketplace add w3mg/resultkit-skills` followed by `/plugin install rkit@resultkit` on a clean machine and verifying skills load.

**Acceptance Scenarios**:

1. **Given** a clean environment with no rkit plugin installed, **When** the user runs `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`, **Then** the install completes without error and `~/.claude/plugins/cache/resultkit/rkit/<version>/` exists with plugin files
2. **Given** a successful install, **When** the user starts a new Claude Code session, **Then** all `rkit:*` skills are available
3. **Given** a successful install, **When** `installed_plugins.json` is inspected, **Then** an `rkit@resultkit` entry exists with the correct version, installPath, and gitCommitSha

---

### User Story 2 - Plugin Update Works After Initial Install (Priority: P2)

An existing user who has the plugin installed runs `/plugin marketplace update` to get the latest version. The update completes and they get access to new skill versions.

**Why this priority**: Without a working install, updates are secondary. But once install is fixed, update must also work so users aren't stuck on the version they manually installed.

**Independent Test**: Can be tested by having a working install at an older version, then running `/plugin marketplace update` and verifying the cache and installed_plugins.json reflect the new version.

**Acceptance Scenarios**:

1. **Given** an outdated plugin is installed, **When** the user runs `/plugin marketplace update`, **Then** the cache is updated to the new version and `installed_plugins.json` reflects the new version and gitCommitSha
2. **Given** a failed update (network issue), **When** the update fails, **Then** the previous working install remains intact and usable

---

### Edge Cases

- What happens if the user runs `/plugin install rkit@resultkit` without first adding the marketplace?
- What happens if the network is unavailable during the GitHub download step?
- What if an older version of the plugin is already cached — does install use the cache or re-download?
- What if `installed_plugins.json` already has an `rkit@resultkit` entry (reinstall scenario)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The `marketplace.json` file MUST correctly describe the `rkit` plugin source so the Claude Code plugin system can locate and download it
- **FR-002**: The plugin source entry in `marketplace.json` MUST use the format recognized by the install system (e.g., `{ "source": "url", "url": "https://...git" }` for external repos) to correctly resolve and fetch the plugin
- **FR-003**: Running `/plugin install rkit@resultkit` MUST result in the plugin files being placed in `~/.claude/plugins/cache/resultkit/rkit/<version>/`
- **FR-004**: Running `/plugin install rkit@resultkit` MUST result in an `rkit@resultkit` entry in `~/.claude/plugins/installed_plugins.json` with correct `installPath`, `version`, and `gitCommitSha`
- **FR-005**: After a successful install, all `rkit:*` skills MUST be available in Claude Code without any manual file copying or JSON editing
- **FR-006**: The fix MUST NOT break the existing manual workaround for users who have already applied it — they should be able to run `/plugin marketplace update` to migrate to the official install

### Key Entities

- **marketplace.json**: The plugin catalog file at `.claude-plugin/marketplace.json` that describes available plugins and their source locations. The `plugins[].source` entry may need a `path` field to indicate the plugin lives at the repo root.
- **plugin.json**: The plugin manifest at `.claude-plugin/plugin.json` that describes the plugin itself (name, version, skills). Must match what the install system expects.
- **Plugin cache**: The directory structure at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` where the install system places plugin files.
- **installed_plugins.json**: The registry at `~/.claude/plugins/installed_plugins.json` that tracks what is installed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with no prior rkit install can go from zero to working skills in under 3 minutes using only the documented install commands (no manual file copying)
- **SC-002**: 100% of users who follow the documented install steps (`/plugin marketplace add` + `/plugin install`) end up with a working plugin — no install failures due to missing `path` or configuration fields
- **SC-003**: The install process requires zero manual intervention (no editing JSON files, no running bash commands outside of the two documented `/plugin` commands)
- **SC-004**: Users who applied the manual workaround can migrate to the official install path by running `/plugin marketplace update` without data loss or skill disruption

## Assumptions

- The root cause is the wrong source format in `marketplace.json` — the install system does not recognize `{ "source": "github", "repo": "..." }` and requires `{ "source": "url", "url": "https://...git" }` for external repos (confirmed via research)
- The `plugin.json` format is already correct and does not need changes (assumption based on the fact that the marketplace add step works)
- If changing to `url` format does not fix the issue, restructuring the repo (moving `rkit` into a `plugins/rkit/` subdirectory) is in scope as a fallback
- This fix does not require changes to Claude Code internals — it is purely a configuration change in this repository
- The issue is not OS-specific; the fix will apply to all platforms
