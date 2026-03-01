# Feature Specification: Review Skill

**Feature Branch**: `020-review-skill`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #9: [API Change] Handoff: Review API V2 Endpoints (020)

## Clarifications

### Session 2026-03-01

- Q: Archive review is listed in FR-005 and US3 description but has no acceptance scenario — should it be added? → A: Add archive acceptance scenario to US3 (consistent with FR-005).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Reviews (Priority: P1)

A user runs `/rkit:reviews` and sees a list of their performance reviews showing ID, reviewee, reviewer, status, and dates. They can drill into a specific review to see its full detail including assessment responses, core values ratings, action items, and attachments. Assessment visibility follows role-based rules: reviewees see reviewer assessments only after sign-off.

**Why this priority**: Viewing reviews is the most common action — every user involved in a review (reviewee, reviewer, admin) needs to see their reviews and drill into detail. This is the entry point for all other review workflows.

**Independent Test**: Run `/rkit:reviews` to see the review list, then `/rkit:reviews {id}` to see detail. Verify the table renders correctly and detail shows all available sections.

**Acceptance Scenarios**:

1. **Given** a user with active reviews, **When** they run `/rkit:reviews`, **Then** they see a table with ID, reviewee name, reviewer name, status, and review period dates.
2. **Given** a specific review ID, **When** the user runs `/rkit:reviews {id}`, **Then** they see the full review detail including assessments (based on visibility rules), core values ratings, action items, and attachments.
3. **Given** a reviewee viewing a review in `in_progress` status, **When** they view the detail, **Then** they see their own self-assessment (if drafted/submitted) but NOT the reviewer assessment.
4. **Given** a reviewee viewing a review in `signed_off` status, **When** they view the detail, **Then** they see both their self-assessment and the reviewer assessment.
5. **Given** no reviews exist for the user, **When** they run `/rkit:reviews`, **Then** they see "No reviews found."

---

### User Story 2 - Submit Assessment (Priority: P2)

A user (reviewee or reviewer) drafts and submits their assessment for a review. The skill walks them through each prompt from the review template, collecting responses and optional core values ratings. They can save a draft to continue later, or submit the final assessment.

**Why this priority**: Completing assessments is the primary action that moves reviews through their lifecycle. Without this, reviews stay in `in_progress` forever.

**Independent Test**: Run `/rkit:reviews {id} assess` and complete the prompted assessment flow. Verify the assessment is saved as draft or submitted.

**Acceptance Scenarios**:

1. **Given** a review in `in_progress` status, **When** the reviewee runs `/rkit:reviews {id} assess`, **Then** they are prompted for each template question with the appropriate input type (text, range, boolean, multiple choice) and can submit their self-assessment.
2. **Given** a review in `in_progress` status, **When** the reviewer runs `/rkit:reviews {id} assess`, **Then** they are prompted for each template question and can submit their reviewer assessment.
3. **Given** both assessments have been submitted, **Then** the review automatically transitions to `assessed` status.
4. **Given** a user wants to save progress, **When** they run `/rkit:reviews {id} draft`, **Then** their partial responses are saved as a draft without advancing the review state.
5. **Given** a review not in `in_progress` status, **When** a user tries to assess, **Then** they see an error explaining the review must be in progress.

---

### User Story 3 - Review Lifecycle Actions (Priority: P3)

Authorized users can perform lifecycle actions on reviews: reviewers can sign off assessed reviews, admins can create new reviews, void reviews, and archive reviews.

**Why this priority**: These actions complete the review lifecycle but are less frequent than viewing or assessing.

**Independent Test**: Run `/rkit:reviews {id} sign-off` as a reviewer on an assessed review. Verify the review transitions to `signed_off`.

**Acceptance Scenarios**:

1. **Given** a review in `assessed` status, **When** the reviewer runs `/rkit:reviews {id} sign-off`, **Then** they are prompted for their initials and the review transitions to `signed_off`.
2. **Given** admin permissions, **When** the user runs `/rkit:reviews create`, **Then** they are prompted for reviewee, reviewer, and template, and a new review is created.
3. **Given** admin permissions, **When** the user runs `/rkit:reviews {id} void`, **Then** they are prompted for a reason and the review is voided.
4. **Given** admin permissions, **When** the user runs `/rkit:reviews {id} archive`, **Then** the review is soft-deleted (archived) and no longer appears in the default review list.
5. **Given** a non-reviewer tries to sign off, **Then** they see a permission error.
6. **Given** a non-admin tries to create, void, or archive, **Then** they see a permission error.

---

### User Story 4 - Core Values Ratings (Priority: P4)

A user can view the organization's core values and rate a team member on those values. Ratings can be standalone (outside a review) or included as part of an assessment.

**Why this priority**: Core values are a supporting feature used alongside reviews. Less frequent than the main review workflow.

**Independent Test**: Run `/rkit:reviews values` to see core values, then `/rkit:reviews rate {user_id}` to submit ratings.

**Acceptance Scenarios**:

1. **Given** an organization with core values defined, **When** the user runs `/rkit:reviews values`, **Then** they see a list of core values with ID, name, and description.
2. **Given** a target user ID, **When** the user runs `/rkit:reviews rate {user_id}`, **Then** they are prompted to score each core value and the ratings are submitted.
3. **Given** no core values are defined, **When** the user runs `/rkit:reviews values`, **Then** they see "No core values defined for your organization."

---

### Edge Cases

- What happens when a user tries to assess a review they're not a participant in? Show permission error from the API.
- What happens when a user tries to sign off a review that's not in `assessed` status? Show "Review must be in assessed status to sign off."
- What happens when an admin tries to void an already-voided review? Show the API's error response.
- What happens when an admin tries to archive an already-archived review? Show the API's error response.
- What happens when assessment prompts have different answer types (range, text, boolean, multiple)? The skill must handle each type with appropriate input collection.
- What happens when a review has no template? Show available fields without template-specific prompts.
- What happens when a draft assessment already exists? Load the existing draft responses as defaults when re-assessing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST list reviews as a table with ID, reviewee, reviewer, status, and review period.
- **FR-002**: Skill MUST show review detail including assessments (respecting visibility rules), core values ratings, action items, and attachments.
- **FR-003**: Skill MUST support drafting and submitting assessments by walking through template prompts with appropriate input handling per answer type.
- **FR-004**: Skill MUST support reviewer sign-off with initials collection.
- **FR-005**: Skill MUST support admin actions: create review (with reviewee, reviewer, template selection), void review (with reason), and archive review.
- **FR-006**: Skill MUST list and display core values, and support standalone core values rating for a given user.
- **FR-007**: Skill MUST handle assessment visibility: reviewees see reviewer assessments only after `signed_off` status.
- **FR-008**: Skill MUST resolve team ID for context where needed, using the standard 3-tier precedence.
- **FR-009**: Skill MUST handle all standard error responses (401, 403, 404, 422) per the shared error handling pattern, with review-specific 403 messages for permission-gated actions.
- **FR-010**: Skill MUST confirm all write operations (create, submit, sign-off, void, archive, rate) before executing.

### Key Entities

- **Review**: A performance review with ID, reviewee, reviewer, status (`in_progress`, `assessed`, `signed_off`, `voided`), template, date range, assessments, core values ratings, action items, and attachments.
- **Assessment**: A set of responses to template prompts, submitted by either the reviewee (self) or reviewer. Can be in draft or submitted state.
- **Review Template**: A reusable form defining the prompts (questions) used in reviews, with answer types (range, text, textarea, boolean, multiple).
- **Core Value**: An organization-level value with name and description, used for rating team members.
- **Core Values Rating**: A score given to a user on a specific core value, either standalone or within a review.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their reviews and drill into detail in a single command invocation each.
- **SC-002**: Users can complete an assessment (draft or submit) through a guided prompt flow without leaving the CLI.
- **SC-003**: The full review lifecycle (create → assess → sign-off) can be completed entirely through the skill.
- **SC-004**: Core values can be listed and rated in single command invocations.
- **SC-005**: All permission-gated actions show clear, actionable error messages when unauthorized.

## Assumptions

- The review API endpoints are already live and documented in api-reference.md. No new API work is needed.
- Assessment visibility rules are enforced server-side — the skill renders whatever the API returns.
- The skill follows the same patterns as other rkit skills: SKILL.md entry point, api.sh for API calls, scoped Bash patterns in frontmatter.
- Review templates and core values are managed at the organization level — the skill needs no team context for most operations.
- The `assess` flow collects responses interactively using AskUserQuestion, one prompt at a time or in batches based on answer type.
