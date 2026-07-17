# Team Selection UX

The user will hit the team selection step every time they refresh the doc. It needs to be fast on the common path (refresh same selection) and friendly when they want to add or remove teams.

## Goals

1. **One-keystroke refresh.** When the user just wants to update the data for the same teams as last time, they should be able to confirm in one click.
2. **Easy to add or trim.** Changing the selection should be a multi-select diff, not a full re-pick from scratch.
3. **Visually grouped.** A user with 50+ teams should be able to scan the list and find the orgs they care about in seconds.

## On refresh (doc exists)

**First question** — single-select via `AskUserQuestion`:

> Refresh `{path}` — currently tracking {N} teams ({comma-list of org names, max 5; if more, "…and K more"}).
>
> 1. Refresh same selection
> 2. Change which teams are tracked
> 3. Cancel

- `1` → skip to the fetch step. This is the default.
- `2` → ask the multi-select question with the previous selection pre-checked.
- `3` → exit without writing.

## On first run (doc missing)

Skip the single-select. Go straight to the multi-select with no pre-checks. Briefly orient the user:

> First run — let's pick which teams/orgs you want in your reference doc. You can change this anytime by re-running `/rkit:meetings`.

## Multi-select question

Use `AskUserQuestion` with `multiSelect: true`. Build the option list:

1. Fetch all teams: `GET /teams?per_page=100`. Paginate if `meta.total_pages > 1`.
2. Group by `parent_id`:
   - Top-level teams (no `parent_id`, or whose parent isn't in the response) are the "orgs."
   - Child teams nest under their parent.
3. Sort orgs alphabetically. Within each org, sort children alphabetically.
4. Render each option label as `{name} (id: {id})`. Indent children by 2 spaces in the label.
5. On refresh, set `defaultSelected` to the previously-tracked team IDs.

### Example option list

```
☐ Curantis Solutions (id: 2770)
☐   GSD Squad 2 (id: 2784)
☐   Leadership Team (id: 2771)
☐ Mender (id: 2707)
☐   Leadership Team (id: 2713)
☐   Platform Team (id: 2761)
☐ OIT (id: 2552)
☐ ResultMaps Incorporated (id: 345)
```

## Edge cases

- **>50 teams.** Still one multi-select. Splitting it into multiple paged questions is worse — the user loses sight of what they've selected.
- **User picks an org but not its children (or vice versa).** Respect the literal selection. Don't auto-include or auto-exclude. The user knows what they want tracked.
- **Team has no `parent_id`.** Render at top level.
- **Team's `parent_id` points to a team not in the response** (no access). Treat the child as top-level — don't drop it.
- **User cancels mid-selection.** Exit without writing. Don't write a partial doc.

## Why these choices

- **Refresh-same as the default** matches how the skill is actually used: the user sets up their list once, then re-runs it weekly to refresh data. Asking them to re-pick teams every time would make the skill annoying.
- **One multi-select, not a wizard.** A single visible list is easier to scan than a wizard that asks "Add Curantis? Add OIT? Add…" one at a time.
- **Indented grouping over a tree widget.** AskUserQuestion gives us a flat list. Indented labels are the cheapest way to communicate hierarchy without losing single-list scanability.
