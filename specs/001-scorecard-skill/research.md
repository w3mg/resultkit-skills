# Research: Scorecard Skill (rkit:scorecard)

**Branch**: `001-scorecard-skill` | **Date**: 2026-03-05

No NEEDS CLARIFICATION markers in spec. All API behavior is fully specified in GitHub Issue #21. This document records decisions made from reviewing the spec, existing skills, and API handoff.

---

## Decision: Skill Directory Name

**Decision**: `skills/scorecard/` → skill name `rkit:scorecard`
**Rationale**: Follows naming convention of all existing skills (`skills/seats/` → `rkit:seats`, `skills/board/` → `rkit:board`). "scorecard" is the dominant product term in the API handoff and EOS framework.
**Alternatives**: `rkit:measures` — rejected because users think in terms of "scorecard", not "measures".

---

## Decision: History Display — How Many Weeks to Show

**Decision**: Show the **last 4 completed weeks** by default in the list view (not all 52 slots).
**Rationale**: 52 weekly slots would produce overwhelming output. 4 weeks covers the most recent month and matches the natural weekly review cadence. The `--year` flag fetches all 52 slots but the display still truncates to the last 4 unless `--all-weeks` is specified.
**Alternatives**: Show all weeks (too verbose), show 8 weeks (reasonable but 4 is cleaner for a terminal view).

---

## Decision: Measure Name Resolution

**Decision**: Case-insensitive exact match first; if no exact match, case-insensitive substring match; if multiple substring matches, show disambiguation list and stop.
**Rationale**: Consistent with how `rkit:today` resolves item names. Avoids silent wrong-measure operations.
**Alternatives**: Require exact match (too strict for CLI use); fuzzy match (unpredictable).

---

## Decision: Current Monday Computation

**Decision**: Compute current Monday's date in Bash as: `date -d "last monday" +%Y-%m-%d` on Linux, with fallback via `$(date -v-$(date +%u)d +%Y-%m-%d)` on macOS.
**Rationale**: The API requires ISO date strings for the `history` endpoint. Monday is the correct week anchor per the API spec (histories are keyed to Mondays).
**Alternatives**: Use today's date — incorrect, the API would reject non-Monday dates. Use a hardcoded offset — fragile.

---

## Decision: Confirmation Flow for Writes

**Decision**: For `record`, `add`, `update`, and `archive`, show a summary of the intended action and ask "Confirm? (y/n)" before calling the API.
**Rationale**: Constitution principle IV. Consistent with `rkit:seats` and `rkit:braindump`.
**Alternatives**: Require `--confirm` flag (non-standard for this skill suite); no confirmation (violates constitution).

---

## Decision: Framework-Aware Terminology

**Decision**: When the team's `framework` is `"eos"`, display "Measurables" instead of "Measures" and "Scorecard" remains unchanged (it's universal across EOS). For all other frameworks, use "Measures".
**Rationale**: EOS terminology uses "Measurables" for the individual KPI entries. Constitution principle VI.
**Alternatives**: Always use "Measures" — simpler but breaks EOS terminology alignment.

---

## Decision: api-reference.md Update

**Decision**: Add a "Team Scorecard Measures" section to the master `api-reference.md` before implementing the skill, then run `/sync-plugin` to copy to all skill directories.
**Rationale**: Constitution / CLAUDE.md mandate: read `api-reference.md` before writing skill logic. Keeping the reference current ensures future skills can also use these endpoints.
**Alternatives**: Add only to `skills/scorecard/references/api-reference.md` — violates the master-copy policy.

---

## API Behavior Notes (from Issue #21)

- `GET /api/v2/teams/:id/measures` — query params: `year`, `include_archived`, `owner_id`. Returns 52 history slots per year.
- `POST /api/v2/teams/:id/measures` — only `name` required. Returns 201 with empty `histories`.
- `PATCH /api/v2/measures/:id` — partial update. `archived: true` soft-deletes; `archived: false` restores.
- `DELETE /api/v2/measures/:id` — soft-archive, idempotent. Returns 200.
- `POST /api/v2/measures/:id/history` — upsert by (measure_id, date). Value must be numeric string. Returns 200.
- Direction field: `"higher"` or `"lower"`. Default: `"higher"`.
- Unit field: any string (e.g., `"#"`, `"$"`, `"%"`). Default: `""`.
