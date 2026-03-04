# Research: Review Template Team Ownership & Sharing

**Phase**: 0 — Pre-design
**Feature**: 027-review-template-teams

## Summary

No external research required. The API change spec (Issue #17 / 008-review-template-teams.md) is complete and unambiguous. All decisions are derived from the authoritative source.

---

## Decision: Template Management Scope

**Decision**: Extend `skills/reviews/SKILL.md` with a `templates` sub-command flow covering list, create, and update. The existing delete endpoint will also be covered.

**Rationale**: The spec's FRs (FR-002, FR-003, FR-005, FR-007) require handling POST and PATCH on `/review-templates`, which the skill currently does not expose as user-invocable flows. The template listing in the Create Review flow already calls GET `/review-templates` — that existing call will be updated (FR-001). New `templates` argument sub-commands will cover the management flows. This is the minimal complete implementation.

**Alternatives considered**:
- Out-of-scope template management (update api-reference only): Rejected — spec FRs explicitly require POST/PATCH handling.
- Separate `rkit:templates` skill: Rejected — review templates are tightly coupled to the reviews domain; no constitution principle requires a separate skill for a sub-resource.

---

## Decision: Argument Structure for Template Management

**Decision**: Add `templates` as a new argument routing key with sub-commands: `templates list`, `templates create`, `templates {id} update`, `templates {id} delete`.

**Rationale**: Mirrors the existing argument parsing table pattern. Keeps template management commands discoverable under one prefix.

**Alternatives considered**:
- Top-level commands like `create-template`, `update-template`: Inconsistent with existing pattern; less discoverable.

---

## Decision: `owning_team_id` on POST

**Decision**: Prompt for owning team ID as an optional field during template creation. If the user leaves it blank, omit from request body.

**Rationale**: The API defaults to the user's current team context when omitted. Spec FR-002 states "only sends it when the user explicitly specifies a team."

---

## Decision: `shared_with_team_ids` Semantics on PATCH

**Decision**: Display replace-all semantics clearly during template update. Prompt user for a comma-separated list of team IDs to share with; pass `[]` if they enter none/clear.

**Rationale**: The API uses replace-all semantics — omitting the field leaves sharing unchanged; passing `[]` clears all sharing. Users must understand this distinction.

---

## Decision: `owning_team` null handling

**Decision**: Display "—" wherever `owning_team` is null.

**Rationale**: Legacy templates may have no owning team. The spec (FR-001, edge cases) requires null-safe display without errors.

---

## API Fields Reference (verified from Issue #17)

### GET /review-templates — List item shape (updated)
```json
{
  "id": 5,
  "name": "Q1 2026 Review",
  "target_role": null,
  "prompt_count": 8,
  "created_at": "...",
  "owning_team": { "id": 10, "name": "Engineering" }
}
```

### POST /review-templates — New request field
- `owning_team_id` (integer, optional)

### POST /review-templates — Detail response (updated)
```json
{
  "owning_team": { "id": 10, "name": "Engineering" },
  "shared_with_teams": []
}
```

### PATCH /review-templates/:id — New request field
- `shared_with_team_ids` (array of integers, optional — replace-all)
- `owning_team_id` — REJECTED with 400 "Cannot change owning team after creation"

### PATCH /review-templates/:id — Detail response (updated)
```json
{
  "owning_team": { "id": 10, "name": "Engineering" },
  "shared_with_teams": [
    { "id": 12, "name": "Product" },
    { "id": 15, "name": "Design" }
  ]
}
```

### Auth change
- POST/PATCH/DELETE now require **admin on the owning team** (team admin or account admin), not just any account admin.
- Error: `status: 403` — message: "Admin on the owning team required."
