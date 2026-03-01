# Quickstart: Review Skill

**Branch**: `020-review-skill` | **Date**: 2026-03-01

## Verification Scenarios

### US1: View Reviews

**Scenario 1**: List reviews
```
User: /rkit:reviews
Expected: Table with ID, reviewee, reviewer, status, start_date, end_date
Empty: "No reviews found."
```

**Scenario 2**: Review detail
```
User: /rkit:reviews 42
Expected: Full detail with assessments (visibility-dependent), core values ratings, action items, attachments
404: "Review 42 not found."
```

**Scenario 3**: Assessment visibility
```
User (reviewee): /rkit:reviews 42 (status: in_progress)
Expected: self_assessment shown (if exists), reviewer_assessment NOT shown

User (reviewee): /rkit:reviews 42 (status: signed_off)
Expected: Both self_assessment and reviewer_assessment shown
```

### US2: Submit Assessment

**Scenario 4**: Assess flow
```
User: /rkit:reviews 42 assess
Expected: Fetch review detail → fetch template detail → walk through each prompt → show summary → confirm → submit
Status check: Review must be in_progress, else error
```

**Scenario 5**: Draft flow
```
User: /rkit:reviews 42 draft
Expected: Same prompt walk-through → save as draft without advancing state
```

**Scenario 6**: Answer type handling
```
Prompt (range): "Rate performance 1-5" → AskUserQuestion with options 1-5
Prompt (text): "Key accomplishments?" → AskUserQuestion free-form
Prompt (textarea): "Detailed feedback" → AskUserQuestion free-form
Prompt (boolean): "Met expectations?" → AskUserQuestion Yes/No
Prompt (multiple): "Category" → AskUserQuestion with options from answer_meta_data
```

### US3: Lifecycle Actions

**Scenario 7**: Sign off
```
User: /rkit:reviews 42 sign-off
Expected: Prompt for initials → confirm → POST sign-off
Status check: Review must be in assessed state
Permission check: Must be the reviewer
```

**Scenario 8**: Create review
```
User: /rkit:reviews create
Expected: Prompt for reviewee ID → reviewer ID → fetch templates → select template → optional dates → confirm → POST create
Permission check: Must be admin/people-ops
```

**Scenario 9**: Void review
```
User: /rkit:reviews 42 void
Expected: Prompt for reason → confirm → PUT void
Permission check: Must be admin/people-ops
```

**Scenario 10**: Archive review
```
User: /rkit:reviews 42 archive
Expected: Confirm → DELETE archive
Permission check: Must be admin/people-ops
```

### US4: Core Values

**Scenario 11**: List core values
```
User: /rkit:reviews values
Expected: Table with ID, name, description
Empty: "No core values defined for your organization."
```

**Scenario 12**: Rate core values
```
User: /rkit:reviews rate 15
Expected: Fetch core values → prompt score for each → show summary → confirm → POST ratings
```

### Error Scenarios

**Scenario 13**: Permission errors
```
Non-reviewer signs off → 403 → "You must be the reviewer to sign off."
Non-admin creates/voids/archives → 403 → "Admin/people-ops permissions required."
Non-participant assesses → 403 → Show API error
```

**Scenario 14**: Status errors
```
Assess when not in_progress → "Review must be in progress to assess."
Sign off when not assessed → "Review must be in assessed status to sign off."
Void already-voided → Show API error
Archive already-archived → Show API error
```
