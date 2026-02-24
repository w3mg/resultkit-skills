# Research: rkit:headlines

**Date**: 2026-02-24

## R1: Default Expiration Date

**Question**: The API does not compute a default `expires_at` when creating a headline. What should the skill default to?

**Decision**: Default to 7 days from today (YYYY-MM-DD format), computed client-side.

**Rationale**: The original Rails app computes expiration as "next weekly meeting + 1 day" using the team's `team_weekly_wday` and meeting start time. The V2 API has no endpoint to fetch the team's weekly meeting schedule, so the skill cannot replicate this calculation. Seven days is a reasonable approximation — it covers one full weekly cycle and matches the API's built-in 7-day visibility window for headlines without expiration. The user can always override with `--expires`.

**Alternatives considered**:
- No default (pass null): Headline would only be visible for 7 days via the recency window, then disappear with no expiration record. Functionally similar but less explicit.
- Prompt user every time: Too much friction for a simple "add headline" action.

## R2: Soft-Delete Visibility After Archive

**Question**: After archiving a headline (DELETE sets `expires_at` to today), will it still appear in GET results?

**Decision**: Yes — if the headline was created within the last 7 days. The skill must warn users about this.

**Rationale**: The API's visibility rule is: headline appears if `created_at` is within last 7 days **OR** `expires_at > today`. Archiving sets `expires_at = today`, which fails condition 2, but condition 1 may still be true. The eos-headlines-research.md confirms: "A recently-created headline that is 'deleted' will still appear until it ages past the 7-day window." The skill should note this after a successful archive: "Note: recently-created headlines may still appear for up to 7 days after archiving."

**Alternatives considered**: None — this is API behavior that cannot be changed client-side.

## R3: Team ID Resolution Pattern

**Question**: Should headlines skill use the same team resolution as `rkit:weekly` (default_team_id + --team flag)?

**Decision**: Yes — reuse the identical pattern.

**Rationale**: Headlines are team-scoped, same as the weekly board. Using the same resolution logic keeps the user experience consistent. The `--team` flag can appear anywhere in args, and `default_team_id` from config is the fallback. No new config fields needed.

**Alternatives considered**: None — consistency with existing skills is the clear choice.

## R4: Headline Display Format

**Question**: What format should the headline list use?

**Decision**: Markdown table with columns: ID, Text, Creator, Expires, Created.

**Rationale**: Follows Constitution IX (Concise Output) and matches the table format used by `rkit:weekly` and `rkit:board`. Text may be long, so it should be the widest column. Creator shows `first_name last_name` (or `login` as fallback). Dates show YYYY-MM-DD.

**Alternatives considered**:
- Numbered list: Less structured, harder to scan for specific fields.
- Compact one-line-per-headline: Loses the creator and date fields.

## R5: Argument Parsing — Quoted Text vs Flags

**Question**: How to handle headline text that may contain spaces alongside flags like `--expires` and `--team`?

**Decision**: The text argument is the first non-flag argument (or all non-flag arguments joined). Flags are `--expires {date}`, `--team {id}`, and `--text "..."` for the update flow.

**Rationale**: Claude Code parses the user's input as a string, not shell-style argv. The skill's SKILL.md instructs Claude to parse the arguments intelligently — identify the sub-command (add/remove/update), extract flag values, and treat the remaining text as the headline content. This matches how `rkit:board add {board_id} {column_id} "name"` works.

**Alternatives considered**: Strict positional parsing — rejected because headline text with spaces would require quoting rules that are hard to communicate to users.
