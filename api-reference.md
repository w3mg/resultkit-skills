# ResultMaps V2 API Reference

**Source**: https://api.resultmaps.com/api-docs/v2 — refresh from here when endpoints change or docs seem stale.

Base URL: `https://api.resultmaps.com/api/v2`
Web App: `https://app.resultmaps.com` — Web URL column values are paths relative to this base.
Auth: Bearer token in `Authorization` header or `token` query param. Find your token in your profile settings at https://app.resultmaps.com/customize.
Interactive docs: <https://api.resultmaps.com/api-docs/v2>

## Common Query Parameters

Many list endpoints accept these shared params:

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `per_page` | integer | Results per page, 1–100 (default: 25) |
| `q` | string | Filter by name (min 2 chars, case-insensitive contains match) |

Endpoints that support `q` are noted below.

## Items

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items` | List authenticated user's items (params: page, per_page, q, status, team_id) | "show my tasks", "list items", "what's on my plate", "my to-dos" | — |
| POST | `/items` | Create item (body: name*, description, due, status, on_weekly, team_id, parent_id, context) | "add task", "create item", "new to-do", "add action item" | `/items/{id}` |
| GET | `/items/{id}` | Get item detail (includes first-level children) | "show item", "item details", "open task", "what's in item X" | `/items/{id}` |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly) | "update item", "change status", "rename task", "set due date" | `/items/{id}` |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) | "archive item", "delete task", "remove item", "soft delete" | — |
| GET | `/items/{id}/children` | List child items (params: page, per_page, q) | "show sub-tasks", "list children", "nested items", "what's under this" | `/items/{id}` |
| PUT | `/items/{id}/move` | Reposition item in tree (body: parent_id, left_id, right_id) | "move item", "reparent", "nest under", "reorder" | `/items/{id}` |

Item fields: `id`, `name`, `description`, `due`, `status`, `on_weekly`,
`team` (TeamSimple | null), `owner` (UserSimple), `assignees` (UserSimple[]),
`parent_id`, `created_at`, `updated_at`.

ItemDetail: Item fields + `children` (Item[]).

Move body fields: `parent_id` (integer or null — move under parent or to root), `left_id` (integer — place after sibling), `right_id` (integer — place before sibling). At least one required. If both `left_id` and `right_id` given, `left_id` takes precedence.

Smart text: `POST /items` supports `@username` in name to auto-assign, and hashtag date shortcuts (`#tomorrow`, `#nextweek`, `#1month`) to auto-set due date.

### Item Assignees

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items/{id}/assignees` | List assignees (paginated) | "who's assigned", "show assignees", "assigned to" | `/items/{id}` |
| PUT | `/items/{id}/assignees` | Add assignee (body: user_id*) | "assign to", "add assignee", "give to" | `/items/{id}` |
| DELETE | `/items/{id}/assignees/{user_id}` | Remove assignee | "unassign", "remove assignee", "take off" | `/items/{id}` |

### Item Comments

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items/{id}/comments` | List comments (chronological, paginated) | "show comments", "show notes", "what's been said" | `/items/{id}` |
| POST | `/items/{id}/comments` | Create comment (body: body*) | "add comment", "leave a note", "comment on" | `/items/{id}` |

Comment fields: `id`, `body`, `author` (UserSimple), `created_at`.

## Teams

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams` | Authenticated user's teams (params: include_muted, q). Default team first, then alphabetical. | "show my teams", "list teams", "which teams", "my groups" | — |
| POST | `/teams` | Create team (body: name*, description, framework) | "create team", "new team", "add group" | `/teams/{id}` |
| GET | `/teams/{id}` | Get team detail (includes members) | "show team", "team details", "team info", "who's on the team" | `/teams/{id}` |
| PATCH | `/teams/{id}` | Update team (body: name, description, framework) | "update team", "rename team", "change framework" | `/teams/{id}` |
| DELETE | `/teams/{id}` | Delete team (permanent) | "delete team", "remove team" | — |

`GET /teams` response fields per team: `id`, `name`, `description`,
`framework`, `organization_name`, `organization_id`, `parent_name`,
`parent_id`, `is_default`, `is_muted`, `owner` (UserSimple),
`created_at`, `updated_at`.

Team detail fields: `id`, `name`, `description`, `framework`,
`owner` (UserSimple), `created_at`, `updated_at`, `members` (TeamMember[]).

TeamMember: `id`, `team` (TeamSimple), `user` (UserSimple), `role` ("member" | "admin").

### Team Members

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/members` | List members (params: page, per_page, q) | "show members", "who's on the team", "team roster" | `/teams/{id}` |
| PUT | `/teams/{id}/members` | Add member (body: user_id*, role?: "member"\|"admin") | "add member", "invite to team", "make admin" | `/teams/{id}` |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member | "remove member", "kick from team" | `/teams/{id}` |

### Team Weekly Board (Items)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/items` | All team items (params: page, per_page, q, all) | "show weekly", "team board", "weekly board", "L10 board" | `/teams/{id}` |
| POST | `/teams/{id}/items` | Create team item (on_weekly=true) | "add to weekly", "new team task", "create on board" | `/items/{item_id}` |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board (sets on_weekly=true) | "put on weekly", "add to board", "show on weekly" | `/items/{item_id}` |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (sets on_weekly=false, keeps item) | "remove from weekly", "take off board", "hide from weekly" | — |
| GET | `/teams/{id}/items/next` | Items with status=next (params: page, per_page, q, all) | "show next", "priorities", "to-dos (EOS)", "up next" | `/teams/{id}` |
| PUT | `/teams/{id}/items/next/{item_id}` | Add to board + set status=next | "move to next", "prioritize", "set as to-do" | `/items/{item_id}` |
| GET | `/teams/{id}/items/done` | Items with status=done (params: page, per_page, q, all) | "show done", "completed", "finished items" | `/teams/{id}` |
| PUT | `/teams/{id}/items/done/{item_id}` | Add to board + set status=done | "mark done", "complete", "finish item" | `/items/{item_id}` |
| GET | `/teams/{id}/items/issues` | Items with status=blocked (params: page, per_page, q) | "show issues", "blockers", "stuck items", "IDS (EOS)" | `/teams/{id}` |
| PUT | `/teams/{id}/items/issues/{item_id}` | Add to board + set status=blocked | "flag as blocked", "raise issue", "mark stuck" | `/items/{item_id}` |
| GET | `/teams/{id}/items/parked` | Items with status=parked (params: page, per_page, q) | "show parked", "parking lot", "on hold", "deprioritized" | `/teams/{id}` |
| PUT | `/teams/{id}/items/parked/{item_id}` | Add to board + set status=parked | "park item", "put on hold", "deprioritize" | `/items/{item_id}` |

The `all` param (boolean, default false) shows all team members' items when true; otherwise only current user's.


### Team Projects

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/projects` | List active projects (params: page, per_page, q, all) | "show projects", "team projects", "rocks (EOS)", "execution plan" | `/teams/{id}` |
| POST | `/teams/{id}/projects` | Create project in team (body: name*, description, due, status, on_weekly, team_id, parent_id, context) | "create project", "new project on team", "add rock" | `/items/{project_id}` |
| PUT | `/teams/{id}/projects/{project_id}` | Convert item to team project (sets type=TodoList, assigns to team). Idempotent. | "convert to project", "promote to project", "make it a project" | `/items/{project_id}` |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project (body: name, description, due, status, on_weekly) | "update project", "rename project", "change project status" | `/items/{project_id}` |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (clears group_id, keeps project) | "remove project from team", "unlink project", "take off team board" | — |

## Users

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/users/me` | Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`. | "who am I", "my profile", "my token", "my API key" | `/customize` |
| GET | `/users/search` | Search users (params: q* — min 2 chars, page, per_page). Searches login, email, first_name, last_name. Returns active users visible to current user. | "find user", "search people", "look up user" | — |
| GET | `/users/{id}` | User profile (no api_token). Returns UserPublic. | "show user", "user profile", "who is this" | `/users/{id}` |
| GET | `/users/{id}/items` | User's items (requires same-team membership; params: page, per_page, q, status) | "show their tasks", "user's items", "what's assigned to them" | `/users/{id}` |

User fields (`/users/me`): `id`, `login`, `email`, `first_name`, `last_name`,
`api_token`, `default_team` (TeamSimple | null), `current_team` (TeamSimple | null).

UserPublic fields: `id`, `login`, `email`, `first_name`, `last_name`.

UserSimple fields: `id`, `login`, `first_name`, `last_name`.

TeamSimple: `{ id: integer, name: string }`.

## Day Plans

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plans/today` | Today's plan (auto-creates if none exists) | "show today", "my plan", "daily plan", "prioritizer" | `/day-plans/today` |
| GET | `/day-plans/today/items` | Today's items (params: page, per_page, q) | "today's tasks", "what's on today", "my plan items" | `/day-plans/today` |
| POST | `/day-plans/today/items` | Create item in today's plan (auto-creates plan) | "add to today", "new task for today", "put on my plan" | `/items/{item_id}` |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (auto-creates plan, body: position?) | "attach to today", "add to plan", "link to today" | `/day-plans/today` |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) | "check off", "mark done for today", "complete for today", "undo" | `/day-plans/today` |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) | "remove from today", "take off plan", "drop from today" | — |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD) | "show plan for Monday", "last Friday's plan" | `/day-plans/{date}` |
| GET | `/day-plans/{date}/items` | Items by date (params: page, per_page, q) | "items for that day", "what was on Monday" | `/day-plans/{date}` |
| POST | `/day-plans/{date}/items` | Create item in date's plan (plan must already exist) | "add to that day's plan" | `/items/{item_id}` |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date (plan must already exist, body: position?) | "attach to that plan" | `/day-plans/{date}` |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) | "check off for that day" | `/day-plans/{date}` |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) | "remove from that day" | — |

DayPlan fields: `id`, `date`, `owner` (UserSimple), `items` (DayPlanItem[]).

DayPlanItem fields: Item fields + `completed` (boolean), `position` (integer).

Day plan completion: regular items also get status=done. Recurring/daily items only toggle `completed` for that day — item stays active for tomorrow.

## Meetings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/meetings` | List meetings (paginated) | "show meetings", "my meetings", "list 1:1s", "L10s" | — |
| GET | `/meetings/{id}` | Meeting detail (includes issues, done, next arrays) | "show meeting", "meeting details", "open meeting" | `/meetings/{id}` |
| GET | `/meetings/{id}/items` | All meeting items (params: owner_id?, page, per_page, q) | "meeting items", "what's on the agenda" | `/meetings/{id}` |
| POST | `/meetings/{id}/items` | Create item in meeting | "add to meeting", "new meeting item" | `/items/{item_id}` |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item | "attach to meeting", "link item to meeting" | `/meetings/{id}` |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove from meeting (keeps item) | "remove from meeting", "detach from meeting" | — |
| GET | `/meetings/{id}/items/next` | Next items (params: owner_id?, page, per_page, q) | "meeting next items", "meeting priorities" | `/meetings/{id}` |
| GET | `/meetings/{id}/items/done` | Done items (params: owner_id?, page, per_page, q) | "meeting done items", "what got done" | `/meetings/{id}` |
| GET | `/meetings/{id}/items/blocked` | Blocked items (params: owner_id?, page, per_page, q) | "meeting blockers", "meeting issues" | `/meetings/{id}` |

MeetingSimple fields: `id`, `type` (one_on_one | project), `date`,
`person1` (UserSimple), `person2` (UserSimple),
`project` ({ id, name } | null).

Meeting fields: MeetingSimple + `issues` (Item[]), `done` (Item[]), `next` (Item[]).

## Status Values

`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`

`draft` is read-only — cannot be set via POST or PATCH (422 if attempted). Only allowed transition: `draft` → `not_started`.

## Error Responses

All errors return: `{ "error": { "code": "<error_code>", "message": "<human-readable>", "details": { ... } } }`

| Status | Code | Meaning |
|--------|------|---------|
| 400 | `bad_request` | Missing or invalid query parameter |
| 401 | `unauthorized` | Invalid/missing token |
| 403 | `forbidden` | Not authorized for resource |
| 404 | `not_found` | Resource not found |
| 422 | `validation_error` | Validation error (per-field details in `details`) |

## Pagination

Most list endpoints return: `{ data: [...], meta: { page, per_page, total, total_pages } }`

Delete responses return `204 No Content` with empty body.

---

## Glossary

### User Language → API Concept

| User Says | API Concept | Endpoint |
|-----------|-------------|----------|
| item, task, action item, to-do, priority | Item (type=Task) | `/items` |
| project, todo list, TodoList | Item (type=TodoList) | `/items` (type: "TodoList"), `/teams/{id}/projects` |
| outcome, objective (as item type) | Item (type=Outcome) | `/items` (type: "Outcome") |
| key result, KR, measure (as item type) | Item (type=KeyResult) | `/items` (type: "KeyResult") |
| team, group | Team | `/teams` |
| meeting, weekly meeting, weekly sync, L10, team meeting | Meeting | `/meetings` |
| 1:1, 1x1, one-on-one | Meeting (type=one_on_one) | `/meetings` |
| project meeting | Meeting (type=project) | `/meetings` |
| day plan, daily plan, prioritizer, tasks for today, my plan | Day Plan | `/day-plans/today`, `/day-plans/{date}` |
| weekly, team weekly, weekly board, Level 10, L10 (EOS) | Team Items (weekly board; called "Level 10" for EOS teams) | `/teams/{id}/items` |
| issue, blocker, blocked item, challenge | Item with status=blocked | `/teams/{id}/items/issues` |
| next, to-do (column), priority for the week | Item with status=next | `/teams/{id}/items/next` |
| parked, parking lot, park for later | Item with status=parked | `/teams/{id}/items/parked` |
| done, completed, finished | Item with status=done | `/teams/{id}/items/done` |
| assignee, owner, assigned to | Assignee | `/items/{id}/assignees` |
| comment, note | Comment | `/items/{id}/comments` |
| member, team member | Team Member | `/teams/{id}/members` |
| child, sub-task, sub-item, nested item | Child Item (parent_id) | `/items/{id}/children` |
| move, reorder, reparent, nest under | Move Item | `PUT /items/{id}/move` |
| convert to project, promote to project | Convert Item to Project | `PUT /teams/{id}/projects/{item_id}` |
| put on weekly, add to board, show on weekly | Set on_weekly=true | `PUT /teams/{id}/items/{item_id}` |
| remove from weekly, take off board | Set on_weekly=false | `DELETE /teams/{id}/items/{item_id}` |
| attach, link to meeting | Attach Item to Meeting | `PUT /meetings/{id}/items/{item_id}` |
| add to plan, add to today, put on my plan | Attach to Day Plan | `PUT /day-plans/today/items/{item_id}` |
| check off, mark done for today, complete for today | Day Plan Completion | `PATCH /day-plans/today/items/{item_id}` |
| archive, soft delete, remove item | Archive Item (status→archived) | `DELETE /items/{id}` |
| search, find, look up | Search (q param) | `GET /items?q=...`, `GET /users/search?q=...` |
| my token, API key, api token | API Token | `GET /users/me` |
| admin, team admin, make admin | Team Member Role | `PUT /teams/{id}/members` (role: "admin") |
| recurring, daily item, repeating task | Recurring Item | Day plan completion doesn't change item status |

### Item Types

| User Language | DB type | POST body |
|---------------|---------|-----------|
| task, to-do, action item | Task (default) | `{ "name": "..." }` |
| project, todo list | TodoList | `{ "name": "...", "type": "TodoList" }` |
| outcome, objective | Outcome | `{ "name": "...", "type": "Outcome" }` |
| key result, KR | KeyResult | `{ "name": "...", "type": "KeyResult" }` |

### Context (Where to Create)

| User Says | Context Body | Effect |
|-----------|-------------|--------|
| create in team, add to team 42 | `{ "type": "team", "id": 42 }` | Creates in team, sets on_weekly=true |
| create for meeting, add to meeting 99 | `{ "type": "meeting", "id": 99 }` | Creates and links to meeting |
| create for today, add to my plan | `{ "type": "day_plan" }` | Creates and adds to today's day plan |
| _(nothing)_ | _(omit context)_ | Creates as standalone item |

### Smart Text Features

| User Says | Feature | Example | Effect |
|-----------|---------|---------|--------|
| assign @john, @username | @-mention auto-assign | `"Fix bug @jdoe"` | Auto-assigns mentioned user |
| due tomorrow, #tomorrow | Hashtag date shortcut | `"Fix bug #tomorrow"` | Sets due to tomorrow |
| due next week, #nextweek | Hashtag date shortcut | `"Fix bug #nextweek"` | Sets due to next week |
| due in a month, #1month | Hashtag date shortcut | `"Fix bug #1month"` | Sets due to 1 month from now |

### Status Aliases

| User Says | API Status | Notes |
|-----------|-----------|-------|
| not started, new, fresh | `not_started` | Default for new items |
| next, to-do, priority, up next | `next` | Prioritized for this period |
| parked, on hold, deprioritized, later | `parked` | Temporarily shelved |
| blocked, stuck, issue, waiting | `blocked` | Has a dependency/blocker |
| done, complete, finished, resolved | `done` | Completed (sets complete date) |
| archived, deleted, removed | `archived` | Soft-deleted |
| draft | `draft` | Read-only — cannot be set via API |

### Framework Column Names

| API Column | Default | EOS | OKR | 4DX | V2MOM | SRT | SVEP |
|-----------|---------|-----|-----|-----|-------|-----|------|
| next | Next | To-Do | Priorities | WIG Actions | Next | Next | Next |
| done | Done | Done | Done | Done | Done | Done | Done |
| issues | Issues | Issues | Issues + Challenges | Blockers | Obstacles | Issues | Issues |
| parked | Parked | Parked | Park for Later | Parked | Parked | Parked | Parked |

### Key Distinctions

| Concept A | Concept B | Difference |
|-----------|-----------|------------|
| Owner (`owner` field) | Assignee (`assignees` array) | Owner = who created the item. Assignees = who's responsible. One owner, many assignees. |
| Archive (`DELETE /items/{id}`) | Delete (`DELETE /teams/{id}`) | Items are soft-deleted (status→archived). Teams are permanently deleted. |
| Completed (day plan) | Done (item status) | Day plan `completed: true` checks off for that day. Item status `done` marks it globally done. For recurring items only the day plan toggles. |
| on_weekly (item field) | status (item field) | `on_weekly` controls board visibility. `status` controls the column. An item can be `status: next` but `on_weekly: false`. |
| One-on-one meeting | Project meeting | `type: "one_on_one"` has person1/person2. `type: "project"` has a project field. Same endpoints. |
| Team projects (`/teams/{id}/projects`) | Standalone projects (`/projects`) | Team projects are scoped to a team. Standalone are user-level. Same underlying data (type=TodoList). |
| `DELETE /teams/{id}/projects/{pid}` | `DELETE /projects/{id}` | Team version removes from team (clears group_id). Standalone version archives the project. |
