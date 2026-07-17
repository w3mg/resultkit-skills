# Doc Format

Specification for the file `rkit:meetings` produces and refreshes.

## File location

- Default: `/Users/scottilevy/Development/rk-chief-of-staff/ResultMaps Team and Project IDs.md`
- Override: `meetings_doc_path` in `~/.config/resultkit/config.json`

The file is meant to be the user's stable, human-readable reference. Other Claude sessions grep it to resolve names → IDs ("the Mender team," "my 1:1 with Stacy") without making API calls.

## Top-level structure

```markdown
# ResultMaps Team and Project IDs

Source: ResultMaps V2 API
Last updated: YYYY-MM-DD via /rkit:meetings

<!-- Anything above the start marker is human-owned. Never modify it. -->

<!-- rkit:meetings:start -->
## Teams

| Team | Team ID | Org |
|---|---|---|
| Mender | 2707 | Mender |
| Platform Team | 2761 | Mender |
| Curantis Solutions | 2770 | Curantis Solutions |
| GSD Squad 2 | 2784 | Curantis Solutions |
| OIT | 2552 | OIT |
| ResultMaps Incorporated | 345 | ResultMaps Incorporated |

## Projects

### Mender

| Project | Project ID |
|---|---|
| Mender Pricing Tool RoadMap | 206572 |
| Mender Platform and Portal Sprints | 207411 |

### Curantis Solutions

_None._

(Repeat ### per selected team.)

## One-on-Ones

Pulled YYYY-MM-DD via `GET /1-on-1?group_id={team_id}`.

### Mender

| 1:1 ID | Meeting | Created |
|---|---|---|
| 387 | Scott Levy x yamileth najarro | 2026-05-05 |
| 386 | Scott Levy x Stacy Forsyth | 2026-05-05 |

### Curantis Solutions

_None._

(Repeat ### per selected team.)
<!-- rkit:meetings:end -->

<!-- Anything below the end marker is human-owned. Never modify it. -->
```

## Marker rules

- Auto-managed content lives strictly between `<!-- rkit:meetings:start -->` and `<!-- rkit:meetings:end -->`.
- On refresh, **replace only the lines between the markers**. Lines before the start marker and after the end marker are the user's; never touch them.
- If the file exists without markers, **ask before overwriting**. The user may have hand-written content that looks auto-generated. Two acceptable resolutions:
  1. **Wrap-and-refresh**: wrap the existing auto-looking sections (everything from `## Teams` to the end) in markers, then refresh as usual.
  2. **Full overwrite**: the user explicitly accepts losing the existing content; create the doc from scratch with the standard template.

## Field rules

### Teams table

- `Team` — `/teams[].name`.
- `Team ID` — `/teams[].id`.
- `Org` — if `parent_id` is set, the parent team's name; otherwise the team's own name. The point is to disambiguate names like "Leadership Team" that appear under multiple parents.
- Sort: by `Org` ascending, then within an org the parent team first, then children by name ascending.

### Projects subsection

One `### {Team Name}` per selected team, in the same order as the Teams table.

- `Project` — `/teams/{id}/projects[].name`.
- `Project ID` — `.id`.
- Sort by name ascending.
- Empty result: render `_None._` (italicized) — don't drop the heading.

### One-on-Ones subsection

One `### {Team Name}` per selected team, in the same order as the Teams table.

- `1:1 ID` — `/1-on-1[].id`.
- `Meeting` — `.human_name`. If null/empty, fall back to `1:1 Meeting #{id}`.
- `Created` — first 10 chars of `.created_at` (`YYYY-MM-DD`).
- Sort newest first (by `created_at` desc).
- Empty result: `_None._`.

## Header line

The line `Last updated: YYYY-MM-DD via /rkit:meetings` lives **above the start marker** so it's part of the human-owned area but still auto-friendly to read. On refresh, **also update this line** as a special exception. (It's the one piece of "human-owned" text the skill is allowed to touch, because it's effectively a metadata stamp.)

If the user has restructured the header area, leave it alone — find the date string and update it in place if possible; otherwise, log a warning and skip the date update.

## Why these choices

- **Markers protect human notes.** Most reference docs accumulate hand-written annotations over time ("Mender Platform team — Patrick is lead"). Wiping those on every refresh is the kind of paper cut that makes users distrust the skill.
- **`Org` column survives renames.** When a team is renamed, the `Org` column still helps the user recognize what they're looking at.
- **Empty subsections aren't omitted.** Seeing `### Curantis Solutions` followed by `_None._` is more useful than the heading silently disappearing — it confirms the skill checked.
