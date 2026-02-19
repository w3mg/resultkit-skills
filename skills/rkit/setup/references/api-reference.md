# ResultMaps V2 API Reference

**Source**: https://api.resultmaps.com/api-docs/v1 — refresh from here when endpoints change or docs seem stale.

Base URL: `https://api.resultmaps.com/api/v2`
Auth: Bearer token in `Authorization` header or `token` query param. Find your token in your profile settings at https://app.resultmaps.com/customize.
Interactive docs: <https://api.resultmaps.com/api-docs/v2>
Auth: Bearer token in `Authorization` header or `token` query param.

## Common Query Parameters

Many list endpoints accept these shared params:

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `per_page` | integer | Results per page, 1–100 (default: 25) |
| `q` | string | Filter by name (min 2 chars, case-insensitive contains match) |

Endpoints that support `q` are noted below.

## Items

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items` | List authenticated user's items (params: page, per_page, q, status, team_id) |
| POST | `/items` | Create item (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| GET | `/items/{id}` | Get item detail (includes first-level children) |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly) |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) |
| GET | `/items/{id}/children` | List child items (params: page, per_page, q) |
| PUT | `/items/{id}/move` | Reposition item in tree (body: parent_id* — integer or null) |

Item fields: `id`, `name`, `description`, `due`, `status`, `on_weekly`,
`team` (TeamSimple | null), `owner` (UserSimple), `assignees` (UserSimple[]),
`parent_id`, `created_at`, `updated_at`.

ItemDetail: Item fields + `children` (Item[]).

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

Comment fields: `id`, `body`, `author` (UserSimple), `created_at`.

## Teams

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams` | Authenticated user's teams — **flat array, no pagination**. Default team first, then alphabetical. (params: include_muted, q) |
| POST | `/teams` | Create team (body: name*, description, framework) |
| GET | `/teams/{id}` | Get team detail (includes members) |
| PATCH | `/teams/{id}` | Update team (body: name, description, framework) |
| DELETE | `/teams/{id}` | Delete team |

`GET /teams` response fields per team: `id`, `name`, `description`,
`framework`, `organization_name`, `organization_id`, `parent_name`,
`parent_id`, `is_default`, `is_muted`, `owner` (UserSimple),
`created_at`, `updated_at`.

Team detail fields: `id`, `name`, `description`, `framework`,
`owner` (UserSimple), `created_at`, `updated_at`, `members` (TeamMember[]).

TeamMember: `id`, `team` (TeamSimple), `user` (UserSimple), `role` ("member" | "admin").

### Team Members

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/members` | List members (params: page, per_page, q) |
| PUT | `/teams/{id}/members` | Add member (body: user_id*, role?: "member"\|"admin") |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member |

### Team Weekly Board (Items)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/items` | All team items (params: page, per_page, q, all) |
| POST | `/teams/{id}/items` | Create team item (is_wow=true) |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board (sets group_id, is_wow=true) |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (sets is_wow=false, keeps item) |
| GET | `/teams/{id}/items/next` | Items with status=next (params: page, per_page, q, all) |
| PUT | `/teams/{id}/items/next/{item_id}` | Add to board + set status=next |
| GET | `/teams/{id}/items/done` | Items with status=done (params: page, per_page, q, all) |
| PUT | `/teams/{id}/items/done/{item_id}` | Add to board + set status=done |
| GET | `/teams/{id}/items/issues` | Items with status=blocked (params: page, per_page, q) |
| PUT | `/teams/{id}/items/issues/{item_id}` | Add to board + set status=blocked |
| GET | `/teams/{id}/items/parked` | Items with status=parked (params: page, per_page, q) |
| PUT | `/teams/{id}/items/parked/{item_id}` | Add to board + set status=parked |

The `all` param (boolean, default false) shows all team members' items when true; otherwise only current user's.

### Team Projects

| Method | Path | Description |
|--------|------|-------------|
| GET | `/teams/{id}/projects` | List active projects (params: page, per_page, q, all) |
| POST | `/teams/{id}/projects` | Create project in team (body: name*, description, due, status, on_weekly, team_id, parent_id, context) |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project (body: name, description, due, status, on_weekly) |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (clears group_id, keeps project) |

## Users

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`. |
| GET | `/users/search` | Search users (params: q* — min 2 chars, page, per_page). Searches login, email, first_name, last_name. Returns active users visible to current user. |
| GET | `/users/{id}` | User profile (no api_token). Returns UserPublic. |
| GET | `/users/{id}/items` | User's items (requires same-team membership; params: page, per_page, q, status) |

User fields (`/users/me`): `id`, `login`, `email`, `first_name`, `last_name`,
`api_token`, `default_team` (TeamSimple | null), `current_team` (TeamSimple | null).

UserPublic fields: `id`, `login`, `email`, `first_name`, `last_name`.

UserSimple fields: `id`, `login`, `first_name`, `last_name`.

TeamSimple: `{ id: integer, name: string }`.

## Day Plans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/day-plans/today` | Today's plan (auto-creates if none exists) |
| GET | `/day-plans/today/items` | Today's items (params: page, per_page, q) |
| POST | `/day-plans/today/items` | Create item in today's plan (auto-creates plan) |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (auto-creates plan, body: position?) |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD) |
| GET | `/day-plans/{date}/items` | Items by date (params: page, per_page, q) |
| POST | `/day-plans/{date}/items` | Create item in date's plan (plan must already exist) |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date (plan must already exist, body: position?) |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) |

DayPlan fields: `id`, `date`, `owner` (UserSimple), `items` (DayPlanItem[]).

DayPlanItem fields: Item fields + `completed` (boolean), `position` (integer).

## Meetings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/meetings` | List meetings (paginated) |
| GET | `/meetings/{id}` | Meeting detail (includes issues, done, next arrays) |
| GET | `/meetings/{id}/items` | All meeting items (params: owner_id?, page, per_page, q) |
| POST | `/meetings/{id}/items` | Create item in meeting |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove from meeting (keeps item) |
| GET | `/meetings/{id}/items/next` | Next items (params: owner_id?, page, per_page, q) |
| GET | `/meetings/{id}/items/done` | Done items (params: owner_id?, page, per_page, q) |
| GET | `/meetings/{id}/items/blocked` | Blocked items (params: owner_id?, page, per_page, q) |

MeetingSimple fields: `id`, `type` (one_on_one | project), `date`,
`person1` (UserSimple), `person2` (UserSimple),
`project` ({ id, name } | null).

Meeting fields: MeetingSimple + `issues` (Item[]), `done` (Item[]), `next` (Item[]).

## Status Values

`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`

## Error Responses

| Status | Meaning |
|--------|---------|
| 400 | Missing or invalid query parameter |
| 401 | Invalid/missing token |
| 403 | Not authorized for resource |
| 404 | Resource not found |
| 422 | Validation error (details in response) |

## Pagination

Most list endpoints return: `{ data: [...], meta: { page, per_page, total, total_pages } }`

**Exception**: `GET /teams` returns a flat array (no pagination wrapper).
