# Project Handoffs

**Last Updated**: 2026-02-23

## Active

- [ ] **003-board**: `/speckit.clarify` complete (5/5). Spec updated with US5 (remove). **Next step**: `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`.
- [ ] **004-weekly**: Full spec + plan + research ready in `specs/004-weekly/`. Needs tasks → implement after 003 is done
- [ ] **011-1on1**: Spec drafted in `specs/011-1on1/spec.md`. One-on-one specific skill (`/rkit:1on1`), separate from project meetings (`/rkit:meeting`). Follows weekly skill patterns — same column display, move/add/remove flows, confirm-before-write. **Next step**: clarify → plan → implement.

## Clarifications Completed (003-board, session 2026-02-16)

1. Max columns: Cap at 10; show "(N more columns not shown)" if exceeded
2. Default board ID: Support `default_board_id` in config with "ask to confirm" option. Always confirm before writes. If not set, prompt user.
3. Duplicate column names: List matches with IDs, ask user to pick. If user is an editor, suggest renaming one.
4. Remove/archive: Board supports remove (re-parent/orphan). Archive deferred to future `rkit:archive` skill.
5. Remove flow: Prompt user — remove from all projects (orphan + offer day plan), move to another project, or move to a one-on-one/other source. Orphan mechanic hidden behind friendly language.

## Pending Re-evaluation

- [ ] **005-add**: Conflates "board" with "team weekly". Re-evaluate after 003-board and 004-weekly are complete
- [ ] **006-status**: Uses "board" when it means "team weekly". Re-evaluate after 003-board and 004-weekly are complete
- [ ] **009-team**: References "board" ambiguously. Re-evaluate after 003-board and 004-weekly are complete

## Future Skills to Define

- [ ] **rkit:move**: Item move skill — re-parent an item to a different parent (`PUT /items/{id}/move` with `parent_id`). Needed for board column moves and general item tree reorganization. Determine if this is standalone or part of `rkit:item`.
- [ ] **rkit:archive**: Item archive skill — soft-delete an item (`DELETE /items/{id}`, sets status=archived). Determine if this is standalone or part of `rkit:item`. Clarify relationship to board remove (removing from a column vs archiving entirely).

## Open Issues

- [x] **Plugin cache not picking up new skills on marketplace update** — **RESOLVED 2026-02-22**
  - **Root cause**: The plugin cache is keyed by the `version` field in `plugin.json`. Code changes without a version bump are invisible to users because the cache serves the old version. The original failure was pushing new skills without bumping the version first.
  - **Fix**: Always bump `version` in `plugin.json` before pushing. The `/plugin-dev publish` skill now enforces this workflow (sync shared files → bump version → commit → push).
  - **How updates actually work** (from official docs):
    1. Cache lives at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`
    2. `claude plugin update` pulls latest from source and creates a new cache entry only if version changed
    3. Version can be set in `plugin.json` or `marketplace.json` — `plugin.json` takes priority if both are set
    4. Old cache versions are marked with `.orphaned_at` but not immediately deleted
  - **Current state**: Cache has both `1.0.0/` (orphaned) and `1.1.0/` with all 6 skills. Published v1.1.1 with correct workflow.
  - **Developer tooling added**: `.claude/skills/plugin-dev/SKILL.md` — project-local skill with validate, publish, status, diagnose, scaffold, and info commands. Encodes the full plugin lifecycle so future sessions don't repeat this mistake.

- [x] **api.sh path resolver glob doesn't match plugin cache structure** — **RESOLVED 2026-02-22**
  - **Root cause**: SKILL.md used `$HOME/.claude/plugins/*/rkit/skills/...` but cache path is `$HOME/.claude/plugins/cache/resultkit/rkit/<version>/skills/...`. Missing `cache/`, marketplace name, and version directory levels.
  - **Fix**: Replaced all 5 skill path resolvers (setup, today, board, weekly, projects) to: (1) check `${CLAUDE_PLUGIN_ROOT}` first (the official plugin env var), (2) fall back to corrected cache glob `$HOME/.claude/plugins/cache/*/rkit/*/skills/<name>/scripts/api.sh`, (3) then legacy paths. Also updated the scaffold template in `/plugin-dev`.

- [ ] **API gap**: Item detail and item summary responses should return team context (team_id, framework, etc.) so board skill can derive team context from an item without a separate team lookup. Affects 003-board and potentially 008-item.

## Completed

- [x] **001-setup**: Merged
- [x] **002-today**: Merged
