---
name: rkit:today
description: View and manage today's day plan. Interprets what the user says, matches against known intents, and calls the correct API endpoint. Primary "start of day" skill.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:today

A single skill that handles all day plan operations by interpreting user intent against a tool routing table.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`for p in "$HOME/.claude/skills/rkit:today/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"`
- Today: !`date +%Y-%m-%d`

## Rules

- **Interpret first, act second.** Read the user's message. Match it against the Tool Routing Table below. Pick the best match. If ambiguous, ask.
- **Confirm writes.** GET requests execute immediately. POST/PUT/PATCH/DELETE: describe the action and ask for confirmation first.
- **Show IDs.** Always include item IDs in output.
- **Concise output.** Tables and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.

---

## Tool Routing Table

Match the user's message against the **Triggers** column. Pick the first matching row.

| Triggers | Intent | Tool/Flow |
|---|---|---|
| "show my day", "what's on today", "daily plan", "day plan", "what do I have today", "show today", "my plan", "today's items", "what's planned", "show {date}" | View day plan items with completion status | `get_day_plan` |
| "add to today", "create a task", "new item", "add to my plan", "plan this for", "add to tomorrow", "put on my day", "add a to-do", "create to-do" | Create a new item on a day plan | `create_new_item` |
| "attach to today", "put {id} on today", "add item {id}", "attach {id}", "move {id} to today", "add existing", "put {id} on my plan" | Attach an existing item to a day plan by ID | `attach_existing_item` |
| "mark done", "check off", "complete", "finish {id}", "done {id}" | Mark a day plan item as complete | `mark_item_complete` |
| "undo {id}", "uncheck", "mark incomplete", "uncomplete" | Undo a completed day plan item | `mark_item_incomplete` |
| "remove from today", "take off my plan", "remove {id}", "don't need this today", "skip this", "drop from plan", "remove from tomorrow" | Remove an item from a day plan | `remove_from_day_plan` |

---

## Tool/Flow

### get_day_plan

**Trigger**: No args, or a date argument like `2026-02-13`

Determine the date path segment:
- No args → use `today`
- Date argument → use the date string (e.g., `2026-02-13`)

#### Step 1: Fetch plan items

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/day-plans/DATE_SEGMENT/items")
echo "$RESPONSE"
```

Replace `DATE_SEGMENT` with `today` or the `YYYY-MM-DD` date.

#### Step 2: Handle response

Parse the JSON response from api.sh:

**Error responses** (status 0 or non-200):
- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 404` → "No plan found for that date."
- Other non-200 → Show status code and error from response body.

**Success (status 200)**:

Extract `body.data` array (the items) and `body.meta` (pagination info).

- **Empty array**: Display:
  > No items on today's plan. Use `add "task name"` to add one.

- **Items present**: Display as a table:

  ```
  ## Day Plan — {date_label}

  | # | ID | Name | Status | Done |
  |---|---|---|---|---|
  | 1 | 415 | Write proposal | next | |
  | 2 | 412 | Fix login bug | next | yes |

  **{total} items** — {remaining} remaining
  ```

  - `#` = position field
  - `Done` column: "yes" if `completed` is true, blank if false
  - `date_label`: "Today" for today segment, or the formatted date
  - Summary line: count of remaining (not completed) items

---

### mark_item_complete

**Trigger**: `done {id}`, "mark done", "check off", "complete", "finish {id}"

#### Step 1: Confirm

Extract the item ID from args. Display:
> Mark item **{id}** as complete?

Wait for confirmation.

#### Step 2: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" PATCH "/day-plans/DATE_SEGMENT/items/ITEM_ID" '{"completed":true}')
echo "$RESPONSE"
```

#### Step 3: Handle response

- **Status 200**: Display confirmation, then show the updated plan (re-fetch using `get_day_plan`).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules.

---

### mark_item_incomplete

**Trigger**: `undo {id}`, "uncheck", "mark incomplete", "uncomplete"

#### Step 1: Confirm

Extract the item ID from args. Display:
> Mark item **{id}** as incomplete?

Wait for confirmation.

#### Step 2: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" PATCH "/day-plans/DATE_SEGMENT/items/ITEM_ID" '{"completed":false}')
echo "$RESPONSE"
```

#### Step 3: Handle response

- **Status 200**: Display confirmation, then show the updated plan (re-fetch using `get_day_plan`).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules.

---

### create_new_item

**Trigger**: `add "text"` or `add text`, "create a task", "new item", "add to my plan"

#### Step 1: Confirm

Extract the item name from args. Display:
> Create item "**{name}**" on {date_label}'s plan?

Wait for confirmation.

#### Step 2: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" POST "/day-plans/DATE_SEGMENT/items" '{"name":"ITEM_NAME"}')
echo "$RESPONSE"
```

Escape any double quotes in ITEM_NAME.

#### Step 3: Handle response

- **Status 200 or 201**: Show the new item with its ID:
  > Created item **{id}**: "{name}"

  Then show the updated plan (re-fetch using `get_day_plan`).
- **Status 422**: Show validation error from response body.
- **Other errors**: Handle per error handling rules.

---

### attach_existing_item

**Trigger**: `attach {id}`, "put {id} on today", "add item {id}", "move {id} to today"

#### Step 1: Confirm

Extract the item ID from args. Display:
> Attach item **{id}** to {date_label}'s plan?

Wait for confirmation.

#### Step 2: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" PUT "/day-plans/DATE_SEGMENT/items/ITEM_ID")
echo "$RESPONSE"
```

#### Step 3: Handle response

- **Status 200**: Display confirmation:
  > Item **{id}** attached to {date_label}'s plan.

  Then show the updated plan (re-fetch using `get_day_plan`).
- **Status 404**: "Item {id} not found."
- **Other errors**: Handle per error handling rules.

---

### remove_from_day_plan

**Trigger**: `remove {id}`, "remove from today", "take off my plan", "skip this"

#### Step 1: Confirm

Extract the item ID from args. Display:
> Remove item **{id}** from {date_label}'s plan? (Item will still exist in your items.)

Wait for confirmation.

#### Step 2: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" DELETE "/day-plans/DATE_SEGMENT/items/ITEM_ID")
echo "$RESPONSE"
```

#### Step 3: Handle response

- **Status 200 or 204**: Display confirmation:
  > Item **{id}** removed from {date_label}'s plan.

  Then show the updated plan (re-fetch using `get_day_plan`).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules.

---

### Edge Cases

- **No config**: Any flow → "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Run `scripts/install.sh` to install rkit skills."
- **Item already on plan** (PUT/attach): Idempotent — API returns 200, confirm it's on the plan.
- **Empty plan on view**: Show helpful message with add hint.
- **Date plan doesn't exist**: 404 → "No plan exists for {date}."

---

## How to Interpret

1. **Read the user's message.** Look for trigger words/phrases from the table.
2. **Extract parameters.** Look for:
   - An **item ID** (integer, e.g., "415", "item 415", "#415")
   - A **date** (e.g., "tomorrow", "Monday", "2026-02-20", "Feb 20") → convert to `YYYY-MM-DD`
   - A **name** (quoted text, or text after "add"/"create")
   - A **completion intent** ("done", "undo", "check", "uncheck")
3. **Pick the matching tool row.** If the user provides an ID with "add"/"attach"/"put", use `attach_existing_item`. If they provide a name/text, use `create_new_item`.
4. **Default to `get_day_plan`** if no clear write intent is detected.
5. **If ambiguous**, ask the user: "Did you mean to [option A] or [option B]?"

### Date Resolution

| User says | Segment value |
|---|---|
| *(nothing)* / "today" | `today` |
| "tomorrow" | tomorrow's date as `YYYY-MM-DD` |
| "yesterday" | yesterday's date as `YYYY-MM-DD` |
| "Monday", "next Tuesday", etc. | resolve to `YYYY-MM-DD` |
| "2026-02-20", "Feb 20" | `2026-02-20` |

Use the current date from **Current State** to resolve relative dates.

---

## Schemas

**DayPlanItem:**
```json
{
  "id": 415,
  "name": "Write proposal",
  "description": null,
  "due": "2026-02-25",
  "status": "next",
  "on_weekly": true,
  "team": { "id": 1, "name": "Acme Team" },
  "owner": { "id": 1, "login": "patrick", "first_name": "Patrick", "last_name": "Smith" },
  "assignees": [{ "id": 7, "login": "sarah", "first_name": "Sarah", "last_name": "Lee" }],
  "parent_id": 100,
  "created_at": "2026-02-19T08:00:00Z",
  "updated_at": "2026-02-19T08:00:00Z",
  "completed": false
}
```

**Pagination:**
```json
{
  "current_page": 1,
  "per_page": 25,
  "total_count": 3,
  "total_pages": 1
}
```

---

## Error Handling

| Status | Response |
|---|---|
| `error: NO_CONFIG` | "Config not found. Run `/rkit:setup` first." |
| `error: NO_TOKEN` | "No API token. Run `/rkit:setup` to configure." |
| `error: CURL_FAILED` | "Network error. Check your connection." |
| `status: 401` | "Unauthorized. Run `/rkit:setup` to update your token." |
| `status: 404` | "Not found. Item may not exist or isn't on this plan." |
| `status: 422` | Show validation error from response body. |
| Other non-200 | Show status code and error message. |

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
