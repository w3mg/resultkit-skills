# Data Model: Review Template Team Ownership & Sharing

**Feature**: 027-review-template-teams

## Entities

### ReviewTemplateListItem (updated)

Returned by GET `/review-templates`.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Template ID |
| name | string | Template display name |
| target_role | string \| null | Optional role filter |
| prompt_count | integer | Number of assessment prompts |
| created_at | ISO timestamp | |
| owning_team | `{ id, name }` \| null | **NEW** — null for legacy templates |

**Skill display**: Show `owning_team.name` or "—" if null.

---

### ReviewTemplateDetail (updated)

Returned by GET `/review-templates/:id`, POST, and PATCH responses.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Template ID |
| name | string | |
| target_role | string \| null | |
| reviewer_instructions | string \| null | |
| prompts | AssessmentPrompt[] | Ordered by position |
| created_at | ISO timestamp | |
| updated_at | ISO timestamp | |
| owning_team | `{ id, name }` \| null | **NEW** |
| shared_with_teams | `[{ id, name }]` | **NEW** — empty array when unshared |

---

### POST /review-templates — Request (updated)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | yes | |
| target_role | string | no | |
| reviewer_instructions | string | no | |
| owning_team_id | integer | no | **NEW** — defaults to user's current team if omitted |

---

### PATCH /review-templates/:id — Request (updated)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | no | |
| target_role | string | no | |
| reviewer_instructions | string | no | |
| shared_with_team_ids | integer[] | no | **NEW** — replace-all; omit to leave unchanged; `[]` to clear |
| owning_team_id | — | — | **REJECTED** — 400 "Cannot change owning team after creation" |

---

## State / Auth Changes

| Operation | Previous Auth | New Auth |
|-----------|--------------|----------|
| POST /review-templates | Any account admin | Admin on owning team (team admin or account admin) |
| PATCH /review-templates/:id | Any account admin | Admin on owning team |
| DELETE /review-templates/:id | Any account admin | Admin on owning team |
| GET /review-templates | All users see all | Non-admins see only templates owned by or shared with their team |
