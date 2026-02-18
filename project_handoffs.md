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

- [ ] **API gap**: Item detail and item summary responses should return team context (team_id, framework, etc.) so board skill can derive team context from an item without a separate team lookup. Affects 003-board and potentially 008-item.

## Completed

- [x] **001-setup**: Merged
- [x] **002-today**: Merged
