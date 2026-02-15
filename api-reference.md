# ResultMaps V2 API Reference

Base URL: `https://app.resultmaps.com/api/v2`
Auth: Bearer token in `Authorization` header or `token` query param.

## Items

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items` | List authenticated user's items (params: page, per_page, status, team_id) |
| POST | `/items` | Create item (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| GET | `/items/{id}` | Get item detail (includes first-level children) |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly) |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) |
| GET | `/items/{id}/children` | List child items (paginated) |
| PUT | `/items/{id}/move` | Reposition item in tree (body: parent_id* — integer or null) |

### Item Assignees

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items/{id}/assignees` | List assignees (paginated) |
| PUT | `/items/{id}/assignees` | Add assignee (body: user_id*) |
| DELETE | `/items/{id}/assignees/{user_id}` | Remove assignee |

### Item Comments

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items/{id}/comments` | List comments (chronological, paginated) |
| POST | `/items/{id}/comments` | Create comment (body: body*) |

## Teams

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams` | Authenticated user's teams — **flat array, no pagination**. Default team first, then alphabetical. (param: include_muted) |
| POST | `/teams` | Create team (body: name*, description, framework) |
| GET | `/teams/{id}` | Get team detail (includes members) |
| PATCH | `/teams/{id}` | Update team (body: name, description, framework) |
| DELETE | `/teams/{id}` | Delete team |

`GET /teams` response fields per team: `id`, `name`, `description`,
`framework`, `organization_name`, `organization_id`, `parent_name`,
`parent_id`, `is_default`, `is_muted`.

### Team Members

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/members` | List members (paginated) |
| PUT | `/teams/{id}/members` | Add member (body: user_id*, role?: "member"\|"admin") |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member |

### Team Weekly Board

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/items` | All team items (paginated) |
| POST | `/teams/{id}/items` | Create team item (is_wow=true) |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board (sets group_id, is_wow=true) |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (sets is_wow=false, keeps item) |
| GET | `/teams/{id}/items/next` | Items with status=next |
| PUT | `/teams/{id}/items/next/{item_id}` | Add to board + set status=next |
| GET | `/teams/{id}/items/done` | Items with status=done |
| PUT | `/teams/{id}/items/done/{item_id}` | Add to board + set status=done |
| GET | `/teams/{id}/items/issues` | Items with status=blocked |
| PUT | `/teams/{id}/items/issues/{item_id}` | Add to board + set status=blocked |
| GET | `/teams/{id}/items/parked` | Items with status=parked |
| PUT | `/teams/{id}/items/parked/{item_id}` | Add to board + set status=parked |

### Team Projects

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/projects` | List active projects (type=TodoList, status=active) |
| POST | `/teams/{id}/projects` | Create project in team (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project (body: name, description, due, status, on_weekly) |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (clears group_id, keeps item) |

## Users

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Authenticated user (includes api_token) |
| GET | `/users/{id}` | User profile (no api_token) |
| GET | `/users/{id}/items` | User's items (requires same-team membership, paginated) |

User fields: `id`, `login`, `email`, `first_name`, `last_name`,
`api_token` (only on `/users/me`).

## Day Plans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/day-plans/today` | Today's plan (auto-creates if none exists) |
| GET | `/day-plans/today/items` | Today's items |
| POST | `/day-plans/today/items` | Create item in today's plan (auto-creates plan) |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (auto-creates plan, body: position?) |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD) |
| GET | `/day-plans/{date}/items` | Items by date |
| POST | `/day-plans/{date}/items` | Create item in date's plan (plan must already exist) |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date (plan must already exist, body: position?) |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) |

DayPlanItem fields: item fields + `completed` (boolean), `position`
(integer).

## Meetings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/meetings` | List meetings (paginated) |
| GET | `/meetings/{id}` | Meeting detail (includes issues, done, next arrays) |
| GET | `/meetings/{id}/items` | All meeting items (param: owner_id?, paginated) |
| POST | `/meetings/{id}/items` | Create item in meeting |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove from meeting (keeps item) |
| GET | `/meetings/{id}/items/next` | Next items (param: owner_id?) |
| GET | `/meetings/{id}/items/done` | Done items (param: owner_id?) |
| GET | `/meetings/{id}/items/blocked` | Blocked items (param: owner_id?) |

Meeting fields: `id`, `type` (one_on_one | project), `date`,
`person1`, `person2`, `project`, `issues`, `done`, `next`.

## Status Values

`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`

## Error Responses

| Status | Meaning |
|--------|---------|
| 401 | Invalid/missing token |
| 403 | Not authorized for resource |
| 404 | Resource not found |
| 422 | Validation error (details in response) |

## Pagination

Most list endpoints return: `{ data: [...], meta: { page, per_page, total, total_pages } }`

**Exception**: `GET /teams` returns a flat array (no pagination wrapper).
