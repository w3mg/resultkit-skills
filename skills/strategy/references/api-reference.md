# ResultMaps V2 API Reference

**Source**: https://api.resultmaps.com/api-docs/v2 — refresh from here when endpoints change or docs seem stale.

Base URL: `https://api.resultmaps.com/api/v2`
Web App: `https://resultkit.ai` — Web URL column values are paths relative to this base. NEVER link users to the legacy `app.resultmaps.com` UI.
Deep links: `?item={id}` opens the item detail sidebar appended to ANY authenticated path (canonical cold link: `https://resultkit.ai/?item={id}`); `?target={id}` does the same for rocks/yearly-goals/milestones. Team-scoped pages use the current team; `/level-10-meeting` and `/plugins/projects` accept `?team={id}` to switch it. `/teams/{id}` is the team home page.
Auth: Bearer token in `Authorization` header or `token` query param. Find your token in your profile settings at https://resultkit.ai/customize.
Interactive docs: <https://api.resultmaps.com/api-docs/v2>

> **V1 endpoints**: Some newer endpoints use `/api/v1/` paths. When calling via `api.sh`, pass the full versioned path (e.g., `/api/v1/items/{id}/attachments`). The script detects paths starting with `/api/` and automatically strips the `/v2` suffix from the base URL.

## Common Query Parameters

Many list endpoints accept these shared params:

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `per_page` | integer | Results per page, 1–100 (default: 100) |
| `q` | string | Filter by name (min 2 chars, case-insensitive contains match) |
| `include_archived` | string | When `"true"`, includes archived items (default: `"false"`) |

Endpoints that support `q` and `include_archived` are noted below.

`include_archived`: by default, archived items are excluded from all list endpoints. Pass `include_archived=true` to include them. Supported on `GET /items`, `GET /projects`, `GET /1-on-1/{id}/items`, and `GET /1-on-1/{id}/items/{section}` (next section only).

## Items

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items` | List authenticated user's items (params: page, per_page, q, status, team_id, include_archived) | "show my tasks", "list items", "what's on my plate", "my to-dos" | — |
| POST | `/items` | Create item (body: name*, type, description, due, status, on_weekly, team_id, parent_id, context) | "add task", "create item", "new to-do", "add action item" | `/?item={id}` |
| GET | `/items/{id}` | Get item detail (includes first-level children) | "show item", "item details", "open task", "what's in item X" | `/?item={id}` |
| PATCH | `/items/{id}` | Update item (body: name, description, due, status, on_weekly, third_party_tracker). `third_party_tracker`: object to set/replace, `null` to clear, omit to leave unchanged. | "update item", "change status", "rename task", "set due date", "link to HubSpot", "attach ticket" | `/?item={id}` |
| DELETE | `/items/{id}` | Archive item (soft delete, sets status=archived) | "archive item", "delete task", "remove item", "soft delete" | — |
| GET | `/items/{id}/children` | List child items as nested tree (params: page, per_page, q, depth). `depth` default 2, range 1-20. | "show sub-tasks", "list children", "nested items", "what's under this" | `/?item={id}` |
| PUT | `/items/{id}/move` | Reposition item in tree (body: parent_id, left_id, right_id, position?, group_by?). Optional `position` (0-based integer) places item at a specific slot within the new parent. Optional `group_by: "status"` scopes `position` to the item's status group (use on status-grouped boards); omit for global ordering. Invalid `group_by` value → 400. | "move item", "reparent", "nest under", "reorder" | `/?item={id}` |
| PATCH | `/items/bulk-move` | Move up to 1000 items under a target parent (body: item_ids, parent_id). Items removed from all weekly boards. | "bulk move", "move items", "move these under", "reparent multiple" | — |
| POST | `/items/{id}/reposition` | Move item to a new 0-based position among its siblings (body: position*, group_by?). Optional `group_by: "status"` scopes position to the item's status group (use on status-grouped boards); omit for global ordering. Invalid `group_by` value → 400. Returns updated item. | "reorder item", "move to position", "drag item", "reposition" | — |
| POST | `/items/{id}/indent` | Make item a child of its nearest left sibling (outliner indent). No body. Returns 400 if no left sibling exists. | "indent item", "make subtask", "nest under previous", "demote item" | — |
| POST | `/items/{id}/outdent` | Promote item to sibling of its parent (outliner outdent). No body. Returns 400 if item is already at top level. | "outdent item", "promote task", "move to parent level", "unindent" | — |
| POST | `/items/{id}/duplicate` | Duplicate an item (body: include_children? boolean). Due dates, start dates, and completion status are cleared; assignments are copied. Returns 201 with `{ data: { item, children: [] } }`. | "duplicate item", "copy task", "clone item" | — |
| POST | `/items/{id}/toggle_is_top` | Toggle item must-do (is_top) flag. No body. Each call flips the current value. Turning OFF strips `#must` hashtag from item name. Returns updated item. Errors: 400 (invalid ID), 401, 403, 404. | "mark must-do", "tag as must do", "remove must tag", "toggle priority flag" | `/?item={id}` |
| POST | `/items/context` | Batch context lookup for up to 500 item IDs (body: `{ "item_ids": integer[] }`). Returns 24-field context projection per item (6 chip kinds). Unviewable/non-existent IDs silently dropped. | "get item context", "batch context", "breadcrumbs for items", "item badges", "item chips", "item context chips" | — |
| POST | `/items/{id}/align` | Polymorphic alignment — align an item to a goal, outcome, key result, item, or work session (body: align_to_id*, align_to_type* — one of `Goal`, `Outcome`, `KeyResult`, `Item`, `WorkSession`). Idempotent. Returns `{ data: { aligning_id, aligning_type, align_to_id, align_to_type } }`. | "align item", "link to goal", "connect to outcome", "align to key result", "align to work session" | — |
| PATCH | `/items/remove-next-tag` | Bulk strip `#next` hashtag from item names for the authenticated user (no body required). Returns `{ data: { updated: N } }`. | "remove #next tags", "clear next tags", "strip priority hashtags", "clean up #next" | — |
| PATCH | `/items/move-to-team-idea-list` | Reparent items to a team idea list and optionally clean up day-plan actions (body: item_ids*, target_id* — the destination item ID; dpa_cleanup? boolean). Returns `{ data: { moved: N } }`. | "move to idea list", "send to team backlog", "move to parking lot", "reparent to idea list" | — |

Batch context response: `{ "data": { "<item_id>": { "stored_ancestor_path": string\|null, "on_weekly": boolean, "is_long_term": boolean, "1x1_id": integer\|null, "1x1_name": string\|null, "todolist_id": integer\|null, "todolist_group_id": integer\|null, "todolist_name": string\|null, "day_plan_date": string\|null, "group_id": integer\|null, "group_name": string\|null, "project_meeting_id": integer\|null, "project_meeting_name": string\|null, "parent_item_id": integer\|null, "parent_item_name": string\|null, "measurable_id": integer\|null, "measurable_name": string\|null, "quarterly_planning_id": integer\|null, "quarterly_planning_team_name": string\|null, "parent_rock_id": integer\|null, "parent_rock_name": string\|null, "parent_rock_goal_name": string\|null, "parent_one_year_goal_id": integer\|null, "parent_one_year_goal_name": string\|null } } }`. All 24 keys always present per entry. Fields `1x1_id`, `1x1_name`, and `day_plan_date` are scoped to the requesting user (not item owner). Empty object `{}` when input is empty or all IDs are unviewable. Chip text templates: project_meeting → `project_meeting_name`; parent item → `parent_item_name`; measurable → `measurable_name`; quarterly planning → `"{quarterly_planning_team_name} Quarterly Planning"`; parent rock → `"{parent_rock_goal_name}, {parent_rock_name}"`; parent one-year goal → `parent_one_year_goal_name`.

Item fields: `id`, `name`, `description`, `due`, `status`, `on_weekly`,
`is_long_term` (boolean, defaults to `false`),
`is_top` (boolean — must-do / prioritizer flag; included in all v2 item responses),
`team` (TeamSimple | null), `creator` (UserSimple), `assignees` (UserSimple[]),
`parent_id`, `created_at`, `updated_at`,
`third_party_tracker` (`{ provider: string, external_id: string, name: string } | null` — always present; `null` when no tracker linked; provider is one of `clickup`, `monday`, `hubspot`, `salesforce`, `notion`).

Item `type` values: `Task` (default), `TodoList`, `Outcome`, `KeyResult`.

ItemDetail: Item fields + `children` (Item[]).

ItemTreeNode: Item fields + `children` (ItemTreeNode[]). Returned by `GET /items/{id}/children`. Nested recursively to the requested `depth` (1–20, default 2). Empty array at leaf nodes or max depth.

Move body fields: `parent_id` (integer or null — move under parent or to root), `left_id` (integer — place after sibling), `right_id` (integer — place before sibling). At least one required. If both `left_id` and `right_id` given, `left_id` takes precedence.

Bulk move: `PATCH /items/bulk-move` body: `{ "item_ids": integer[], "parent_id": integer }`. Response: `{ "data": { "moved": integer, "failed": integer, "errors": [{ "id": integer, "reason": string }] } }`. Per-item error reasons: `not_found`, `forbidden`, `self_reference`. Items already under the target parent are silently counted as moved. Duplicate item_ids are deduplicated server-side. Items are removed from all weekly board placements after being moved. Returns 403 if user cannot access the target parent, 404 if target parent not found, 422 for validation errors (empty item_ids, exceeds 1000, missing parent_id).

Smart text: `POST /items` supports `@username` in name to auto-assign, and hashtag date shortcuts (`#tomorrow`, `#nextweek`, `#1month`) to auto-set due date.

### Item Assignees

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items/{id}/assignees` | List assignees (paginated) | "who's assigned", "show assignees", "assigned to" | `/?item={id}` |
| PUT | `/items/{id}/assignees` | Add assignee (body: user_id*) | "assign to", "add assignee", "give to" | `/?item={id}` |
| DELETE | `/items/{id}/assignees/{user_id}` | Remove assignee | "unassign", "remove assignee", "take off" | `/?item={id}` |

### Item Comments

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items/{id}/comments` | List comments (chronological, paginated) | "show comments", "show notes", "what's been said" | `/?item={id}` |
| POST | `/items/{id}/comments` | Create comment (body: body*) | "add comment", "leave a note", "comment on" | `/?item={id}` |

Comment fields: `id`, `body`, `author` (UserSimple), `created_at`, `updated_at` (equal to `created_at` when unedited; later when edited — use to show "edited" badge).

### Comment Edit / Delete (flat by id)

Flat routes that work for comments on any surface (Items, Projects, Result Feed, etc.).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| PATCH | `/comments/{commentId}` | Edit a comment body (body: body* HTML). Author-only. Empty body returns 422. | "edit comment", "update comment", "fix my comment" | — |
| DELETE | `/comments/{commentId}` | Remove a comment (hard delete). Author or surface admin. Cleans up activity feed + decrements comment_count. | "delete comment", "remove comment", "remove my note" | — |

- `PATCH` response: `{ data: { id, body, author, created_at, updated_at } }`
- `DELETE` response: `{ data: { id, deleted: true } }`
- 403 if non-author tries to edit, or non-author/non-admin tries to delete. 404 if comment not viewable (no existence leak). 422 on empty edit body.

### Item Attachments (V1)

> **Note**: These endpoints use the V1 API base. Pass the full versioned path to `api.sh` (e.g., `/api/v1/items/{id}/attachments`).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/api/v1/items/{id}/attachments` | List all attachments (files + links) on an item | "show attachments", "list files", "what's attached", "item files", "show linked URLs" | `/?item={id}` |
| POST | `/api/v1/items/{id}/attachments` | Upload file attachment (multipart/form-data: file*, name?, description?). Max 4.5 MB. | "upload file", "attach file", "add attachment", "upload to item" | `/?item={id}` |
| POST | `/api/v1/items/{id}/links` | Add URL link (body: url* HTTPS required, title?, description?, media_type_code?) | "add link", "attach URL", "add resource link", "link to item" | `/?item={id}` |
| DELETE | `/api/v1/attachments/{material_id}` | Delete file attachment. Use `material_id` from list response. | "delete attachment", "remove file", "delete file from item" | — |
| GET | `/api/v1/attachments/{material_id}/download` | Download file — 302 redirect to pre-signed S3 URL (5-min expiry). Use `material_id`. | "download file", "get file", "download attachment" | — |
| DELETE | `/api/v1/links/{material_id}` | Delete URL link. Use `material_id` from list response. | "delete link", "remove link", "remove URL from item" | — |

Attachment list response: `{ "attachments": [AttachmentEntry] }`. Empty list: `{ "attachments": [] }`.

AttachmentEntry (file): `type: "file"`, `id` (Document ID), `material_id` (ItemMaterial ID — **use for delete/download**), `name`, `filename`, `content_type`, `size` (bytes), `url` (pre-signed S3 URL, ~1h expiry), `user_id`, `created_at`.

AttachmentEntry (link): `type: "link"`, `id` (LinkedUrl ID), `material_id` (ItemMaterial ID — **use for delete**), `title`, `url`, `description`, `media_type_code` (0=Article, 1=Video, 2=URL default, 3=Audio, 4=PDF, 5=Image, 6=Loom), `user_id`, `created_at`.

Upload errors: `400 { "error": "unsupported_extension" }` — file type not allowed; `400 { "error": "mime_mismatch" }` — MIME doesn't match extension; `413` — file exceeds 4.5 MB. Supported extensions (29): `.pdf .doc .docx .txt .rtf .odt .md .mdx .xls .xlsx .csv .ods .ppt .pptx .odp .png .jpg .jpeg .gif .svg .webp .zip .gz .tar .json .yaml .yml .xml .html`.

Auth: `canEdit` on Item for upload, add-link, and delete. `canView` on Item for list and download.

### Item Recurrence

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/items/{id}/recurrence` | Read current recurrence state | "show recurrence", "item schedule", "how often does this repeat", "recurrence settings" | `/?item={id}` |
| PUT | `/items/{id}/recurrence` | Set or clear recurrence (body: type*, day_within_interval?) | "set recurrence", "make daily", "repeat weekly", "set schedule", "clear recurrence", "remove recurrence" | `/?item={id}` |

Recurrence response: `{ "data": { "type": string|null, "day_within_interval": integer|null, "ends_after": null } }`

`type` values: `"daily"`, `"weekly"`, `"monthly"`, `"quarterly"`, or `null` (clears recurrence). Case-sensitive — `"DAILY"` or `"yearly"` → 422.

`day_within_interval` rules: required for weekly (0–6, Sun=0), monthly (1–31), quarterly (1–91). Ignored for daily. Pass `null` for `type` to clear.

Behavior: Setting any cadence clears the previous recurrence. Every successful write creates an activity feed entry. PUT response returns the updated state — no second GET needed. Returns 404 if item not found or not accessible (uniform, no existence leak).

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
`logo_url` (string | null — Filestack CDN URL or null if no logo set), `has_slack_webhook` (boolean — team has a Slack webhook configured), `has_discord_webhook` (boolean — team has a Discord webhook configured), `creator` (UserSimple), `created_at`, `updated_at`, `members` (TeamMember[]).

TeamMember: `id`, `team` (TeamSimple), `user` (UserSimple), `role` ("member" | "admin").

Mute/unmute response: `{ data: { id, name, is_muted } }`.

### Team Members

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/members` | List members (params: page, per_page, q) | "show members", "who's on the team", "team roster" | `/teams/{id}` |
| GET | `/teams/{id}/suggested-members` | All unique members across the full org hierarchy rooted at `{id}`, deduplicated by user ID (params: search — substring filter on login/email/first_name/last_name, activates at ≥2 chars). Excludes muted-team members unless they also belong to a non-muted team. Same response shape as `/teams/{id}/members`. No pagination — all matches returned in one response. `role` is always `"member"`. | "suggested members", "org members", "mention candidates", "who can I mention", "all members across teams", "assignee lookup" | — |
| PUT | `/teams/{id}/members` | Add existing user to team (body: user_id*, role?: "member"\|"admin") | "add member", "make admin" | `/teams/{id}` |
| POST | `/teams/{id}/members/invite` | Add or invite a user to the team by email (body: email*, first_name?, last_name?). Admin only. Returns 201. If the email belongs to an **existing** user (including cross-org), adds them directly and sends a "you were added" notification. If brand-new, creates a passive user and sends a confirmation/setup email (fire-and-forget via SES). | "invite member", "invite to team", "send invite", "invite new user", "add user by email", "add cross-org user" | `/teams/{id}` |
| PATCH | `/teams/{id}/members/{user_id}` | Change member role (body: role* — "admin" or "member"). Admin-only. Cannot demote last admin. | "change role", "make admin", "promote to admin", "demote member", "change member role" | `/teams/{id}` |
| DELETE | `/teams/{id}/members/{user_id}` | Remove member | "remove member", "kick from team" | `/teams/{id}` |
| POST | `/teams/{id}/members/{user_id}/resend-invite` | Re-send confirmation email to a pending (unconfirmed) member. Admin-only. No body. Returns 200 `{ data: { success: true, user_id, team_id } }`. 403 if not admin; 404 if team/user not found or not a member; 422 if member already confirmed. | "resend invite", "resend confirmation", "send invite again", "re-invite pending member" | — |

POST /teams/{id}/members/invite body: `{ "email"*, "first_name"?, "last_name"? }`. `first_name`/`last_name` used only when creating a brand-new user. Response 201: `{ "data": { "id", "team": { "id", "name" }, "user": { "id", "login", "first_name", "last_name" }, "role": "member" } }`. Errors: 401, 403 (not team admin), 404, 422 (email missing; `"has already been invited to this team"` for pending invites; `"is already a member of this team"` for active members). **Behavior**: if email belongs to an existing user not yet on the team (including cross-org users), they are added as an active member (not pending) and receive a "you were added" notification. If email is brand-new, a passive user is created and a confirmation/setup email is sent (fire-and-forget; SES failure does not fail the request). `PUT /teams/{id}/members` (by user_id) remains same-organization only.

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

Per-team settings stored in `object_metas` table — no schema changes required.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/settings` | Get all team settings (auth: any team member) | "team settings", "show settings", "is strict mode on", "check team settings" | `/teams/{id}` |
| PATCH | `/teams/{id}/settings` | Update one or more settings (auth: team admin only). Unrecognized keys silently ignored. Returns full settings object after update. | "update settings", "change setting", "enable strict mode", "turn on bhag", "toggle setting", "set parent team", "set inheritance" | `/teams/{id}` |

Settings response shape: `{ "data": { "is_cascading_goals": bool, "is_strict": bool, "bhag_enabled": bool, "assignments_require_review": bool, "skip_show_completion_message": bool, "scorecard_notes_visible": bool, "scorecard_date_order": string, "parent_vision_id": int|null, "parent_scoreboard_id": int|null, "use_parent_goals": bool|null } }`.

| Setting Key | Type | Description |
|-------------|------|-------------|
| `is_cascading_goals` | bool | Whether goals cascade to sub-teams |
| `is_strict` | bool | EOS strict meeting accountability mode (EOS teams default `true` when no record exists) |
| `bhag_enabled` | bool | Whether the BHAG section is visible |
| `assignments_require_review` | bool | Whether action assignments require a review step |
| `skip_show_completion_message` | bool | Whether to suppress the item completion message |
| `scorecard_notes_visible` | bool | Whether the notes column is displayed on the team scorecard UI (default `false`; display hint only — the API always returns `notes` on measures regardless) |
| `scorecard_date_order` | string | Order of scorecard date columns: `"newest_first"` or `"oldest_first"` |
| `parent_vision_id` | int\|null | ID of the ancestor team this team inherits its vision/rocks from. `null` = no inheritance set. Three-state: `null` means no ObjectMeta record exists (distinguishable from `false` or `0`). |
| `parent_scoreboard_id` | int\|null | ID of the ancestor team whose scorecard this team inherits. `null` = no inheritance set. Same three-state semantics as `parent_vision_id`. |
| `use_parent_goals` | bool\|null | Whether this team uses its parent team's goals. `null` = not set (distinguishable from `false`). |

PATCH body: any subset of the recognized keys. Boolean keys require boolean values; `parent_vision_id` / `parent_scoreboard_id` require integer or `null`; `use_parent_goals` requires boolean or `null`. Sending `null` for the inheritance fields deletes the underlying ObjectMeta record (clears inheritance). Omitting a key leaves its value unchanged. The API does **not** validate that `parent_vision_id` / `parent_scoreboard_id` values are actual ancestor team IDs — client must validate. Errors: 400 (invalid team id), 401 (no auth), 403 (GET: not a team member; PATCH: not a team admin), 404 (team not found), 422 (wrong value type — `{ "error": "Validation failed", "details": { "<key>": ["must be an integer or null"] } }`).

### Team Rhythm Settings

Per-team rhythm meeting time slots stored in `object_metas`. Returns defaults if no custom times saved — GET never returns 404.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/rhythm-settings` | Fetch rhythm meeting time slots (custom or system defaults). Auth: any team member. | "rhythm times", "meeting times", "rhythm settings", "what time is the meeting" | — |
| PATCH | `/teams/{id}/rhythm-settings` | Set all 7 rhythm meeting time slots (full replacement). Auth: team admin only. | "set meeting times", "update rhythm times", "change meeting schedule", "set rhythm settings" | — |

Response shape (both endpoints): `{ "data": { "times": string[] } }` — always exactly 7 time strings in 12-hour format (e.g. `"9:00 AM"`).

PATCH body: `{ "times": ["9:00 AM", "9:15 AM", "9:30 AM", "9:45 AM", "10:00 AM", "10:15 AM", "10:30 AM"] }` — exactly 7 strings required, each must match `/^\d{1,2}:\d{2} (AM|PM)$/i`.

Errors: 400 (invalid JSON), 403 (non-admin on PATCH), 404 (team not found / no access), 422 (wrong count or invalid time format — e.g. `"times must contain exactly 7 entries"` or `"times[2] is not a valid 12-hour time (e.g. 9:00 AM)"`).

System defaults (returned when no custom times saved): `["9:00 AM", "9:15 AM", "9:30 AM", "9:45 AM", "10:00 AM", "10:15 AM", "10:30 AM"]`.

### Team Customer-to-Cash Departments

Ordered list of departments a customer passes through from first contact to revenue collection. Stored in `object_metas` (`meta_key = 'customer_to_cash_data'`). GET returns defaults if none saved — never returns 404.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/customer-to-cash` | Get department list (custom or defaults). Auth: any team member. | "customer to cash departments", "c2c departments", "department flow", "c2c flow" | — |
| PUT | `/teams/{id}/customer-to-cash` | Replace entire department list (full replacement). Auth: team admin only. | "set departments", "update c2c departments", "save department flow", "set customer to cash departments" | — |

Response shape (both endpoints): `{ "data": { "departments": string[] } }`.

Default departments (returned when none saved): `["Marketing", "Sales", "Customer Success", "Engineering/Product/Service Delivery", "Finance"]`.

PUT body: `{ "departments": ["Marketing", "Sales", ...] }` — non-empty array, max 50 items, each ≤255 chars.

Errors: 400 (invalid team ID or malformed JSON), 401 (unauthenticated), 403 (GET: not a team member; PUT: not a team admin), 404 (team not found), 422 (validation failure — `{ "error": { "code": "validation_error", "details": { "departments": ["departments must not be empty"] } } }`).

### Team Weekly Board (Items)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/items` | All team items (params: page, per_page, q, all, include_archived) | "show weekly", "team board", "weekly board", "L10 board" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/items` | Create team item (on_weekly=true) | "add to weekly", "new team task", "create on board" | `/?item={item_id}` |
| PUT | `/teams/{id}/items/{item_id}` | Add item to board (sets on_weekly=true) | "put on weekly", "add to board", "show on weekly" | `/?item={item_id}` |
| DELETE | `/teams/{id}/items/{item_id}` | Remove from weekly (sets on_weekly=false, keeps item) | "remove from weekly", "take off board", "hide from weekly" | — |
| GET | `/teams/{id}/items/{section}` | Items by section (params: page, per_page, q, all, include_archived). Section: `done`, `next`, `blocked`, `parked`. | "show next", "show done", "show issues", "show parked", "priorities", "blockers", "parking lot" | `/level-10-meeting?team={id}` |
| PUT | `/teams/{id}/items/{section}/{item_id}` | Move item to section on board. Section: `done`, `next`, `blocked`, `parked`. | "move to next", "mark done", "flag as blocked", "park item", "prioritize" | `/?item={item_id}` |

Section values for `{section}`: `done`, `next`, `blocked`, `parked`.

| Section | GET shows | PUT effect |
|---------|-----------|------------|
| `next` | Items with status=next. Default: due within 7 days. Pass `?all=true` to skip. | Sets status=next, ensures on_weekly=true, auto-sets due date if null |
| `done` | Items with status=done. Default: completed within 7 days. Pass `?all=true` to skip. | Sets status=done, records completion timestamp |
| `blocked` | Items with status=blocked. No time filter. | Sets status=blocked, ensures on_weekly=true |
| `parked` | Items with status=parked. No time filter. Supports `include_archived`. | Sets status=parked, ensures on_weekly=true |

The `all` param (boolean, default false) on team item endpoints shows all team members' items when true; otherwise only current user's. Note: team projects do NOT use `all` — use `followed_only` and `include_muted` instead.

### Team Issues (dedicated endpoint)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/issues` | List team issues (items with status=blocked, is_wow=true). Supports rich filtering. No pagination — returns all matches. | "show team issues", "list all issues", "filter issues by label", "long-term issues", "IDS items" | `/components?tab=issues` |

Query params: `is_long_term` (boolean — filter long-term vs short-term issues; null treated as false), `search` (string, min 2 chars — case-insensitive name search), `custom_label_ids[]` (integer[] — AND logic, item must have all specified labels), `created_at_from` (YYYY-MM-DD), `created_at_to` (YYYY-MM-DD), `completed_from` (YYYY-MM-DD), `completed_to` (YYYY-MM-DD).

**Notes**: Completion date filters (`completed_from`/`completed_to`) also include `realized` items (not just `blocked`). Response includes `can_edit` (boolean), `comment_count` (integer), `attachment_count` (integer) in addition to standard Item fields.

Due date auto-set: creating an item with `status: "next"` in a team context (or moving an item to the `next` column via `PUT .../items/{section}/{item_id}`) with no explicit `due` date auto-sets `due` to 7 days from now. Explicit `due` values are always preserved.


### Team Projects

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/projects` | List team projects (params: page, per_page, q, status, include_muted, followed_only). Default: active, non-parkinglot, non-muted. Each project includes `default_view` (string\|null) and completion stats: `percent_complete` (number, 0–100), `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count` (all integers). | "show projects", "team projects", "rocks (EOS)", "execution plan", "project completion", "how complete is this project" | `/plugins/projects` |
| POST | `/teams/{id}/projects` | Create project in team (body: name*, description, due, status, on_weekly, team_id, parent_id, context). Note: stat fields are NOT included in create responses. | "create project", "new project on team", "add rock" | `/plugins/projects/{project_id}/overview` |
| GET | `/projects/{id}` | Get single project detail. Includes `default_view` (string\|null) and completion stats: `percent_complete`, `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count`. Also includes `children` array. | "show project", "project detail", "open project" | `/plugins/projects/{project_id}/overview` |
| PUT | `/teams/{id}/projects/{project_id}` | Convert item to team project (sets type=TodoList, assigns to team). Idempotent. | "convert to project", "promote to project", "make it a project" | `/plugins/projects/{project_id}/overview` |
| PATCH | `/teams/{id}/projects/{project_id}` | Update project (body: name, description, due, status, on_weekly) | "update project", "rename project", "change project status" | `/plugins/projects/{project_id}/overview` |
| PATCH | `/projects/{id}/default-view` | Set default view for a project (body: default_view*). Any team member with view access. Shared across all members. | "set default view", "change default view", "default to board view", "set project view" | — |
| DELETE | `/teams/{id}/projects/{project_id}` | Remove project from team (clears group_id, keeps project) | "remove project from team", "unlink project", "take off team board" | — |

Default filtering: returns only active, non-parkinglot, non-muted projects. Use `status` to override the active-only filter (e.g. `?status=done`). Use `include_muted=true` to include muted items.

**Project completion stats** (`percent_complete`, `total_children`, `realized_count`, `blocked_count`, `overdue_count`, `active_count`): returned on all GET project responses (list and detail). All fields are always numeric (never null); projects with no children have all zeros. Stats are NOT returned on POST/PATCH responses. Counts exclude archived children.

`default_view` valid values: `"overview"`, `"board"`, `"table"`, `"roadmap"`, `"outline"`, `"mindmap"`, `null` (resets to no preference; treated as `"overview"` by clients). Per-project, shared across all team members. `PATCH /projects/{id}/default-view` body: `{ "default_view": string | null }`. Response 200: `{ "data": { "id": integer, "default_view": string | null } }`. Response 422: `{ "errors": ["default_view is not a valid view"] }`.

### Project Hierarchy (read this before pulling project contents)

A project is a container for items, and **its contents are usually two levels deep**. Treating a project as a flat list of to-dos will surface column headers as if they were tasks.

**Standard shape (columnar — most projects):**

```
Project
├── Column A    ← direct child #1 (a section header, NOT a to-do)
│   ├── Item   ← grandchild — the actual task
│   └── Item
├── Column B    ← direct child #2
│   └── Item
└── Column C    ← direct child #3
```

Direct children of the project are **columns / section names** (Backlog, Doing, Done, etc.). The actual to-dos are **grandchildren** — children of the columns.

**Flat-checklist shape (minority case):**

```
Project
├── Item       ← direct child IS the to-do (no column layer)
├── Item
└── Item
```

A project with no columns has items as its direct children. Treat the direct-children list as the to-dos.

**How to detect which shape a project uses:**

1. **Fastest** — `GET /api/v2/projects/{id}/columns`. If the response returns columns, the project is columnar. An empty result means flat-checklist.
2. **From a fetched child** — columns carry the `is_project_column` ObjectMeta flag (see Project Columns section). A direct child without that flag is a to-do, meaning the project is flat.
3. **From `default_view`** — `"board"`, `"table"`, `"roadmap"` strongly imply columns are in use. `"outline"`, `"mindmap"`, `"overview"` may be either; do not rely on this alone.

**Recommended fetch patterns:**

- **Get the columns + items in one call (preferred):** `GET /api/v2/projects/{id}/columns` returns columns with embedded `items[]` by default. Use `?include_items=false` for the header row only.
- **Manual two-level walk:** `GET /items/{project_id}/children` for columns, then `GET /items/{column_id}/children` for items in each column. Use this only if you need fields not returned by the columns endpoint.

**Rules for any consumer (skills, MCP servers, integrations):**

- Never present a project's direct children as to-dos without first checking whether they are columns.
- When listing "to-dos in project X," walk to the grandchild level for columnar projects.
- Always handle the flat-checklist case — don't assume columns exist.
- When showing a kanban / board view, columns are the direct children; items are the grandchildren.

### Project Columns

Columns are plain `Item` records with `parent_id = projectId`, distinguished by an `is_project_column` ObjectMeta flag. Color uses the native `Item.color` column.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/api/v2/projects/{id}/columns` | List all columns for a project, ordered by position. Each column includes embedded `items[]` by default. Use `?include_items=false` for columns-only (header row). | "list project columns", "show columns", "project table headers", "view board columns" | — |
| POST | `/api/v2/projects/{id}/columns` | Create a new column (body: name* 1–255 chars, color? hex string). Position auto-assigned to end. Returns 201 with new column. | "add column", "create project column", "new board column" | — |
| PATCH | `/api/v2/projects/{id}/columns/{columnId}` | Update a column's name and/or color (body: name?, color?). | "rename column", "change column color", "update column" | — |
| DELETE | `/api/v2/projects/{id}/columns/{columnId}` | Archive a column; child items are reparented to the project root automatically. | "delete column", "archive column", "remove board column" | — |
| POST | `/api/v2/projects/{id}/columns/{columnId}/reposition` | Move a column to a new 0-based position (body: position*). Clamped to valid range; siblings renumber. | "reorder columns", "move column", "drag column to position" | — |
| POST | `/api/v2/projects/{id}/columns/{columnId}/duplicate` | Duplicate a column with all its child items. | "duplicate column", "copy column", "clone board column" | — |
| PUT | `/api/v2/projects/{id}/columns/{columnId}/move` | Nest one column under another (body: parent_id*). Circular-reference prevention enforced. | "nest column", "move column under", "reparent column" | — |

Column shape: `id`, `name`, `color` (hex or null), `position` (0-based), `parent_id`, `status`, `number_of_children`, `created_at`, `updated_at`, `items[]` (embedded by default).

Item shape within a column: `id`, `name`, `status`, `due` (YYYY-MM-DD or null), `position`, `color`, `assignee_id_cache`, `number_of_children`.

### Process Rules

Automation rules on columns. Fire when an item's `parent_id` changes to a rule-bearing column (via move, indent, or outdent). Failures are logged but do not block the move.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/api/v2/projects/{id}/columns/{columnId}/process-rules` | List automation rules on a column. | "list rules", "show automation rules", "column rules" | — |
| POST | `/api/v2/projects/{id}/columns/{columnId}/process-rules` | Create an automation rule (body: rule_type*, config*). Returns 201. | "add automation rule", "create process rule", "automate column" | — |
| PATCH | `/api/v2/process-rules/{id}` | Update a process rule (body: rule_type?, config?, enabled?). All fields optional. | "update rule", "disable rule", "toggle automation" | — |
| DELETE | `/api/v2/process-rules/{id}` | Delete a process rule permanently. | "delete rule", "remove automation rule" | — |

Process rule `rule_type` values and `config` shapes:
- `assign` — `{ "user_id": integer }` — assigns user to item on entry
- `status` — `{ "status": "completed" }` — sets item status on entry
- `hashtag` — `{ "tag": "urgent" }` — applies label to item on entry
- `due_date` (relative) — `{ "mode": "relative", "days": integer }` — sets due to today + N days
- `due_date` (absolute) — `{ "mode": "absolute", "date": "YYYY-MM-DD" }` — sets specific due date

Process rule fields: `id`, `item_id` (the column's item ID), `rule_type`, `config` (JSON object), `enabled` (boolean), `created_at`, `updated_at`.

### Team Headlines

Only available for teams using the EOS framework.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/headlines` | List active headlines (params: page, per_page). Active = no expiration AND created within 7 days, OR expires_at > today. When expires_at is set, only expiration matters. | "show headlines", "team headlines", "what's new", "announcements" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/headlines` | Create headline (body: text*, expires_at?) | "add headline", "new headline", "share update", "post announcement" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/headlines/{headline_id}` | Update headline (body: text?, expires_at?). Creator or team admin only. | "update headline", "edit headline", "change headline" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/headlines/{headline_id}` | Archive headline (soft delete — sets expires_at to today, immediately hidden). Creator or team admin only. | "delete headline", "remove headline", "archive headline" | — |

Headline fields: `id`, `text`, `creator` (UserSimple), `expires_at` (YYYY-MM-DD | null), `created_at`, `updated_at`.

HeadlineCreateRequest: `text` (string, required), `expires_at` (YYYY-MM-DD, optional — if omitted, headline visible for 7 days from creation).

HeadlineUpdateRequest: `text` (string), `expires_at` (YYYY-MM-DD). At least one field required.

### EOS Level 10 (L10)

EOS-friendly URL aliases for the team weekly board. These endpoints return the same data as their generic V2 counterparts but use Level 10 terminology. Only available for EOS teams.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/todos` | List L10 to-dos (alias for `GET /teams/{id}/items/next`; params: page, per_page, q, all) | "show L10 to-dos", "L10 todos", "weekly to-dos" | `/level-10-meeting?team={id}` |
| GET | `/teams/{id}/l10/done` | List completed L10 to-dos (alias for `GET /teams/{id}/items/done`; params: page, per_page, q, all). Default: completed within 7 days. `all=true` for older. | "show L10 done", "completed to-dos", "L10 completed" | `/level-10-meeting?team={id}` |
| GET | `/teams/{id}/l10/issues` | List L10 issues (alias for `GET /teams/{id}/items/blocked`; params: page, per_page, q) | "show L10 issues", "IDS list", "L10 blockers" | `/level-10-meeting?team={id}` |
| GET | `/teams/{id}/l10/parked` | List L10 parking lot (alias for `GET /teams/{id}/items/parked`; params: page, per_page, q) | "show L10 parking lot", "L10 parked", "parked items" | `/level-10-meeting?team={id}` |
| GET | `/teams/{id}/l10/headlines` | List L10 headlines (alias for `GET /teams/{id}/headlines`; params: page, per_page) | "show L10 headlines", "L10 announcements" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/todos` | Create L10 to-do (body: name*, description?, due?). Status=next, due defaults to 7 days. | "add L10 to-do", "new to-do", "create L10 todo" | `/?item={item_id}` |
| POST | `/teams/{id}/l10/issues` | Create L10 issue (body: name*, description?, due?). Status=blocked. | "add L10 issue", "raise issue", "new IDS item" | `/?item={item_id}` |
| POST | `/teams/{id}/l10/headlines` | Create L10 headline (alias for `POST /teams/{id}/headlines`; body: text*, expires_at?) | "add L10 headline", "new L10 headline" | `/level-10-meeting?team={id}` |
| PUT | `/teams/{id}/l10/todos/{item_id}` | Move item to L10 to-dos. Sets status=next, auto-sets due to 7 days if null. Alias for `PUT /teams/{id}/items/next/{item_id}`. | "move to L10 to-dos", "make it a to-do", "prioritize in L10" | `/?item={item_id}` |
| PUT | `/teams/{id}/l10/done/{item_id}` | Mark L10 item as done. Sets status=done, records completion. Alias for `PUT /teams/{id}/items/done/{item_id}`. | "mark L10 done", "complete L10 to-do", "L10 done" | `/?item={item_id}` |
| PUT | `/teams/{id}/l10/issues/{item_id}` | Move item to L10 issues. Sets status=blocked. Alias for `PUT /teams/{id}/items/blocked/{item_id}`. | "move to L10 issues", "flag as issue", "IDS this" | `/?item={item_id}` |
| PUT | `/teams/{id}/l10/parked/{item_id}` | Park L10 item. Sets status=parked. Alias for `PUT /teams/{id}/items/parked/{item_id}`. | "park L10 item", "move to parking lot", "shelve in L10" | `/?item={item_id}` |
| DELETE | `/teams/{id}/l10/items/{item_id}` | Remove item from L10 board (sets on_weekly=false, keeps item). Alias for `DELETE /teams/{id}/items/{item_id}`. | "remove from L10", "take off L10 board", "drop from L10" | — |
| GET | `/teams/{id}/l10/quick-wins` | Fetch contextual coaching articles from MasteryMaps based on subscriber persona and team framework. Always returns 200 — empty array if no articles available (persona=1, non-EOS/OKR framework, or external API failure). | "quick wins", "coaching articles", "L10 tips", "team coaching" | — |

QuickWinsArticle fields: `id` (integer), `headline` (string), `subheadline` (string | null), `thumbnail_url` (string | null), `type` (string, e.g. "Video How To"), `body` (string — HTML), `link_text` (string | null), `video_url` (string | null).

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
| GET | `/teams/{id}/l10/weekly-focus` | Get current + previous weekly focus entries (params: date — YYYY-MM-DD) | "show rally cry", "weekly focus", "what's the focus", "team rally cry" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/weekly-focus` | Set weekly focus for a date (body: focus_name*, date*). Admin only. | "set rally cry", "set weekly focus", "new rally cry" | `/level-10-meeting?team={id}` |

GET response: `{ data: { id, weekly_focus, created_for, previous_weekly_focus: [{ id, created_for, focus_name, average_rating }] } }`.
POST response (201): `{ data: { id, focus_name, created_for } }`.

#### Weekly Notes

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/weekly-notes` | Get current + previous meeting notes | "show meeting notes", "weekly notes", "L10 notes" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/weekly-notes` | Create a meeting note (body: title*, body*, json_content*). Admin only. HTML body sanitized server-side. | "add meeting note", "new weekly note", "create L10 note" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/weekly-notes/{note_id}` | Update a meeting note (body: title?, body?). Admin only. | "update meeting note", "edit weekly note" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/weekly-notes/{note_id}` | Delete a meeting note. Admin only. | "delete meeting note", "remove weekly note" | `/level-10-meeting?team={id}` |

GET response: `{ data: { current: { id, title, body, json_content, creator_id, created_at, updated_at }, previous: [same shape] } }`.
POST response (201): Created note in `data` envelope. DELETE: 204 No Content.

#### Wins

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/wins` | Get team wins for a date range (params: date — YYYY-MM-DD). | "show wins", "team wins", "what did we win", "victories" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/wins` | Create a win (body: name*, win_type* ["personal"\|"professional"], win_date* [YYYY-MM-DD], description?). Member auth. user_id set from auth token. | "add win", "create win", "log a win", "new win" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/wins/{win_id}` | Update a win (body: name?, win_type?, win_date?, description?). Owner or admin only. | "update win", "edit win", "change win" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/wins/{win_id}` | Delete a win. Owner or admin only. Returns 204. | "delete win", "remove win" | `/level-10-meeting?team={id}` |

Response (GET): `{ data: { wins: [{ id, name, description, win_type, win_date, user: { id, full_name }, created_at }] } }`. `win_type`: "professional" or "personal".

Response (POST 201, PATCH 200): `{ data: { win: { id, name, description, win_type, win_date, user: { id, full_name }, created_at } } }`.

Response (DELETE): 204 No Content. Errors: 403 if not owner and not admin.

#### Documents

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/documents` | List team documents (paginated). Returns `material_category_id` per document. | "show documents", "team docs", "team files", "list documents" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/documents` | Upload a document (multipart form data: file*, name*, material_category_id?, description?). Member auth. | "upload document", "add team file", "new document" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/documents/{doc_id}` | Update document metadata (body: name?, material_category_id?, description?). Admin/owner only. | "update document", "rename document" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/documents/{doc_id}` | Delete a document. Admin/owner only. | "delete document", "remove file" | `/level-10-meeting?team={id}` |

Document fields: `id`, `name`, `filename`, `content_type`, `size`, `description`, `material_category_id`, `user_id`, `created_at`. Paginated with `meta`. POST uses multipart form data (not JSON). DELETE: 204.

#### Linked URLs

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/linked-urls` | List linked URLs (paginated) | "show linked urls", "team links", "list urls" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/linked-urls` | Create a linked URL (body: title*, full_path*, description?, media_type_code?, material_category_id?). Member auth. | "add linked url", "new team link", "link a url" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/linked-urls/{url_id}` | Update a linked URL (body: title?, full_path?, description?, media_type_code?, material_category_id?). Member auth. | "update linked url", "edit team link" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/linked-urls/{url_id}` | Delete a linked URL. Member auth. | "delete linked url", "remove team link" | `/level-10-meeting?team={id}` |

LinkedURL fields: `id`, `title`, `full_path`, `description`, `media_type_code`, `material_category_id`, `user_id`, `created_at`. Paginated with `meta`. DELETE: 204.

#### Shared Links

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/shared-links` | List shared links | "show shared links", "team shared links" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/shared-links` | Create a shared link (body: title*, link_string*). **Admin role required** (403 for non-admin). | "add shared link", "share a link", "new shared link" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/shared-links/{link_id}` | Update shared link title (body: title*). Member auth (non-viewer). | "update shared link", "rename shared link", "edit link title" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/shared-links/{link_id}` | Delete a shared link. Member auth. | "delete shared link", "remove shared link" | `/level-10-meeting?team={id}` |

SharedLink fields: `id`, `title`, `full_path`, `link_string`, `user_id`, `created_at`. Response in `data` envelope. DELETE: 204.

#### Material Categories

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/material-categories` | List material categories. Any team member. | "show material categories", "document categories", "list categories" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/material-categories` | Create material category (body: name*). Member auth (non-viewer). 409 if name already exists. | "create category", "new document category", "add category" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/material-categories/{cat_id}` | Rename material category (body: name*). Member auth (non-viewer). | "rename category", "update category name" | `/level-10-meeting?team={id}` |
| DELETE | `/teams/{id}/l10/material-categories/{cat_id}` | Delete material category. Creator only (403 for others). Sets material_category_id=null on associated documents and linked URLs. | "delete category", "remove category" | `/level-10-meeting?team={id}` |

MaterialCategory fields: `id`, `name`, `user_id`, `created_at`, `updated_at`. Response in `data` envelope.

#### Weekly Ratings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/weekly-ratings` | Get all-time average rating, total count, and per-week history (param: weeks — int 1–52, default 12) | "show weekly rating", "team rating", "meeting rating", "how are meetings rated", "rating trend", "meeting rating history" | `/level-10-meeting?team={id}` |
| POST | `/teams/{id}/l10/weekly-ratings` | Submit or update weekly rating (body: rating*, date*). One rating per user per week — upserts. Member auth. | "rate meeting", "submit rating", "rate the week", "rate weekly" | `/level-10-meeting?team={id}` |

GET response: `{ data: { average_rating, total_ratings, weekly_history: [{ week_of, average_rating, count }] } }`. `weekly_history` is ordered most-recent-first; weeks with no ratings appear with `average_rating: null` and `count: 0`. `week_of` is the Monday of the week (YYYY-MM-DD). Use `?weeks=N` to control the number of slots (default 12, max 52).
POST response (201 new, 200 updated): `{ data: { id, stars, created_at } }`.

#### Braindump

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/l10/braindump` | Bulk create items on the board (body: items* — string[], section*). Admin only. Max 50 items per request. | "braindump", "bulk add items", "dump items to board", "brain dump" | `/level-10-meeting?team={id}` |

`section` values: `next`, `blocked`, `parked`.
Response (201): `{ data: { items: [{ id, name }], count } }`.

#### Item Reorder

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| PATCH | `/teams/{id}/l10/reorder` | Reorder organizer items (body: item_ids* — integer[]). Admin only. All IDs must belong to the team and be on the organizer board (is_wow=true). | "reorder items", "rearrange board", "sort items" | `/level-10-meeting?team={id}` |

Response (200): `{ data: { success: true, count } }`.

#### Meeting Settings

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/l10/meeting-settings` | Get meeting day, start time, and section durations | "show meeting settings", "meeting schedule", "L10 settings", "meeting time" | `/level-10-meeting?team={id}` |
| PATCH | `/teams/{id}/l10/meeting-settings` | Update meeting settings (body: meeting_day?, start_time?, section_durations?). Admin only. | "update meeting settings", "change meeting day", "set meeting time", "adjust section times" | `/level-10-meeting?team={id}` |

Response: `{ data: { meeting_day, start_time, section_durations: { transition, scorecard, goals, headlines, done, next, blocked } } }`.
`meeting_day`: 0-6 (Sunday=0). `start_time`: formatted string e.g. `"01:30 PM"`. `section_durations`: values are integers (minutes).

#### Meeting Summary Email

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/l10/meeting-summary` | Send summary email to all team members. Admin only. Fire-and-forget. | "send meeting summary", "email meeting notes", "send L10 summary" | `/level-10-meeting?team={id}` |

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
| GET | `/users/me` | Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`. `current_team` reflects the team last set via `PATCH /users/me/team-context` (was always null before 2026-03-13 API fix). Optional param: `?include=access` enriches `default_team` and `current_team` with `access_level` object (`is_admin`, `designation`, `seats_owned`) plus `is_leadership_team` and `framework` — use for LLM/AI context needing role awareness. | "who am I", "my profile", "my token", "my API key", "my role", "my access level", "am I admin" | `/customize` |
| GET | `/users/search` | Search users (params: q* — min 2 chars, page, per_page). Searches login, email, first_name, last_name. Returns active users visible to current user. | "find user", "search people", "look up user" | — |
| GET | `/users/{id}` | User profile (no api_token). Returns UserPublic. | "show user", "user profile", "who is this" | `/users/{id}` |
| GET | `/users/{id}/items` | User's items (requires same-team membership; params: page, per_page, q, status) | "show their tasks", "user's items", "what's assigned to them" | `/users/{id}` |
| GET | `/users/{user_id}/stats` | User profile stats (supports `me` as ID; requires shared team membership) | "show stats", "user stats", "profile stats", "how am I doing" | `/users/{user_id}` |
| GET | `/users/{user_id}/measurables` | User scorecard metrics with periodic data (params: period?, year?, active_only?; requires shared team membership) | "show measurables", "scorecard", "metrics", "KPIs" | `/users/{user_id}` |
| GET | `/users/{user_id}/rocks` | User rocks/goals with milestone progress (params: year?, page, per_page; requires shared team membership) | "show rocks", "my rocks", "goals", "quarterly priorities" | `/users/{user_id}` |
| GET | `/users/{user_id}/feedback` | User feedback/High5s (params: direction* — "given" or "received", page, per_page; requires shared team membership) | "show feedback", "High5s", "kudos", "recognition" | `/users/{user_id}` |
| GET | `/users/check-login` | Check if login/handle is available (params: login* — 3-40 chars) | "check login", "is handle available", "username taken" | — |
| GET | `/users/me/preferences` | Get full preferences (profile, notifications, timezone, startup view, API token, subscriber_persona, day-plan sorting/view preferences) | "my preferences", "settings", "notification settings" | `/customize` |
| PATCH | `/users/me/preferences` | Update preferences (body: login?, time_zone?, notifications?, startup_view_code?, preferred_team_id?, secondary_email?, update_frequency?, unsubscribe_all?, slack_username?, day_plan_sorting? — int 0–4: 0=priority, 1=result, 2=due, 3=creator, 4=quadrant; day_plan_show_settings? — `everything`/`must`/`not deferred and completed`; today_index_view? — `#list_view`/`#quadrant_view`). Partial update — only sent fields change. Notification booleans represent the logical ON/OFF value (true=on); the API inverts from the raw DB `should_suppress` field. Returns full preferences envelope including all day-plan fields. | "update preferences", "change settings", "change timezone", "toggle notifications", "turn off digest", "turn on notifications", "change day plan sorting", "switch to quadrant view", "set planner view" | `/customize` |
| GET | `/users/me/progress` | Personal progress — strategy metrics, practice scorecard, streak totals (params: period? — week/month/quarter) | "my progress", "practice streak", "how am I doing", "scorecard" | — |
| GET | `/users/me/integrations` | Get third-party integration selections (task_management, sales_revops, team_communication) | "my integrations", "connected apps", "integration settings" | `/customize` |
| PATCH | `/users/me/integrations` | Update integration selections (body: task_management?, sales_revops?, team_communication?). Set to null to disconnect. | "update integrations", "connect app", "disconnect integration" | `/customize` |
| POST | `/users/me/password` | Change password (body: current_password?, password*, password_confirmation*). current_password required unless OAuth-only user. | "change password", "update password", "new password" | `/customize` |
| PATCH | `/users/me/team-context` | Set the authenticated user's active team (body: team_id*). Returns `{ data: { id, name } }` of the newly active team. Idempotent. Errors: 400 (malformed body), 401 (unauthorized), 422 (team_id missing/invalid/not a member). | "switch team", "use team", "set active team", "change my team" | — |
| GET | `/users/me/context` | Full organizational context snapshot — user profile, all orgs/teams, strategic data (vision, plans, rocks, measures, projects, todos, issues), and today's day_plan in one call. **For full schema and disambiguation patterns, read `references/user-context-schema.md`.** Use this endpoint when the user references a team by name, asks about data across multiple teams, or needs organizational grounding. | "my context", "full context", "organizational context", "load my context", "everything about my teams", "all my rocks and issues", "my orgs and teams", "session context" | — |
| GET | `/users/me/notifications` | Paginated list of notifications for the authenticated user. Query params: `is_read` (boolean), `is_archived` (boolean, defaults false — archived excluded by default), `subscribeable_type` (string), `since` (ISO timestamp), `page`, `per_page`. | "my notifications", "what's new", "unread notifications", "notification inbox" | — |
| GET | `/users/me/notifications/unread-count` | Fast count of unread, non-archived notifications. Returns `{ "data": { "count": N } }`. | "unread count", "notification badge", "how many notifications", "do I have notifications" | — |
| POST | `/users/me/notifications/mark-all-read` | Mark all notifications as read. Body: `{ "subscribeable_type"?: string, "subscribeable_id"?: number }` — both optional. Omit both to mark all read. Scoped by type marks only that type's notifications. | "mark all read", "clear notifications", "dismiss notifications" | — |
| PATCH | `/users/me/notifications/:id` | Update a single notification. Body: `{ "is_read"?: boolean, "is_archived"?: boolean }`. Returns updated notification. 404 for another user's notification (no data leakage). | "mark notification read", "archive notification", "dismiss notification" | — |
| DELETE | `/users/me/notifications/:id` | Soft-archive a notification (sets `is_archived=true`, never hard-deletes). Returns 204. 404 for another user's notification. | "delete notification", "remove notification", "archive notification" | — |
| GET | `/users/me/activity-feed` | Paginated activity feed events for objects the user subscribes to. Query params: `page`, `per_page`, `since` (ISO timestamp). | "activity feed", "recent activity", "what happened", "feed" | — |
| GET | `/users/me/muted-items` | Paginated list of muted items (items with suppressed notifications) for the authenticated user. | "muted items", "what I've muted", "notification mutes" | — |
| POST | `/users/me/muted-items` | Mute an item (suppress notifications for it). Body: `{ "subscribeable_type": string, "subscribeable_id": number }`. | "mute item", "silence notifications for item", "stop notifications" | — |
| DELETE | `/users/me/muted-items/:id` | Unmute an item. `:id` is the `subscribeable_id` (the item ID), not a row ID. Muted items stored as JSON blob in `object_metas`. | "unmute item", "restore notifications for item" | — |
| GET | `/api/v2/users/me/upcoming-tasks` | Upcoming tasks for the current user across three sources: items assigned to caller (not authored), items authored by caller, and today's day-plan items. Params: `start_date` (YYYY-MM-DD, default today), `end_date` (YYYY-MM-DD, default start_date+30d), `include_done` (string, optional — pass literal `"true"` to include past-realized items from sources 1 and 2; any other value or absent = exclude). Returns `{ items: [...] }`. Sort: day-plan items first, then due ASC (nulls last), then created_at ASC. Excludes #parkinglot items and deferred day-plan actions. `day_plan_date` is non-null only for day-plan source items. Priority-tag filter applied to day-plan-sourced items (source 3): non-active priority-tagged items are excluded. Due-date sources (1 and 2) are unaffected. | "upcoming tasks", "my tasks", "tasks this week", "timeline tasks", "what's due soon", "my upcoming items", "tasks due next week", "show done tasks", "include completed tasks" | `/prioritizer/timeline` |
| POST | `/api/v2/users/me/history` | Record a visited entity. Body: `{ "entity_type": string, "entity_id": integer }`. Upserts `visited_at` if same tuple exists; prunes oldest entries beyond 100. Returns `{ ok: true }`. Valid entity_type values: `Item`, `Rock`, `Measure`, `Project`, `Person`, `Meeting`, `Page`, `Review`. Returns 422 for invalid entity_type. | "record visit", "track visit", "add to history", "mark visited" | — |
| GET | `/api/v2/users/me/history` | Retrieve recent visit history for the authenticated user. Returns up to 50 entries ordered newest-first. Names resolved at read time from entity tables; deleted entities are omitted. Returns `{ history: [{ id, entity_type, entity_id, name, team_name, visited_at }] }`. | "my history", "recently visited", "visit history", "recent items", "what I visited" | — |
| GET | `/api/v2/users/me/onboarding-state` | Returns the authenticated user's onboarding state. Fields: `onboarding_role` ("visionary"\|"integrator"\|"manager"\|null), `total_steps` (int), `completed_steps` (int), `completed_step_names` (string[]), `is_complete` (boolean), `should_show_onboarding` (boolean — true only when flag is set, valid account+team context exists, onboarding not complete, and user qualifies). Wrapped in `{ data: { ... } }`. | "onboarding status", "onboarding progress", "should I show onboarding", "is onboarding complete", "my onboarding role" | — |
| POST | `/api/v2/users/me/onboarding-state/skip` | Permanently dismisses the onboarding banner for the authenticated user. No request body. Returns `{ data: { success: true } }`. Idempotent. After this call, `GET /api/v2/users/me/onboarding-state` returns `should_show_onboarding: false`. | "skip onboarding", "dismiss onboarding banner", "hide onboarding", "don't show onboarding" | — |
| GET | `/api/v2/users/me/inbox` | Items the authenticated user has been assigned by other users (`assignment.user_id = me AND assignment.creator_id != me`). Self-assigned items excluded. Params: `status` (comma-separated V2 statuses, default `not_started,next`), `group_id` (comma-separated team IDs), `page`, `per_page` (default 100). Response envelope: `{ data: [...items], meta: { page, per_page, total, total_pages } }`. Same item shape as `GET /users/{id}/items`. `archived` excluded by default. | "my inbox", "items assigned to me", "what teammates asked me to do", "delegated items", "assigned by others", "inbox" | — |
| GET | `/api/v2/users/me/outbox` | Items the authenticated user has delegated to others (`assignment.creator_id = me AND assignment.user_id != me, active=true`). Params: `status` (comma-separated V2 statuses, default `active,archived,blocked,realized,review`), `group_id` (comma-separated team IDs), `show_all` (boolean — include realized items beyond 30-day window), `start_date`/`end_date` (ISO date range for realized items), `order` (`most_recently_assigned` sorts by assignment `created_at` DESC; `most_recently_updated` sorts by item `feed_updated_at` DESC; default sorts by hashtag priority tier then `assignment.position` ASC), `page`, `per_page` (default 100). Response envelope: `{ data: { ids_of_assignments_without_group_ids: integer[], items: [...OutboxItems] } }`. Each OutboxItem includes `id`, `name`, `status`, `type`, `group_id`, `is_wow`, `stored_ancestor_path`, `feed_updated_at`, `parent`, `assignments[]` (each with `id`, `user_id`, `creator_id`, `position`, `workflow_status_id`, `created_at`, `user`), `last_3_feeds[]`. `ids_of_assignments_without_group_ids` holds assignment IDs where `item.group_id IS NULL` (powers "Track All Under A Team" popup). Priority sort tier: #next → #toppriority/#priority → #1–#4 → #must → unlabeled → realized. | "my outbox", "items I delegated", "items assigned by me to others", "what I asked teammates to do", "delegated tasks", "outbox", "delegated to others" | — |
| POST | `/api/v2/users/me/outbox/reorder` | Reorder outbox items by setting assignment positions. Body: `{ "item_ids": integer[] }` (full ordered list). Returns `{ data: { ok: true } }`. | "reorder outbox", "drag outbox item", "reposition delegated item", "sort outbox" | — |
| POST | `/api/v2/users/me/outbox/filter-by-person` | Outbox narrowed to items delegated to a specific assignee. Body: `{ "user_id": integer }`. Returns same envelope as `GET /api/v2/users/me/outbox`. | "filter outbox by person", "show items assigned to person", "outbox for user", "delegated to person", "outbox filtered by assignee" | — |
| POST | `/api/v2/items` | **Extended** create item with optional outbox-friendly fields. All existing `/items` create params supported. New optional params: `assignees` (integer[] — user IDs to assign on create), `with_assignments` (boolean — include created assignments in response), `with_last_3_updates` (boolean — include last 3 activity feeds in response). When neither flag is set, returns legacy bare-item `{ data: <Item> }`. When flags are set, returns `{ data: { item, assignments[], assignees[], last_3_updates[] } }`. Fully backward compatible — callers omitting the new fields see unchanged behavior. | "create item with assignees", "create delegated item", "add task with assignment", "create outbox item" | `/?item={id}` |
| GET | `/items/:id/activity-feed` | Item-scoped activity feed events. Paginated; params: `page`, `per_page`, `since`. Returns 403 (not 404) when user lacks read access. | "item activity", "what happened on this item", "item history", "item feed" | — |
| GET | `/subscriptions` | Lists authenticated user's subscriptions. Query param: `subscribeable_type` (filter). | "my subscriptions", "what I'm subscribed to", "subscriptions" | — |
| POST | `/subscriptions` | Subscribe to an object. Body: `{ "subscribeable_type": string, "subscribeable_id": number }`. Idempotent: returns 200 with existing record if already subscribed, 201 if newly created. | "subscribe", "follow item", "watch item", "get notifications for" | — |
| DELETE | `/subscriptions/:id` | Unsubscribe. Returns 404 for another user's subscription. | "unsubscribe", "unfollow item", "stop following", "stop watching" | — |
| GET | `/communication-trackers` | Returns all 8 scheduled email tracker records for the authenticated user. Not paginated — always exactly 8 records; missing records created on demand. | "email trackers", "communication preferences", "email schedule", "digest settings" | — |
| PATCH | `/communication-trackers/:id` | Toggle email suppression for a tracker. Body: `{ "should_supress": boolean }` (intentional legacy typo — matches DB column name). Recomputes `next_send` after update. | "suppress emails", "turn off digest", "enable digest", "toggle email notifications" | — |

User fields (`/users/me`): `id`, `login`, `email`, `first_name`, `last_name`,
`api_token`, `default_team` (TeamSimple | null), `current_team` (TeamSimple | null — reflects the team last set via `PATCH /users/me/team-context`. Non-null after at least one team-context set call).

With `?include=access`, `default_team` and `current_team` gain: `is_leadership_team` (boolean), `framework` (string), `access_level` (`{ is_admin: boolean, designation: "visionary"|"integrator"|"leadership_team"|"front_line", seats_owned: [{ id, name }] }`). `designation` is derived from seat ownership — not a stored field.

UserPublic fields: `id`, `login`, `email`, `first_name`, `last_name`.

UserSimple fields: `id`, `login`, `first_name`, `last_name`. In 1-on-1 person objects (`persons.person1`, `persons.person2`), also includes `title` (string | null — organizational role from participant's most recently updated non-archived Seat; null if no active Seat).

TeamSimple: `{ id: integer, name: string }`.

UserStats fields: `wins_given`, `wins_received`, `goals_aspired`, `goals_realized`, `actions_done`.

UserMeasurable fields: `id`, `name`, `target_value`, `target_unit`, `owner` (UserSimple), `is_archived`, `values` ([{ date, value, on_track, percent_change }]).

Measurables params: `period` ("week" | "month", default "week"), `year` (default current), `active_only` (default true).

UserRock fields: `id`, `name`, `status` ("on_track" | "off_track" | "completed" | "dropped"), `due_date`, `team` (TeamSimple), `milestones_total`, `milestones_completed`, `created_at`.

FeedbackEntry fields: `id`, `message`, `from_user` (UserSimple + profile_photo_thumb_path), `to_user` (UserSimple + profile_photo_thumb_path), `created_at`.

UserPreferences fields: `id`, `profile_photo_thumb_path`, `login`, `first_name`, `last_name`, `email`, `secondary_email`, `time_zone`, `notifications` ({ morning_day_ahead, week_ahead_sunday, end_of_day_digest, weekly_digest_friday, weekly_status_request, daily_status_request, daily_status_request_to_slack, confirmation_link } — all boolean, true=on, false=off; API inverts the raw DB `should_suppress` field so clients read/write logical on/off values directly), `update_frequency` ("once_daily" | "every_change"), `unsubscribe_all`, `startup_view_code`, `startup_view_label`, `preferred_team_id`, `slack_username`, `api_token`, `is_coach`, `subscriber_persona` (integer 1-7, read-only, default 3 = Leadership Team Member).

Notification fields: `id`, `subscription_id`, `subscribeable_type`, `subscribeable_id`, `subscribeable_title`, `body` (HTML string), `is_read` (boolean), `is_archived` (boolean), `sent_at`, `created_at`, `actor` ({ user_id, user_name, user_avatar_url } — all null if no actor can be determined).

Subscription fields: `id`, `subscribeable_type`, `subscribeable_id`, `created_at`.

CommunicationTracker fields: `id`, `email_type_id` (1=end_of_week_digest, 2=end_of_day_digest, 3=mentions, 4=weekly_status_request, 5=item_assigned, 6=daily_status_request, 7=daily_status_request_to_slack, 8=confirmation_link), `email_type_key`, `should_supress` (boolean — intentional legacy typo matching DB column; true=suppressed/off), `next_send`, `last_sent` (nullable).

ActivityFeedEntry fields: `id`, `trackable_type`, `trackable_id`, `verb_clause`, `user_friendly_detail`, `comment_text` (nullable), `comment_id` (nullable), `document_id` (nullable), `progress_id` (nullable), `created_at`, `user` ({ id, name, avatar_url }).

MutedItem fields: `id`, `subscribeable_type`, `subscribeable_id`.

PersonalProgress fields: `targets` ({ rocks_realized_all_time, milestones_realized_all_time, milestones_realized_this_quarter }), `practice_scorecard` ({ days: [{ date, day_name, completed }] }), `practice_totals` ({ all_time, current_streak, longest_streak }).

UserIntegrations fields: `task_management` ({ selected, options }), `sales_revops` ({ selected, options }), `team_communication` ({ selected, options }).

## Third-Party Integrations (Nango)

User-scoped HubSpot / OAuth connection management. All routes require auth. Provider whitelist: `clickup`, `monday`, `hubspot`, `salesforce`, `notion`. Only HubSpot has a dedicated tickets reader; the other four providers use connect/status/disconnect only.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| `POST` | `/api/v2/nango/connect` | Persist a Nango connection_id after OAuth popup. Body: `provider`*, `connection_id`*. Idempotent — re-connecting returns 201 + `connected: true`. | "connect HubSpot", "link HubSpot account", "save nango connection" | — |
| `GET` | `/api/v2/nango/status?provider={provider}` | Check if user is connected. Always 200 for authed callers — read `data.connected` and `data.error`. Safe to poll. | "is HubSpot connected", "check integration status", "HubSpot connection status" | — |
| `DELETE` | `/api/v2/nango/disconnect?provider={provider}` | Remove cached connection for the (user, provider) pair. Local cache only — does not revoke remote. Idempotent. | "disconnect HubSpot", "unlink integration", "remove HubSpot connection" | — |
| `GET` | `/api/v2/nango/hubspot/tickets?limit&after` | Page the user's HubSpot CRM tickets. Returns `{ id, subject }` per ticket. Last page: `paging: null`. 401 = not connected; 502 = HubSpot unreachable. Lazy-evicts cached token on HubSpot 401/403. | "show HubSpot tickets", "list tickets", "HubSpot CRM tickets", "pick a ticket" | — |

Connection envelope: `{ "data": { "provider": string, "connected": boolean, "error": string|null } }`. Tickets envelope: `{ "data": { "results": [{ "id": string, "subject": string }], "paging": { "next": { "after": string } } | null } }`. Status is always 200 — never 401/5xx for missing token; use `connected` + `error` fields. `POST /connect` validates `connection_id` contains the authenticated user's ID (mismatches → 400). No token ever appears in any response. `DELETE /disconnect` is local-cache only.

**Linking an Item to a HubSpot ticket**: PATCH `/items/{id}` with `{ "third_party_tracker": { "provider": "hubspot", "external_id": "12345", "name": "Ticket subject" } }`. Clear with `{ "third_party_tracker": null }`. Read back from `GET /items/{id}` — field always present (object or `null`).

## Account Management

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/accounts` | Create account / signup (unauthenticated). Body: `login`*, `email`*, `password`*, `password_confirmation`*, `name`?, `framework`? (`eos`,`okr`,`v2mom`,`srt`,`default`; defaults to `okr`). Returns 201 with user+account+team+api_token on success, 422 with field-level `details` on validation failure. Transactional — rolls back entirely on failure. Sends welcome email fire-and-forget. | "create account", "sign up", "new account", "register", "onboard new user" | — |
| PUT | `/accounts/{id}/framework` | Set management framework for an account. Body: `framework`* (`eos`,`okr`,`v2mom`,`srt`,`default`). Account owner only. Returns 200 with `{ account_id, framework }`. | "set framework", "change framework", "select management framework" | — |
| PUT | `/accounts/{id}/leadership-team` | Designate a team as the leadership team for an account. Body: `team_id`* (must belong to account). Account owner only. Returns 200 with `{ account_id, leadership_team_id, previous_leadership_team_id }`. One leadership team per account — designating a new one removes the previous. | "set leadership team", "designate leadership team", "change leadership team" | — |
| GET | `/users/me/accounts` | List accounts the user belongs to (includes is_owner flag) | "my accounts", "list accounts", "which accounts" | — |
| GET | `/accounts/{account_id}/members` | List account members (params: page, per_page). Any account member can view. | "account members", "who's in account", "list users in account" | — |
| DELETE | `/accounts/{account_id}/members/{user_id}` | Remove member from account. Account owner only. Cannot remove owner. | "remove from account", "kick from account", "remove account member" | — |

UserAccount fields: `id`, `name`, `is_owner` (boolean).

AccountMember fields: `id`, `login`, `first_name`, `last_name`, `email`, `profile_photo_thumb_path`, `is_owner` (boolean).

Signup response (201): `{ data: { user: { id, login, email, api_token }, account: { id, name }, team: { id, name } } }`. Validation error (422): `{ error: { code: "validation_error", message, details: { field: [messages] } } }`.

## Search

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/api/v2/search` | Full-text search across 8 entity types. Params: `q`* (min 2 chars), `types` (comma-separated: `items,rocks,measures,projects,people,meetings,pages,reviews`; default: all), `limit` (per type; default 20). Returns `{ groups: { items: [...], rocks: [...], measures: [...], projects: [...], people: [...], meetings: [...], pages: [...], reviews: [...] }, total: N }`. Each result: `{ id, entity_type, name, status, assignee, due_date, team_id, team_name, url_hint }`. Returns 400 if q < 2 chars. | "search", "find", "look up", "search for item", "search everything", "full-text search", "find across teams" | — |

## Day Plans

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plans/today` | Today's plan (auto-creates if none exists). Priority-tag filter applied: items whose name contains a priority hashtag (`#next`, `#priority`, `#toppriority`, `#must`, `#1`–`#4`) are excluded when their status is not `active`. Item responses include `day_plan_action_id` (required when calling DPA-centric endpoints). Optional `?show=` query param for server-side filtering: `everything` (default — returns all items), `must` (only items where `is_top=true` OR name contains `#must`), `not deferred and completed` (excludes completed, deferred, or realized/done items). Invalid value → 400. | "show today", "my plan", "daily plan", "prioritizer" | `/prioritizer` |
| GET | `/day-plans/today/items` | Today's items (params: page, per_page, q, include_archived). Item responses include `day_plan_action_id` (required when calling DPA-centric endpoints such as defer, move-to-week, move-to-day). | "today's tasks", "what's on today", "my plan items" | `/prioritizer` |
| POST | `/day-plans/today/items` | Create item in today's plan (auto-creates plan). Hashtag side-effects processed on create: `#must` → `is_top=true`, `#daily` → `recur_daily=true`, `#next` or `#1` → `quadrant_position=1`, `#2`/`#3`/`#4` → respective quadrant. Hashtags remain in stored name. | "add to today", "new task for today", "put on my plan" | `/?item={item_id}` |
| PUT | `/day-plans/today/items/{item_id}` | Attach existing item to today (auto-creates plan, body: position?) | "attach to today", "add to plan", "link to today" | `/prioritizer` |
| PATCH | `/day-plans/today/items/{item_id}` | Toggle completion (body: completed*) | "check off", "mark done for today", "complete for today", "undo" | `/prioritizer` |
| DELETE | `/day-plans/today/items/{item_id}` | Remove from plan (keeps item) | "remove from today", "take off plan", "drop from today" | — |
| POST | `/day-plans/today/items/{item_id}/defer` | Defer an item to a future date (body: defer_to* — YYYY-MM-DD). Sets `deferred_to_date` on the day-plan action. Returns `{ data: { item_id, day_plan_action_id, deferred_to_date } }`. | "defer item", "snooze task", "push to later", "postpone item", "defer to date" | — |
| DELETE | `/day-plans/today/items/{item_id}/defer` | Clear deferral — remove the deferred_to_date from a day-plan action. Returns the updated day-plan action. | "clear deferral", "undefer item", "bring back to today", "stop deferring" | — |
| DELETE | `/day-plans/today/items` | Bulk remove items from today's plan (body: item_ids*, delete_items? boolean — if true, also archives items). Returns `{ data: { removed: N, deleted: N, skipped: [{ item_id, reason }] } }`. Skip reason `has_children` means item was not archived. OpenAPI path: `/day-plans/today/items/bulk-delete`. | "bulk remove from plan", "remove multiple items", "clear items from today", "bulk delete plan items" | — |
| POST | `/day-plan-actions/{id}/move-back-to-today` | Clear deferral and reassign a day-plan action back to today's plan. No body. | "move back to today", "bring deferred item back", "un-defer to today" | — |
| POST | `/day-plan-actions/{id}/move-to-day` | Reassign a day-plan action to a specific date (body: date* — YYYY-MM-DD). | "move to a different day", "reschedule to date", "move item to Wednesday" | — |
| POST | `/day-plan-actions/{id}/move-to-week` | Move item to current week plan and remove the day-plan action from today. No body. | "move to week", "add to weekly board", "send to this week" | — |
| POST | `/day-plans/today/set-positions` | Reorder today's plan items (body: item_ids* — complete ordered array of item IDs; assigns position=1-based index to each). Empty array is valid. Subset allowed — only provided items get updated positions. Auto-creates today's plan if needed. Returns `{ "data": { "success": true } }`. | "reorder today", "sort plan", "drag to reorder", "set item order", "change order of today's items" | — |
| POST | `/day-plans/today/items/{item_id}/set-quadrant-position` | Assign an Eisenhower quadrant to an item on today's plan, keyed by item_id (body: quadrant* — one of: urgent_important, not_urgent_important, urgent_not_important, not_urgent_not_important, unassigned). Returns `{ data: { action, quadrant_position } }` where quadrant_position is 1–4 (or 0 for unassigned). 404 if item not on today's plan. | "put in quadrant", "assign to Q1", "set quadrant", "prioritize to urgent", "Eisenhower quadrant", "move to do first", "unassign quadrant" | `/prioritizer/quadrants` |
| GET | `/day-plans/upcoming-actions` | Flat list of every action on the caller's day plans dated today or later (no upper bound). Runs the idempotent prep gate first (auto-creates today's plan, inserts daily-recurring items, rolls over prior-day actions — at most once per day). Returns non-deferred actions (`deferred_to_date IS NULL`) whose item status is active/blocked/realized/review. Excludes #parkinglot items and non-active priority-tagged items. Each row includes `day_plan_date` (YYYY-MM-DD) for client-side bucketing — Today / This Week / Next Week / Later. No query parameters. Response: `{ data: [...] }` with the same V2_ITEM_SELECT item projection as `/day-plans/today`. Use for the day/week column view; use `upcoming-tasks` for the Timeline view. | "upcoming day plan actions", "what's on my schedule next few weeks", "day/week column view", "my future plans", "upcoming planned tasks", "what have I planned" | — |
| GET | `/day-plans/{date}` | Plan by date (YYYY-MM-DD). Priority-tag filter applied (same rule as `/day-plans/today`): non-active priority-tagged items are excluded. Supports the same `?show=` query param as `/day-plans/today` (`everything`, `must`, `not deferred and completed`). | "show plan for Monday", "last Friday's plan" | `/prioritizer` |
| GET | `/day-plans/{date}/items` | Items by date (params: page, per_page, q, include_archived) | "items for that day", "what was on Monday" | `/prioritizer` |
| POST | `/day-plans/{date}/items` | Create item in date's plan (plan must already exist) | "add to that day's plan" | `/?item={item_id}` |
| PUT | `/day-plans/{date}/items/{item_id}` | Attach existing item to date (plan must already exist, body: position?) | "attach to that plan" | `/prioritizer` |
| PATCH | `/day-plans/{date}/items/{item_id}` | Toggle completion (body: completed*) | "check off for that day" | `/prioritizer` |
| DELETE | `/day-plans/{date}/items/{item_id}` | Remove from plan (keeps item) | "remove from that day" | — |
| POST | `/day-plans/{date}/items/{item_id}/set-quadrant-position` | Assign an Eisenhower quadrant to an item on a specific date's plan, keyed by item_id (body: quadrant* — one of: urgent_important, not_urgent_important, urgent_not_important, not_urgent_not_important, unassigned). Returns `{ data: { action, quadrant_position } }`. 400 if date invalid. 404 if no plan for date or item not on that plan. | "set quadrant for past day", "assign quadrant for date" | — |
| POST | `/day-plan-actions/{id}/set-quadrant-position` | Assign an Eisenhower quadrant to a day-plan action, keyed by action id (body: quadrant* — same enum as above). Returns `{ data: { action, quadrant_position } }`. Legacy endpoint — prefer item-keyed variants when you have item_id. | "set action quadrant" | — |

DayPlan fields: `id`, `date`, `creator` (UserSimple), `items` (DayPlanItem[]).

DayPlanItem fields: Item fields + `completed` (boolean), `position` (integer), `quadrant_position` (integer 0–4; 0 = unassigned, 1 = urgent+important, 2 = not urgent+important, 3 = urgent+not important, 4 = not urgent+not important), `day_plan_action_id` (integer — required when calling DPA-centric endpoints: defer, move-back-to-today, move-to-day, move-to-week), `deferred_to_date` (YYYY-MM-DD or null).

Eisenhower quadrant values: `urgent_important` (Q1), `not_urgent_important` (Q2), `urgent_not_important` (Q3), `not_urgent_not_important` (Q4), `unassigned` (0).

Day plan completion: regular items also get status=done. Recurring/daily items only toggle `completed` for that day — item stays active for tomorrow.

### Day Plan Columns (Custom Columns / Personal Planner Buckets)

Personal Planner custom column lanes. All endpoints require auth. Items embedded in column responses are automatically scoped to the caller's today DayPlan — no filter param needed.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plan-columns` | List all active (non-archived) columns owned by the caller, with embedded items scoped to today's plan. Priority-tag filter applied to embedded items (same rule as `/day-plans/today`): non-active priority-tagged items are excluded. Response includes `color: string \| null` on each column (6-digit hex e.g. `#2563EB`, or null). | "list my columns", "show custom columns", "what are my planner buckets", "show planner columns" | `/prioritizer/custom-columns` |
| POST | `/day-plan-columns` | Create a new column (body: name* — 1–255 chars, color? — 6-digit hex e.g. `#2563EB` or omit for no color). Position auto-assigned to end. Returns 201 with new column including `color`. | "add a column", "create a planner bucket", "new column called X", "create column with color" | `/prioritizer/custom-columns` |
| PATCH | `/day-plan-columns/{id}` | Update a column (body: name? — 1–255 chars; color? — 6-digit hex to set, `null` to clear, omit to leave unchanged). Both fields are now optional — send either or both. Returns 404 if not owned or archived. | "rename column", "change column name", "set column color", "change column color", "clear column color" | `/prioritizer/custom-columns` |
| DELETE | `/day-plan-columns/{id}` | Soft-archive a column (sets is_archived=true, removes all action rows). Returns 200 with archived column. Items in the column are unlinked but not deleted. | "delete column", "archive column", "remove planner bucket" | `/prioritizer/custom-columns` |
| POST | `/day-plan-columns/{id}/reposition` | Move column to new 0-indexed position (body: position* — non-negative integer, clamped to end). Siblings re-numbered. Returns `{ data: { success: true } }`. | "reorder columns", "move column", "drag column" | `/prioritizer/custom-columns` |
| POST | `/day-plan-columns/drop-action` | Place an item into a column at a position (body: item_id*, new_column_id* (number or null), position?). One-column-per-item enforced globally — removes item from all other columns first. Pass new_column_id: null to unlink from all columns. Returns 200 `{ data: { success: true } }`. 403 if item not viewable; 404 for missing/archived/unowned column. | "put item in column", "move item to column", "drop into bucket", "unlink item from columns", "remove item from planner" | `/prioritizer/custom-columns` |

DayPlanColumn fields: `id`, `name`, `position` (0-indexed), `is_archived` (boolean), `created_at`, `updated_at`, `items` (DayPlanColumnItem[]).

DayPlanColumnItem fields: `id`, `name`, `completed` (boolean), `due` (YYYY-MM-DD or null), `recur_daily` (boolean), `position` (0-indexed within column).

## Result Feed

The "90-second practice" — a daily check-in report where users record what they got done, what's next, and what's blocked. **Auto-DONE**: when a user marks any item done through any V2 surface (`PATCH /items/:id`, day-plan completion, L10 section move, etc.), it is automatically recorded into the completing user's check-in `done` section for their local today — no manual add needed. Credited to the actor (completer), not the item owner. Does not fire for `recur_daily` items or on uncomplete. Best-effort; a check-in write failure never fails the completion.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/result-feed/{date}` | Get check-in for date (auto-creates empty report). `{date}` accepts `YYYY-MM-DD` or literal `today`. Returns `{ data: ResultFeed }` with 4 sections: `done`, `review`, `next`, `blocked` — each a structured object `{ items, notes, attachments }`. | "show my check-in", "90 seconds", "result feed", "daily report", "what did I do", "show check-in for {date}" | — |
| POST | `/result-feed/{date}/{section}` | Create new item in section (body: name*) | "add done", "add next", "add blocked", "new done item", "got something done" | — |
| PUT | `/result-feed/{date}/{section}/{item_id}` | Add existing item to section (idempotent) | "add item {id} to done", "put {id} in next", "attach {id} to blocked" | — |
| DELETE | `/result-feed/{date}/{section}/{item_id}` | Remove item from section (keeps item, does not revert status) | "remove {id} from done", "take {id} off next", "drop {id} from blocked" | — |
| POST | `/result-feed/{date}/submit` | Submit + share check-in (body: optional team_id, item_ids). Requires ≥1 item in both done and next. Idempotent. | "submit", "finalize", "done for the day", "submit check-in" | — |
| GET | `/teams/{id}/result-feed` | List team's shared check-ins (params: page, per_page). Reverse chronological. Requires team membership. | "team check-ins", "team feed", "team result feed", "show team check-ins" | — |
| PUT | `/result-feed/{date}/{section}` | Update section metadata (body: notes, attachment_ids). `notes: null` clears notes. `attachment_ids` replaces current list (filtered to IDs the user owns). Valid sections: `done`, `review`, `next`, `blocked`. | "add notes to done", "update notes", "set notes on done/next/blocked/review", "edit section notes", "attach files" | — |
| POST | `/result-feed/{date}/push-to-slack` | Push check-in to team's Slack webhook (body: group_context_id*, exclude_item_ids[]). 422 if no webhook configured, 502 if webhook fails, 403 if not a team member. | "share to slack", "push to slack", "send check-in to slack" | — |
| POST | `/result-feed/{date}/push-to-discord` | Push check-in to team's Discord webhook (body: group_context_id*, exclude_item_ids[]). Same error codes as push-to-slack. | "share to discord", "push to discord", "send check-in to discord" | — |
| POST | `/result-feed/{date}/reactions` | Toggle high-five reaction on a report (body: user_id — whose report to react to). Returns `{ data: { reacted: boolean, count: integer } }`. | "high-five", "react", "give kudos", "high five check-in" | — |
| GET | `/result-feed/{date}/reactions` | Get current reaction state for a report (query: user_id*). Returns `{ data: { reacted: boolean, count: integer } }`. | "show reactions", "reaction count", "did I react", "high-five count" | — |
| POST | `/result-feed/{date}/attachments` | Upload a file attachment to a check-in (multipart/form-data: file*). Max 4.5 MB. Returns `{ data: { id, filename, content_type, filesize, parent_object_type } }`. Use returned `id` as `attachment_id` in PUT section metadata. | "upload file to check-in", "attach file", "upload attachment" | — |
| GET | `/result-feed/{date}/comments` | List comments on a report (query: user_id* — whose report). Returns `{ data: [{ id, comment, user_id, created_at }] }`. | "show comments", "read comments", "comments on check-in" | — |
| POST | `/result-feed/{date}/comments` | Add comment to a report (body: body*, user_id* — whose report). body required, non-empty, ≤ 10,000 chars. Returns 201 with created comment `{ id, comment, user_id, created_at }`. | "comment on check-in", "add comment", "reply to check-in" | — |
| GET | `/teams/{id}/result-feed/{date}/{user_id}` | View a specific user's report for a date. Returns `{ data: { report: ResultFeed, is_quiet: boolean } }`. `is_quiet: true` when shared to a different team context. 403 if not a member, 404 if no report. | "show user's check-in", "view teammate's report", "team member report" | — |
| POST | `/users/me/group-context` | Set the calling user's active group context (body: group_id*). Same effect as `PATCH /users/me/team-context`. Returns `{ data: { success: true } }`. | "set team context", "switch team", "set group context" | — |

ResultFeed fields: `id`, `date`, `is_completed`, `done` (ResultFeedSection), `review` (ResultFeedSection), `next` (ResultFeedSection), `blocked` (ResultFeedSection).

ResultFeedSection fields: `items` (Item[]), `notes` (string | null), `attachments` (Attachment[]).

Attachment fields: `id`, `filename`, `content_type` (MIME type, e.g. "image/png"), `size` (integer — bytes).

UploadedDocument fields (returned by POST attachments): `id`, `filename`, `content_type`, `filesize`, `parent_object_type` (always "CustomContent"). Use `id` as `attachment_id` in PUT section metadata.

TeamResultFeed fields: ResultFeed fields + `user` (UserSimple).

Comment fields: `id`, `comment` (text body), `user_id`, `created_at`.

Reaction response fields: `reacted` (boolean — whether the requesting user has reacted), `count` (integer — total reaction count).

Submit request body (all optional): `team_id` (integer — team to share with), `item_ids` (integer[] — items to highlight).

Section path parameter: `done`, `review`, `next`, `blocked`.

Date path parameter: `YYYY-MM-DD` or literal `today` (resolved server-side via user timezone).

Push-to-slack/discord request body: `group_context_id` (integer — required, the team/group context ID), `exclude_item_ids` (integer[] — optional items to omit from the push).

Behavioral notes:
- GET auto-creates an empty report if none exists for the date.
- GET result-feed sections are objects (`{ items, notes, attachments }`), NOT flat arrays.
- PUT section metadata: `notes: null` clears notes; `attachment_ids` replaces the full list (filtered to IDs the caller owns).
- PUT (add item) is idempotent — adding an already-present item returns 200.
- DELETE (remove item) returns 404 if item is not in that section. Does NOT delete the item or revert its status.
- Submit is idempotent — re-submitting a completed report returns 200.
- Submit validation: requires ≥1 item in both `done` and `next` (422 otherwise).
- Submit side-effects (server-side, no skill action required): upserts ObjectMeta `last_status_provided` timestamp for the user, triggers daily recurrence item rollover (recurrent items due today roll to tomorrow).
- Adding items triggers status side-effects: done→done, next→next, blocked→blocked.
- Removing items does NOT revert status side-effects.
- React (high-five) is a toggle — calling again removes the reaction.
- Comments: body is required, non-empty, max 10,000 characters.
- Push-to-slack/discord: 422 if team has no webhook configured, 502 if webhook returns non-2xx, 403 if caller is not a team member.
- Team-feed detail: `is_quiet: true` when the report was shared to a different team than the requester's active group context.

## One-on-Ones (1-on-1)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/1-on-1` | List one-on-ones (params: group_id — team scope; account_id — organization scope *(new)*; page, per_page, archived — `true`/`false`/`all`; default `false` = active only). Scope tiers: `group_id` = this team; `account_id` = this org; neither = all orgs. `group_id` wins when both are sent. `account_id` must be a valid integer (400 otherwise). | "show 1:1s", "my one-on-ones", "list 1:1s", "one-on-one meetings", "show archived 1:1s", "1:1s in my org", "organization 1:1s" | — |
| GET | `/1-on-1/{id}` | Meeting detail (response includes `items.next`, `items.done`, `items.issues` arrays). Non-participants receive 403 (not 500). | "show meeting", "meeting details", "open 1:1" | `/1-on-1/{id}` |
| GET | `/1-on-1/{id}/items` | All meeting items (params: creator_id?, page, per_page, q, include_archived) | "meeting items", "what's on the agenda" | `/1-on-1/{id}` |
| GET | `/1-on-1/{id}/items/{section}` | Items by section (params: creator_id?, page, per_page, q, include_archived). Section: `next`, `blocked`. | "meeting next items", "meeting blockers", "meeting issues" | `/1-on-1/{id}` |
| GET | `/1-on-1/{id}/done` | Done items (params: since? YYYY-MM-DD, page, per_page) | "meeting done items", "completed items", "done since date" | `/1-on-1/{id}` |
| POST | `/1-on-1/{id}/items` | Create item in meeting (body: name*, column? — `next`/`blocked`/`done`, default `next`; description? — HTML body) | "add to meeting", "new meeting item", "add to 1:1" | `/?item={item_id}` |
| POST | `/1-on-1/{id}/align` | Align a measure, goal, or item to the session (body: alignable_type* — `Measure`, `Goal`, or `Item`; alignable_id*). Idempotent. Use `alignable_type: "Item"` to attach an existing item to the meeting — there is NO `PUT /1-on-1/{id}/items/{item_id}` endpoint. | "attach to meeting", "link item to 1:1", "add existing item to meeting", "align to 1:1", "track goal in 1:1", "add measure to meeting" | `/1-on-1/{id}` |
| POST | `/1-on-1/{id}/unalign` | Remove an alignment from the session (body: alignable_type*, alignable_id*). For Goals, cascades to remove their KeyResults. | "unalign from 1:1", "stop tracking in meeting", "remove goal from 1:1" | `/1-on-1/{id}` |
| DELETE | `/1-on-1/{id}/items/{item_id}` | Remove an item from the meeting by URL param (keeps the item). Equivalent to unalign with `alignable_type: "Item"`. Returns 204. | "remove from meeting", "detach from 1:1" | — |
| PUT | `/1-on-1/{id}/notes` | Save meeting notes (body: `{"notes":"text"}`). Overwrites existing notes. | "save notes", "add notes to 1:1", "write meeting notes" | `/1-on-1/{id}` |
| PUT | `/1-on-1/{id}` | Schedule (or clear) next meeting. Body: `{"next_meeting_at":"<ISO 8601 datetime>"}` or `{"next_meeting_at":null}`. Returns updated MeetingSimple. | "schedule next meeting", "set next 1:1", "clear next meeting date" | `/1-on-1/{id}` |
| GET | `/1-on-1/fetch` | Find-or-create a 1-on-1 session between two users (params: `person1_id`, `person2_id` — required). Returns existing session or creates one. | "find 1:1 with", "get meeting between", "open 1:1 between users" | — |
| POST | `/1-on-1` | Create a new 1-on-1 session (body: `{ person1_id, person2_id }`). Returns new MeetingSimple with `can_edit`. | "create 1:1", "start new one-on-one", "new meeting between" | — |
| POST | `/1-on-1/{id}/archive` | Archive a session (participants only — creator or other participant; 403 if not participant; 404 for project sessions). Idempotent. | "archive 1:1", "archive meeting", "hide one-on-one" | — |
| POST | `/1-on-1/{id}/unarchive` | Restore an archived session. Idempotent. | "unarchive 1:1", "restore meeting", "unarchive one-on-one" | — |

OneOnOneSimple fields: `id`, `date` (YYYY-MM-DD | null), `human_name` (pre-formatted display string),
`persons`: `{ person1: UserSimple+title, person2: UserSimple+title }`,
`cadence` (string | null — e.g. `"weekly"`, `"biweekly"`, `"monthly"`; null if no cadence configured),
`cadence_interval` (integer | null — multiplier, e.g. 1 = every period, 2 = every 2 periods; null if no cadence),
`next_meeting_at` (string | null — UTC ISO 8601 datetime of next scheduled meeting; null if not scheduled),
`archived` (boolean — `true` if archived by a participant; archived sessions excluded from default list),
`can_edit` (boolean — always present, never null; `true` if the current user is person1, person2, or a listed assistant; `false` for viewers and non-participants; fail-closed), `can_view` (boolean).

OneOnOne (detail) fields: OneOnOneSimple + `items`: `{ next: Item[], done: Item[], issues: Item[] }`,
`notes` (string | null), `can_edit_notes` (boolean), `measures`, `goals`, `attachments`, `assistants`.

> **Terminology**: The `issues` array in the API is the "blocked/issues" column in the UI. The `group_id` param filters by team.

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

## Invite Confirmation

Endpoints for the teammate-invite accept flow (unauthenticated).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/api/v2/users/confirmation` | Validate an invite token (params: token*). Always 200. Returns `{ data: { status, valid, login? } }`. **Tri-state status**: `valid` — live, unconfirmed invite (show signup form, `login` is present); `used` — link already consumed, route to sign in; `invalid` — no pending invite, offer a fresh invite. `valid` boolean is retained for backward compatibility (`true` only when `status === 'valid'`). | "validate invite token", "check invite link" | — |
| POST | `/api/v2/users/confirmation` | Activate account by accepting an invite (unauthenticated, body: token*, login*, password*). Password must be 6–20 characters. Returns 422 if token already used or password out of range. | "accept invite", "confirm account", "activate account" | — |
| POST | `/api/v2/users/confirmation/resend` | Self-serve resend of invite email by invitee (unauthenticated, body: email*). Always 200. Status: `sent` — email sent; `throttled` — within rate-limit window (default 5 min), no email; `already_active` — account confirmed, sign in instead; `no_invite` — no pending invite, ask admin. No account is created on any path. | "resend invite email", "resend confirmation email", "send invite again" | — |

## Status Values

`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`

`draft` is read-only — cannot be set via POST or PATCH (422 if attempted). Only allowed transition: `draft` → `not_started`.

## Core Values

**Note**: `GET /api/v2/core-values` has been removed. Core values are now managed via EOS Vision: `GET /teams/{id}/core-values` (see EOS Vision section below). The `core_value_id` in ratings requests now references a label ID from the EOS Vision core values list.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/core-values-ratings` | List ratings for a subject (params: subject_id*, page, per_page) | "show ratings", "core value ratings", "ratings for user" | — |
| POST | `/core-values-ratings` | Create standalone core value ratings (body: subject_id*, ratings[{core_value_id*, score*}]) — `core_value_id` is a label ID from EOS Vision core values | "rate core values", "submit ratings", "score values" | — |

CoreValuesRating fields: `id`, `core_value` ({ id, name }), `score` (integer), `justification` (string | null), `rater` (UserSimple), `review_id` (integer | null), `created_at`.

## Reviews

Performance reviews with self-assessment and reviewer assessment workflow.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/reviews` | List reviews (params: page, per_page, status, q, team_id). `team_id` filters by organization — resolves the team's root ancestor and returns only reviews where the reviewee is a member of any team in that org. 400 if team_id invalid, 404 if not found. Omitting team_id returns all reviews. Excludes archived. Response includes `user_id` (creator ID, nullable). | "show reviews", "list reviews", "my reviews", "performance reviews" | — |
| POST | `/reviews` | Create review (body: reviewee_id*, reviewer_id*, template_id*, review_type?, start_date?, end_date?). Admin/people-ops only. reviewee_id and reviewer_id must be members of at least one team in the account (400 "is not a member of any team in this account" if not). | "create review", "start review", "new performance review" | — |
| GET | `/reviews/{id}` | Review detail. Assessment visibility depends on requesting user's role. Response includes `user_id` (creator ID, nullable), `can_delete` (boolean — whether the authenticated user may delete this review), and `gwc_evaluations` (GwcEvaluationEntry[] — 0-2 entries, one per respondent_type). Reviewer GWC entries hidden from reviewee until `signed_off` status. | "show review", "review details", "open review" | — |
| PATCH | `/reviews/{id}` | Update review (body: review_type?, start_date?, end_date?) | "update review", "change review dates", "edit review" | — |
| DELETE | `/reviews/{id}` | Archive review (soft delete). Allowed for admins/people-ops and for the review creator (unless the reviewee has saved assessment data — 403 "Cannot delete: the reviewee has already saved assessment data"). Use `can_delete` from the detail response to determine visibility. | "archive review", "delete review", "remove review" | — |
| PUT | `/reviews/{id}/draft-assessment` | Save draft assessment (WIP, does not advance state). Body: AssessmentSubmitRequest (includes optional `gwc_evaluation`). | "save draft", "draft assessment", "save progress" | — |
| POST | `/reviews/{id}/submit-assessment` | Submit final assessment. Transitions to assessed when both parties submit. Body: AssessmentSubmitRequest (includes optional `gwc_evaluation`). | "submit assessment", "finalize assessment", "submit review" | — |
| POST | `/reviews/{id}/sign-off` | Sign off review (body: initials*). Must be in assessed state. Reviewer only. | "sign off", "approve review", "finalize review" | — |
| PUT | `/reviews/{id}/void` | Void review (body: reason*). Admin/people-ops only. Rejects all further actions. | "void review", "cancel review", "invalidate review" | — |
| PUT | `/reviews/{id}/notes` | Update review notes (body: notes*). Reviewer or people-ops. | "update review notes", "add notes", "edit review notes" | — |
| POST | `/reviews/{id}/action-items` | Create action item (body: title*, assignee_id*) | "add action item", "create follow-up", "review action item" | — |
| POST | `/reviews/{id}/attachments` | Upload attachment (multipart/form-data: file*). Beta. | "attach file", "upload to review", "add attachment" | — |
| DELETE | `/reviews/{id}/attachments/{aid}` | Delete attachment | "remove attachment", "delete file from review" | — |
| GET | `/reviews/{id}/audit-log` | Audit log entries for review | "review history", "audit log", "review changes" | — |
| GET | `/reviews/{id}/seat-accountability-comments` | List all seat accountability comments for a review. Response: array of { id, review_id, seat_id, comment (HTML string), respondent_type ("self"\|"reviewer"), created_at, updated_at }. Auth: reviewer, reviewee, or review admin. | "seat accountability comments", "list accountability comments" | — |
| PUT | `/reviews/{id}/seat-accountability-comments/{seatId}` | Create or update (upsert) a seat accountability comment (body: comment* (HTML), respondent_type* ("self"\|"reviewer")). respondent_type "self" — reviewee only; "reviewer" — reviewer only. 200 on update, 201 on create. 400 invalid input, 403 unauthorized for respondent_type, 404 review/seat not found. | "save accountability comment", "upsert seat comment", "update seat accountability" | — |

Review status values: `in_progress`, `assessed`, `signed_off`, `voided`.

ReviewListItem fields: `id`, `user_id` (integer | null — creator ID), `reviewee` (UserSimple), `reviewer` (UserSimple), `status`, `review_type` (integer | null), `template` ({ id, name } | null), `start_date`, `end_date`, `created_at`.

ReviewDetail fields: ReviewListItem + `can_delete` (boolean — whether the current user can delete), `notes`, `void_reason`, `signed_off_at`, `signed_off_initials`, `self_assessment` (Assessment | null), `reviewer_assessment` (Assessment | null), `core_values_ratings` (CoreValuesRatingEntry[]), `gwc_evaluations` (GwcEvaluationEntry[] — defaults to `[]`), `attachments` (Attachment[]), `action_items` (ActionItem[]), `updated_at`.

Assessment fields: `respondent_type` ("self" | "reviewer"), `respondent` (UserSimple), `is_draft` (boolean), `responses` ([{ prompt_id, description, response_value, score }]).

AssessmentSubmitRequest: `respondent_type` ("self" | "reviewer"), `assessment_responses` ([{ prompt_id*, response_value?, score? }]), `core_values_ratings?` ([{ core_value_id*, score*, justification? (string, max 5000 chars, HTML stripped, empty string → null) }]), `gwc_evaluation?` (GwcEvaluationInput — optional, upserts GWC data keyed by respondent_type).

GwcEvaluationEntry fields: `respondent_type` ("self" | "reviewer"), `gets_it_1..3` (boolean | null), `gets_it_verdict` (boolean | null), `wants_it_1..5` (boolean | null), `wants_it_verdict` (boolean | null), `capacity_1..4` (integer | null), `capacity_total` (integer | null — server-computed, sum of capacity_1–4, null if any capacity field null). Reviewer entries hidden from reviewee until review reaches `signed_off` status.

GwcEvaluationInput: same fields as GwcEvaluationEntry except `capacity_total` (read-only, do not send). All fields nullable — partial saves allowed.

ActionItem fields: `id`, `title`, `assignee` (UserSimple), `status`, `created_at`.

Attachment fields: `id`, `file_name`, `file_type`, `file_size`, `url`, `created_at`.

AuditLogEntry fields: `id`, `change_type`, `user` (UserSimple), `description`, `created_at`.

### Review Templates

Templates that define the prompts used in reviews. Access is role-based (`canView`/`canEdit`/`canDelete`): viewers, editors, authors, and contributors can access templates through direct or group-inherited roles. Account admins and team admins retain full access. Permissions can be managed via the standard permissions service with `object_type='ReviewTemplate'`.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/review-templates` | List review templates (params: page, per_page). Returns templates visible to the user through direct or group-inherited roles (viewer, editor, author, contributor) plus team-shared templates. Account admins see all. **Excludes archived templates.** | "show templates", "list review templates", "review forms", "list templates" | — |
| POST | `/review-templates` | Create template (body: name*, target_role?, reviewer_instructions?, owning_organization_id?, shared_with_organization_ids?). Admin on owning organization (team admin or account admin). Organization IDs must be root teams. | "create template", "new review template", "add review form" | — |
| PATCH | `/review-templates/{id}` | Update template (body: name?, target_role?, reviewer_instructions?, shared_with_organization_ids? — replace-all, archived? — boolean to archive/unarchive). owning_organization_id is rejected (400). Requires `canEdit`. Organization IDs must be root teams (422 if sub-team IDs sent). `archived` must be boolean (400 otherwise); idempotent. | "update template", "edit review template", "rename template", "share template", "manage template sharing", "archive template", "unarchive template", "restore template" | — |
| GET | `/review-templates/{id}` | Fetch single template by ID. Returns archived templates (includes `archived` boolean field). | "get template", "fetch template", "view template" | — |
| DELETE | `/review-templates/{id}` | Delete template (permanent). Requires `canDelete` (delegates to `canEdit`) — editor, author, contributor, or org admin. | "delete template", "remove review template" | — |
| POST | `/review-templates/{id}/prompts` | Create assessment prompt (body: description*, answer_type*, hint?, answer_meta_data?). Requires `canEdit` on parent template. | "add prompt", "new question", "add review question" | — |
| PATCH | `/review-templates/{id}/prompts/{pid}` | Update prompt (body: description?, hint?, answer_type?, answer_meta_data?). Requires `canEdit` on parent template. | "update prompt", "edit question", "change prompt" | — |
| DELETE | `/review-templates/{id}/prompts/{pid}` | Delete prompt. Requires `canEdit` on parent template. | "delete prompt", "remove question" | — |
| PUT | `/review-templates/{id}/prompts/positions` | Reorder prompts (body: positions[{id*, position*}]). All prompts must be included. Requires `canEdit` on parent template. | "reorder prompts", "rearrange questions", "sort prompts" | — |
| GET | `/review-templates/{id}/permissions` | List individual user permissions on a template. Returns `{ data: { object_type, object_id, viewers: [{user_id, login, first_name, last_name, profile_photo_thumb_path, role_name}], collaborators: [...] } }`. Requires `canEdit`. | "who has access to template", "list template permissions", "view template roles" | — |
| POST | `/review-templates/{id}/permissions` | Grant a role to a user on a template (body: user_id*, permission_type* — viewer/editor/author/admin). Returns 204. Requires `canEdit`. | "grant template access", "add template permission", "give user access to template" | — |
| DELETE | `/review-templates/{id}/permissions` | Revoke a role from a user on a template (body: user_id*, permission_type? — omit to revoke all roles). Returns 204. Requires `canEdit`. | "revoke template access", "remove template permission", "remove user from template" | — |
| POST | `/review-templates/{id}/copy` | Copy a review template (no request body). Accessible to any user with view access (creator, account admin, owning team member, shared team member). Returns 201 with the new template. Copy name = original + " (Copy)". All prompts duplicated with new IDs. Copy owned by requesting user, starts unshared, never archived. `can_edit` is always true on response. | "copy template", "duplicate review template", "clone template", "make a copy of template" | — |

ReviewTemplateListItem fields: `id`, `name`, `target_role` (string | null), `prompt_count` (integer), `created_at`, `owning_organization` (`{ id, name }` | null), `organization_id` (integer | null — root team ID).

ReviewTemplateDetail fields: `id`, `name`, `target_role`, `reviewer_instructions`, `archived` (boolean — true if archived), `prompts` (AssessmentPrompt[]), `created_at`, `updated_at`, `owning_organization` (`{ id, name }` | null), `shared_with_organizations` (`[{ id, name }]`), `organization_id` (integer | null — root team ID).

422 on POST/PATCH when any organization ID is not a root team: `{ "error": "Organization ID(s) {ids} are not root teams" }`.

AssessmentPrompt fields: `id`, `description`, `hint` (string | null), `answer_type` ("range" | "text" | "textarea" | "boolean" | "multiple"), `answer_meta_data` (object | null), `position` (integer).

## Seats (Accountability Chart)

Seats represent positions on a team's accountability chart. Each seat can have an owner, aligned measures, aligned goals, and URL links. Seats form a hierarchy (parent/child) within a team.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/seats` | Get team accountability chart — full hierarchical tree (params: `include_archived`, `context`). Pass `?context=organization` to resolve the org root from the team ID and return the full org-level seat tree (for accountability charts visible to subteam members); omit for team-scoped results (default). Each node includes `roles` (string[] | null) and `seat_level` ("leadership_team"\|"department"\|"individual_contributor"\|null). | "show org chart", "accountability chart", "team seats", "who does what", "org-level seat tree", "full organization chart" | `/plugins/accountability-chart` |
| GET | `/users/{id}/seats` | Flat list of seats owned by user `id`, scoped to teams the requester can access (teams where requester is a member or admin; others are silently excluded). Returns same `SeatTreeNode` shape as `/teams/{id}/seats` but `children` is always `[]`. Param: `include_archived` (boolean, default false — when true each node has `archived: true`). Errors: 400 (invalid id), 401 (no auth), 404 (user not found). | "seats for user", "what seats does this person own", "user's positions on org chart" | — |
| POST | `/seats` | Create seat (body: name*, team_id or parent_id, accountabilities?, notes?, seat_owner_id?, associated_team_id?). Root requires team_id; child requires parent_id. One root per team. | "create seat", "add position", "new role on chart" | — |
| GET | `/seats/{id}` | Get seat detail (children as SeatSimple, one level deep). Includes `roles`, `seat_level`, and `has_direct_reports` (boolean, computed). | "show seat", "seat details", "position details" | — |
| PATCH | `/seats/{id}` | Update seat (body: name?, accountabilities?, notes?, seat_owner_id?, associated_team_id?, roles?, seat_level?). Owner changes cascade to aligned measures/goals. `roles`: string[] | null, max 5 items, 500 chars each. `seat_level`: "leadership_team"\|"department"\|"individual_contributor"\|null. | "update seat", "rename seat", "change seat owner", "assign seat", "set seat roles", "set seat level" | — |
| DELETE | `/seats/{id}` | Archive seat and all descendants (soft delete). Cannot archive root seat. | "archive seat", "delete seat", "remove position" | — |
| PUT | `/seats/{id}/restore` | Restore archived seat (children remain archived, restore individually) | "restore seat", "unarchive seat", "bring back seat" | — |
| PUT | `/seats/{id}/move` | Re-parent seat (body: parent_id*). Validates no circular refs, same group. Cannot move root. | "move seat", "reparent seat", "reorganize chart" | — |
| POST | `/teams/{id}/seats/scaffold` | Scaffold default accountability chart for a team (empty body). Idempotent — returns 200 with `seats_created: 0` if team already has seats, 201 with seat count and root seat details if created. Seat names depend on framework: EOS uses Visionary/Integrator, all others use CEO/COO-President. | "scaffold seats", "create default org chart", "set up accountability chart", "initialize seats" | — |

Seat fields: `id`, `name`, `accountabilities` (string | null, HTML sanitized), `notes` (string | null, HTML sanitized), `parent` (SeatSimple | null — `{ id, name }` object), `creator` (UserSimple), `seat_owner` (UserSimple | null), `team` (TeamSimple + framework), `associated_team` (TeamSimple | null), `measures` ([{ id, name, description }]), `goals` ([{ id, name, description }]), `links` ([{ id, title, url }]), `children` (Seat[] in tree, SeatSimple[] in detail), `roles` (string[] | null — max 5, 500 chars each; Seat Builder accountability roles), `seat_level` ("leadership_team" | "department" | "individual_contributor" | null), `has_direct_reports` (boolean, computed, only on GET /seats/{id}), `created_at`, `updated_at`.

SeatSimple: `{ id: integer, name: string }`.

### Seat Measures

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/seats/{id}/measures` | List measures aligned to seat. Response includes `chart_type` (string | null), `current_value` (string | null), and `target_value` (string | null) on each measure object. | "seat measures", "show KPIs for seat", "aligned measures" | — |
| PUT | `/seats/{id}/measures` | Align measure to seat (body: measure_id*). Moves alignment if already aligned elsewhere. | "align measure", "add KPI to seat", "link measure" | — |
| DELETE | `/seats/{id}/measures/{measure_id}` | Remove measure alignment | "remove measure", "unlink KPI", "detach measure" | — |

### Seat Goals

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/seats/{id}/goals` | List goals aligned to seat. Response includes `status` (string | null — mapped from `current_state`: `active`, `at_risk`, `off_track`, `complete`, `archived`) and `due_date` (string | null, YYYY-MM-DD) on each goal object. | "seat goals", "show rocks for seat", "aligned goals" | — |
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

### Seat Snapshots

Team admins can save, list, view, update, delete, and revert snapshots of their team's seat hierarchy. Seat edits (PATCH, move, archive, restore) automatically create a pre-change snapshot (non-blocking — seat ops always succeed even if snapshot fails).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| POST | `/teams/{id}/snapshots` | Create a named snapshot (body: title*, description?) | "save snapshot", "create checkpoint", "save chart state", "backup accountability chart" | — |
| GET | `/teams/{id}/snapshots` | List snapshots for team (newest first) | "list snapshots", "show chart history", "view saved charts", "snapshot history" | — |
| GET | `/teams/{id}/snapshots/{snapshotId}` | Get snapshot detail with full seat data | "show snapshot", "view saved chart", "get checkpoint" | — |
| PATCH | `/teams/{id}/snapshots/{snapshotId}` | Update snapshot title/description | "rename snapshot", "update snapshot", "edit checkpoint" | — |
| DELETE | `/teams/{id}/snapshots/{snapshotId}` | Delete a snapshot | "delete snapshot", "remove checkpoint" | — |
| PUT | `/teams/{id}/snapshots/{snapshotId}/revert` | Revert chart to snapshot (body: create_backup? boolean, default true) | "revert chart", "restore snapshot", "undo chart changes", "roll back chart" | — |

All snapshot endpoints require team admin. Non-admins receive 403.

Snapshot list fields: `id`, `title`, `description`, `creator_name`, `created_at`.

Snapshot detail adds: `seats` (array of seat objects with `id`, `name`, `description`, `parent_id`, `user_id`, `accountability_owner_id`, `notes`).

Revert response: `{ message, backup_snapshot_id }` — `backup_snapshot_id` is null if `create_backup: false`.

## Team Scorecard Measures

Team scorecard measures are KPIs tracked weekly on a team's scorecard. Each measure can have a target, unit, direction (higher/lower is better), target period, aggregation type, and an optional owner. Weekly history values are recorded against Monday dates.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/measures` | List all measures for a team with weekly history (params: year?, include_archived?, owner_id?). Results sorted ascending by `position`. | "show scorecard", "list measures", "team KPIs", "team measurables", "scorecard measures", "weekly metrics", "what are our KPIs" | `/components?tab=data` |
| POST | `/teams/{id}/measures` | Create a new measure (body: measure wrapper with name*, unit?, direction?, target_value?, target_period? ("week"\|"month"\|"quarter"\|"year"; default "week"), aggregation_type? ("sum"\|"last"\|"average"; default "sum"), owner_id?, data_source_type? (default 0), roll_up_type? ("sum"\|"average"), roll_up_measure_ids? (integer[]), chart_type? (string — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; omit or null for no preference)). Server auto-assigns `position = max(existing) + 1` (or 1 if first). | "add measure", "create KPI", "new measurable", "add scorecard item", "create metric", "set monthly target", "quarterly measure" | — |
| PATCH | `/teams/{id}/measures/reorder` | Persist a new ordering for the team's active scorecard measures. Admin-only. Body: `{ "measure_ids": [int, ...] }` — must be the **complete** ordered list of every active (non-archived) measure ID for the team. Returns `{ "data": { "success": true, "count": N } }`. Statuses: 200 success, 403 non-admin, 422 incomplete/invalid list (missing IDs, duplicates, archived IDs, cross-team IDs, empty array). | "reorder measures", "reorder scorecard", "drag and drop measures", "change measure order", "rearrange KPIs", "sort scorecard measures" | — |
| PATCH | `/measures/{id}` | Update measure fields (body: measure wrapper with name?, unit?, direction?, target_value?, target_period? ("week"\|"month"\|"quarter"\|"year"; omit to preserve, null rejected), aggregation_type? ("sum"\|"last"\|"average"; omit to preserve, null rejected), archived?, notes? (string\|null — sanitized HTML; omit to preserve, send null to clear), data_source_type?, roll_up_type? ("sum"\|"average"), roll_up_measure_ids? (integer[]), chart_type? (string — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; omit key to preserve, send null to clear)). Use `archived: true` to soft-archive, `archived: false` to restore. | "update measure", "rename KPI", "change target", "edit measurable", "restore measure", "add measure notes", "set measure description notes", "clear measure notes", "set monthly target", "change measure period", "set aggregation", "make this a last-value measure" | — |
| DELETE | `/measures/{id}` | Archive a measure (soft-delete, idempotent). Sets is_archived=true. | "archive measure", "delete KPI", "remove measurable", "hide measure" | — |
| POST | `/measures/{id}/history` | Record a weekly or monthly value for a measure (body: date*, value*, period?). `period` is optional: `"week"` (default, date must be a Monday) or `"month"` (date as `YYYY-MM` or `YYYY-MM-01`, response normalises to `YYYY-MM-01`). Omitting `period` defaults to weekly — fully backward-compatible. Upserts by (measure_id, date). | "record value", "log KPI", "enter score", "record measurable", "update scorecard value", "fill in weekly number", "record monthly value", "log monthly score", "enter monthly measure", "monthly scorecard entry" | — |
| POST | `/measures/{id}/history/note` | Record or clear a per-week text note on a history slot (body: date*, note — string ≤255 chars or null/empty to clear). Upserts; clearing a slot with no note is a no-op. | "add note", "record note", "annotate week", "note this week", "clear note", "remove note", "weekly note" | — |

Measure fields: `id`, `name`, `description` (string | null), `notes` (string | null — sanitized HTML, present on all measure responses; null if not set), `unit` (string, e.g. `"#"`, `"$"`, `"%"`), `direction` (`"higher"` | `"lower"`), `target_value` (numeric string | null), `target_period` (`"week"` | `"month"` | `"quarter"` | `"year"` — the time period that `target_value` applies to; default `"week"`), `aggregation_type` (`"sum"` | `"last"` | `"average"` — how weekly values combine when rolled up for display; `"sum"` adds, `"last"` takes the most recent, `"average"` takes the mean; default `"sum"`), `position` (integer — display order, ascending; use reorder endpoint to change), `owner` (UserSimple | null), `is_archived` (boolean), `chart_type` (string | null — one of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`; null = no preference), `histories` (MeasureHistory[]), `data_source_type` (integer, always present: 0=manual, 1=google_sheets, 2=other_api, 3=roll_up).

Roll-up fields (present in responses only when `data_source_type=3`): `roll_up_type` (`"sum"` | `"average"`), `roll_up_measure_ids` (integer[] — IDs of source measures on the same team).

MeasureHistory fields: `id` (integer | null — null if no value recorded), `date` (YYYY-MM-DD, always a Monday), `value` (numeric string | null), `target_value` (numeric string | null), `note` (string | null — null if no note recorded for this slot).

**Response envelopes**:
- `GET /teams/{id}/measures` → `{ "data": Measure[], "meta": { "year": int, "date_range": { "start": string, "end": string } } }` — returns 52 weekly history slots per year per measure
- `POST /teams/{id}/measures` → `{ "data": Measure }` (201, histories is empty array, includes `position`)
- `PATCH /teams/{id}/measures/reorder` → `{ "data": { "success": true, "count": N } }` (200)
- `PATCH /measures/{id}` → `{ "data": Measure }` (200, no histories field)
- `DELETE /measures/{id}` → `{ "data": Measure }` (200, is_archived: true, no histories field)
- `POST /measures/{id}/history` → `{ "data": { "id": int, "measure_id": int, "date": string, "value": string, "target_value": string | null, "period": "week" | "month" } }` (200, upsert; for monthly entries `date` is always normalised to `YYYY-MM-01`)
- `POST /measures/{id}/history/note` → `{ "data": { "id": int|null, "measure_id": int, "date": string, "note": string|null } }` (200, upsert; id is null when note is cleared)

**Validation**: `name` must not be blank (422). `value` must be a numeric string (422). `date` must be a valid ISO date (Monday preferred). `direction` must be `"higher"` or `"lower"`. `target_period` must be one of `"week"`, `"month"`, `"quarter"`, `"year"` (422 for any other value, including null); omitting on PATCH preserves the stored value. `aggregation_type` must be one of `"sum"`, `"last"`, `"average"` (422 for any other value, including null); omitting on PATCH preserves the stored value. `data_source_type` must be 0–3 (422 otherwise). `chart_type` must be one of `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart` or null if provided (422 otherwise); omitting the key on PATCH preserves the existing value. For roll-up measures (`data_source_type=3`): `roll_up_type` must be `"sum"` or `"average"` (422); `roll_up_measure_ids` must all belong to the same team (422 cross-team); a measure may not include itself in `roll_up_measure_ids` (422 self-reference); circular references (A→B→A) return 422.

## Strategy & Targets

### Strategy Tree (read-only, all frameworks)

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/targets` | Get team strategy tree (params: year?, quarter? — default current; use `"All"` or `0` for all) | "show strategy", "strategy tree", "goals and rocks", "team objectives", "OKRs", "V2MOM", "show rocks", "annual goals", "quarterly priorities", "show targets" | `/components?tab=traction` |

TargetResponse: `{ "data": { "framework": string, "targets": TargetNode[], "unaligned": TargetNode[] } }`

TargetNode fields: `id`, `name` (string | null), `description` (string | null), `status` (active | complete | archived | deferred | review | draft | cancelled | at_risk | off_track), `object_type` (yearly_goal | rock | focus_area | objective | key_result | milestone | action), `type` (integer for Goals: 0=objective/WIG, 1=rock, 2=yearly; string for Items: KeyResult, ResultArea), `color` (string | null), `assignees` (TargetAssignee[]), `creator` (TargetAssignee | null), `due` (YYYY-MM-DD | null), `children` (TargetNode[]), `inherited` (boolean), `inherited_from` ({ team_id, team_name } | null), `can_edit` (boolean — server-computed edit permission for the current user reflecting cascade rules: rocks include parent-goal cascade, milestones include parent-rock cascade; always present on every node at every depth; inherited nodes always `false`).

TargetAssignee fields: `id`, `first_name` (string | null), `last_name` (string | null).

**Supported frameworks**: EOS, OKR, 4DX. SRT and V2MOM are **not yet supported** (returns 400 error).

**GET filtering rules**: EOS: yearly goals by `year`, rocks by `quarter` (persistent active rocks always included, realized persistent excluded). OKR: focus areas included if they have qualifying children, objectives "pulled up" if any child key result is in range. 4DX: same as OKR for L1-L3, actions filtered by year/quarter.

**Inherited nodes**: Nodes with `inherited: true` come from a parent team and are read-only. `inherited_from` contains the source `team_id` and `team_name`.

### Goals — Yearly

**EOS restriction**: POST endpoints return `422 Unprocessable Entity` with message "This endpoint is only available for EOS teams" when called against a non-EOS team. **GET is available for all team types** (EOS restriction removed as of 2026-04-16).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/goals` | List yearly goals (params: year?) — available for all team types | "list goals", "show yearly goals", "annual goals", "1-year goals" | `/components?tab=traction` |
| POST | `/teams/{id}/goals` | Create a yearly goal (body: name*, achieve_by?, assignee_ids?) — EOS teams only | "create goal", "add yearly goal", "new annual goal" | `/components?tab=traction` |
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
| GET | `/teams/{id}/rocks` | List quarterly rocks (params: year?, quarter?, parent_id?). Each rock includes `aligned_measurables` array (may be empty). | "list rocks", "show rocks", "quarterly rocks", "90-day priorities" | `/components?tab=traction` |
| POST | `/teams/{id}/rocks` | Create a rock (body: name*, parent_id?, assignee_ids?). **Permissions**: team admin, OR any member who can edit the parent 1-yr goal (when `parent_id` is set). No `parent_id` → admin-only. | "create rock", "add rock", "new quarterly rock" | `/components?tab=traction` |
| PUT | `/rocks/{id}` | Align rock to a yearly goal (body: parent_id*). **Permissions**: creator, assignee, team admin, or member who can edit the parent 1-yr goal. | "align rock to goal", "link rock", "move rock under goal" | — |
| PATCH | `/rocks/{id}` | Update a rock (body: name?, description?, status?, assignee_ids?). **Permissions**: creator, assignee, team admin, or member who can edit the parent 1-yr goal. | "update rock", "rename rock", "mark rock complete", "change rock status" | — |
| DELETE | `/rocks/{id}` | Archive a rock. **Permissions**: creator, assignee, team admin, or member who can edit the parent 1-yr goal. | "archive rock", "delete rock", "remove rock" | — |
| GET | `/rocks/{id}/alignments` | List scorecard measurables aligned to a rock, ordered by position | "rock alignments", "rock measurables", "linked measurables for rock" | — |
| POST | `/rocks/{id}/alignments` | Link a rock to a scorecard measurable (body: measurable_id*). Returns 409 if already linked, 422 if measurable archived | "link rock to measurable", "align rock to scorecard", "connect rock to measurable" | — |
| DELETE | `/rocks/{id}/alignments/{alignment_id}` | Remove a rock–measurable alignment. Returns 204 No Content. Requires edit access to the rock. | "remove rock alignment", "unlink rock from measurable", "detach rock measurable" | — |

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

**Rock list includes `aligned_measurables`** on every rock (added 2026-04-24):
```json
"aligned_measurables": [
  {
    "alignment_id": 7,
    "measurable_id": 42,
    "name": "Monthly Recurring Revenue",
    "current_value": "85000",
    "target_value": "100000",
    "unit_measure_id": 3
  }
]
```
Field is always present (empty array `[]` when no alignments exist). Applies to `GET /teams/{id}/rocks` and `GET /users/{id}/rocks`.

**Rock alignment response shape** (POST /rocks/{id}/alignments → 201):
```json
{
  "id": 7,
  "rock_id": 5,
  "measure_id": 42,
  "position": 1,
  "measurable": {
    "id": 42,
    "name": "Monthly Recurring Revenue",
    "current_value": "85000",
    "target_value": "100000",
    "unit_measure_id": 3
  },
  "created_at": "2026-04-23T12:00:00.000Z",
  "updated_at": "2026-04-23T12:00:00.000Z"
}
```

**Response envelopes**:
- `GET /teams/{id}/rocks` → `{ "data": [Rock], "meta": { page, per_page, total, total_pages } }` (200)
- `POST /teams/{id}/rocks` → `{ "data": Rock }` (201)
- `PUT /rocks/{id}` → `{ "data": Rock }` (200)
- `PATCH /rocks/{id}` → `{ "data": Rock }` (200)
- `DELETE /rocks/{id}` → `{ "data": Rock }` (200, status: "archived")
- `GET /rocks/{id}/alignments` → array of alignment records (200)
- `POST /rocks/{id}/alignments` → alignment record (201); 409 already linked; 422 archived measurable
- `DELETE /rocks/{id}/alignments/{alignment_id}` → 204 No Content

### Milestones (EOS only)

All milestone endpoints return `422 Unprocessable Entity` for non-EOS teams.

**Known bug**: `GET /teams/{id}/milestones?year=&quarter=` returns incorrect results. Use `?parent_id=ROCK_ID` instead for accurate filtering.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/milestones` | List milestones (params: parent_id? — **recommended**; year?, quarter? — **avoid, known bug**) | "list milestones", "show milestones", "deliverables" | `/components?tab=traction` |
| POST | `/teams/{id}/milestones` | Create a milestone (body: name*, parent_id?, due?). **Permissions**: team admin, OR any member who can edit the parent rock (when `parent_id` is set). No `parent_id` → admin-only. | "create milestone", "add milestone", "new deliverable" | `/components?tab=traction` |
| PUT | `/milestones/{id}` | Align milestone to a rock (body: parent_id*). **Permissions**: creator, assignee, team admin, or member who can edit the parent rock. | "align milestone to rock", "link milestone", "move milestone under rock" | — |
| PATCH | `/milestones/{id}` | Update a milestone (body: name?, description?, status?, due?). **Permissions**: creator, assignee, team admin, or member who can edit the parent rock. | "update milestone", "rename milestone", "mark milestone complete" | — |
| DELETE | `/milestones/{id}` | Archive a milestone. **Permissions**: creator, assignee, team admin, or member who can edit the parent rock. | "archive milestone", "delete milestone", "remove milestone" | — |
| POST | `/milestones/{id}/reorder` | Reorder a milestone within its parent rock (body: position*). **Permissions**: keyed off the **parent rock** — requires ability to edit the rock (not just the milestone). 403 if caller cannot edit the parent rock. | "reorder milestone", "move milestone", "change milestone order" | — |

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

### Team Vision (cross-framework)

Universal vision endpoint that returns framework-appropriate vision data for any team. Use this instead of `/eos-vision` when the team's framework is unknown or when building framework-agnostic views (e.g. TBR report).

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/vision` | Get framework-appropriate vision data (works for EOS, OKR, 4DX, and others). Response: `{ data: { framework, framework_supported, vision, mission, core_values, eos_vision } }`. `framework_supported` is `true` for EOS/OKR/4DX, `false` for V2MOM/SRT/Pinnacle/unknown. `vision`/`mission`/`core_values` present when supported. `eos_vision` non-null for EOS only (full V/TO composite). `core_values` ordered by position. Errors: 400 non-numeric ID, 403 not a team member, 404 team not found. | "team vision", "show vision", "vision and mission", "core values", "strategic direction", "what's our vision", "team mission" | — |
| PATCH | `/teams/{id}/vision` | Create or update vision and mission (merge semantics — omitted fields unchanged). Body: `{ vision?: { purpose?, description? }, mission?: { name?, description? } }` — at least one of `vision` or `mission` required. Response: `{ success: true, data: { vision: { id, purpose, description }, mission: { id, name, description } } }`. Creates records if absent; all strings HTML-sanitized. Errors: 400 empty body/empty sub-object, 403 not team admin or team inherits parent vision, 404 team not found. | "update vision", "set mission", "save vision", "write vision", "update mission", "set our vision", "edit vision description", "update vision purpose" | — |
| GET | `/teams/{id}/vision-builder/answers` | Retrieve saved Vision Builder questionnaire answers. Response: `{ success: true, data: { answers: { prompt_key: "answer", ... } } }`. Returns `answers: null` when no answers saved yet. Auth: team member. | "get vision builder answers", "vision questionnaire answers", "saved vision answers", "vision builder progress" | — |
| PUT | `/teams/{id}/vision-builder/answers` | Save Vision Builder questionnaire answers (full replacement — previous blob is completely replaced). Body: `{ answers: { prompt_key: "answer", ... } }` — `answers` required, must be an object; use `{}` to clear all. Response: `{ success: true, data: { answers: { ... } } }`. All strings HTML-sanitized. Auth: team admin. Errors: 400 missing/non-object answers, 403 not admin or parent vision block. | "save vision builder answers", "store vision answers", "update vision questionnaire", "save vision builder progress", "clear vision answers" | — |

**Framework behaviour**:

| Framework | `framework_supported` | `vision` | `mission` | `core_values` | `eos_vision` |
|-----------|----------------------|----------|-----------|---------------|--------------| 
| `eos` | `true` | from DB | from DB | from labels | full composite |
| `okr` | `true` | from DB | from DB | from labels | `null` |
| `4dx` | `true` | from DB | from DB | from labels | `null` |
| `v2mom` / `srt` / other | `false` | `null` | `null` | `[]` | `null` |

### EOS Vision (V/TO)

The Vision/Traction Organizer (V/TO) covers six EOS components: core values, core focus (purpose/niche), BHAG (10-year target), marketing strategy, three-year picture, and year/quarter plans.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/eos-vision` | Get complete V/TO (all 6 sections in one call) | "show vision", "show V/TO", "vision traction organizer", "EOS vision", "show the VTO" | `/vision` |
| GET | `/teams/{id}/core-values` | List core values | "show core values", "list core values", "our values" | `/vision` |
| POST | `/teams/{id}/core-values` | Create core value (body: name*, description?) | "add core value", "create core value", "new value" | `/vision` |
| PATCH | `/core-values/{valueId}` | Update core value (body: name?, description?) — standalone, no team prefix | "update core value", "edit value", "rename value" | — |
| DELETE | `/core-values/{valueId}` | Delete core value — standalone, no team prefix | "delete core value", "remove value" | — |
| GET | `/teams/{id}/eos-core-focus` | Get core focus (purpose + niche) | "show core focus", "what's our purpose", "our niche" | `/vision` |
| PATCH | `/teams/{id}/eos-core-focus` | Update core focus (body: purpose?, niche?) | "update core focus", "set purpose", "change niche" | `/vision` |
| GET | `/teams/{id}/eos-bhag` | Get BHAG (10-year target) | "show BHAG", "10-year target", "big hairy audacious goal" | `/vision` |
| PATCH | `/teams/{id}/eos-bhag` | Update BHAG (body: text*) | "update BHAG", "set 10-year target", "change BHAG" | `/vision` |
| GET | `/teams/{id}/eos-marketing-strategy` | Get marketing strategy | "show marketing strategy", "target market", "our uniques", "proven process", "guarantee" | `/vision` |
| PATCH | `/teams/{id}/eos-marketing-strategy` | Update marketing strategy (body: targetMarket?, uniques?, provenProcess?, guarantee?) | "update marketing strategy", "set target market", "change uniques" | `/vision` |
| GET | `/teams/{id}/eos-three-year-picture` | Get three-year picture | "show three-year picture", "3-year picture", "where we'll be in 3 years" | `/vision` |
| PATCH | `/teams/{id}/eos-three-year-picture` | Update three-year picture (body: description?, futureDate?, revenue?, profit?, measurables?) | "update three-year picture", "set 3-year picture" | `/vision` |
| GET | `/teams/{id}/eos-plans` | Get all year/quarter plans | "show plans", "annual plan", "quarterly plan", "year plans" | `/team-rhythm-quarterly` |
| GET | `/teams/{id}/eos-plans/{year}` | Get plans for a specific year | "show 2026 plans", "plans for this year" | `/team-rhythm-quarterly` |
| GET | `/teams/{id}/eos-plans/{year}/{quarter}` | Get specific quarter plan (quarter: 0=annual, 1-4=Q1-Q4) | "show Q1 plan", "annual plan for 2026" | `/team-rhythm-quarterly` |
| PATCH | `/teams/{id}/eos-plans/{year}/{quarter}` | Update year/quarter plan (body: text, date, revenue, profit, measures — all string or null) | "update Q1 plan", "set annual plan", "change quarterly plan" | `/team-rhythm-quarterly` |

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

## EOS Tools Checklist

Tracks which EOS practice tools a team has adopted. State is stored as a JSON blob keyed by tool slug. Only available for EOS-framework teams.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/teams/{id}/eos-tools-checklist` | Get saved EOS Tools checklist state | "show EOS tools checklist", "which EOS tools do we use", "EOS tools adoption", "show tools checklist" | — |
| PATCH | `/teams/{id}/eos-tools-checklist` | Partial update — merge tool states (body: `tools*` — object of slug→boolean) | "update EOS tools checklist", "toggle EOS tool", "mark EOS tool adopted", "check off EOS tool" | — |

**Request body (PATCH)**:
```json
{ "tools": { "the-eos-model": true, "the-five-leadership-abilities": false } }
```

**Response shape (GET 200 / PATCH 200)**:
```json
{ "data": { "tools": { "the-eos-model": true, "the-five-leadership-abilities": false } } }
```

**Behavior notes**:
- **GET 404 = no checklist saved yet** — treat as all tools unchecked. Do not show an error; render a blank checklist.
- **PATCH is a partial merge** — only supplied keys are updated; unspecified keys retain their existing values.
- **Boolean values only** — all values in `tools` must be booleans. Non-boolean values yield 422.
- **EOS teams only** — both endpoints return 403 if the team's `team_management_framework` is not `'EOS'`.
- **Auth**: GET requires team Member; PATCH requires team Admin.
- **Unknown keys are silently ignored** by the API (not stored).

## Quarterly Review

Per-team HTML blob storage for quarterly review summaries. Data is persisted in `object_metas` keyed by team, year, and quarter. Writes are admin-only; reads require team membership.

| Method | Path | Description | User Phrases | Auth |
|--------|------|-------------|--------------|------|
| GET | `/api/v2/teams/{id}/quarterly-review` | Fetch saved quarterly review blobs (params: `year`*, `quarter`* 1–4). Returns 404 if no data saved yet for this period. | "show quarterly review", "get quarterly review", "quarterly review data", "what's in our quarterly review" | Team member |
| PATCH | `/api/v2/teams/{id}/quarterly-review` | Partially update quarterly review fields (params: `year`*, `quarter`* 1–4; body: `wins`?, `went_well`?, `focus`?). Creates record if none exists. | "save quarterly review", "update quarterly review", "set quarterly wins", "update went well", "update focus" | Team admin |
| GET | `/api/v2/teams/{id}/quarterly-review/linked-urls` | List file/URL attachments for a quarterly review (params: `year`*, `quarter`* 1–4). Auto-creates the review record if none exists. Returns `{ linked_urls: [...] }`. | "quarterly review attachments", "quarterly review links", "quarterly review files", "list quarterly review urls" | Team member |
| POST | `/api/v2/teams/{id}/quarterly-review/linked-urls` | Add a URL attachment to a quarterly review (params: `year`*, `quarter`* 1–4; body: `url`*, `name`?). Returns 201 with `{ linked_url: { id, url, name, created_at } }`. | "attach url to quarterly review", "add link to quarterly review", "upload quarterly review file", "add quarterly review attachment" | Team admin |
| DELETE | `/api/v2/teams/{id}/quarterly-review/linked-urls/{url_id}` | Remove a URL attachment from a quarterly review (params: `year`*, `quarter`* 1–4). Returns 204 No Content. Returns 404 if url_id doesn't belong to the requested review. | "remove quarterly review attachment", "delete quarterly review link", "remove attachment from quarterly review" | Team admin |

**Request body (PATCH)** — all fields optional; omit to preserve, send `""` to clear:
```json
{ "wins": "<p>...</p>", "went_well": "<p>...</p>", "focus": "<p>...</p>" }
```

**Response shape** (both endpoints):
```json
{ "data": { "id": 42, "year": 2026, "quarter": 1, "wins": "", "went_well": "", "focus": "" } }
```

Response fields: `id` (team ID), `year`, `quarter`, `wins`, `went_well`, `focus` (all sanitized HTML strings; empty string if never set).

**Linked-URL response shape** (GET returns array, POST returns single object):
```json
{
  "linked_urls": [
    { "id": 301, "url": "https://docs.google.com/...", "name": "Q2 Review Notes", "created_at": "2026-04-10T14:22:00.000Z" }
  ]
}
```

**Behavior notes**:
- **404 on GET**: No data saved yet — treat as empty editor, not an error.
- **Partial PATCH**: Only provided fields are updated; omitted fields retain existing values.
- **HTML sanitization**: All fields sanitized server-side on write.
- **50 KB per field**: Each of `wins`, `went_well`, `focus` capped at 51,200 bytes (400 if exceeded).
- **Admin gate**: PATCH requires `isTeamAdmin`; GET requires `canViewGroup`. Non-members/non-admins receive 403.
- **Missing/invalid params**: Both endpoints return 400 if `year` or `quarter` is missing, non-integer, or `quarter` is outside 1–4.
- **Linked-URL scoping**: Attachments are scoped to the specific quarterly review (team + year + quarter). Not the same as L10 meeting linked URLs. GET auto-creates the review record if missing.
- **Linked-URL DELETE 404**: Returned if `url_id` doesn't belong to the requested quarterly review (cross-review deletion prevented).

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

## Custom Labels

Labels that can be attached to Items and Goals. Labels support three scopes: **personal** (user-owned), **team** (shared across team members), and **project** (shared within a project). All endpoints require Bearer / Token auth.

### Custom Label Endpoints

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/custom-labels` | List accessible custom labels including ancestor-team inherited labels (params: page, per_page, scope, team_id, project_id — omit scope for union of all accessible); each label includes `inherited` (bool) and `source_team_id` (int\|null) fields. **Access control**: `scope=team&team_id=N` returns 403 unless caller can view team N or an ancestor team; `scope=project&project_id=N` returns 404 if project doesn't exist or 403 if caller can't view it. | "list my labels", "show custom labels", "my tags", "my labels", "team labels", "project labels" |
| POST | `/api/v2/custom-labels` | Create a custom label (body: name*, color?, scope?, scope_id? — scope defaults to personal; team/project scope requires admin) | "create label", "add label", "new label", "create tag" |
| PATCH | `/api/v2/custom-labels/{id}` | Update label name and/or color — scope-aware auth (admin required for team/project labels); returns 403 if caller is a descendant-team admin but not admin of the label's owning team (body: name?, color?) | "rename label", "update label", "change label color" |
| DELETE | `/api/v2/custom-labels/{id}` | Delete label — scope-aware auth; returns 422 `reserved_label` for reserved labels; returns 403 if caller is a descendant-team admin but not admin of the label's owning team | "delete label", "remove label", "delete tag" |
| POST | `/api/v2/custom-labels/manage` | Bulk sync labels on an Item or Goal — accepts label IDs from ancestor teams (body: labeled_type*, labeled_id*, custom_label_ids* — array of label IDs) | "set labels on item", "tag item", "apply labels", "sync labels", "label this item", "attach labels" |
| GET | `/api/v2/custom-labels/content` | Get attached + creator labels for an Item or Goal — includes ancestor-team labels; each label has `inherited` and `source_team_id` fields (params: labeled_type*, labeled_id*) | "labels on this item", "show item labels", "label picker", "which labels are attached" |

**BREAKING CHANGE**: `POST /api/v2/custom-labels/manage` body field changed from `custom_labels: string[]` (names) to `custom_label_ids: number[]` (IDs). Sending old `custom_labels` field returns 422 with migration guidance.

### Team Admin Endpoints

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/teams/{id}/admins` | List team admins | "list team admins", "who are team admins" |
| POST | `/api/v2/teams/{id}/admins` | Grant team admin (body: user_id*) | "make team admin", "grant team admin" |
| DELETE | `/api/v2/teams/{id}/admins/{user_id}` | Revoke team admin | "remove team admin", "revoke team admin" |

### Project Admin Endpoints

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/projects/{id}/admins` | List project admins | "list project admins", "who are project admins" |
| POST | `/api/v2/projects/{id}/admins` | Grant project admin (body: user_id*) | "make project admin", "grant project admin" |
| DELETE | `/api/v2/projects/{id}/admins/{user_id}` | Revoke project admin | "remove project admin", "revoke project admin" |

### Project Permissions Endpoints

Manage individual role grants on a project. Requires **edit permission** on the project. Valid roles: `viewer`, `editor`, `author`, `contributor`.

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/projects/{id}/permissions` | List all individual role grants on a project. Response: `{ data: [{ id, role, user_id, user: { id, login, first_name, last_name } }] }`. Errors: 400 (non-numeric id), 401, 403, 404. | "list project permissions", "who has access to project", "project roles", "project access" |
| POST | `/api/v2/projects/{id}/permissions` | Grant a role to a user on a project (body: role*, user_id*). Returns 201 (empty body). Errors: 400 (missing field), 401, 403, 404, 422 (invalid role, duplicate grant, non-existent user_id). | "grant project access", "give user project role", "add project permission", "share project with user" |
| DELETE | `/api/v2/projects/{id}/permissions` | Revoke a role from a user (body: role*, user_id*); omit `role` to revoke all roles for that user. Returns 204 (idempotent — no-op if grant absent). Errors: 400 (missing user_id), 401, 403, 404. | "revoke project access", "remove user from project", "remove project permission", "remove all project roles for user" |

Custom Label object fields: `id`, `name`, `color` (hex string or null), `scope` (personal/team/project), `scope_id` (null for personal), `template_code` (null for user-created), `group_id`, `item_id`, `is_inverted`.

Admin object fields: `user_id`, `login`, `email`, `role`, `is_owner`.

- **Color**: hex string (`#fff` or `#ff00aa`) or null. Optional on create/update.
- **Name**: required, max 255 chars, trimmed. Duplicate name per user returns `422 { name: ["already exists"] }`.
- **Cascade delete**: `DELETE` removes all `custom_labelings` associations first, then the label.
- **Scope-aware auth**: Personal labels — owner only. Team/project labels — team/project admin required for PATCH/DELETE.
- **`/manage` semantics**: Diff-based sync by ID — adds missing associations, removes stale. Sending `[]` clears all. `labeled_type` must be `"Item"` or `"Goal"` (other values → `422`). User must have view access to the target.
- **`/content` response**: `{ data: { attached_labels: [...], creator_labels: [...] } }`. Returns scope metadata (`scope`, `scope_id`) on each label. Multi-scope visibility.
- **Item response**: `GET /api/v2/items/{id}` now includes `custom_labels` array with scope-aware visibility. All item responses now emit **both** `tags` (deprecated) and `custom_labels` with identical content and order. Prefer `custom_labels` — `tags` will be removed in a future phase. `tags` removal will not happen until all consumers confirm migration.

## Pages

Team-scoped hierarchical document pages. Pages form a tree via `parent_id`; the list endpoint returns a **flat array** — build the tree client-side. All endpoints require Bearer / Token auth and team membership.

| Method | Path | Auth | Description | User Phrases |
|--------|------|------|-------------|--------------|
| GET | `/api/v2/teams/{team_id}/pages` | Bearer / Token | List all pages for a team (flat list) | "list pages", "show team pages", "team wiki", "team docs", "team notes" |
| POST | `/api/v2/teams/{team_id}/pages` | Bearer / Token | Create a page (team admin only) | "create page", "add page", "new page", "new doc", "new wiki page" |
| GET | `/api/v2/teams/{team_id}/pages/{page_id}` | Bearer / Token | Get a single page | "show page", "get page", "view page", "open page" |
| PATCH | `/api/v2/teams/{team_id}/pages/{page_id}` | Bearer / Token | Update a page (title, body, parent_id, position) | "edit page", "update page", "rename page", "move page", "reorder page" |
| DELETE | `/api/v2/teams/{team_id}/pages/{page_id}` | Bearer / Token | Delete page + all descendants (author or team admin) | "delete page", "remove page", "archive page" |
| GET | `/api/v2/pages/{page_id}/permissions` | Bearer / Token | List page role assignments (author only) | "list page permissions", "who can edit page", "page roles" |
| POST | `/api/v2/pages/{page_id}/permissions` | Bearer / Token | Grant role to user on page (author only) | "grant page access", "add page editor", "share page", "give page permission" |
| DELETE | `/api/v2/pages/{page_id}/permissions` | Bearer / Token | Revoke role from user on page (author only) | "revoke page access", "remove page editor", "remove page permission" |

**Page object shape**:
```json
{
  "id": 1,
  "title": "Getting Started",
  "body": "<p>HTML content, sanitized server-side</p>",
  "parent_id": null,
  "position": 0,
  "team_id": 10,
  "user_id": 42,
  "can_edit": true,
  "can_delete": false,
  "created_at": "2026-04-18T12:00:00.000Z",
  "updated_at": "2026-04-18T12:00:00.000Z"
}
```

**Page permission object shape**:
```json
{
  "id": 101,
  "role": "editor",
  "user_id": 55,
  "user": { "id": 55, "login": "jsmith", "first_name": "Jane", "last_name": "Smith" }
}
```

**Permission model**:
- **View** (`GET`): any team member
- **Create** (`POST`): team admin only; creator automatically receives `author` role on the new page
- **Edit** (`PATCH`): team admin OR user with `author`, `editor`, or `contributor` role on the page
- **Delete** (`DELETE`): team admin OR user with `author` role (cascades to all descendants)
- **Manage permissions** (`/permissions`): `author` role on the page only

Role hierarchy on pages: `author` > `editor` > `contributor` > `viewer`

**Create request** (body: `title`*, `body`, `parent_id`):
```json
{ "title": "Onboarding", "body": "<p>Welcome!</p>", "parent_id": null }
```
Response: `201` with `{ "data": { ...page } }`.

**Update request** — all fields optional; send `parent_id` to move, `position` to reorder among siblings:
```json
{ "title": "New Title", "body": "<p>...</p>", "parent_id": 3, "position": 1 }
```
Cycle detection prevents moving a page to one of its own descendants (returns `400`).

**Grant permission request** (body: `role`*, `user_id`*):
```json
{ "role": "editor", "user_id": 55 }
```

**Revoke permission request** (body: `user_id`*):
```json
{ "user_id": 55 }
```

**Error codes**:
| Status | Condition |
|--------|-----------|
| `400` | Missing/empty title, title > 255 chars, body > 100KB, parent_id from different team, cycle detected, invalid role |
| `401` | Missing or invalid token |
| `403` | Insufficient permission (not admin, not author/editor, etc.) |
| `404` | Team or page not found |

Use `can_edit` / `can_delete` flags on each page object to gate write suggestions. The list endpoint returns a flat array — build the tree client-side from `parent_id`. Position is 0-based ordering among siblings, auto-maintained on create/move/delete.

## Framework Articles

Proxy endpoint that returns Cmd+K command palette help articles sourced from MasteryMaps, scoped to a management framework. The server fetches upstream, transforms, and caches for 1 hour — clients always receive a clean `{ "data": [] }` on any failure (never a 5xx). Authenticated users only.

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/framework-articles?framework=<value>` | Fetch Cmd+K help articles for a framework (`eos`, `okr`, `4dx`; case-insensitive). Unknown or missing framework → `200 { "data": [] }`. OKR and 4DX map to the same upstream chapter. Any upstream failure (timeout, non-200, bad JSON) also returns empty array with 200. | "framework articles", "help articles", "get help for framework", "Cmd+K articles", "framework shortcuts" |

FrameworkArticle fields: `type` (always `"command"`), `title` (string), `description` (string), `key` (string | null), `isAlt` (boolean), `isShift` (boolean), `isCtrl` (boolean), `isMeta` (boolean), `onclick` (string | null).

- **Auth**: `requireAuth` — unauthenticated requests return 401.
- **Caching**: 1 hour per chapter via Next.js Data Cache. Cache hits complete in well under 300 ms.
- **Scope**: UI-helper endpoint for the Cmd+K palette; content is the same for all users (no per-team filtering).

## Project Templates

Reusable project blueprints created from existing items. Templates are backed by archived items and can be shared across teams, launched as new projects, or applied to existing items.

Template object fields: `id`, `name`, `description` (string | null), `template_type` (string — e.g. `"project_or_process"`), `templateable_id` (integer — backing item ID), `templateable_type` (string — e.g. `"Item"`), `shared_with_teams` ([{ id, name }]), `default_view` (`"show"` | `"board"` | `"outline"` | `"roadmap"` | null), `can_edit` (boolean), `can_delete` (boolean), `created_at`, `updated_at`.

| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/api/v2/templates` | List templates visible to the user (params: `page?`, `per_page?` (default 100, max 100), `team_id?` for optional filter). Returns paginated list with `meta.page`, `meta.per_page`, `meta.total`, `meta.total_pages`. | "list templates", "show templates", "browse templates", "available templates", "project templates" |
| POST | `/api/v2/templates` | Create template from an existing item (body: `name`*, `source_item_id`*, `description?`, `include_attachments?` (bool), `keep_alignments?` (bool)). Requires edit access on source item. Returns 201 with template object. | "create template", "save as template", "make template from project", "turn project into template" |
| GET | `/api/v2/templates/{id}` | Get template detail. Includes `backing_item` ({ id, name, type, descendant_count }) and `can_edit`/`can_delete` flags. | "get template", "show template detail", "view template" |
| PATCH | `/api/v2/templates/{id}` | Update template name and/or description (body: `name?`, `description?`). Requires edit access. Returns full template object. | "rename template", "update template", "edit template description" |
| DELETE | `/api/v2/templates/{id}` | Delete template and its backing item tree. Requires team admin or account admin. Returns 204. | "delete template", "remove template" |
| POST | `/api/v2/templates/{id}/launch` | Launch template as a new active project (body: `name`*, `due?`, `assignee_id?`, `parent_id?`, `group_id?`). Returns 201 with new item (`id`, `name`, `type`, `status`, `due`, `group_id`, `parent_id`, `descendant_count`, `created_at`). | "launch template", "use template", "create project from template", "start project from template", "apply template as new project" |
| POST | `/api/v2/templates/{id}/apply` | Apply template's child items to an existing item (body: `target_item_id`*, `assign_to_object_assignees?` (bool)). Inserts template descendants under the target without creating a root item. Returns 201 with `{ target_item_id, items_created, items: [{id, name, parent_id}] }`. | "apply template", "add template to project", "inject template checklist", "apply template items" |
| POST | `/api/v2/templates/{id}/share` | Share template with a team (body: `team_id`*). Returns updated `shared_with_teams` list. | "share template", "share template with team", "add team to template" |
| DELETE | `/api/v2/templates/{id}/share` | Remove team from template sharing (body: `team_id`*). Returns updated `shared_with_teams` list. | "unshare template", "remove team from template", "stop sharing template" |
| PATCH | `/api/v2/templates/{id}/default-view` | Set default launch view (body: `default_view`* — one of: `"show"`, `"board"`, `"outline"`, `"roadmap"`). Returns `{ data: { id, default_view } }`. | "set template view", "default view for template", "set template default" |

**Response envelopes**:
- `GET /api/v2/templates` → `{ "data": Template[], "meta": { "page": int, "per_page": int, "total": int, "total_pages": int } }`
- `POST /api/v2/templates` → `{ "data": Template }` (201)
- `GET /api/v2/templates/{id}` → `{ "data": Template }` (includes `backing_item`)
- `PATCH /api/v2/templates/{id}` → `{ "data": Template }` (200)
- `DELETE /api/v2/templates/{id}` → 204 No Content
- `POST /api/v2/templates/{id}/launch` → `{ "data": { id, name, type, status, due, group_id, parent_id, descendant_count, created_at } }` (201)
- `POST /api/v2/templates/{id}/apply` → `{ "data": { target_item_id, items_created, items: [{id, name, parent_id}] } }` (201)
- `POST /api/v2/templates/{id}/share` / `DELETE /api/v2/templates/{id}/share` → `{ "data": { id, shared_with_teams } }` (200)
- `PATCH /api/v2/templates/{id}/default-view` → `{ "data": { id, default_view } }` (200)

**Validation**: `name` required, max 255 chars (422). `source_item_id` must be viewable and editable (403/404). `default_view` must be one of the four valid values (422). Template delete requires team admin or account admin (403). Launch/apply require view access to template and edit access to parent/target (403).

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
| meeting, weekly meeting, weekly sync, L10, team meeting | Team Weekly Board (L10) | `/teams/{id}/items` |
| 1:1, 1x1, one-on-one | One-on-One | `/1-on-1` |
| project meeting | (separate skill — out of scope) | — |
| day plan, daily plan, prioritizer, tasks for today, my plan | Day Plan | `/day-plans/today`, `/day-plans/{date}` |
| check-in, 90-second practice, result feed, daily report | Result Feed (daily check-in report) | `/result-feed/today`, `/result-feed/{date}` |
| team check-ins, team feed, team result feed | Team Result Feeds (shared check-ins) | `/teams/{id}/result-feed` |
| teammate's check-in, user's report, team member report | Team Result Feed Detail (single user's report) | `/teams/{id}/result-feed/{date}/{user_id}` |
| high-five, react, kudos, toggle reaction | Result Feed Reaction (toggle) | `POST /result-feed/{date}/reactions` |
| show reactions, reaction count, did I react, high-five count | Result Feed Reaction (read) | `GET /result-feed/{date}/reactions` |
| comments on check-in, check-in comments | Result Feed Comments | `/result-feed/{date}/comments` |
| share to slack, push to slack | Push Result Feed to Slack | `/result-feed/{date}/push-to-slack` |
| share to discord, push to discord | Push Result Feed to Discord | `/result-feed/{date}/push-to-discord` |
| section notes, done notes, add notes, review notes | Result Feed Section Metadata | `PUT /result-feed/{date}/{section}` |
| upload file to check-in, attach file, upload attachment | Result Feed File Upload | `POST /result-feed/{date}/attachments` |
| set group context, switch team context | Group Context (active team for sharing) | `/users/me/group-context` |
| weekly, team weekly, weekly board, Level 10, L10 (EOS) | Team Items (weekly board; called "Level 10" for EOS teams) | `/teams/{id}/items` |
| issue, blocker, blocked item, challenge | Item with status=blocked | `/teams/{id}/items/blocked` |
| next, to-do (column), priority for the week | Item with status=next | `/teams/{id}/items/next` |
| parked, parking lot, park for later | Item with status=parked | `/teams/{id}/items/parked` |
| done, completed, finished | Item with status=done | `/teams/{id}/items/done` |
| L10 to-do, weekly to-do | Item with status=next (EOS alias) | `/teams/{id}/l10/todos` |
| L10 issue, IDS item | Item with status=blocked (EOS alias) | `/teams/{id}/l10/issues` |
| team issues, filter issues, long-term issues, IDS board | Team issues with filter support | `GET /teams/{id}/issues` |
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
| project template, template, blueprint, reusable project | Project Template | `/api/v2/templates` |
| launch template, use template, create from template | Template Launch | `POST /api/v2/templates/{id}/launch` |
| apply template, add template to project, inject template | Template Apply | `POST /api/v2/templates/{id}/apply` |
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
| attach, link to meeting, link item to 1:1 | Attach Item to One-on-One | `POST /1-on-1/{id}/align` (body: `{"alignable_type":"Item","alignable_id":<id>}`) |
| add to plan, add to today, put on my plan | Attach to Day Plan | `PUT /day-plans/today/items/{item_id}` |
| check off, mark done for today, complete for today | Day Plan Completion | `PATCH /day-plans/today/items/{item_id}` |
| reorder today, sort my plan, change order of today, drag to reorder, set item order | Reorder Day Plan | `POST /day-plans/today/set-positions` |
| archive, soft delete, remove item | Archive Item (status→archived) | `DELETE /items/{id}` |
| search, find, look up, search everything, search across teams, full-text search | Search (full-text) | `GET /api/v2/search` |
| my history, recently visited, visit history, recent items, what I visited | Visit History | `GET /api/v2/users/me/history` |
| record visit, track visit, mark visited | Record Visit | `POST /api/v2/users/me/history` |
| onboarding status, onboarding progress, should I show onboarding, is onboarding complete, my onboarding role | Onboarding State | `GET /api/v2/users/me/onboarding-state` |
| skip onboarding, dismiss onboarding banner, hide onboarding, don't show onboarding | Skip Onboarding | `POST /api/v2/users/me/onboarding-state/skip` |
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
| set recurrence, repeat item, recurrence schedule, make daily, repeat weekly, item cadence | Item Recurrence | `GET /items/{id}/recurrence`, `PUT /items/{id}/recurrence` |
| reset password, send password reset, password reset for user | Password Reset (admin) | `POST /passwords/reset` |
| set new password, complete password reset | Password Update (unauthenticated) | `PUT /passwords` |
| change password, update my password, new password, set password | Change Password (authenticated) | `POST /users/me/password` |
| seat, position, role on chart, accountability chart | Seat | `/teams/{id}/seats`, `/seats/{id}` |
| seats for user, user's seats, person's positions, what seats does someone own | User Seats | `GET /users/{id}/seats` |
| org chart, accountability chart, who does what | Team Seats (chart) | `GET /teams/{id}/seats` |
| seat owner, who owns the seat, assigned to seat | Seat Owner | `PATCH /seats/{id}` (seat_owner_id) |
| seat measure, KPI for seat, aligned measure | Seat Measure | `/seats/{id}/measures` |
| seat goal, rock for seat, aligned goal | Seat Goal | `/seats/{id}/goals` |
| seat link, URL on seat, resource link | Seat Link | `/seats/{id}/links` |
| move seat, reparent seat, reorganize chart | Move Seat | `PUT /seats/{id}/move` |
| archive seat, delete seat, remove position | Archive Seat | `DELETE /seats/{id}` |
| restore seat, unarchive seat | Restore Seat | `PUT /seats/{id}/restore` |
| seat roles, accountability roles, LMA roles, seat responsibilities | Seat Roles | `PATCH /seats/{id}` (roles[]) |
| seat level, org level, leadership team, department, individual contributor | Seat Level | `PATCH /seats/{id}` (seat_level) |
| has direct reports, seat with reports, seat builder | Seat Builder | `GET /seats/{id}` (has_direct_reports) |
| seat snapshot, chart snapshot, accountability chart history, save chart, checkpoint | Seat Snapshot | `/teams/{id}/snapshots` |
| revert chart, restore snapshot, undo chart changes, roll back accountability chart | Snapshot Revert | `PUT /teams/{id}/snapshots/{snapshotId}/revert` |
| strategy, strategy tree, goals and rocks, OKRs, annual goals, team objectives, targets, show targets | Strategy Tree | `GET /teams/{id}/targets` |
| team vision, vision and mission, strategic direction, what's our vision, team mission (any framework) | Team Vision (cross-framework) | `GET /teams/{id}/vision` |
| update vision, set mission, save vision, edit vision, write vision, update mission, edit vision purpose, set vision description | Update Vision/Mission | `PATCH /teams/{id}/vision` |
| vision builder answers, vision questionnaire, saved vision answers, vision builder progress | Vision Builder Answers | `GET /teams/{id}/vision-builder/answers`, `PUT /teams/{id}/vision-builder/answers` |
| vision, V/TO, vision traction organizer, EOS vision, show VTO | EOS Vision (composite) | `GET /teams/{id}/eos-vision` |
| core values, our values, company values (EOS V/TO) | EOS Core Values | `GET /teams/{id}/core-values` |
| core focus, purpose, niche, why we exist (EOS V/TO) | EOS Core Focus | `GET /teams/{id}/eos-core-focus` |
| BHAG, 10-year target, big hairy audacious goal (EOS V/TO) | EOS BHAG | `GET /teams/{id}/eos-bhag` |
| marketing strategy, target market, uniques, proven process, guarantee (EOS V/TO) | EOS Marketing Strategy | `GET /teams/{id}/eos-marketing-strategy` |
| three-year picture, 3-year picture, where we'll be (EOS V/TO) | EOS Three-Year Picture | `GET /teams/{id}/eos-three-year-picture` |
| annual plan, quarterly plan, year plan, Q1 plan (EOS V/TO) | EOS Plans | `GET /teams/{id}/eos-plans` |
| EOS tools checklist, which EOS tools, tools adoption, EOS practice tools, tools we use, check off EOS tool, toggle EOS tool | EOS Tools Checklist | `GET /teams/{id}/eos-tools-checklist`, `PATCH /teams/{id}/eos-tools-checklist` |
| yearly goal, annual goal, 1-year goal, create goal, add goal, new goal | Goal (yearly) | `POST /teams/{id}/goals`, `GET /teams/{id}/goals` |
| rock, quarterly rock, 90-day priority, create rock, add rock, new rock | Rock (quarterly) | `POST /teams/{id}/rocks`, `GET /teams/{id}/rocks` |
| milestone, deliverable, create milestone, add milestone, new milestone | Milestone | `POST /teams/{id}/milestones`, `GET /teams/{id}/milestones` |
| update goal, rename goal, change goal status, mark goal complete | Update Goal | `PATCH /goals/{id}` |
| update rock, rename rock, change rock status, mark rock complete | Update Rock | `PATCH /rocks/{id}` |
| update milestone, rename milestone, mark milestone complete | Update Milestone | `PATCH /milestones/{id}` |
| align rock to goal, link rock, move rock under goal | Align Rock | `PUT /rocks/{id}` |
| align milestone to rock, link milestone, move milestone under rock | Align Milestone | `PUT /milestones/{id}` |
| rock measurable alignment, link rock to measurable, aligned measurables for rock, rock KPI link | Rock–Measurable Alignment | `GET /rocks/{id}/alignments`, `POST /rocks/{id}/alignments`, `DELETE /rocks/{id}/alignments/{alignment_id}` |
| detach goal, unlink goal, archive goal, delete goal | Archive/Unlink Goal | `PATCH /goals/{id}` (unlink), `DELETE /goals/{id}` (archive) |
| detach rock, unlink rock, archive rock, remove rock from goal | Archive/Unlink Rock | `PATCH /rocks/{id}` (unlink), `DELETE /rocks/{id}` (archive) |
| detach milestone, unlink milestone, archive milestone, remove milestone | Archive/Unlink Milestone | `PATCH /milestones/{id}` (unlink), `DELETE /milestones/{id}` (archive) |
| label, tag, team label | Team Label | `/teams/{id}/labels` |
| integration, webhook, Slack integration, Discord integration | Team Integration | `/teams/{id}/integrations` |
| team logo, upload logo, remove logo, delete logo | Team Logo | `POST /teams/{id}/logo`, `DELETE /teams/{id}/logo` |
| activity log, team activity, membership changes | Team Activity Log | `GET /teams/{id}/activity-logs` |
| quarterly review, team quarterly review, q1 review, q2 review, wins, went well, focus | Quarterly Review | `GET /teams/{id}/quarterly-review`, `PATCH /teams/{id}/quarterly-review` |
| quarterly review attachments, quarterly review links, quarterly review files, attach url to quarterly review | Quarterly Review Linked URLs | `GET /teams/{id}/quarterly-review/linked-urls`, `POST /teams/{id}/quarterly-review/linked-urls`, `DELETE /teams/{id}/quarterly-review/linked-urls/{url_id}` |
| change role, promote to admin, demote, make admin | Change Member Role | `PATCH /teams/{id}/members/{user_id}` |
| create account, sign up, new account, register, onboard new user | Create Account (Signup) | `POST /accounts` |
| set framework, change framework, select management framework | Set Account Framework | `PUT /accounts/{id}/framework` |
| set leadership team, designate leadership team, change leadership team | Set Leadership Team | `PUT /accounts/{id}/leadership-team` |
| scaffold seats, create default org chart, set up accountability chart, initialize seats | Scaffold Seats | `POST /teams/{id}/seats/scaffold` |
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
| my context, full context, organizational context, load my context, everything about my teams, all my rocks and issues, my orgs and teams, session context | User Context Snapshot | `GET /users/me/context` |
| upcoming tasks, my tasks, tasks this week, timeline tasks, what's due soon, tasks due next week, my upcoming items | Upcoming Tasks | `GET /api/v2/users/me/upcoming-tasks` |
| upcoming day plan actions, what's on my schedule, day/week column view, my future plans, upcoming planned tasks, what have I planned | Upcoming Day Plan Actions | `GET /api/v2/day-plans/upcoming-actions` |
| my inbox, items assigned to me, what teammates asked me to do, delegated items, assigned by others, inbox | My Inbox | `GET /api/v2/users/me/inbox` |
| my outbox, items I delegated, items assigned by me to others, what I asked teammates to do, delegated tasks, outbox, delegated to others | My Outbox | `GET /api/v2/users/me/outbox` |
| reorder outbox, drag outbox item, reposition delegated item, sort outbox | Reorder Outbox | `POST /api/v2/users/me/outbox/reorder` |
| filter outbox by person, show items assigned to person, outbox for user, delegated to person, outbox filtered by assignee | Filter Outbox by Person | `POST /api/v2/users/me/outbox/filter-by-person` |
| custom label, personal label, team label, project label, tag, my label | Custom Label | `GET /api/v2/custom-labels` |
| create label, add label, new label, create tag, create team label, create project label | Create Label | `POST /api/v2/custom-labels` |
| rename label, update label, change label color | Update Label | `PATCH /api/v2/custom-labels/{id}` |
| delete label, remove label, delete tag | Delete Label | `DELETE /api/v2/custom-labels/{id}` |
| set labels on item, tag item, apply labels, sync labels, label this, attach labels, update item labels | Manage Labels on Content | `POST /api/v2/custom-labels/manage` |
| labels on this item, show item labels, label picker, which labels are attached | Labels for Content | `GET /api/v2/custom-labels/content` |
| team admin, who is team admin, list team admins | Team Admin | `GET /api/v2/teams/{id}/admins` |
| make team admin, grant team admin, add team admin | Grant Team Admin | `POST /api/v2/teams/{id}/admins` |
| remove team admin, revoke team admin | Revoke Team Admin | `DELETE /api/v2/teams/{id}/admins/{user_id}` |
| project admin, who is project admin, list project admins | Project Admin | `GET /api/v2/projects/{id}/admins` |
| make project admin, grant project admin, add project admin | Grant Project Admin | `POST /api/v2/projects/{id}/admins` |
| remove project admin, revoke project admin | Revoke Project Admin | `DELETE /api/v2/projects/{id}/admins/{user_id}` |
| project permissions, who has access to project, list project roles, project access | List Project Permissions | `GET /api/v2/projects/{id}/permissions` |
| grant project access, give user project role, add project permission, share project with user | Grant Project Permission | `POST /api/v2/projects/{id}/permissions` |
| revoke project access, remove user from project, remove project permission, remove all project roles | Revoke Project Permission | `DELETE /api/v2/projects/{id}/permissions` |
| page, doc, wiki, team doc, team wiki, team note, team knowledge base | Page | `/teams/{team_id}/pages`, `/teams/{team_id}/pages/{page_id}` |
| list pages, show team pages, team docs, team wiki | List Pages | `GET /teams/{team_id}/pages` |
| create page, new page, new doc, new wiki page | Create Page | `POST /teams/{team_id}/pages` |
| edit page, update page, rename page | Update Page | `PATCH /teams/{team_id}/pages/{page_id}` |
| move page, nest page under, reparent page, reorder page | Move/Reorder Page | `PATCH /teams/{team_id}/pages/{page_id}` (parent_id / position) |
| delete page, remove page | Delete Page | `DELETE /teams/{team_id}/pages/{page_id}` |
| page permissions, who can edit page, page roles, share page | Page Permissions | `/pages/{page_id}/permissions` |
| grant page access, add page editor, share page with | Grant Page Permission | `POST /pages/{page_id}/permissions` |
| revoke page access, remove page editor | Revoke Page Permission | `DELETE /pages/{page_id}/permissions` |

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
| One-on-one meeting | Project meeting | One-on-ones use `/1-on-1` endpoints; persons nested under `persons.person1`/`persons.person2`. Project meetings are out of scope for rkit:1on1 and will get a separate skill. |
| Team projects (`/teams/{id}/projects`) | Standalone projects (`/projects`) | Team projects are scoped to a team. Standalone are user-level. Same underlying data (type=TodoList). |
| `DELETE /teams/{id}/projects/{pid}` | `DELETE /projects/{id}` | Team version removes from team (clears group_id). Standalone version archives the project. |
| Headline (`/teams/{id}/headlines`) | Comment (`/items/{id}/comments`) | Headlines are team-level announcements (EOS only, auto-expire after 7 days). Comments are item-level notes. |
| Draft assessment | Submitted assessment | Draft saves WIP without advancing state. Submit finalizes and transitions review when both parties submit. |
| Review archive (`DELETE /reviews/{id}`) | Review void (`PUT /reviews/{id}/void`) | Archive soft-deletes. Void records a reason and blocks all further lifecycle actions. |
| Core values ratings (standalone) | Core values ratings (in review) | Standalone via `POST /core-values-ratings`. In-review via `core_values_ratings` in AssessmentSubmitRequest. |
