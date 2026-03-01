# API Contracts: Review Skill

**Branch**: `020-review-skill` | **Date**: 2026-03-01

## Endpoints Used

### Reviews

| Method | Path | Spec Ref | User Story |
|--------|------|----------|------------|
| GET | `/reviews` | FR-001 | US1: List reviews |
| GET | `/reviews/{id}` | FR-002 | US1: Review detail |
| POST | `/reviews` | FR-005 | US3: Create review |
| PUT | `/reviews/{id}/draft-assessment` | FR-003 | US2: Save draft |
| POST | `/reviews/{id}/submit-assessment` | FR-003 | US2: Submit assessment |
| POST | `/reviews/{id}/sign-off` | FR-004 | US3: Sign off |
| PUT | `/reviews/{id}/void` | FR-005 | US3: Void review |
| DELETE | `/reviews/{id}` | FR-005 | US3: Archive review |

### Review Templates

| Method | Path | Spec Ref | User Story |
|--------|------|----------|------------|
| GET | `/review-templates` | FR-005 | US3: Template selection during create |
| GET | `/review-templates/{id}` | FR-003 | US2: Load prompts for assess flow |

### Core Values

| Method | Path | Spec Ref | User Story |
|--------|------|----------|------------|
| GET | `/core-values` | FR-006 | US4: List core values |
| GET | `/core-values-ratings` | FR-006 | US4: View ratings |
| POST | `/core-values-ratings` | FR-006 | US4: Submit standalone ratings |

## Request/Response Contracts

### GET /reviews

**Params**: `page`, `per_page`, `status` (filter), `q` (search)

**Response** (200):
```json
{
  "data": [
    {
      "id": 42,
      "reviewee": { "id": 1, "first_name": "Jane", "last_name": "Doe", "login": "jdoe" },
      "reviewer": { "id": 2, "first_name": "John", "last_name": "Smith", "login": "jsmith" },
      "status": "in_progress",
      "review_type": null,
      "template": { "id": 5, "name": "Q1 2026 Review" },
      "start_date": "2026-01-01",
      "end_date": "2026-03-31",
      "created_at": "2026-01-15T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 25, "total": 3, "total_pages": 1 }
}
```

### GET /reviews/{id}

**Response** (200):
```json
{
  "data": {
    "id": 42,
    "reviewee": { "id": 1, "first_name": "Jane", "last_name": "Doe", "login": "jdoe" },
    "reviewer": { "id": 2, "first_name": "John", "last_name": "Smith", "login": "jsmith" },
    "status": "assessed",
    "review_type": null,
    "template": { "id": 5, "name": "Q1 2026 Review" },
    "start_date": "2026-01-01",
    "end_date": "2026-03-31",
    "notes": null,
    "void_reason": null,
    "signed_off_at": null,
    "signed_off_initials": null,
    "self_assessment": {
      "respondent_type": "self",
      "respondent": { "id": 1, "first_name": "Jane", "last_name": "Doe", "login": "jdoe" },
      "is_draft": false,
      "responses": [
        { "prompt_id": 10, "description": "What were your key accomplishments?", "response_value": "Led the migration project.", "score": null }
      ]
    },
    "reviewer_assessment": {
      "respondent_type": "reviewer",
      "respondent": { "id": 2, "first_name": "John", "last_name": "Smith", "login": "jsmith" },
      "is_draft": false,
      "responses": [
        { "prompt_id": 10, "description": "What were your key accomplishments?", "response_value": "Strong leadership on migration.", "score": null }
      ]
    },
    "core_values_ratings": [
      { "id": 1, "core_value": { "id": 3, "name": "Integrity" }, "score": 4, "rater": { "id": 2 }, "review_id": 42 }
    ],
    "attachments": [],
    "action_items": [],
    "created_at": "2026-01-15T10:00:00Z",
    "updated_at": "2026-02-20T14:30:00Z"
  }
}
```

### POST /reviews

**Body**:
```json
{
  "reviewee_id": 1,
  "reviewer_id": 2,
  "template_id": 5,
  "review_type": null,
  "start_date": "2026-01-01",
  "end_date": "2026-03-31"
}
```

**Response** (201): Same as GET /reviews/{id}

### POST /reviews/{id}/submit-assessment

**Body** (AssessmentSubmitRequest):
```json
{
  "respondent_type": "self",
  "assessment_responses": [
    { "prompt_id": 10, "response_value": "Led the migration project." },
    { "prompt_id": 11, "score": 4 }
  ],
  "core_values_ratings": [
    { "core_value_id": 3, "score": 4 }
  ]
}
```

**Response** (200): Updated review detail

### PUT /reviews/{id}/draft-assessment

**Body**: Same as submit-assessment (AssessmentSubmitRequest)

**Response** (200): Updated review detail

### POST /reviews/{id}/sign-off

**Body**:
```json
{ "initials": "JS" }
```

**Response** (200): Updated review detail (status → signed_off)

### PUT /reviews/{id}/void

**Body**:
```json
{ "reason": "Review cycle cancelled." }
```

**Response** (200): Updated review detail (status → voided)

### DELETE /reviews/{id}

**Body**: None

**Response** (200 or 204): Review archived (soft-deleted)

### POST /core-values-ratings

**Body**:
```json
{
  "subject_id": 1,
  "ratings": [
    { "core_value_id": 3, "score": 4 },
    { "core_value_id": 7, "score": 5 }
  ]
}
```

**Response** (201): Created ratings

## Error Responses

All endpoints follow the standard V2 error pattern:

| Status | Meaning | Skill Message |
|--------|---------|---------------|
| 401 | Invalid/expired token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | Not authorized for action | Review-specific: "You must be the reviewer to sign off." / "Admin/people-ops permissions required." |
| 404 | Resource not found | "Review {id} not found." / "Template {id} not found." |
| 422 | Validation error | Show error details from response body |
