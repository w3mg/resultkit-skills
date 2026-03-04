# Research: Extend rkit:profile with Measurables, Rocks, Feedback, Progress, and Integrations

**Feature**: 026-users-mgmt-api
**Date**: 2026-03-04

## Summary

No NEEDS CLARIFICATION items. All endpoints are fully documented in api-reference.md with field shapes from the API Change Handoff. Existing rkit:profile patterns cover the implementation model entirely.

---

## Decision 1: Extend rkit:profile vs. create new skill

**Decision**: Extend the existing `skills/profile/SKILL.md`

**Rationale**: All 5 new flows (measurables, rocks, feedback, progress, integrations) are personal user-data commands — a natural fit under `/rkit:profile`. Creating new skills would fragment the user namespace for closely related data. The issue itself says "extend rkit:profile skill (or create new skills)" — one skill is simpler.

**Alternatives considered**: Separate `rkit:measurables`, `rkit:progress`, etc. — rejected because it adds skills without clear benefit and splits what users think of as "my profile data."

---

## Decision 2: Pagination strategy for rocks and feedback

**Decision**: Use the same `per_page=100` paginated loop already in the account members flow.

**Rationale**: Rocks and feedback use the same `meta.total_pages` structure. Reusing the existing pattern keeps the skill consistent and avoids per-page truncation for power users.

**Alternatives considered**: Single-page fetch — rejected because users may have more than one page of feedback.

---

## Decision 3: Measurables period/year params

**Decision**: Pass `period` and `year` as optional query params; default to API defaults (week, current year, active_only=true).

**Rationale**: The API already defaults sensibly. Only expose params when user explicitly provides them.

---

## Decision 4: Integrations null/disconnect

**Decision**: Accept `none` or `null` as the value in `integrations set {category} none` to send `null` in the PATCH body (disconnects the integration).

**Rationale**: API sets to null to disconnect. User-facing "none" is clearer than asking users to type `null`.

---

## API Field Reference

| Endpoint | Key Fields |
|----------|------------|
| GET /users/{id}/measurables | `id`, `name`, `target_value`, `target_unit`, `is_archived`, `values[{date,value,on_track}]` |
| GET /users/{id}/rocks | `id`, `name`, `status`, `due_date`, `team.name`, `milestones_total`, `milestones_completed` |
| GET /users/{id}/feedback | `id`, `message`, `from_user.first_name/last_name`, `to_user.first_name/last_name`, `created_at` |
| GET /users/me/progress | `strategy.{rocks_realized_all_time, milestones_realized_all_time, milestones_realized_this_quarter}`, `practice_scorecard.days[{date,day_name,completed}]`, `practice_totals.{all_time,current_streak,longest_streak}` |
| GET /users/me/integrations | `task_management.{selected,options}`, `sales_revops.{selected,options}`, `team_communication.{selected,options}` |
| PATCH /users/me/integrations | Body: `{task_management?, sales_revops?, team_communication?}` — null to disconnect |

---

## No open questions

All API behaviors are confirmed from the handoff doc and api-reference.md. No further research needed.
