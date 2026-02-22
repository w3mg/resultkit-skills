# Project Handoffs

**Last Updated**: 2026-02-16

## Active

- [ ] **003-board**: `/speckit.clarify` complete (5/5). Spec updated with US5 (remove). **Next step**: `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`.
- [ ] **004-weekly**: Full spec + plan + research ready in `specs/004-weekly/`. Needs tasks → implement after 003 is done

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

- [ ] **Plugin cache not picking up new skills on marketplace update**
  - **Symptom**: After adding `skills/projects/` and running `/plugin marketplace update`, the cache at `~/.claude/plugins/cache/resultkit/rkit/1.0.0/skills/projects/` gets the subdirectories (`scripts/`, `references/`) but NOT `SKILL.md`. Other existing skills (today, board, etc.) have their SKILL.md in the cache.
  - **What was tried**: Bumped `plugin.json` version from 1.0.0 to 1.1.0 and pushed. Marketplace update then entered an infinite loop asking the user what to do. The cache directory still shows version `1.0.0/` — the 1.1.0 bump didn't create a new cache folder.
  - **Workaround applied**: Manually copied SKILL.md into the cache (`cp skills/projects/SKILL.md ~/.claude/plugins/cache/resultkit/rkit/1.0.0/skills/projects/SKILL.md`). This works but doesn't solve the deployment pipeline.
  - **Things to investigate**:
    1. How does `/plugin marketplace update` decide what to pull? Does it diff against the cached version or re-clone?
    2. Does the version bump in `plugin.json` require a corresponding change in `marketplace.json`?
    3. Is there a `.gitattributes`, GitHub release tag, or branch requirement that controls what gets fetched?
    4. Check if other plugins in `~/.claude/plugins/` follow a different cache versioning pattern
    5. The cache stayed at `1.0.0/` even after pushing `1.1.0` — is the cache keyed by the version at install time?
  - **Files involved**: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `~/.claude/plugins/cache/resultkit/`

- [ ] **API gap**: Item detail and item summary responses should return team context (team_id, framework, etc.) so board skill can derive team context from an item without a separate team lookup. Affects 003-board and potentially 008-item.

## Completed

- [x] **001-setup**: Merged
- [x] **002-today**: Merged
