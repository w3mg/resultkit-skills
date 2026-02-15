# ResultMaps V2 API Reference

Base URL: `https://api.resultmaps.com`
Auth: Bearer token in `Authorization` header or `token` query param.

## Items

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items` | List items (params: page, per_page, status, team_id) |
| POST | `/items` | Create item (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| GET | `/items/{id}` | Get item detail (includes children) |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly) |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) |
| GET | `/items/{id}/children` | List child items |
| PUT | `/items/{id}/move` | Move item in tree (body: parent_id, left_id, right_id) |

### Item Assignees

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items/{id}/assignees` | List assignees |
| PUT | `/items/{id}/assignees` | Add assignee (body: user_id) |
| DELETE | `/items/{id}/assignees/{user_id}` | Remove assignee |

### Item Comments

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items/{id}/comments` | List comments (chronological) |
| POST | `/items/{id}/comments` | Create comment (body: body*) |

## Teams

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams` | List teams |
| POST | `/teams` | Create team (body: name*, description, framework) |
| GET | `/teams/{id}` | Get team detail (includes members) |
| PATCH | `/teams/{id}` | Update team |
| DELETE | `/teams/{id}` | Delete team |

### Team Members

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/members` | List members |
| PUT | `/teams/{id}/members` | Add member (body: user_id, role?) |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member |

### Team Weekly Board

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/items` | All team items |
| POST | `/teams/{id}/items` | Create team item (is_wow=true) |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (keeps item) |
| GET | `/teams/{id}/items/next` | Items with status=next |
| PUT | `/teams/{id}/items/next/{item_id}` | Move to next column |
| GET | `/teams/{id}/items/done` | Items with status=done |
| PUT | `/teams/{id}/items/done/{item_id}` | Move to done column |
| GET | `/teams/{id}/items/issues` | Items with status=blocked |
| PUT | `/teams/{id}/items/issues/{item_id}` | Move to issues column |
| GET | `/teams/{id}/items/parked` | Items with status=parked |
| PUT | `/teams/{id}/items/parked/{item_id}` | Move to parked column |

### Team Projects

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/projects` | List active projects |
| POST | `/teams/{id}/projects` | Create project (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (keeps item) |

## Users

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Authenticated user (includes api_token) |
| GET | `/users/{id}` | User profile (no api_token) |
| GET | `/users/{id}/teams` | User's teams |
| GET | `/users/{id}/items` | User's items (requires same-team membership) |

## Day Plans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/day-plans/today` | Today's plan (auto-creates) |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD) |
| GET | `/day-plans/today/items` | Today's items |
| GET | `/day-plans/{date}/items` | Items by date |
| POST | `/day-plans/today/items` | Create item in today's plan |
| POST | `/day-plans/{date}/items` | Create item in date's plan |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (body: position?) |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) |

## Meetings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/meetings` | List meetings |
| GET | `/meetings/{id}` | Meeting detail (includes issues, done, next arrays) |
| GET | `/meetings/{id}/items` | All meeting items (param: owner_id?) |
| POST | `/meetings/{id}/items` | Create item in meeting |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove from meeting (keeps item) |
| GET | `/meetings/{id}/items/next` | Next items (param: owner_id?) |
| GET | `/meetings/{id}/items/done` | Done items (param: owner_id?) |
| GET | `/meetings/{id}/items/blocked` | Blocked items (param: owner_id?) |

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

All list endpoints return: `{ data: [...], meta: { page, per_page, total, total_pages } }`
