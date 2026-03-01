# Research: Review Skill

**Branch**: `020-review-skill` | **Date**: 2026-03-01

## Finding 1: Assessment Answer Types

**Decision**: Handle each `answer_type` with a specific AskUserQuestion pattern.

**Rationale**: The API defines 5 answer types for assessment prompts: `range`, `text`, `textarea`, `boolean`, `multiple`. Each maps naturally to AskUserQuestion capabilities. The `answer_meta_data` field on each prompt contains type-specific config (e.g., min/max for range, options for multiple).

**Alternatives considered**:
- Batch all questions in one prompt — rejected, too complex for mixed types and poor UX for long templates.
- Use Bash `read` for input — rejected, AskUserQuestion provides structured options and validation.

## Finding 2: Review API Endpoints Confirmed

**Decision**: All 25 endpoints documented in api-reference.md are available and follow standard V2 patterns.

**Rationale**: The review endpoints use the same auth (Bearer token), envelope (`{ data, meta }`), pagination, and error format as all other V2 endpoints. No special handling needed beyond what api.sh already provides.

**Key endpoints for the skill**:
- `GET /reviews` — list (params: page, per_page, status, q)
- `GET /reviews/{id}` — detail (includes assessments, ratings, action items, attachments)
- `POST /reviews` — create (body: reviewee_id, reviewer_id, template_id, review_type?, start_date?, end_date?)
- `PUT /reviews/{id}/draft-assessment` — save draft
- `POST /reviews/{id}/submit-assessment` — submit final
- `POST /reviews/{id}/sign-off` — sign off (body: initials)
- `PUT /reviews/{id}/void` — void (body: reason)
- `DELETE /reviews/{id}` — archive (soft delete)
- `GET /review-templates` — list templates (for create flow)
- `GET /review-templates/{id}` — template detail with prompts (for assess flow)
- `GET /core-values` — list core values
- `GET /core-values-ratings` — list ratings (params: subject_id)
- `POST /core-values-ratings` — create standalone ratings

## Finding 3: Assessment Visibility is Server-Side

**Decision**: No client-side visibility logic needed.

**Rationale**: The API reference states: "Assessment visibility depends on requesting user's role." The `ReviewDetail` response includes `self_assessment` and `reviewer_assessment` fields — the API simply omits or nulls the reviewer assessment for reviewees until the review reaches `signed_off` status. The skill renders whatever is present.

## Finding 4: Scope Boundaries

**Decision**: Initial skill covers 13 of 25 review-related endpoints. Template CRUD, action items, attachments, notes, and audit log are out of scope.

**Rationale**: The spec's 4 user stories map to the core review workflow. Template management is an admin function typically done in the web UI. Action items, attachments, and notes are supporting features that can be added as future user stories. The audit log is a diagnostic tool, not a daily workflow.

**Out-of-scope endpoints**:
- `PATCH /reviews/{id}` (update review dates)
- `PUT /reviews/{id}/notes`
- `POST /reviews/{id}/action-items`
- `POST /reviews/{id}/attachments`, `DELETE /reviews/{id}/attachments/{aid}`
- `GET /reviews/{id}/audit-log`
- All 7 review-template mutation endpoints (POST/PATCH/DELETE templates and prompts, PUT positions)
