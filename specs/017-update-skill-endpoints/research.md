# Research: Update Skills to Reflect Latest Endpoints

**Date**: 2026-02-28
**Feature**: 017-update-skill-endpoints

## Research Questions

### R1: Are L10 PUT routes true aliases for generic PUT routes?

**Decision**: Yes — L10 PUT routes are aliases.

**Rationale**: The api-reference.md explicitly documents each L10 PUT route as an alias:
- `PUT /teams/{id}/l10/todos/{item_id}` → alias for `PUT /teams/{id}/items/next/{item_id}`
- `PUT /teams/{id}/l10/done/{item_id}` → alias for `PUT /teams/{id}/items/done/{item_id}`
- `PUT /teams/{id}/l10/issues/{item_id}` → alias for `PUT /teams/{id}/items/blocked/{item_id}`
- `PUT /teams/{id}/l10/parked/{item_id}` → alias for `PUT /teams/{id}/items/parked/{item_id}`

**Alternatives considered**: Using generic routes only. Rejected because the L10 skill is EOS-specific and should use EOS-terminology routes for consistency.

### R2: Is DELETE /teams/{id}/l10/items/{item_id} an alias for the generic DELETE?

**Decision**: Yes — it's an alias for `DELETE /teams/{id}/items/{item_id}`.

**Rationale**: api-reference.md line 172: "Remove item from L10 board (sets on_weekly=false, keeps item). Alias for DELETE /teams/{id}/items/{item_id}."

**Alternatives considered**: None. The L10 route is the correct choice for the L10 skill.

### R3: What L10 GET routes exist for done and parked?

**Decision**: Both exist and are aliases.

**Rationale**: api-reference.md lines 161, 163:
- `GET /teams/{id}/l10/done` → alias for `GET /teams/{id}/items/done`
- `GET /teams/{id}/l10/parked` → alias for `GET /teams/{id}/items/parked`

Both support the same query params (page, per_page, q, all for done; page, per_page, q for parked).

### R4: Do headlines and 1on1 skills need updates?

**Decision**: No — both skills already fully cover their respective endpoint sets.

**Rationale**: Audited against the user's endpoint table:
- `rkit:headlines`: Covers GET, POST, PATCH, DELETE for `/teams/{id}/headlines` plus L10 headline aliases. All 4 headline endpoints present.
- `rkit:1on1`: Covers GET /meetings, GET /meetings/{id}, GET/POST/PUT/DELETE /meetings/{id}/items, GET /meetings/{id}/items/{section}. All 7 meeting endpoints present.

### R5: What display patterns do existing L10 sections use?

**Decision**: Follow existing patterns exactly.

**Rationale**: Current L10 board view fetches todos, issues, headlines. New sections (done, parked) should use identical display rules:
- Section header with count from `meta.total`
- Table with columns: ID, Name, Creator, Due
- Creator shows `first_name last_name`, fall back to `login`
- Due shows YYYY-MM-DD or "—" if null
- Empty sections show "(empty)"
- Overflow: "Showing {returned} of {total} — more items exist"

### R6: What is the L10 board section order?

**Decision**: To-Dos, Done, Issues, Parked, Headlines.

**Rationale**: This matches the natural L10 meeting flow: review what's due (to-dos), celebrate completions (done), work through blockers (issues/IDS), check parking lot, share headlines. The current skill shows To-Dos → Issues → Headlines; inserting Done after To-Dos and Parked after Issues maintains logical flow.

## Summary

No NEEDS CLARIFICATION items remain. All L10 routes are confirmed as aliases. Two skills need changes; two are already complete.
