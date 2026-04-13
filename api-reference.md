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
| `per_page` | integer | Results per page, 1–100 (default: 100) |
| `q` | string | Filter by name (min 2 chars, case-insensitive contains match) |
| `include_archived` | string | When `"true"`, includes archived items (default: `"false"`) |

Endpoints that support `q` and `include_archived` are noted below.

`include_archived`: by default, archived items are excluded from all list endpoints. Pass `include_archived=true` to include them. Supported on `GET /items`, `GET /projects`, `GET /meetings/{id}/items`, and `GET /meetings/{id}/items/{section}` (next section only).

## Items

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items` | List authenticated user's items (params: page, per_page, q, status, team_id, include_archived) | "show my tasks", "list items", "what's on my plate", "my to-dos" | — |
| POST | `/items` | Create item (body: name*, type, description, due, status, on_weekly, team_id, parent_id, context) | "add task", "create item", "new to-do", "add action item" | `/items/{id}` |
| GET | `/items/{id}` | Get item detail (includes first-level children) | "show item", "item details", "open task", "what's in item X" | `/items/{id}` |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly) | "update item", "change status", "rename task", "set due date" | `/items/{id}` |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) | "archive item", "delete task", "remove item", "soft delete" | — |
| GET | `/items/{id}/children` | List child items as nested tree (params: page, per_page, q, depth). `depth` default 2, range 1-20. | "show sub-tasks", "list children", "nested items", "what's under this" | `/items/{id}` |
| PUT | `/items/{id}/move` | Reposition item in tree (body: parent_id, left_id, right_id) | "move item", "reparent", "nest under", "reorder" | `/items/{id}` |
| PATCH | `/items/bulk-move` | Move up to 1000 items under a target parent (body: item_ids, parent_id). Items removed from all weekly boards. | "bulk move", "move items", "move these under", "reparent multiple" | — |

Item fields: `id`, `name`, `description`, `due`, `status`, `on_weekly`,
`team` (TeamSimple | null), `creator` (UserSimple), `assignees` (UserSimple[]),
`parent_id`, `created_at`, `updated_at`.

Item `type` values: `Task` (default), `TodoList`, `Outcome`, `KeyResult`.

ItemDetail: Item fields + `children` (Item[]).

ItemTreeNode: Item fields + `children` (ItemTreeNode[]). Returned by `GET /items/{id}/children`. Nested recursively to the requested `depth` (1–20, default 2). Empty array at leaf nodes or max depth.

Move body fields: `parent_id` (integer or null — move under parent or to root), `left_id` (integer — place after sibling), `right_id` (integer — place before sibling). At least one required. If both `left_id` and `right_id` given, `left_id` takes precedence.

Bulk move: `PATCH /items/bulk-move` body: `{ "item_ids": integer[], "parent_id": integer }`. Response: `{ "data": { "moved": integer, "failed": integer, "errors": [{ "id": integer, "reason": string }] } }`. Per-item error reasons: `not_found`, `forbidden`, `self_reference`. Items already under the target parent are silently counted as moved. Duplicate item_ids are deduplicated server-side. Items are removed from all weekly board placements after being moved. Returns 403 if user cannot access the target parent, 404 if target parent not found, 422 for validation errors (empty item_ids, exceeds 1000, missing parent_id).

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
| POST | `/teams` | Create team (body: name*, description, framework, parent_id?). Optional `parent_id` creates a child team under an existing parent; child inherits parent's account, framework (unless overridden), and team settings (`is_strict`, `assignments_require_review`, `is_cascading_goals`). Returns 403 if caller lacks view access to parent, 422 if parent_id is invalid. | "create team", "new team", "add group", "create child team", "create sub-team", "create team under" | `/teams/{id}` |
| GET | `/teams/{id}` | Get team detail (includes members) | "show team", "team details", "team info", "who's on the team" | `/teams/{id}` |
| PATCH | `/teams/{id}` | Update team (body: name, description, framework) | "update team", "rename team", "change framework" | `/teams/{id}` |
| DELETE | `/teams/{id}` | Delete team (permanent) | "delete team", "remove team" | — |
| PUT | `/teams/{id}/mute` | Mute team for current user (idempotent). Muted teams excluded from `GET /teams` unless `include_muted=true`. | "mute team", "hide team", "silence team" | — |
| DELETE | `/teams/{id}/mute` | Unmute team for current user (idempotent) | "unmute team", "unhide team", "show team again" | — |

`GET /teams` returns the standard data envelope: `{ "data": [...] }`. Response fields per team: `id`, `name`, `description`,
`framework`, `organization_name`, `organization_id`, `parent_name`,
`parent_id`, `is_default`, `is_muted`, `logo_url` (string | null — Filestack CDN URL or null if no logo set), `creator` (UserSimple),
`created_at`, `updated_at`.

Team detail fields: `id`, `name`, `description`, `framework`, `parent_id` (integer | null — ID of parent team, or null for root teams),
`logo_url` (string | null — Filestack CDN URL or null if no logo set), `creator` (UserSimple), `created_at`, `updated_at`, `members` (TeamMember[]).

TeamMember: `id`, `team` (TeamSimple), `user` (UserSimple), `role` ("member" | "admin").

Mute/unmute response: `{ data: { id, name, is_muted } }`.

### Team Members

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/members` | List members (params: page, per_page, q) | "show members", "who's on the team", "team roster" | `/teams/{id}` |
| PUT | `/teams/{id}/members` | Add existing user to team (body: user_id*, role?: "member"\|"admin") | "add member", "make admin" | `/teams/{id}` |
| POST | `/teams/{id}/members/invite` | Invite new user by email (body: email*, first_name*, last_name*). Creates passive user + sends invite email via SES (fire-and-forget). Admin only. Returns 201 with membership. | "invite member", "invite to team", "send invite", "invite new user" | `/teams/{id}` |
| PATCH | `/teams/{id}/members/{user_id}` | Change member role (body: role* — "admin" or "member"). Admin-only. Cannot demote last admin. | "change role", "make admin", "promote to admin", "demote member", "change member role" | `/teams/{id}` |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member | "remove member", "kick from team" | `/teams/{id}` |

POST /teams/{id}/members/invite body: `{ "email", "first_name", "last_name" }`. Response 201: `{ "data": { "id", "team": { "id", "name" }, "user": { "id", "login", "first_name", "last_name" }, "role": "member" } }`. Errors: 401, 403 (not team admin), 404, 422 (email taken or blank fields). Invited user is created in `passive` state — cannot log in until they complete sign-up via the invitation email link. Email delivery is fire-and-forget (SES failure does not fail the request). If email already belongs to an existing user, returns 422 with `details.email: ["has already been taken"]` — use PUT /teams/{id}/members to add existing users instead.

PATCH /teams/{id}/members/{user_id} body: `{ "role": "admin" | "member" }`. Response: `{ "data": { "id", "login", "first_name", "last_name", "email", "role" } }`. Errors: 401 (unauthorized), 403 (not a team admin), 404 (team or user not found), 422 (invalid role).

### Team Activity Logs

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/activity-logs` | Paginated list of membership changes (params: page, per_page). Team member auth required. | "activity logs", "team history", "membership changes", "who joined", "who was removed", "team audit log" | — |

ActivityLogEntry fields: `id`, `action` ("member_added" \| "member_removed" \| "role_changed"), `target_user` (UserSimple), `actor` (UserSimple), `details` (string), `created_at`. Wrapped in standard `{ data: [...], meta: { page, per_page, total, total_pages } }` envelope. Errors: 401, 403 (not a team member), 404 (team not found).

### Team Labels

Admin-only for writes. Labels are organizational tags (name + color) used in the web UI.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/labels` | List team labels (params: page, per_page). Team member auth required. | "team labels", "team tags", "show labels" | — |
| POST | `/teams/{id}/labels` | Create label (body: name*, color*). Admin only. | "create label", "add label", "new team tag" | — |
| PATCH | `/teams/{id}/labels/{label_id}` | Update label (body: name?, color?). Admin only. | "update label", "rename label", "change label color" | — |
| DELETE | `/teams/{id}/labels/{label_id}` | Delete label. Admin only. | "delete label", "remove label" | — |

Label fields: `id`, `name`, `color` (hex string, e.g. "#3b82f6"), `created_at`. Wrapped in standard `{ data: [...], meta }` envelope (list) or `{ data: {...} }` (create/update). Errors: 401, 403 (non-member for GET; non-admin for writes), 404.

### Team Integrations

Admin-only. Webhook configurations (e.g. Slack). Managed via web UI — reference only.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/integrations` | List integrations (params: page, per_page). Admin only. | "team integrations", "slack integration", "team webhook", "team webhook list" | — |
| POST | `/teams/{id}/integrations` | Create/upsert integration by type (body: type*, name*, webhook_url*). Admin only. | "create integration", "add webhook", "set up slack" | — |
| PATCH | `/teams/{id}/integrations/{integration_id}` | Update integration (body: name?, webhook_url?). Admin only. | "update integration", "change webhook url" | — |
| DELETE | `/teams/{id}/integrations/{integration_id}` | Delete integration (disables it). Admin only. | "delete integration", "remove webhook", "disable slack" | — |

Integration fields: `id`, `type` ("slack"; others TBD), `name`, `webhook_url`, `enabled` (boolean), `created_at`, `updated_at`. POST upserts by type — one integration per type per team. Errors: 401, 403 (non-admin), 404.

### Team Logo

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/logo` | Set team logo URL (body: logo_url* — must be `https://cdn.filestackcontent.com/` URL). Admin-only. Upserts (replaces previous). | "upload logo", "team logo", "set team logo" | — |
| DELETE | `/teams/{id}/logo` | Remove team logo. Admin-only. Idempotent (200 even if no logo). | "remove logo", "delete team logo", "clear team logo" | — |

Response: `{ data: { logo_url: "https://cdn.filestackcontent.com/..." | null } }`. Errors: 403 (non-admin), 404 (team not found), 422 (invalid URL — POST only).

### Team Settings

Per-team boolean settings stored in `object_metas` table — no schema changes required.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/settings` | Get all team settings (auth: any team member) | "team settings", "show settings", "is strict mode on", "check team settings" | `/teams/{id}` |
| PATCH | `/teams/{id}/settings` | Update one or more settings (auth: team admin only). Unrecognized keys silently ignored. Returns full settings object after update. | "update settings", "change setting", "enable strict mode", "turn on bhag", "toggle setting" | `/teams/{id}` |

Settings response shape: `{ "data": { "is_cascading_goals": bool, "is_strict": bool, "bhag_enabled": bool, "assignments_require_review": bool, "skip_show_completion_message": bool, "scorecard_notes_visible": bool } }`.

| Setting Key | Description |
|-------------|-------------|
| `is_cascading_goals` | Whether goals cascade to sub-teams |
| `is_strict` | EOS strict meeting accountability mode (EOS teams default `true` when no record exists) |
| `bhag_enabled` | Whether the BHAG section is visible |
| `assignments_require_review` | Whether action assignments require a review step |
| `skip_show_completion_message` | Whether to suppress the item completion message |
| `scorecard_notes_visible` | Whether the notes column is displayed on the team scorecard UI (default `false`; display hint only — the API always returns `notes` on measures regardless) |

PATCH body: any subset of the five recognized boolean keys (e.g. `{ "is_strict": false }`). Errors: 400 (invalid team id), 401 (no auth), 403 (GET: not a team member; PATCH: not a team admin), 404 (team not found), 422 (non-boolean value sent — `{ "error": { "code": "validation_error", "details": { "<key>": ["must be a boolean"] } } }`).

### Team Weekly Board (Items)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/items` | All team items (params: page, per_page, q, all, include_archived) | "show weekly", "team board", "weekly board", "L10 board" | `/teams/{id}` |
| POST | `/teams/{id}/items` | Create team item (on_weekly=true) | "add to weekly", "new team task", "create on board" | `/items/{item_id}` |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board (sets on_weekly=true) | "put on weekly", "add to board", "show on weekly" | `/items/{item_id}` |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (sets on_weekly=false, keeps item) | "remove from weekly", "take off board", "hide from weekly" | — |
| GET | `/teams/{id}/items/{section}` | Items by section (params: page, per_page, q, all, include_archived). Section: `done`, `next`, `blocked`, `parked`. | "show next", "show done", "show issues", "show parked", "priorities", "blockers", "parking lot" | `/teams/{id}` |
| PUT | `/teams/{id}/items/{section}/{item_id}` | Move item to section on board. Section: `done`, `next`, `blocked`, `parked`. | "move to next", "mark done", "flag as blocked", "park item", "prioritize" | `/items/{item_id}` |

Section values for `{section}`: `done`, `next`, `blocked`, `parked`.

| Section | GET shows | PUT effect |
|---------|-----------|------------|
| `next` | Items with status=next. Default: due within 7 days. Pass `?all=true` to skip. | Sets status=next, ensures on_weekly=true, auto-sets due date if null |
| `done` | Items with status=done. Default: completed within 7 days. Pass `?all=true` to skip. | Sets status=done, records completion timestamp |
| `blocked` | Items with status=blocked. No time filter. | Sets status=blocked, ensures on_weekly=true |
| `parked` | Items with status=parked. No time filter. Supports `include_archived`. | Sets status=parked, ensures on_weekly=true |

The `all` param (boolean, default false) on team item endpoints shows all team members' items when true; otherwise only current user's. Note: team projects do NOT use `all` — use `followed_only` and `include_muted` instead.

Due date auto-set: creating an item with `status: "next"` in a team context (or moving an item to the `next` column via `PUT .../items/{section}/{item_id}`) with no explicit `due` date auto-sets `due` to 7 days from now. Explicit `due` values are always preserved.


### Team Projects

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/projects` | List team projects (params: page, per_page, q, status, include_muted, followed_only). Default: active, non-parkinglot, non-muted. Each project includes `default_view` (string\|null) and completion stats: `percent_complete` (number, 0–100), `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count` (all integers). | "show projects", "team projects", "rocks (EOS)", "execution plan", "project completion", "how complete is this project" | `/teams/{id}` |
| POST | `/teams/{id}/projects` | Create project in team (body: name*, description, due, status, on_weekly, team_id, parent_id, context). Note: stat fields are NOT included in create responses. | "create project", "new project on team", "add rock" | `/items/{project_id}` |
| GET | `/projects/{id}` | Get single project detail. Includes `default_view` (string\|null) and completion stats: `percent_complete`, `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count`. Also includes `children` array. | "show project", "project detail", "open project" | `/items/{project_id}` |
| PUT | `/teams/{id}/projects/{project_id}` | Convert item to team project (sets type=TodoList, assigns to team). Idempotent. | "convert to project", "promote to project", "make it a project" | `/items/{project_id}` |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project (body: name, description, due, status, on_weekly) | "update project", "rename project", "change project status" | `/items/{project_id}` |
| PATCH | `/projects/{id}/default-view` | Set default view for a project (body: default_view*). Any team member with view access. Shared across all members. | "set default view", "change default view", "default to board view", "set project view" | — |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (clears group_id, keeps project) | "remove project from team", "unlink project", "take off team board" | — |

Default filtering: returns only active, non-parkinglot, non-muted projects. Use `status` to override the active-only filter (e.g. `?status=done`). Use `include_muted=true` to include muted items.

**Project completion stats** (`percent_complete`, `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count`): returned on all GET project responses (list and detail). All fields are always numeric (never null); projects with no children have all zeros. Stats are NOT returned on POST/PATCH responses. Counts exclude archived children.

`default_view` valid values: `"overview"`, `"board"`, `"table"`, `"roadmap"`, `"outline"`, `"mindmap"`, `null` (resets to no preference; treated as `"overview"` by clients). Per-project, shared across all team members. `PATCH /projects/{id}/default-view` body: `{ "default_view": string | null }`. Response 200: `{ "data": { "id": integer, "default_view": string | null } }`. Response 422: `{ "errors": ["default_view is not a valid view"] }`.

### Team Headlines

Only available for teams using the EOS framework.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/headlines` | List active headlines (params: page, per_page). Active = no expiration AND created within 7 days, OR expires_at > today. When expires_at is set, only expiration matters. | "show headlines", "team headlines", "what's new", "announcements" | `/teams/{id}` |
| POST | `/teams/{id}/headlines` | Create headline (body: text*, expires_at?) | "add headline", "new headline", "share update", "post announcement" | `/teams/{id}` |
| PATCH | `/teams/{id}/headlines/{headline_id}` | Update headline (body: text?, expires_at?). Creator or team admin only. | "update headline", "edit headline", "change headline" | `/teams/{id}` |
| DELETE | `/teams/{id}/headlines/{headline_id}` | Archive headline (soft delete — sets expires_at to today, immediately hidden). Creator or team admin only. | "delete headline", "remove headline", "archive headline" | — |

Headline fields: `id`, `text`, `creator` (UserSimple), `expires_at` (YYYY-MM-DD | null), `created_at`, `updated_at`.

HeadlineCreateRequest: `text` (string, required), `expires_at` (YYYY-MM-DD, optional — if omitted, headline visible for 7 days from creation).

HeadlineUpdateRequest: `text` (string), `expires_at` (YYYY-MM-DD). At least one field required.

### EOS Level 10 (L10)

EOS-friendly URL aliases for the team weekly board. These endpoints return the same data as their generic V2 counterparts but use Level 10 terminology. Only available for EOS teams.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/todos` | List L10 to-dos (alias for `GET /teams/{id}/items/next`; params: page, per_page, q, all) | "show L10 to-dos", "L10 todos", "weekly to-dos" | `/teams/{id}` |
| GET | `/teams/{id}/l10/done` | List completed L10 to-dos (alias for `GET /teams/{id}/items/done`; params: page, per_page, q, all). Default: completed within 7 days. `all=true` for older. | "show L10 done", "completed to-dos", "L10 completed" | `/teams/{id}` |
| GET | `/teams/{id}/l10/issues` | List L10 issues (alias for `GET /teams/{id}/items/blocked`; params: page, per_page, q) | "show L10 issues", "IDS list", "L10 blockers" | `/teams/{id}` |
| GET | `/teams/{id}/l10/parked` | List L10 parking lot (alias for `GET /teams/{id}/items/parked`; params: page, per_page, q) | "show L10 parking lot", "L10 parked", "parked items" | `/teams/{id}` |
| GET | `/teams/{id}/l10/headlines` | List L10 headlines (alias for `GET /teams/{id}/headlines`; params: page, per_page) | "show L10 headlines", "L10 announcements" | `/teams/{id}` |
| POST | `/teams/{id}/l10/todos` | Create L10 to-do (body: name*, description?, due?). Status=next, due defaults to 7 days. | "add L10 to-do", "new to-do", "create L10 todo" | `/items/{item_id}` |
| POST | `/teams/{id}/l10/issues` | Create L10 issue (body: name*, description?, due?). Status=blocked. | "add L10 issue", "raise issue", "new IDS item" | `/items/{item_id}` |
| POST | `/teams/{id}/l10/headlines` | Create L10 headline (alias for `POST /teams/{id}/headlines`; body: text*, expires_at?) | "add L10 headline", "new L10 headline" | `/teams/{id}` |
| PUT | `/teams/{id}/l10/todos/{item_id}` | Move item to L10 to-dos. Sets status=next, auto-sets due to 7 days if null. Alias for `PUT /teams/{id}/items/next/{item_id}`. | "move to L10 to-dos", "make it a to-do", "prioritize in L10" | `/items/{item_id}` |
| PUT | `/teams/{id}/l10/done/{item_id}` | Mark L10 item as done. Sets status=done, records completion. Alias for `PUT /teams/{id}/items/done/{item_id}`. | "mark L10 done", "complete L10 to-do", "L10 done" | `/items/{item_id}` |
| PUT | `/teams/{id}/l10/issues/{item_id}` | Move item to L10 issues. Sets status=blocked. Alias for `PUT /teams/{id}/items/blocked/{item_id}`. | "move to L10 issues", "flag as issue", "IDS this" | `/items/{item_id}` |
| PUT | `/teams/{id}/l10/parked/{item_id}` | Park L10 item. Sets status=parked. Alias for `PUT /teams/{id}/items/parked/{item_id}`. | "park L10 item", "move to parking lot", "shelve in L10" | `/items/{item_id}` |
| DELETE | `/teams/{id}/l10/items/{item_id}` | Remove item from L10 board (sets on_weekly=false, keeps item). Alias for `DELETE /teams/{id}/items/{item_id}`. | "remove from L10", "take off L10 board", "drop from L10" | — |

### Team Activity Logs

Team membership change audit trail. Any team member can view.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/activity-logs` | List membership change events (params: page, per_page). Actions: member_added, member_removed, role_changed. | "team activity", "audit log", "membership changes", "who joined" | — |

ActivityLog fields: `id`, `action` ("member_added" | "member_removed" | "role_changed"), `target_user` (UserSimple), `actor` (UserSimple), `details` (string), `created_at`.

### Team Labels

Team-scoped colored labels. Any member can view; admin-only for create/update/delete.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/labels` | List team labels (paginated) | "show labels", "team labels", "list tags" | — |
| POST | `/teams/{id}/labels` | Create label (body: name*, color?). Admin-only. Name max 50 chars, unique per team. Color hex `#xxxxxx`. | "create label", "add label", "new tag" | — |
| PATCH | `/teams/{id}/labels/{label_id}` | Update label (body: name?, color?). Admin-only. | "update label", "rename label", "change label color" | — |
| DELETE | `/teams/{id}/labels/{label_id}` | Delete label (permanent). Admin-only. | "delete label", "remove label", "remove tag" | — |

Label fields: `id`, `name`, `color` (hex string), `created_at`.

### Team Integrations

Webhook integrations (Slack/Discord). Admin-only for all operations.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/integrations` | List configured integrations (admin-only, paginated) | "show integrations", "list webhooks", "team integrations" | — |
| POST | `/teams/{id}/integrations` | Create or update integration (body: type*, webhook_url*, name?). Admin-only. Upsert: one per type per team. | "add integration", "connect Slack", "set up webhook" | — |
| PATCH | `/teams/{id}/integrations/{integration_id}` | Update integration (body: name?, webhook_url?). Admin-only. | "update integration", "change webhook", "update Slack" | — |
| DELETE | `/teams/{id}/integrations/{integration_id}` | Delete integration (permanent). Admin-only. | "delete integration", "remove webhook", "disconnect Slack" | — |

Integration fields: `id`, `type` ("slack" | "discord"), `name`, `webhook_url`, `enabled` (boolean), `created_at`, `updated_at`.

### Team Logo

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/logo` | Set team logo URL (body: logo_url* — must be `https://cdn.filestackcontent.com/` URL). Admin-only. Upserts (replaces previous). | "upload logo", "set team logo", "change team image" | — |
| DELETE | `/teams/{id}/logo` | Remove team logo. Admin-only. Idempotent (200 even if no logo). | "remove logo", "delete team logo", "clear team logo" | — |

Response: `{ data: { logo_url: "https://cdn.filestackcontent.com/..." | null } }`. Errors: 403 (non-admin), 404 (team not found), 422 (invalid URL — POST only).

### L10 Meeting Organizer

Endpoints supporting the L10 Meeting Organizer page (Team Weekly). All under `/teams/{id}/l10/`.

#### Weekly Focus (Rally Cry)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/weekly-focus` | Get current + previous weekly focus entries (params: date — YYYY-MM-DD) | "show rally cry", "weekly focus", "what's the focus", "team rally cry" | `/teams/{id}` |
| POST | `/teams/{id}/l10/weekly-focus` | Set weekly focus for a date (body: focus_name*, date*). Admin only. | "set rally cry", "set weekly focus", "new rally cry" | `/teams/{id}` |

GET response: `{ data: { id, weekly_focus, created_for, previous_weekly_focus: [{ id, created_for, focus_name, average_rating }] } }`.
POST response (201): `{ data: { id, focus_name, created_for } }`.

#### Weekly Notes

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/weekly-notes` | Get current + previous meeting notes | "show meeting notes", "weekly notes", "L10 notes" | `/teams/{id}` |
| POST | `/teams/{id}/l10/weekly-notes` | Create a meeting note (body: title*, body*, json_content*). Admin only. HTML body sanitized server-side. | "add meeting note", "new weekly note", "create L10 note" | `/teams/{id}` |
| PATCH | `/teams/{id}/l10/weekly-notes/{note_id}` | Update a meeting note (body: title?, body?). Admin only. | "update meeting note", "edit weekly note" | `/teams/{id}` |
| DELETE | `/teams/{id}/l10/weekly-notes/{note_id}` | Delete a meeting note. Admin only. | "delete meeting note", "remove weekly note" | `/teams/{id}` |

GET response: `{ data: { current: { id, title, body, json_content, creator_id, created_at, updated_at }, previous: [same shape] } }`.
POST response (201): Created note in `data` envelope. DELETE: 204 No Content.

#### Wins

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/wins` | Get team wins for a date range (params: date — YYYY-MM-DD). | "show wins", "team wins", "what did we win", "victories" | `/teams/{id}` |
| POST | `/teams/{id}/l10/wins` | Create a win (body: name*, win_type* ["personal"\|"professional"], win_date* [YYYY-MM-DD], description?). Member auth. user_id set from auth token. | "add win", "create win", "log a win", "new win" | `/teams/{id}` |
| PATCH | `/teams/{id}/l10/wins/{win_id}` | Update a win (body: name?, win_type?, win_date?, description?). Owner or admin only. | "update win", "edit win", "change win" | `/teams/{id}` |
| DELETE | `/teams/{id}/l10/wins/{win_id}` | Delete a win. Owner or admin only. Returns 204. | "delete win", "remove win" | `/teams/{id}` |

Response (GET): `{ data: { wins: [{ id, name, description, win_type, win_date, user: { id, full_name }, created_at }] } }`. `win_type`: "professional" or "personal".

Response (POST 201, PATCH 200): `{ data: { win: { id, name, description, win_type, win_date, user: { id, full_name }, created_at } } }`.

Response (DELETE): 204 No Content. Errors: 403 if not owner and not admin.

#### Documents

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/documents` | List team documents (paginated) | "show documents", "team docs", "team files", "list documents" | `/teams/{id}` |
| POST | `/teams/{id}/l10/documents` | Upload a document (multipart form data: file*, name*, material_category_id?, description?). Member auth. | "upload document", "add team file", "new document" | `/teams/{id}` |
| PATCH | `/teams/{id}/l10/documents/{doc_id}` | Update document metadata (body: name?, material_category_id?, description?). Admin/owner only. | "update document", "rename document" | `/teams/{id}` |
| DELETE | `/teams/{id}/l10/documents/{doc_id}` | Delete a document. Admin/owner only. | "delete document", "remove file" | `/teams/{id}` |

Document fields: `id`, `name`, `filename`, `content_type`, `size`, `description`, `material_category_id`, `user_id`, `created_at`. Paginated with `meta`. POST uses multipart form data (not JSON). DELETE: 204.

#### Linked URLs

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/linked-urls` | List linked URLs (paginated) | "show linked urls", "team links", "list urls" | `/teams/{id}` |
| POST | `/teams/{id}/l10/linked-urls` | Create a linked URL (body: title*, full_path*, description?, media_type_code?, material_category_id?). Member auth. | "add linked url", "new team link", "link a url" | `/teams/{id}` |
| PATCH | `/teams/{id}/l10/linked-urls/{url_id}` | Update a linked URL (body: title?, full_path?, description?, media_type_code?, material_category_id?). Member auth. | "update linked url", "edit team link" | `/teams/{id}` |
| DELETE | `/teams/{id}/l10/linked-urls/{url_id}` | Delete a linked URL. Member auth. | "delete linked url", "remove team link" | `/teams/{id}` |

LinkedURL fields: `id`, `title`, `full_path`, `description`, `media_type_code`, `material_category_id`, `user_id`, `created_at`. Paginated with `meta`. DELETE: 204.

#### Shared Links

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/shared-links` | List shared links | "show shared links", "team shared links" | `/teams/{id}` |
| POST | `/teams/{id}/l10/shared-links` | Create a shared link (body: title*, link_string*). Member auth. | "add shared link", "share a link", "new shared link" | `/teams/{id}` |
| DELETE | `/teams/{id}/l10/shared-links/{link_id}` | Delete a shared link. Member auth. | "delete shared link", "remove shared link" | `/teams/{id}` |

SharedLink fields: `id`, `title`, `link_string`, `user_id`, `created_at`. Response in `data` envelope. DELETE: 204.

#### Weekly Ratings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/weekly-ratings` | Get all-time average rating and total count | "show weekly rating", "team rating", "meeting rating", "how are meetings rated" | `/teams/{id}` |
| POST | `/teams/{id}/l10/weekly-ratings` | Submit or update weekly rating (body: rating*, date*). One rating per user per week — upserts. Member auth. | "rate meeting", "submit rating", "rate the week", "rate weekly" | `/teams/{id}` |

GET response: `{ data: { average_rating, total_ratings } }`.
POST response (201 new, 200 updated): `{ data: { id, stars, created_at } }`.

#### Braindump

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/l10/braindump` | Bulk create items on the board (body: items* — string[], section*). Admin only. Max 50 items per request. | "braindump", "bulk add items", "dump items to board", "brain dump" | `/teams/{id}` |

`section` values: `next`, `blocked`, `parked`.
Response (201): `{ data: { items: [{ id, name }], count } }`.

#### Item Reorder

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| PATCH | `/teams/{id}/l10/reorder` | Reorder organizer items (body: item_ids* — integer[]). Admin only. All IDs must belong to the team and be on the organizer board (is_wow=true). | "reorder items", "rearrange board", "sort items" | `/teams/{id}` |

Response (200): `{ data: { success: true, count } }`.

#### Meeting Settings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/meeting-settings` | Get meeting day, start time, and section durations | "show meeting settings", "meeting schedule", "L10 settings", "meeting time" | `/teams/{id}` |
| PATCH | `/teams/{id}/l10/meeting-settings` | Update meeting settings (body: meeting_day?, start_time?, section_durations?). Admin only. | "update meeting settings", "change meeting day", "set meeting time", "adjust section times" | `/teams/{id}` |

Response: `{ data: { meeting_day, start_time, section_durations: { transition, scorecard, goals, headlines, done, next, blocked } } }`.
`meeting_day`: 0-6 (Sunday=0). `start_time`: formatted string e.g. `"01:30 PM"`. `section_durations`: values are integers (minutes).

#### Meeting Summary Email

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/l10/meeting-summary` | Send summary email to all team members. Admin only. Fire-and-forget. | "send meeting summary", "email meeting notes", "send L10 summary" | `/teams/{id}` |

Response (200): `{ data: { sent_to, message } }`. Example: `{ "sent_to": 8, "message": "Meeting summary sent to 8 team members" }`.

#### L10 Meeting Organizer Error Responses

All L10 Meeting Organizer endpoints share these error shapes:
```json
{ "error": { "code": "bad_request", "message": "Invalid team ID" } }
{ "error": { "code": "forbidden", "message": "Admin access required" } }
{ "error": { "code": "not_found", "message": "Team not found" } }
{ "error": { "code": "validation_error", "message": "Validation failed", "details": { "<field>": "Required" } } }
```

## Users

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/users/me` | Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`. `current_team` reflects the team last set via `PATCH /users/me/team-context` (was always null before 2026-03-13 API fix). | "who am I", "my profile", "my token", "my API key" | `/customize` |
| GET | `/users/search` | Search users (params: q* — min 2 chars, page, per_page). Searches login, email, first_name, last_name. Returns active users visible to current user. | "find user", "search people", "look up user" | — |
| GET | `/users/{id}` | User profile (no api_token). Returns UserPublic. | "show user", "user profile", "who is this" | `/users/{id}` |
| GET | `/users/{id}/items` | User's items (requires same-team membership; params: page, per_page, q, status) | "show their tasks", "user's items", "what's assigned to them" | `/users/{id}` |
| GET | `/users/{user_id}/stats` | User profile stats (supports `me` as ID; requires shared team membership) | "show stats", "user stats", "profile stats", "how am I doing" | `/users/{user_id}` |
| GET | `/users/{user_id}/measurables` | User scorecard metrics with periodic data (params: period?, year?, active_only?; requires shared team membership) | "show measurables", "scorecard", "metrics", "KPIs" | `/users/{user_id}` |
| GET | `/users/{user_id}/rocks` | User rocks/goals with milestone progress (params: year?, page, per_page; requires shared team membership) | "show rocks", "my rocks", "goals", "quarterly priorities" | `/users/{user_id}` |
| GET | `/users/{user_id}/feedback` | User feedback/High5s (params: direction* — "given" or "received", page, per_page; requires shared team membership) | "show feedback", "High5s", "kudos", "recognition" | `/users/{user_id}` |
| GET | `/users/check-login` | Check if login/handle is available (params: login* — 3-40 chars) | "check login", "is handle available", "username taken" | — |
| GET | `/users/me/preferences` | Get full preferences (profile, notifications, timezone, startup view, API token) | "my preferences", "settings", "notification settings" | `/customize` |
| PATCH | `/users/me/preferences` | Update preferences (body: login?, time_zone?, notifications?, startup_view_code?, preferred_team_id?, secondary_email?, update_frequency?, unsubscribe_all?, slack_username?). Partial update — only sent fields change. Notification booleans represent the logical ON/OFF value (true=on); the API inverts from the raw DB `should_suppress` field. | "update preferences", "change settings", "change timezone", "toggle notifications", "turn off digest", "turn on notifications" | `/customize` |
| GET | `/users/me/progress` | Personal progress — strategy metrics, practice scorecard, streak totals (params: period? — week/month/quarter) | "my progress", "practice streak", "how am I doing", "scorecard" | — |
| GET | `/users/me/integrations` | Get third-party integration selections (task_management, sales_revops, team_communication) | "my integrations", "connected apps", "integration settings" | `/customize` |
| PATCH | `/users/me/integrations` | Update integration selections (body: task_management?, sales_revops?, team_communication?). Set to null to disconnect. | "update integrations", "connect app", "disconnect integration" | `/customize` |
| POST | `/users/me/password` | Change password (body: current_password?, password*, password_confirmation*). current_password required unless OAuth-only user. | "change password", "update password", "new password" | `/customize` |
| PATCH | `/users/me/team-context` | Set the authenticated user's active team (body: team_id*). Returns `{ data: { id, name } }` of the newly active team. Idempotent. Errors: 400 (malformed body), 401 (unauthorized), 422 (team_id missing/invalid/not a member). | "switch team", "use team", "set active team", "change my team" | — |

User fields (`/users/me`): `id`, `login`, `email`, `first_name`, `last_name`,
`api_token`, `default_team` (TeamSimple | null), `current_team` (TeamSimple | null — reflects the team last set via `PATCH /users/me/team-context`. Non-null after at least one team-context set call).

UserPublic fields: `id`, `login`, `email`, `first_name`, `last_name`.

UserSimple fields: `id`, `login`, `first_name`, `last_name`.

TeamSimple: `{ id: integer, name: string }`.

UserStats fields: `wins_given`, `wins_received`, `goals_aspired`, `goals_realized`, `actions_done`.

UserMeasurable fields: `id`, `name`, `target_value`, `target_unit`, `owner` (UserSimple), `is_archived`, `values` ([{ date, value, on_track, percent_change }]).

Measurables params: `period` ("week" | "month", default "week"), `year` (default current), `active_only` (default true).

UserRock fields: `id`, `name`, `status` ("on_track" | "off_track" | "completed" | "dropped"), `due_date`, `team` (TeamSimple), `milestones_total`, `milestones_completed`, `created_at`.

FeedbackEntry fields: `id`, `message`, `from_user` (UserSimple + profile_photo_thumb_path), `to_user` (UserSimple + profile_photo_thumb_path), `created_at`.

UserPreferences fields: `id`, `profile_photo_thumb_path`, `login`, `first_name`, `last_name`, `email`, `secondary_email`, `time_zone`, `notifications` ({ morning_day_ahead, week_ahead_sunday, end_of_day_digest, weekly_digest_friday } — all boolean, true=on, false=off; API inverts the raw DB `should_suppress` field so clients read/write logical on/off values directly), `update_frequency` ("once_daily" | "every_change"), `unsubscribe_all`, `startup_view_code`, `startup_view_label`, `preferred_team_id`, `slack_username`, `api_token`, `is_coach`.

PersonalProgress fields: `strategy` ({ rocks_realized_all_time, milestones_realized_all_time, milestones_realized_this_quarter }), `practice_scorecard` ({ days: [{ date, day_name, completed }] }), `practice_totals` ({ all_time, current_streak, longest_streak }).

UserIntegrations fields: `task_management` ({ selected, options }), `sales_revops` ({ selected, options }), `team_communication` ({ selected, options }).

## Account Management

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/users/me/accounts` | List accounts the user belongs to (includes is_owner flag) | "my accounts", "list accounts", "which accounts" | — |
| GET | `/accounts/{account_id}/members` | List account members (params: page, per_page). Any account member can view. | "account members", "who's in account", "list users in account" | — |
| DELETE | `/accounts/{account_id}/members/{user_id}` | Remove member from account. Account owner only. Cannot remove owner. | "remove from account", "kick from account", "remove account member" | — |

UserAccount fields: `id`, `name`, `is_owner` (boolean).

AccountMember fields: `id`, `login`, `first_name`, `last_name`, `email`, `profile_photo_thumb_path`, `is_owner` (boolean).

## Day Plans

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plans/today` | Today's plan (auto-creates if none exists) | "show today", "my plan", "daily plan", "prioritizer" | `/day-plans/today` |
| GET | `/day-plans/today/items` | Today's items (params: page, per_page, q, include_archived) | "today's tasks", "what's on today", "my plan items" | `/day-plans/today` |
| POST | `/day-plans/today/items` | Create item in today's plan (auto-creates plan) | "add to today", "new task for today", "put on my plan" | `/items/{item_id}` |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (auto-creates plan, body: position?) | "attach to today", "add to plan", "link to today" | `/day-plans/today` |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) | "check off", "mark done for today", "complete for today", "undo" | `/day-plans/today` |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) | "remove from today", "take off plan", "drop from today" | — |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD) | "show plan for Monday", "last Friday's plan" | `/day-plans/{date}` |
| GET | `/day-plans/{date}/items` | Items by date (params: page, per_page, q, include_archived) | "items for that day", "what was on Monday" | `/day-plans/{date}` |
| POST | `/day-plans/{date}/items` | Create item in date's plan (plan must already exist) | "add to that day's plan" | `/items/{item_id}` |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date (plan must already exist, body: position?) | "attach to that plan" | `/day-plans/{date}` |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) | "check off for that day" | `/day-plans/{date}` |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) | "remove from that day" | — |

DayPlan fields: `id`, `date`, `creator` (UserSimple), `items` (DayPlanItem[]).

DayPlanItem fields: Item fields + `completed` (boolean), `position` (integer).

Day plan completion: regular items also get status=done. Recurring/daily items only toggle `completed` for that day — item stays active for tomorrow.

## Result Feed

The "90-second practice" — a daily check-in report where users record what they got done, what's next, and what's blocked.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/result-feed/{date}` | Get check-in for date (auto-creates empty report). `{date}` accepts `YYYY-MM-DD` or literal `today`. | "show my check-in", "90 seconds", "result feed", "daily report", "what did I do", "show check-in for {date}" | — |
| POST | `/result-feed/{date}/{section}` | Create new item in section (body: name*) | "add done", "add next", "add blocked", "new done item", "got something done" | — |
| PUT | `/result-feed/{date}/{section}/{item_id}` | Add existing item to section (idempotent) | "add item {id} to done", "put {id} in next", "attach {id} to blocked" | — |
| DELETE | `/result-feed/{date}/{section}/{item_id}` | Remove item from section (keeps item, does not revert status) | "remove {id} from done", "take {id} off next", "drop {id} from blocked" | — |
| POST | `/result-feed/{date}/submit` | Submit + share check-in (body: optional team_id, item_ids). Requires ≥1 item in both done and next. Idempotent. | "submit", "finalize", "done for the day", "submit check-in" | — |
| GET | `/teams/{id}/result-feed` | List team's shared check-ins (params: page, per_page). Reverse chronological. Requires team membership. | "team check-ins", "team feed", "team result feed", "show team check-ins" | — |

ResultFeed fields: `id`, `date`, `is_completed`, `done` (Item[]), `next` (Item[]), `blocked` (Item[]).

TeamResultFeed fields: ResultFeed fields + `user` (UserSimple).

Submit request body (all optional): `team_id` (integer — team to share with), `item_ids` (integer[] — items to highlight).

Section path parameter: `done`, `next`, `blocked`.

Date path parameter: `YYYY-MM-DD` or literal `today` (resolved server-side via user timezone).

Behavioral notes:
- GET auto-creates an empty report if none exists for the date.
- PUT (add item) is idempotent — adding an already-present item returns 200.
- DELETE (remove item) returns 404 if item is not in that section. Does NOT delete the item or revert its status.
- Submit is idempotent — re-submitting a completed report returns 200.
- Submit validation: requires ≥1 item in both `done` and `next` (422 otherwise).
- Adding items triggers status side-effects: done→done, next→next, blocked→blocked.
- Removing items does NOT revert status side-effects.

## Meetings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/meetings` | List meetings (params: team_id, page, per_page) | "show meetings", "my meetings", "list 1:1s", "L10s", "team 1:1s" | — |
| GET | `/meetings/{id}` | Meeting detail (includes blocked, done, next arrays) | "show meeting", "meeting details", "open meeting" | `/meetings/{id}` |
| GET | `/meetings/{id}/items` | All meeting items (params: creator_id?, page, per_page, q, include_archived) | "meeting items", "what's on the agenda" | `/meetings/{id}` |
| POST | `/meetings/{id}/items` | Create item in meeting | "add to meeting", "new meeting item" | `/items/{item_id}` |
| PUT | `/meetings/{id}/items/{item_id}` | Attach existing item | "attach to meeting", "link item to meeting" | `/meetings/{id}` |
| DELETE | `/meetings/{id}/items/{item_id}` | Remove from meeting (keeps item) | "remove from meeting", "detach from meeting" | — |
| GET | `/meetings/{id}/items/{section}` | Items by section (params: creator_id?, page, per_page, q, include_archived). Section: `done`, `next`, `blocked`. | "meeting next items", "meeting done items", "meeting blockers", "meeting issues" | `/meetings/{id}` |

MeetingSimple fields: `id`, `type` (one_on_one | project), `date`,
`person1` (UserSimple), `person2` (UserSimple),
`project` ({ id, name } | null).

Meeting fields: MeetingSimple + `blocked` (Item[]), `done` (Item[]), `next` (Item[]).

## Sessions

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/sessions` | Login via credentials or Google OAuth. No auth required. Returns API token. | "login", "authenticate", "get token" | — |
| DELETE | `/sessions` | Logout / destroy current session | "logout", "sign out", "end session" | — |

SessionResponse: `api_token` (string), user fields.

## Passwords

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/passwords/reset` | Trigger password reset email for a user (admin auth required, body: user_id*) | "reset password", "send password reset", "password reset for user" | — |
| PUT | `/passwords` | Complete password reset (unauthenticated, body: token*, password*). Uses reset token from email link. | "set new password", "complete password reset" | — |

POST /passwords/reset: Admin-only. Sends a password reset email to the specified user. Body: `{ "user_id": integer }`. Response: `{ "data": { "message": "Password reset email sent" } }`. Returns 403 if caller is not admin, 422 if user_id is invalid, user not in account, or user has no email.

PUT /passwords: Unauthenticated — the reset token serves as authentication. Body: `{ "token": string, "password": string }`. Response: `{ "data": { "message": "Password updated successfully" } }`. Returns 422 if token is invalid/expired or fields are missing. This endpoint is used by the browser-based reset flow, not by the CLI skill.

## Status Values

`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`

`draft` is read-only — cannot be set via POST or PATCH (422 if attempted). Only allowed transition: `draft` → `not_started`.

## Core Values

**Note**: `GET /api/v2/core-values` has been removed. Core values are now managed via EOS Vision: `GET /teams/{id}/core-values` (see EOS Vision section below). The `core_value_id` in ratings requests now references a label ID from the EOS Vision core values list.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/core-values-ratings` | List ratings for a subject (params: subject_id*, page, per_page) | "show ratings", "core value ratings", "ratings for user" | — |
| POST | `/core-values-ratings` | Create standalone core value ratings (body: subject_id*, ratings[{core_value_id*, score*}]) — `core_value_id` is a label ID from EOS Vision core values | "rate core values", "submit ratings", "score values" | — |

CoreValuesRating fields: `id`, `core_value` ({ id, name }), `score` (integer), `rater` (UserSimple), `review_id` (integer | null), `created_at`.

## Reviews

Performance reviews with self-assessment and reviewer assessment workflow.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/reviews` | List reviews (params: page, per_page, status, q, team_id). `team_id` filters by organization — resolves the team's root ancestor and returns only reviews where the reviewee is a member of any team in that org. 400 if team_id invalid, 404 if not found. Omitting team_id returns all reviews. Excludes archived. | "show reviews", "list reviews", "my reviews", "performance reviews" | — |
| POST | `/reviews` | Create review (body: reviewee_id*, reviewer_id*, template_id*, review_type?, start_date?, end_date?). Admin/people-ops only. reviewee_id and reviewer_id must be members of at least one team in the account (400 "is not a member of any team in this account" if not). | "create review", "start review", "new performance review" | — |
| GET | `/reviews/{id}` | Review detail. Assessment visibility depends on requesting user's role. | "show review", "review details", "open review" | — |
| PATCH | `/reviews/{id}` | Update review (body: review_type?, start_date?, end_date?) | "update review", "change review dates", "edit review" | — |
| DELETE | `/reviews/{id}` | Archive review (soft delete). Admin/people-ops only. | "archive review", "delete review", "remove review" | — |
| PUT | `/reviews/{id}/draft-assessment` | Save draft assessment (WIP, does not advance state). Body: AssessmentSubmitRequest. | "save draft", "draft assessment", "save progress" | — |
| POST | `/reviews/{id}/submit-assessment` | Submit final assessment. Transitions to assessed when both parties submit. Body: AssessmentSubmitRequest. | "submit assessment", "finalize assessment", "submit review" | — |
| POST | `/reviews/{id}/sign-off` | Sign off review (body: initials*). Must be in assessed state. Reviewer only. | "sign off", "approve review", "finalize review" | — |
| PUT | `/reviews/{id}/void` | Void review (body: reason*). Admin/people-ops only. Rejects all further actions. | "void review", "cancel review", "invalidate review" | — |
| PUT | `/reviews/{id}/notes` | Update review notes (body: notes*). Reviewer or people-ops. | "update review notes", "add notes", "edit review notes" | — |
| POST | `/reviews/{id}/action-items` | Create action item (body: title*, assignee_id*) | "add action item", "create follow-up", "review action item" | — |
| POST | `/reviews/{id}/attachments` | Upload attachment (multipart/form-data: file*). Beta. | "attach file", "upload to review", "add attachment" | — |
| DELETE | `/reviews/{id}/attachments/{aid}` | Delete attachment | "remove attachment", "delete file from review" | — |
| GET | `/reviews/{id}/audit-log` | Audit log entries for review | "review history", "audit log", "review changes" | — |

Review status values: `in_progress`, `assessed`, `signed_off`, `voided`.

ReviewListItem fields: `id`, `reviewee` (UserSimple), `reviewer` (UserSimple), `status`, `review_type` (integer | null), `template` ({ id, name } | null), `start_date`, `end_date`, `created_at`.

ReviewDetail fields: ReviewListItem + `notes`, `void_reason`, `signed_off_at`, `signed_off_initials`, `self_assessment` (Assessment | null), `reviewer_assessment` (Assessment | null), `core_values_ratings` (CoreValuesRatingEntry[]), `attachments` (Attachment[]), `action_items` (ActionItem[]), `updated_at`.

Assessment fields: `respondent_type` ("self" | "reviewer"), `respondent` (UserSimple), `is_draft` (boolean), `responses` ([{ prompt_id, description, response_value, score }]).

AssessmentSubmitRequest: `respondent_type` ("self" | "reviewer"), `assessment_responses` ([{ prompt_id*, response_value?, score? }]), `core_values_ratings?` ([{ core_value_id, score }]).

ActionItem fields: `id`, `title`, `assignee` (UserSimple), `status`, `created_at`.

Attachment fields: `id`, `file_name`, `file_type`, `file_size`, `url`, `created_at`.

AuditLogEntry fields: `id`, `change_type`, `user` (UserSimple), `description`, `created_at`.

### Review Templates

Admin-managed templates that define the prompts used in reviews.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/review-templates` | List review templates (params: page, per_page). Team-scoped: non-admins see only templates owned by or shared with their team; account admins see all. | "show templates", "list review templates", "review forms", "list templates" | — |
| POST | `/review-templates` | Create template (body: name*, target_role?, reviewer_instructions?, owning_team_id?). Admin on owning team (team admin or account admin). | "create template", "new review template", "add review form" | — |
| PATCH | `/review-templates/{id}` | Update template (body: name?, target_role?, reviewer_instructions?, shared_with_team_ids? — replace-all). owning_team_id is rejected (400). Admin on owning team. | "update template", "edit review template", "rename template", "share template", "manage template sharing" | — |
| DELETE | `/review-templates/{id}` | Delete template (permanent). Admin on owning team. | "delete template", "remove review template" | — |
| POST | `/review-templates/{id}/prompts` | Create assessment prompt (body: description*, answer_type*, hint?, answer_meta_data?). Admin only. | "add prompt", "new question", "add review question" | — |
| PATCH | `/review-templates/{id}/prompts/{pid}` | Update prompt (body: description?, hint?, answer_type?, answer_meta_data?). Admin only. | "update prompt", "edit question", "change prompt" | — |
| DELETE | `/review-templates/{id}/prompts/{pid}` | Delete prompt. Admin only. | "delete prompt", "remove question" | — |
| PUT | `/review-templates/{id}/prompts/positions` | Reorder prompts (body: positions[{id*, position*}]). All prompts must be included. Admin only. | "reorder prompts", "rearrange questions", "sort prompts" | — |

ReviewTemplateListItem fields: `id`, `name`, `target_role` (string | null), `prompt_count` (integer), `created_at`, `owning_team` (`{ id, name }` | null).

ReviewTemplateDetail fields: `id`, `name`, `target_role`, `reviewer_instructions`, `prompts` (AssessmentPrompt[]), `created_at`, `updated_at`, `owning_team` (`{ id, name }` | null), `shared_with_teams` (`[{ id, name }]`).

AssessmentPrompt fields: `id`, `description`, `hint` (string | null), `answer_type` ("range" | "text" | "textarea" | "boolean" | "multiple"), `answer_meta_data` (object | null), `position` (integer).

## Seats (Accountability Chart)

Seats represent positions on a team's accountability chart. Each seat can have an owner, aligned measures, aligned goals, and URL links. Seats form a hierarchy (parent/child) within a team.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/seats` | Get team accountability chart — full hierarchical tree (params: include_archived) | "show org chart", "accountability chart", "team seats", "who does what" | `/teams/{id}` |
| POST | `/seats` | Create seat (body: name*, team_id or parent_id, accountabilities?, notes?, seat_owner_id?, associated_team_id?). Root requires team_id; child requires parent_id. One root per team. | "create seat", "add position", "new role on chart" | — |
| GET | `/seats/{id}` | Get seat detail (children as SeatSimple, one level deep) | "show seat", "seat details", "position details" | — |
| PATCH | `/seats/{id}` | Update seat (body: name?, accountabilities?, notes?, seat_owner_id?, associated_team_id?). Owner changes cascade to aligned measures/goals. | "update seat", "rename seat", "change seat owner", "assign seat" | — |
| DELETE | `/seats/{id}` | Archive seat and all descendants (soft delete). Cannot archive root seat. | "archive seat", "delete seat", "remove position" | — |
| PUT | `/seats/{id}/restore` | Restore archived seat (children remain archived, restore individually) | "restore seat", "unarchive seat", "bring back seat" | — |
| PUT | `/seats/{id}/move` | Re-parent seat (body: parent_id*). Validates no circular refs, same group. Cannot move root. | "move seat", "reparent seat", "reorganize chart" | — |

Seat fields: `id`, `name`, `accountabilities` (string | null, HTML sanitized), `notes` (string | null, HTML sanitized), `parent` (SeatSimple | null), `creator` (UserSimple), `seat_owner` (UserSimple | null), `team` (TeamSimple + framework), `associated_team` (TeamSimple | null), `measures` ([{ id, name, description }]), `goals` ([{ id, name, description }]), `links` ([{ id, title, url }]), `children` (Seat[] in tree, SeatSimple[] in detail), `created_at`, `updated_at`.

SeatSimple: `{ id: integer, name: string }`.

### Seat Measures

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/seats/{id}/measures` | List measures aligned to seat. Response includes `chart_type` (string | null) on each measure object. | "seat measures", "show KPIs for seat", "aligned measures" | — |
| PUT | `/seats/{id}/measures` | Align measure to seat (body: measure_id*). Moves alignment if already aligned elsewhere. | "align measure", "add KPI to seat", "link measure" | — |
| DELETE | `/seats/{id}/measures/{measure_id}` | Remove measure alignment | "remove measure", "unlink KPI", "detach measure" | — |

### Seat Goals

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/seats/{id}/goals` | List goals aligned to seat | "seat goals", "show rocks for seat", "aligned goals" | — |
| PUT | `/seats/{id}/goals` | Align goal to seat (body: goal_id*). Moves alignment if already aligned elsewhere. | "align goal", "add rock to seat", "link goal" | — |
| DELETE | `/seats/{id}/goals/{goal_id}` | Remove goal alignment | "remove goal", "unlink rock", "detach goal" | — |

### Seat Links

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/seats/{id}/links` | List URL links on seat | "seat links", "show links", "resources for seat" | — |
| POST | `/seats/{id}/links` | Create link (body: url*, title?). URL must be http/https. Title defaults to URL. | "add link", "attach URL", "add resource" | — |
| PATCH | `/seats/{id}/links/{link_id}` | Update link (body: url?, title?). Set title to null to reset to URL. | "update link", "rename link", "change URL" | — |
| DELETE | `/seats/{id}/links/{link_id}` | Delete link (permanent) | "delete link", "remove link", "remove URL" | — |

SeatLink fields: `id`, `title`, `url`.

## Team Scorecard Measures

Team scorecard measures are KPIs tracked weekly on a team's scorecard. Each measure can have a target, unit, direction (higher/lower is better), and an optional owner. Weekly history values are recorded against Monday dates.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/measures` | List all measures for a team with weekly history (params: year?, include_archived?, owner_id?) | "show scorecard", "list measures", "team KPIs", "team measurables", "scorecard measures", "weekly metrics", "what are our KPIs" | `/teams/{id}` |
| POST | `/teams/{id}/measures` | Create a new measure (body: measure wrapper with name*, unit?, direction?, target_value?, owner_id?, data_source_type? (default 0), roll_up_type? ("sum"\|"average"), roll_up_measure_ids? (integer[]), chart_type? (string — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; omit or null for no preference)) | "add measure", "create KPI", "new measurable", "add scorecard item", "create metric" | — |
| PATCH | `/measures/{id}` | Update measure fields (body: measure wrapper with name?, unit?, direction?, target_value?, archived?, notes? (string\|null — sanitized HTML; omit to preserve, send null to clear), data_source_type?, roll_up_type? ("sum"\|"average"), roll_up_measure_ids? (integer[]), chart_type? (string — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; omit key to preserve, send null to clear)). Use `archived: true` to soft-archive, `archived: false` to restore. | "update measure", "rename KPI", "change target", "edit measurable", "restore measure", "add measure notes", "set measure description notes", "clear measure notes" | — |
| DELETE | `/measures/{id}` | Archive a measure (soft-delete, idempotent). Sets is_archived=true. | "archive measure", "delete KPI", "remove measurable", "hide measure" | — |
| POST | `/measures/{id}/history` | Record a weekly or monthly value for a measure (body: date*, value*, period?). `period` is optional: `"week"` (default, date must be a Monday) or `"month"` (date as `YYYY-MM` or `YYYY-MM-01`, response normalises to `YYYY-MM-01`). Omitting `period` defaults to weekly — fully backward-compatible. Upserts by (measure_id, date). | "record value", "log KPI", "enter score", "record measurable", "update scorecard value", "fill in weekly number", "record monthly value", "log monthly score", "enter monthly measure", "monthly scorecard entry" | — |
| POST | `/measures/{id}/history/note` | Record or clear a per-week text note on a history slot (body: date*, note — string ≤255 chars or null/empty to clear). Upserts; clearing a slot with no note is a no-op. | "add note", "record note", "annotate week", "note this week", "clear note", "remove note", "weekly note" | — |

Measure fields: `id`, `name`, `description` (string | null), `notes` (string | null — sanitized HTML, present on all measure responses; null if not set), `unit` (string, e.g. `"#"`, `"$"`, `"%"`), `direction` (`"higher"` | `"lower"`), `target_value` (numeric string | null), `owner` (UserSimple | null), `is_archived` (boolean), `chart_type` (string | null — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; null = no preference), `histories` (MeasureHistory[]), `data_source_type` (integer, always present: 0=manual, 1=google_sheets, 2=other_api, 3=roll_up).

Roll-up fields (present in responses only when `data_source_type=3`): `roll_up_type` (`"sum"` | `"average"`), `roll_up_measure_ids` (integer[] — IDs of source measures on the same team).

MeasureHistory fields: `id` (integer | null — null if no value recorded), `date` (YYYY-MM-DD, always a Monday), `value` (numeric string | null), `target_value` (numeric string | null), `note` (string | null — null if no note recorded for this slot).

**Response envelopes**:
- `GET /teams/{id}/measures` → `{ "data": Measure[], "meta": { "year": int, "date_range": { "start": string, "end": string } } }` — returns 52 weekly history slots per year per measure
- `POST /teams/{id}/measures` → `{ "data": Measure }` (201, histories is empty array)
- `PATCH /measures/{id}` → `{ "data": Measure }` (200, no histories field)
- `DELETE /measures/{id}` → `{ "data": Measure }` (200, is_archived: true, no histories field)
- `POST /measures/{id}/history` → `{ "data": { "id": int, "measure_id": int, "date": string, "value": string, "target_value": string | null, "period": "week" | "month" } }` (200, upsert; for monthly entries `date` is always normalised to `YYYY-MM-01`)
- `POST /measures/{id}/history/note` → `{ "data": { "id": int|null, "measure_id": int, "date": string, "note": string|null } }` (200, upsert; id is null when note is cleared)

**Validation**: `name` must not be blank (422). `value` must be a numeric string (422). `date` must be a valid ISO date (Monday preferred). `direction` must be `"higher"` or `"lower"`. `data_source_type` must be 0–3 (422 otherwise). `chart_type` must be one of `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart` or null if provided (422 otherwise); omitting the key on PATCH preserves the existing value. For roll-up measures (`data_source_type=3`): `roll_up_type` must be `"sum"` or `"average"` (422); `roll_up_measure_ids` must all belong to the same team (422 cross-team); a measure may not include itself in `roll_up_measure_ids` (422 self-reference); circular references (A→B→A) return 422.

## Strategy & Targets

### Strategy Tree (read-only, all frameworks)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/targets` | Get team strategy tree (params: year?, quarter? — default current; use `"All"` or `0` for all) | "show strategy", "strategy tree", "goals and rocks", "team objectives", "OKRs", "V2MOM", "show rocks", "annual goals", "quarterly priorities", "show targets" | `/teams/{id}` |

StrategyResponse: `{ "data": { "framework": string, "strategy": StrategyNode[], "unaligned": StrategyNode[] } }`

StrategyNode fields: `id`, `name` (string | null), `description` (string | null), `status` (active | complete | archived | deferred | review | draft | cancelled | at_risk | off_track), `object_type` (yearly_goal | rock | focus_area | objective | key_result | milestone | action), `type` (integer for Goals: 0=objective/WIG, 1=rock, 2=yearly; string for Items: KeyResult, ResultArea), `color` (string | null), `assignees` (StrategyAssignee[]), `creator` (StrategyAssignee | null), `due` (YYYY-MM-DD | null), `children` (StrategyNode[]), `inherited` (boolean), `inherited_from` ({ team_id, team_name } | null).

StrategyAssignee fields: `id`, `first_name` (string | null), `last_name` (string | null).

**Supported frameworks**: EOS, OKR, 4DX. SRT and V2MOM are **not yet supported** (returns 400 error).

**GET filtering rules**: EOS: yearly goals by `year`, rocks by `quarter` (persistent active rocks always included, realized persistent excluded). OKR: focus areas included if they have qualifying children, objectives "pulled up" if any child key result is in range. 4DX: same as OKR for L1-L3, actions filtered by year/quarter.

**Inherited nodes**: Nodes with `inherited: true` come from a parent team and are read-only. `inherited_from` contains the source `team_id` and `team_name`.

### Goals — Yearly (EOS only)

All goal endpoints return `422 Unprocessable Entity` with message "This endpoint is only available for EOS teams" when called against a non-EOS team.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/goals` | List yearly goals (params: year?) | "list goals", "show yearly goals", "annual goals", "1-year goals" | `/teams/{id}` |
| POST | `/teams/{id}/goals` | Create a yearly goal (body: name*, achieve_by?, assignee_ids?) | "create goal", "add yearly goal", "new annual goal" | `/teams/{id}` |
| PATCH | `/goals/{id}` | Update a yearly goal (body: name?, description?, status?, achieve_by?, assignee_ids?) | "update goal", "rename goal", "mark goal complete", "change goal status" | — |
| DELETE | `/goals/{id}` | Archive a yearly goal | "archive goal", "delete goal", "remove goal" | — |

**Goal response shape** (verified via curl 2026-03-18):
```json
{
  "data": {
    "id": 3645,
    "name": "Hit $10M ARR",
    "description": null,
    "status": "active",
    "type": "yearly_goal",
    "achieve_by": "2026-12-31",
    "color": null,
    "is_visible_to_team": true,
    "assignees": [{"id": 5, "login": "", "first_name": "Alice", "last_name": "Smith", "profile_photo_thumb_path": null}],
    "creator": {"id": 5, "login": "", "first_name": "Alice", "last_name": "Smith", "profile_photo_thumb_path": null},
    "created_at": "2026-01-15T10:00:00.000Z",
    "updated_at": "2026-01-15T10:00:00.000Z"
  }
}
```

**Response envelopes**:
- `GET /teams/{id}/goals` → `{ "data": [Goal], "meta": { page, per_page, total, total_pages } }` (200)
- `POST /teams/{id}/goals` → `{ "data": Goal }` (201)
- `PATCH /goals/{id}` → `{ "data": Goal }` (200)
- `DELETE /goals/{id}` → `{ "data": Goal }` (200, status: "archived")

### Rocks — Quarterly (EOS only)

All rock endpoints return `422 Unprocessable Entity` for non-EOS teams.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/rocks` | List quarterly rocks (params: year?, quarter?, parent_id?) | "list rocks", "show rocks", "quarterly rocks", "90-day priorities" | `/teams/{id}` |
| POST | `/teams/{id}/rocks` | Create a rock (body: name*, parent_id?, assignee_ids?) | "create rock", "add rock", "new quarterly rock" | `/teams/{id}` |
| PUT | `/rocks/{id}` | Align rock to a yearly goal (body: parent_id*) | "align rock to goal", "link rock", "move rock under goal" | — |
| PATCH | `/rocks/{id}` | Update a rock (body: name?, description?, status?, assignee_ids?) | "update rock", "rename rock", "mark rock complete", "change rock status" | — |
| DELETE | `/rocks/{id}` | Archive a rock | "archive rock", "delete rock", "remove rock" | — |

**Rock response shape** (verified via curl 2026-03-18):
```json
{
  "data": {
    "id": 3646,
    "name": "Launch enterprise tier",
    "description": null,
    "status": "active",
    "type": "rock",
    "achieve_by": "2026-03-31",
    "color": null,
    "is_visible_to_team": true,
    "assignees": [],
    "creator": {"id": 5, "login": "", "first_name": "Alice", "last_name": "Smith", "profile_photo_thumb_path": null},
    "created_at": "2026-01-15T10:00:00.000Z",
    "updated_at": "2026-01-15T10:00:00.000Z",
    "parent_id": 3645,
    "persist_until_cleared": false
  }
}
```

**Response envelopes**:
- `GET /teams/{id}/rocks` → `{ "data": [Rock], "meta": { page, per_page, total, total_pages } }` (200)
- `POST /teams/{id}/rocks` → `{ "data": Rock }` (201)
- `PUT /rocks/{id}` → `{ "data": Rock }` (200)
- `PATCH /rocks/{id}` → `{ "data": Rock }` (200)
- `DELETE /rocks/{id}` → `{ "data": Rock }` (200, status: "archived")

### Milestones (EOS only)

All milestone endpoints return `422 Unprocessable Entity` for non-EOS teams.

**Known bug**: `GET /teams/{id}/milestones?year=&quarter=` returns incorrect results. Use `?parent_id=ROCK_ID` instead for accurate filtering.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/milestones` | List milestones (params: parent_id? — **recommended**; year?, quarter? — **avoid, known bug**) | "list milestones", "show milestones", "deliverables" | `/teams/{id}` |
| POST | `/teams/{id}/milestones` | Create a milestone (body: name*, parent_id?, due?) | "create milestone", "add milestone", "new deliverable" | `/teams/{id}` |
| PUT | `/milestones/{id}` | Align milestone to a rock (body: parent_id*) | "align milestone to rock", "link milestone", "move milestone under rock" | — |
| PATCH | `/milestones/{id}` | Update a milestone (body: name?, description?, status?, due?) | "update milestone", "rename milestone", "mark milestone complete" | — |
| DELETE | `/milestones/{id}` | Archive a milestone | "archive milestone", "delete milestone", "remove milestone" | — |

**Milestone response shape** (verified via curl 2026-03-18):
```json
{
  "data": {
    "id": 79874,
    "name": "Sign 3 enterprise customers",
    "description": null,
    "status": "active",
    "type": "milestone",
    "due": "2026-03-31",
    "color": null,
    "parent_id": 3646,
    "assignees": [],
    "creator": {"id": 5, "login": "", "first_name": "Alice", "last_name": "Smith", "profile_photo_thumb_path": null},
    "created_at": "2026-03-17T10:00:00.000Z"
  }
}
```

Note: Milestone responses do NOT include `updated_at`.

**Response envelopes**:
- `GET /teams/{id}/milestones` → `{ "data": [Milestone], "meta": { page, per_page, total, total_pages } }` (200)
- `POST /teams/{id}/milestones` → `{ "data": Milestone }` (201)
- `PUT /milestones/{id}` → `{ "data": Milestone }` (200)
- `PATCH /milestones/{id}` → `{ "data": Milestone }` (200)
- `DELETE /milestones/{id}` → `{ "data": Milestone }` (200, status: "archived")

### EOS Hierarchy

- **Goals** are root-level (no parent)
- **Rocks** align to goals via `parent_id`
- **Milestones** align to rocks via `parent_id`

**Authorization**: Root-level creation requires team admin. Child creation requires team admin or node-level assignment on the parent (assignee of the parent or any ancestor).

### EOS Vision (V/TO)

The Vision/Traction Organizer (V/TO) covers six EOS components: core values, core focus (purpose/niche), BHAG (10-year target), marketing strategy, three-year picture, and year/quarter plans.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/eos-vision` | Get complete V/TO (all 6 sections in one call) | "show vision", "show V/TO", "vision traction organizer", "EOS vision", "show the VTO" | `/teams/{id}` |
| GET | `/teams/{id}/core-values` | List core values | "show core values", "list core values", "our values" | `/teams/{id}` |
| POST | `/teams/{id}/core-values` | Create core value (body: name*, description?) | "add core value", "create core value", "new value" | `/teams/{id}` |
| PATCH | `/core-values/{valueId}` | Update core value (body: name?, description?) — standalone, no team prefix | "update core value", "edit value", "rename value" | — |
| DELETE | `/core-values/{valueId}` | Delete core value — standalone, no team prefix | "delete core value", "remove value" | — |
| GET | `/teams/{id}/eos-core-focus` | Get core focus (purpose + niche) | "show core focus", "what's our purpose", "our niche" | `/teams/{id}` |
| PATCH | `/teams/{id}/eos-core-focus` | Update core focus (body: purpose?, niche?) | "update core focus", "set purpose", "change niche" | `/teams/{id}` |
| GET | `/teams/{id}/eos-bhag` | Get BHAG (10-year target) | "show BHAG", "10-year target", "big hairy audacious goal" | `/teams/{id}` |
| PATCH | `/teams/{id}/eos-bhag` | Update BHAG (body: text*) | "update BHAG", "set 10-year target", "change BHAG" | `/teams/{id}` |
| GET | `/teams/{id}/eos-marketing-strategy` | Get marketing strategy | "show marketing strategy", "target market", "our uniques", "proven process", "guarantee" | `/teams/{id}` |
| PATCH | `/teams/{id}/eos-marketing-strategy` | Update marketing strategy (body: targetMarket?, uniques?, provenProcess?, guarantee?) | "update marketing strategy", "set target market", "change uniques" | `/teams/{id}` |
| GET | `/teams/{id}/eos-three-year-picture` | Get three-year picture | "show three-year picture", "3-year picture", "where we'll be in 3 years" | `/teams/{id}` |
| PATCH | `/teams/{id}/eos-three-year-picture` | Update three-year picture (body: description?, futureDate?, revenue?, profit?, measurables?) | "update three-year picture", "set 3-year picture" | `/teams/{id}` |
| GET | `/teams/{id}/eos-plans` | Get all year/quarter plans | "show plans", "annual plan", "quarterly plan", "year plans" | `/teams/{id}` |
| GET | `/teams/{id}/eos-plans/{year}` | Get plans for a specific year | "show 2026 plans", "plans for this year" | `/teams/{id}` |
| GET | `/teams/{id}/eos-plans/{year}/{quarter}` | Get specific quarter plan (quarter: 0=annual, 1-4=Q1-Q4) | "show Q1 plan", "annual plan for 2026" | `/teams/{id}` |
| PATCH | `/teams/{id}/eos-plans/{year}/{quarter}` | Update year/quarter plan (body: text, date, revenue, profit, measures — all string or null) | "update Q1 plan", "set annual plan", "change quarterly plan" | `/teams/{id}` |

**Composite GET `/eos-vision` response shape**:
```json
{
  "data": {
    "teamId": 456,
    "isInheritingParentVision": false,
    "parentTeamId": null,
    "coreValues": [{ "id": 1, "name": "Integrity", "description": "<p>Do the right thing</p>", "groupId": 456 }],
    "coreFocus": { "purpose": "<p>Our mission</p>", "niche": "<p>Our niche</p>" },
    "bhag": { "text": "<p>Be the best</p>" },
    "marketingStrategy": { "targetMarket": "<p>SMBs</p>", "uniques": ["Speed", "Quality"], "provenProcess": "<p>Our process</p>", "guarantee": "<p>100% satisfaction</p>" },
    "threeYearPicture": { "description": "<p>Where we'll be</p>", "futureDate": "2029-01-01", "revenue": "5000000", "profit": "1000000", "measurables": "Key metrics" },
    "plans": { "2026_0": { "text": "Annual goals", "date": "2026-12-31", "revenue": "1000000", "profit": "200000", "measures": "Key measurables" } }
  }
}
```

**Behavior notes**:
- **PATCH merge semantics**: Marketing strategy and three-year picture only update provided fields — omitted fields retain existing values.
- **Parent vision inheritance**: If a team uses parent vision, reads return parent data with `isInheritingParentVision: true`. All writes return 403.
- **Case convention**: Marketing strategy and three-year picture use camelCase in API (targetMarket, provenProcess, futureDate).
- **Plan keys**: `{year}_{quarter}` format. Quarter 0 = annual, 1-4 = Q1-Q4. Values outside 0-4 return 400.
- **HTML sanitization**: All string inputs sanitized before storage.
- **Standalone core value routes**: PATCH/DELETE at `/core-values/{valueId}` — no team ID in URL. Team inferred from value's `group_id`.
- **Auth**: All GET endpoints require Member role. All write endpoints (POST/PATCH/DELETE) require Admin role.

## Favorites

User-private bookmarks to any relative app URL. Ordered by position. All endpoints require Bearer auth.

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/favorites` | List authenticated user's favorites ordered by position | "show my favorites", "list bookmarks", "my saved pages" |
| POST | `/favorites` | Create a favorite (body: url*, title) | "add favorite", "bookmark this", "save this page", "add to favorites" |
| PATCH | `/favorites/{id}` | Update a favorite's title (body: title) | "rename favorite", "update bookmark title" |
| DELETE | `/favorites/{id}` | Remove a favorite | "remove favorite", "delete bookmark", "unfavorite" |
| PUT | `/favorites/reorder` | Reorder all favorites (body: favorite_ids[]) | "reorder favorites", "move bookmark", "reorganize favorites" |

Favorite fields: `id`, `url`, `title`, `position`, `created_at`, `updated_at`.

- `url`: relative path starting with `/`, max 2048 chars. Unique per user — duplicate returns 409.
- `title`: max 255 chars. Auto-generated from URL path if omitted on create.
- `position`: auto-assigned on create (appended to end). Renumbered only via explicit reorder.
- Ownership violations return 403.
- `PUT /favorites/reorder` body: `{ "favorite_ids": [3, 1, 2] }` — must include ALL user's favorite IDs in desired order. Response: `{ "data": [...] }` with updated positions.

## Error Responses

All errors return: `{ "error": { "code": "<error_code>", "message": "<human-readable>", "details": { ... } } }`

| Status | Code | Meaning |
|--------|------|---------|
| 400 | `bad_request` | Missing or invalid query parameter |
| 401 | `unauthorized` | Invalid/missing token |
| 403 | `forbidden` | Not authorized for resource |
| 404 | `not_found` | Resource not found |
| 422 | `validation_error` | Validation error (per-field details in `details`) |
| 500 | `internal_error` | Internal server error |

## Pagination

Most list endpoints return: `{ data: [...], meta: { page, per_page, total, total_pages } }`

Delete responses vary by resource: strategy objects (goals, rocks, milestones) return `200` with the archived object in `{ "data": ... }`. Other resources may return `204 No Content` with empty body.

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
| check-in, 90-second practice, result feed, daily report | Result Feed (daily check-in report) | `/result-feed/today`, `/result-feed/{date}` |
| team check-ins, team feed, team result feed | Team Result Feeds (shared check-ins) | `/teams/{id}/result-feed` |
| weekly, team weekly, weekly board, Level 10, L10 (EOS) | Team Items (weekly board; called "Level 10" for EOS teams) | `/teams/{id}/items` |
| issue, blocker, blocked item, challenge | Item with status=blocked | `/teams/{id}/items/blocked` |
| next, to-do (column), priority for the week | Item with status=next | `/teams/{id}/items/next` |
| parked, parking lot, park for later | Item with status=parked | `/teams/{id}/items/parked` |
| done, completed, finished | Item with status=done | `/teams/{id}/items/done` |
| L10 to-do, weekly to-do | Item with status=next (EOS alias) | `/teams/{id}/l10/todos` |
| L10 issue, IDS item | Item with status=blocked (EOS alias) | `/teams/{id}/l10/issues` |
| L10 headline | Headline (EOS alias) | `/teams/{id}/l10/headlines` |
| L10 done, L10 completed | Item with status=done (EOS alias) | `/teams/{id}/l10/done` |
| L10 parking lot, L10 parked | Item with status=parked (EOS alias) | `/teams/{id}/l10/parked` |
| move to L10 to-dos, prioritize in L10 | Move item to to-dos section | `PUT /teams/{id}/l10/todos/{item_id}` |
| mark L10 done, complete L10 to-do | Mark item done on L10 board | `PUT /teams/{id}/l10/done/{item_id}` |
| move to L10 issues, IDS this | Move item to issues section | `PUT /teams/{id}/l10/issues/{item_id}` |
| park in L10, move to parking lot | Park item on L10 board | `PUT /teams/{id}/l10/parked/{item_id}` |
| remove from L10, take off L10 board | Remove from L10 board | `DELETE /teams/{id}/l10/items/{item_id}` |
| assignee, assigned to, responsible | Assignee | `/items/{id}/assignees` |
| creator, item creator, who created this | Creator (`creator` field) | `/items`, `/teams`, `/day-plans` |
| accountability owner, accountable | Assignee (if any), else Creator | `/items/{id}/assignees`, `creator` field |
| muted, hidden team, show muted | Muted Team | `GET /teams?include_muted=true` |
| mute team, hide team, silence team | Mute Team | `PUT /teams/{id}/mute` |
| unmute team, unhide team, show team again | Unmute Team | `DELETE /teams/{id}/mute` |
| headline, announcement, team update, news | Headline (EOS only) | `/teams/{id}/headlines` |
| review, performance review, quarterly review | Review | `/reviews` |
| review template, review form | Review Template | `/review-templates` |
| assessment, self-assessment, reviewer assessment | Assessment (within Review) | `/reviews/{id}/submit-assessment`, `/reviews/{id}/draft-assessment` |
| sign off, approve review, finalize review | Review Sign-off | `POST /reviews/{id}/sign-off` |
| void review, cancel review | Void Review | `PUT /reviews/{id}/void` |
| core value, company value | Core Value | `/core-values` |
| core value rating, value score | Core Values Rating | `/core-values-ratings` |
| review prompt, review question | Assessment Prompt | `/review-templates/{id}/prompts` |
| action item (review), follow-up | Review Action Item | `POST /reviews/{id}/action-items` |
| show archived, include archived | Archived filter | `?include_archived=true` on list endpoints |
| comment, note | Comment | `/items/{id}/comments` |
| member, team member | Team Member | `/teams/{id}/members` |
| child, sub-task, sub-item, nested item | Child Item (parent_id) | `/items/{id}/children` |
| move, reorder, reparent, nest under | Move Item | `PUT /items/{id}/move` |
| bulk move, move items, move these under, reparent multiple, move all to | Bulk Move Items | `PATCH /items/bulk-move` |
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
| activity logs, team history, membership changes, who joined, who was removed, team audit log | Team Activity Logs | `GET /teams/{id}/activity-logs` |
| team labels, team tags, label, tag | Team Labels | `GET /teams/{id}/labels` |
| create label, add label, new team tag | Create Team Label | `POST /teams/{id}/labels` |
| slack integration, team webhook, team integration, webhook | Team Integrations | `GET /teams/{id}/integrations` |
| change role, change member role, promote to admin, demote member, demote to member | Member Role Change | `PATCH /teams/{id}/members/{user_id}` |
| upload logo, team logo, set team logo, remove logo, delete logo | Team Logo | `POST /teams/{id}/logo`, `DELETE /teams/{id}/logo` |
| recurring, daily item, repeating task | Recurring Item | Day plan completion doesn't change item status |
| reset password, send password reset, password reset for user | Password Reset (admin) | `POST /passwords/reset` |
| set new password, complete password reset | Password Update (unauthenticated) | `PUT /passwords` |
| change password, update my password, new password, set password | Change Password (authenticated) | `POST /users/me/password` |
| seat, position, role on chart, accountability chart | Seat | `/teams/{id}/seats`, `/seats/{id}` |
| org chart, accountability chart, who does what | Team Seats (chart) | `GET /teams/{id}/seats` |
| seat owner, who owns the seat, assigned to seat | Seat Owner | `PATCH /seats/{id}` (seat_owner_id) |
| seat measure, KPI for seat, aligned measure | Seat Measure | `/seats/{id}/measures` |
| seat goal, rock for seat, aligned goal | Seat Goal | `/seats/{id}/goals` |
| seat link, URL on seat, resource link | Seat Link | `/seats/{id}/links` |
| move seat, reparent seat, reorganize chart | Move Seat | `PUT /seats/{id}/move` |
| archive seat, delete seat, remove position | Archive Seat | `DELETE /seats/{id}` |
| restore seat, unarchive seat | Restore Seat | `PUT /seats/{id}/restore` |
| strategy, strategy tree, goals and rocks, OKRs, annual goals, team objectives, targets, show targets | Strategy Tree | `GET /teams/{id}/targets` |
| vision, V/TO, vision traction organizer, EOS vision, show VTO | EOS Vision (composite) | `GET /teams/{id}/eos-vision` |
| core values, our values, company values (EOS V/TO) | EOS Core Values | `GET /teams/{id}/core-values` |
| core focus, purpose, niche, why we exist (EOS V/TO) | EOS Core Focus | `GET /teams/{id}/eos-core-focus` |
| BHAG, 10-year target, big hairy audacious goal (EOS V/TO) | EOS BHAG | `GET /teams/{id}/eos-bhag` |
| marketing strategy, target market, uniques, proven process, guarantee (EOS V/TO) | EOS Marketing Strategy | `GET /teams/{id}/eos-marketing-strategy` |
| three-year picture, 3-year picture, where we'll be (EOS V/TO) | EOS Three-Year Picture | `GET /teams/{id}/eos-three-year-picture` |
| annual plan, quarterly plan, year plan, Q1 plan (EOS V/TO) | EOS Plans | `GET /teams/{id}/eos-plans` |
| yearly goal, annual goal, 1-year goal, create goal, add goal, new goal | Goal (yearly) | `POST /teams/{id}/goals`, `GET /teams/{id}/goals` |
| rock, quarterly rock, 90-day priority, create rock, add rock, new rock | Rock (quarterly) | `POST /teams/{id}/rocks`, `GET /teams/{id}/rocks` |
| milestone, deliverable, create milestone, add milestone, new milestone | Milestone | `POST /teams/{id}/milestones`, `GET /teams/{id}/milestones` |
| update goal, rename goal, change goal status, mark goal complete | Update Goal | `PATCH /goals/{id}` |
| update rock, rename rock, change rock status, mark rock complete | Update Rock | `PATCH /rocks/{id}` |
| update milestone, rename milestone, mark milestone complete | Update Milestone | `PATCH /milestones/{id}` |
| align rock to goal, link rock, move rock under goal | Align Rock | `PUT /rocks/{id}` |
| align milestone to rock, link milestone, move milestone under rock | Align Milestone | `PUT /milestones/{id}` |
| detach goal, unlink goal, archive goal, delete goal | Archive/Unlink Goal | `PATCH /goals/{id}` (unlink), `DELETE /goals/{id}` (archive) |
| detach rock, unlink rock, archive rock, remove rock from goal | Archive/Unlink Rock | `PATCH /rocks/{id}` (unlink), `DELETE /rocks/{id}` (archive) |
| detach milestone, unlink milestone, archive milestone, remove milestone | Archive/Unlink Milestone | `PATCH /milestones/{id}` (unlink), `DELETE /milestones/{id}` (archive) |
| label, tag, team label | Team Label | `/teams/{id}/labels` |
| integration, webhook, Slack integration, Discord integration | Team Integration | `/teams/{id}/integrations` |
| team logo, upload logo, remove logo, delete logo | Team Logo | `POST /teams/{id}/logo`, `DELETE /teams/{id}/logo` |
| activity log, team activity, membership changes | Team Activity Log | `GET /teams/{id}/activity-logs` |
| change role, promote to admin, demote, make admin | Change Member Role | `PATCH /teams/{id}/members/{user_id}` |
| account, my accounts, account list, account membership | Account | `GET /users/me/accounts` |
| account members, who's in account, who's in my account | Account Members | `GET /accounts/{id}/members` |
| remove from account, kick from account, remove account member | Remove Account Member | `DELETE /accounts/{id}/members/{user_id}` |
| my preferences, my settings, my profile, settings, notification settings | User Preferences | `GET /users/me/preferences` |
| update preferences, change timezone, change settings, toggle notifications, turn off digest, turn on notifications | Update Preferences | `PATCH /users/me/preferences` |
| my progress, practice streak, how am I doing | Personal Progress | `GET /users/me/progress` |
| my integrations, connected apps | User Integrations | `GET /users/me/integrations` |
| stats, profile stats, my stats, my wins, wins given, wins received, my score, goals realized, actions done | User Stats | `GET /users/{user_id}/stats` |
| measurables, scorecard, KPIs, metrics | User Measurables | `GET /users/{user_id}/measurables` |
| rocks, goals, quarterly priorities | User Rocks | `GET /users/{user_id}/rocks` |
| feedback, High5s, kudos, recognition | User Feedback | `GET /users/{user_id}/feedback` |
| check login, login available, check username, is handle available, username taken | Check Login | `GET /users/check-login` |
| switch team, use team, set active team, change my team, team context | Set Active Team | `PATCH /users/me/team-context` |

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
| in progress (review) | `in_progress` | Review: awaiting assessments |
| assessed (review) | `assessed` | Review: both assessments submitted |
| signed off (review) | `signed_off` | Review: reviewer approved |
| voided (review) | `voided` | Review: cancelled with reason |

### Framework Column Names

| API Column | Default | EOS | OKR | 4DX | V2MOM | SRT | SVEP |
|-----------|---------|-----|-----|-----|-------|-----|------|
| next | Next | To-Do | Priorities | WIG Actions | Next | Next | Next |
| done | Done | Done | Done | Done | Done | Done | Done |
| blocked | Issues | Issues | Issues + Challenges | Blockers | Obstacles | Issues | Issues |
| parked | Parked | Parked | Park for Later | Parked | Parked | Parked | Parked |

### Key Distinctions

| Concept A | Concept B | Difference |
|-----------|-----------|------------|
| Creator (`creator` field) | Assignee (`assignees` array) | Creator = who created the item. Assignees = who's responsible for it. One creator, many assignees. Accountability ownership = assignees if any, otherwise creator. |
| Archive (`DELETE /items/{id}`) | Delete (`DELETE /teams/{id}`) | Items are soft-deleted (status→archived). Teams are permanently deleted. |
| Completed (day plan) | Done (item status) | Day plan `completed: true` checks off for that day. Item status `done` marks it globally done. For recurring items only the day plan toggles. |
| on_weekly (item field) | status (item field) | `on_weekly` controls board visibility. `status` controls the column. An item can be `status: next` but `on_weekly: false`. |
| One-on-one meeting | Project meeting | `type: "one_on_one"` has person1/person2. `type: "project"` has a project field. Same endpoints. |
| Team projects (`/teams/{id}/projects`) | Standalone projects (`/projects`) | Team projects are scoped to a team. Standalone are user-level. Same underlying data (type=TodoList). |
| `DELETE /teams/{id}/projects/{pid}` | `DELETE /projects/{id}` | Team version removes from team (clears group_id). Standalone version archives the project. |
| Headline (`/teams/{id}/headlines`) | Comment (`/items/{id}/comments`) | Headlines are team-level announcements (EOS only, auto-expire after 7 days). Comments are item-level notes. |
| Draft assessment | Submitted assessment | Draft saves WIP without advancing state. Submit finalizes and transitions review when both parties submit. |
| Review archive (`DELETE /reviews/{id}`) | Review void (`PUT /reviews/{id}/void`) | Archive soft-deletes. Void records a reason and blocks all further lifecycle actions. |
| Core values ratings (standalone) | Core values ratings (in review) | Standalone via `POST /core-values-ratings`. In-review via `core_values_ratings` in AssessmentSubmitRequest. |
