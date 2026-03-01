# Data Model: Review Skill

**Branch**: `020-review-skill` | **Date**: 2026-03-01

## Entities

### ReviewListItem

From `GET /reviews` response.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary key |
| reviewee | UserSimple | { id, first_name, last_name, login } |
| reviewer | UserSimple | { id, first_name, last_name, login } |
| status | string | `in_progress`, `assessed`, `signed_off`, `voided` |
| review_type | integer \| null | |
| template | { id, name } \| null | |
| start_date | string \| null | Review period start |
| end_date | string \| null | Review period end |
| created_at | string | ISO 8601 |

### ReviewDetail

From `GET /reviews/{id}` response. Extends ReviewListItem.

| Field | Type | Notes |
|-------|------|-------|
| *(all ReviewListItem fields)* | | |
| notes | string \| null | Reviewer/admin notes |
| void_reason | string \| null | Present when status = voided |
| signed_off_at | string \| null | ISO 8601, present when signed off |
| signed_off_initials | string \| null | |
| self_assessment | Assessment \| null | Visibility: always visible to reviewee/reviewer |
| reviewer_assessment | Assessment \| null | Visibility: hidden from reviewee until signed_off |
| core_values_ratings | CoreValuesRatingEntry[] | |
| attachments | Attachment[] | Display only (upload out of scope) |
| action_items | ActionItem[] | Display only (creation out of scope) |
| updated_at | string | ISO 8601 |

### Assessment

Nested within ReviewDetail.

| Field | Type | Notes |
|-------|------|-------|
| respondent_type | string | `"self"` or `"reviewer"` |
| respondent | UserSimple | Who submitted |
| is_draft | boolean | Draft vs submitted |
| responses | AssessmentResponse[] | |

### AssessmentResponse

Nested within Assessment.

| Field | Type | Notes |
|-------|------|-------|
| prompt_id | integer | Maps to template prompt |
| description | string | The prompt text |
| response_value | string \| null | Text answer |
| score | integer \| null | Numeric answer (range, boolean) |

### AssessmentSubmitRequest

Body for `PUT /reviews/{id}/draft-assessment` and `POST /reviews/{id}/submit-assessment`.

| Field | Type | Notes |
|-------|------|-------|
| respondent_type | string | `"self"` or `"reviewer"` (required) |
| assessment_responses | object[] | [{ prompt_id*, response_value?, score? }] |
| core_values_ratings | object[] \| null | [{ core_value_id, score }] (optional) |

### ReviewTemplateListItem

From `GET /review-templates` response.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary key |
| name | string | Template name |
| target_role | string \| null | |
| prompt_count | integer | Number of prompts |
| created_at | string | ISO 8601 |

### ReviewTemplateDetail

From `GET /review-templates/{id}` response.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary key |
| name | string | |
| target_role | string \| null | |
| reviewer_instructions | string \| null | Shown to reviewer during assess |
| prompts | AssessmentPrompt[] | Ordered by position |
| created_at | string | ISO 8601 |
| updated_at | string | ISO 8601 |

### AssessmentPrompt

Nested within ReviewTemplateDetail.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Used as prompt_id in responses |
| description | string | The question text |
| hint | string \| null | Help text for the respondent |
| answer_type | string | `"range"`, `"text"`, `"textarea"`, `"boolean"`, `"multiple"` |
| answer_meta_data | object \| null | Type-specific config (range bounds, multiple options) |
| position | integer | Display order |

### CoreValue

From `GET /core-values` response.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary key |
| name | string | Core value name |
| description | string \| null | |

### CoreValuesRating

From `GET /core-values-ratings` response.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Primary key |
| core_value | { id, name } | |
| score | integer | Rating score |
| rater | UserSimple | Who rated |
| review_id | integer \| null | Null for standalone ratings |
| created_at | string | ISO 8601 |

## State Transitions

```
Review Lifecycle:

  in_progress ──→ assessed ──→ signed_off
       │
       │
       └──→ voided ←────────────────┘

  Any state ──→ archived (soft delete via DELETE)
```

- `in_progress → assessed`: Automatic when both self and reviewer assessments are submitted
- `assessed → signed_off`: Reviewer signs off with initials
- `in_progress → voided`: Admin voids with reason
- `assessed → voided`: Admin voids with reason
- `signed_off → voided`: Admin voids with reason
- Any state → archived: Admin soft-deletes (removed from default list)
