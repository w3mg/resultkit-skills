---
name: rkit:today
description: View and manage today's day plan. See what's on the plan, mark items complete, add or remove items. Primary "start of day" skill.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read
---

# rkit:today

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- api.sh: !`for p in "$HOME/.claude/skills/rkit:today/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"`

## Rules

- **Confirm writes**: Before any POST/PUT/PATCH/DELETE, describe the action and ask for confirmation. GET requests execute immediately.
- **Show IDs**: Always include item IDs in output so users can reference them.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls via api.sh. Never use Task agents or subagents.

## Argument Parsing

Parse the user input to determine which flow to follow:

| Input | Flow |
|-------|------|
| *(no args)* | View Today's Plan |
| `done {id}` | Mark Item Complete |
| `undo {id}` | Mark Item Incomplete |
| `add "text"` | Create New Item on Today |
| `attach {id}` | Attach Existing Item to Today |
| `remove {id}` | Remove Item from Today |
| `{YYYY-MM-DD}` | View That Date's Plan |

If the input doesn't match any pattern, show this usage summary and ask what they'd like to do.

---

## Flow: View Today's Plan

**Trigger**: No args, or a date argument like `2026-02-13`

Determine the date path segment:
- No args → use `today`
- Date argument → use the date string (e.g., `2026-02-13`)

### Step 1: Fetch plan items

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/day-plans/DATE_SEGMENT/items")
echo "$RESPONSE"
```

Replace `DATE_SEGMENT` with `today` or the `YYYY-MM-DD` date.

### Step 2: Handle response

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
  > No items on today's plan. Use `/rkit:today add "task name"` to add one.

- **Items present**: Display as a table:

  ```
  Today's Plan (YYYY-MM-DD) — X items, Y completed

  | # | ID  | Name               | Status | Done |
  |---|-----|--------------------|--------|------|
  | 1 |  42 | Fix login bug      | next   | ✓    |
  | 2 |  88 | Write API tests    | next   |      |

  Z remaining
  ```

  - `#` = position field
  - `Done` column: `✓` if `completed` is true, blank if false
  - Summary line: count of remaining (not completed) items
  - If viewing a specific date (not today), show "Plan for YYYY-MM-DD" instead of "Today's Plan"

---

## Flow: Mark Item Complete

**Trigger**: `done {id}`

### Step 1: Confirm

Extract the item ID from args. Display:
> Mark item **{id}** as complete?

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PATCH "/day-plans/today/items/ITEM_ID" '{"completed":true}')
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: Display confirmation, then show the updated plan (re-fetch and display using the View flow).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules above.

---

## Flow: Mark Item Incomplete

**Trigger**: `undo {id}`

### Step 1: Confirm

Extract the item ID from args. Display:
> Mark item **{id}** as incomplete?

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PATCH "/day-plans/today/items/ITEM_ID" '{"completed":false}')
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: Display confirmation, then show the updated plan (re-fetch and display using the View flow).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules above.

---

## Flow: Create New Item on Today

**Trigger**: `add "text"` or `add text`

### Step 1: Confirm

Extract the item name from args. Display:
> Create item "**{name}**" on today's plan?

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/day-plans/today/items" '{"name":"ITEM_NAME"}')
echo "$RESPONSE"
```

Escape any double quotes in ITEM_NAME.

### Step 3: Handle response

- **Status 200 or 201**: Show the new item with its ID:
  > Created item **{id}**: "{name}"

  Then show the updated plan (re-fetch and display using the View flow).
- **Status 422**: Show validation error from response body.
- **Other errors**: Handle per error handling rules above.

---

## Flow: Attach Existing Item to Today

**Trigger**: `attach {id}`

### Step 1: Confirm

Extract the item ID from args. Display:
> Attach item **{id}** to today's plan?

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/day-plans/today/items/ITEM_ID")
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: Display confirmation:
  > Item **{id}** attached to today's plan.

  Then show the updated plan (re-fetch and display using the View flow).
- **Status 404**: "Item {id} not found."
- **Other errors**: Handle per error handling rules above.

---

## Flow: Remove Item from Today

**Trigger**: `remove {id}`

### Step 1: Confirm

Extract the item ID from args. Display:
> Remove item **{id}** from today's plan? (Item will still exist in your items.)

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" DELETE "/day-plans/today/items/ITEM_ID")
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: Display confirmation:
  > Item **{id}** removed from today's plan.

  Then show the updated plan (re-fetch and display using the View flow).
- **Status 404**: "Item {id} not found on today's plan."
- **Other errors**: Handle per error handling rules above.

---

## Edge Cases

- **No config**: Any flow → "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Run `scripts/install.sh` to install rkit skills."
- **Item already on plan** (PUT/attach): Idempotent — API returns 200, confirm it's on the plan.
- **Empty plan on view**: Show helpful message with add hint.
- **Date plan doesn't exist**: 404 → "No plan exists for {date}."

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
