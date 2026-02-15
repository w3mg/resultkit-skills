# Research: rkit:today

**Date**: 2026-02-15 | **Spec**: [spec.md](./spec.md)

## R1: Day Plans API Behavior

**Question**: How does the Day Plans API work — auto-creation, date
routing, response format?

**Decision**: Use `/day-plans/today/items` for all default operations.
The `today` endpoint auto-creates a plan if none exists.

**Findings**:
- `GET /day-plans/today` — auto-creates plan if none exists, returns
  plan metadata
- `GET /day-plans/today/items` — returns items on today's plan
- `POST /day-plans/today/items` — creates new item AND adds to plan
  (auto-creates plan)
- `PUT /day-plans/today/items/{item_id}` — attaches existing item to
  plan (auto-creates plan, optional `position` body param)
- `PATCH /day-plans/today/items/{item_id}` — toggles completion
  (body: `{ "completed": true/false }`)
- `DELETE /day-plans/today/items/{item_id}` — removes from plan, keeps
  item in system
- Date-specific endpoints (`/day-plans/{date}/items`) require the plan
  to already exist (no auto-creation)

**Alternatives considered**: None — API is well-defined.

## R2: DayPlanItem Response Shape

**Question**: What fields does a day plan item contain?

**Decision**: DayPlanItem = standard item fields + `completed` (boolean)
+ `position` (integer).

**Findings**:
- Standard item fields: `id`, `name`, `description`, `due`, `status`,
  `on_weekly`, `team_id`, `parent_id`, `context`
- Day plan additions: `completed` (boolean), `position` (integer)
- The `completed` field is plan-specific — an item can be "completed"
  on today's plan but retain its original status
- Position determines display order

**Alternatives considered**: None — documented in API reference.

## R3: api.sh Integration

**Question**: How should SKILL.md invoke api.sh?

**Decision**: Use the same pattern as `rkit:setup` — find api.sh at
known install paths, invoke via Bash tool.

**Findings**:
- api.sh accepts `METHOD PATH [BODY]` arguments
- Returns `{ "status": <int>, "body": <object> }` on success
- Returns `{ "status": 0, "error": "NO_CONFIG" }` if config missing
- Returns `{ "status": 0, "error": "NO_TOKEN" }` if token empty
- Returns `{ "status": 0, "error": "CURL_FAILED" }` on network error
- Path format for api.sh: `/day-plans/today/items` (leading slash,
  api.sh appends to api_base)
- Response body for list endpoints is paginated:
  `{ "data": [...], "meta": { ... } }`

**Alternatives considered**: Direct curl calls (rejected — api.sh
handles config loading, error formatting consistently).

## R4: Pagination for Day Plan Items

**Question**: Will day plan items be paginated?

**Decision**: Handle pagination but expect single-page results. Most
users have 3–15 items per day.

**Findings**:
- `GET /day-plans/today/items` returns paginated response
- Typical day plans have 3–15 items — single page expected
- Default `per_page` is sufficient for most users
- If `meta.total_pages > 1`, should note it but not auto-paginate
  (keep skill simple)

**Alternatives considered**: Auto-pagination loop (rejected — over-
engineering for day plan scope).

## R5: Stretch Goal — View Other Dates

**Question**: Should the skill support viewing day plans for dates
other than today?

**Decision**: Support as simple extension — `/rkit:today 2026-02-13`
shows that date's plan. Uses `/day-plans/{date}/items` endpoint.

**Findings**:
- Date-specific endpoint: `GET /day-plans/{date}/items`
- Plan must already exist for the date (no auto-creation)
- 404 if no plan exists for that date
- Spec lists this as a stretch/edge case
- Easy to implement — just swap `today` for `{date}` in the API path

**Alternatives considered**: Separate `/rkit:plan` skill (rejected —
simple date arg is cleaner).
