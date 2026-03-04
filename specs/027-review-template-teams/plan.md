# Implementation Plan: Review Template Team Ownership & Sharing

**Branch**: `027-review-template-teams` | **Date**: 2026-03-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/027-review-template-teams/spec.md`

## Summary

Update `skills/reviews/SKILL.md` to support the new team-ownership and sharing fields on review templates (API Change 008). Changes are additive: update the template listing table to show `owning_team`, add template management flows (create, update, delete) that pass the new fields, handle the new 400/403 error cases, and update `api-reference.md` with the new field documentation.

## Technical Context

**Language/Version**: Bash 5.x (embedded scripts in SKILL.md), Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual verification with `scripts/api.sh` against live API
**Target Platform**: Claude Code skill runtime, any directory
**Project Type**: Single skill modification
**Performance Goals**: N/A — pass-through API calls
**Constraints**: Self-contained skill; no new external dependencies; confirm-writes required for POST/PATCH/DELETE

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Modifying existing SKILL.md only |
| II. Self-Contained | PASS | No new external dependencies |
| III. Config-Driven | PASS | Config reads unchanged |
| IV. Confirm Writes | PASS | New POST/PATCH/DELETE flows confirm before executing |
| V. Show IDs | PASS | owning_team.id and shared_with_teams[].id included in output |
| VI. Framework-Aware | N/A | Review templates are org-level, not framework-specific |
| VII. Direct Execution | PASS | Bash api.sh only; no subagents |
| VIII. Graceful Degradation | PASS | null owning_team → "—"; 400/403 errors handled |
| IX. Concise Output | PASS | Tables with new columns; no verbose prose |

**Gate**: PASS — no violations. Ready for implementation.

## Project Structure

### Documentation (this feature)

```text
specs/027-review-template-teams/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── spec.md              # Feature spec
├── checklists/
│   └── requirements.md  # Quality checklist (all pass)
└── tasks.md             # Phase 2 output (/speckit:tasks — NOT created here)
```

### Source Code (files to modify)

```text
skills/reviews/
└── SKILL.md              # Primary change target

api-reference.md          # Update review-templates section (master copy)
skills/reviews/references/
└── api-reference.md      # Updated via sync-plugin after master edit
```

---

## Phase 0: Research

**Status**: Complete. See [research.md](research.md).

No external research required. API change spec is authoritative and complete. All field names, semantics, and error codes verified from Issue #17.

---

## Phase 1: Design

### 1.1 Argument Parsing Table Update

Add `templates` as a new routing key in the argument parsing table:

| Input | Flow |
|-------|------|
| `templates` or `templates list` | List Templates |
| `templates create` | Create Template |
| `templates {id} update` | Update Template |
| `templates {id} delete` | Delete Template |

### 1.2 Create Review Flow — Template Table Update

In **Flow: Create Review → Step 1 → Template selection**, update the template table to add `Owning Team` column:

**Before**:
```
| ID | Name | Prompts |
|----|------|---------|
| 5  | Q1 2026 Review | 8 |
```

**After**:
```
| ID | Name | Prompts | Owning Team |
|----|------|---------|-------------|
| 5  | Q1 2026 Review | 8 | Engineering |
| 3  | Annual Review | 12 | — |
```

### 1.3 New Flow: List Templates

**Trigger**: `templates` or `templates list`

Fetch GET `/review-templates?per_page=50`. Display table:

```
## Review Templates

| ID | Name | Prompts | Owning Team |
|----|------|---------|-------------|
| 5  | Q1 2026 Review | 8 | Engineering |
| 3  | Annual Review | 12 | — |

{count} templates
```

`owning_team` null → show "—".

### 1.4 New Flow: Create Template

**Trigger**: `templates create`

Prompt via AskUserQuestion for:
1. **Name** (required)
2. **Target role** (optional — leave blank to omit)
3. **Reviewer instructions** (optional — leave blank to omit)
4. **Owning team ID** (optional — leave blank to let API default to user's current team)

Confirm then POST:
```json
{
  "name": "NAME",
  "target_role": "ROLE_OR_OMIT",
  "reviewer_instructions": "INSTRUCTIONS_OR_OMIT",
  "owning_team_id": ID_OR_OMIT
}
```

Response: Show `owning_team` and `shared_with_teams` from detail response.

403 → "Admin on the owning team required."

### 1.5 New Flow: Update Template

**Trigger**: `templates {id} update`

Fetch GET `/review-templates/{id}` first to show current values.

Prompt via AskUserQuestion for each field (show current value as context):
1. **Name** (current: "Q1 2026 Review") — leave blank to keep
2. **Target role** — leave blank to keep
3. **Reviewer instructions** — leave blank to keep
4. **Share with team IDs** (comma-separated, replace-all) — enter IDs or "none" to clear, leave blank to keep unchanged

If sharing input is "none" → send `"shared_with_team_ids": []`
If sharing input is blank → omit `shared_with_team_ids` from body
If sharing input is IDs → send `"shared_with_team_ids": [id1, id2, ...]`

Confirm then PATCH. If 400 with owning team error → "Cannot change owning team after creation."

Response: Show `owning_team` and `shared_with_teams`.

403 → "Admin on the owning team required."

### 1.6 New Flow: Delete Template

**Trigger**: `templates {id} delete`

Fetch GET `/review-templates/{id}` to show name and owning team.

Confirm:
> Delete template #{id} "{name}" (Owning team: {owning_team.name | "—"})? This is permanent.

DELETE. 403 → "Admin on the owning team required."

### 1.7 Error Handling Updates

Add to existing Error Handling section:
- `status: 400` on template PATCH → Show API error message; if it contains "owning team", display "Cannot change owning team after creation."
- `status: 403` on template create/update/delete → "Admin on the owning team required."

### 1.8 api-reference.md Updates

Update the review templates section:

**GET /review-templates** description: Add "Results are team-scoped: non-admins see templates owned by or shared with their team. Account admins see all." Add `owning_team` to ReviewTemplateListItem fields.

**POST /review-templates**: Update body to include `owning_team_id?`. Update auth note to "Admin on the owning team (account admin or team admin)." Add `owning_team` and `shared_with_teams` to response.

**PATCH /review-templates/{id}**: Update body to include `shared_with_team_ids?` (replace-all). Note `owning_team_id` is rejected (400). Update auth note to "Admin on the owning team." Add `owning_team` and `shared_with_teams` to response.

**DELETE /review-templates/{id}**: Update auth note to "Admin on the owning team."

Update ReviewTemplateListItem fields: add `owning_team: { id, name } | null`.
Update ReviewTemplateDetail fields: add `owning_team: { id, name } | null`, `shared_with_teams: [{ id, name }]`.
