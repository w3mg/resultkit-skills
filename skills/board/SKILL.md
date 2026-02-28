---
name: rkit:board
description: View any item's children as a kanban-style board. Children become columns, grandchildren become items. Supports viewing, filtering by column, moving items between columns, adding items, and removing items. Use this skill when users want to see a board view, manage columns, move items between columns, or work with a hierarchical item structure.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:board

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base, default_board_id}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/board/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/board/scripts/api.sh "$HOME/.claude/skills/rkit:board/scripts/api.sh" "$HOME/.agents/skills/board/scripts/api.sh" "$HOME/.gemini/skills/board/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes**: Before any POST/PUT/PATCH/DELETE, describe the action and ask for confirmation. GET requests execute immediately.
- **Show IDs**: Always include item IDs in output so users can reference them.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls via api.sh. Never use Task agents or subagents.

## Argument Parsing

Parse the user input to determine which flow to follow:

| Input | Flow |
|-------|------|
| *(no args)* | View Board |
| `{id}` | View Board (with explicit board ID) |
| `{id} {column}` | View Single Column |
| `move {item_id} {target_id}` | Move Item |
| `add {board_id} ...` | Add Item |
| `remove {item_id}` | Remove Item |

If the input doesn't match any pattern, show this usage summary and ask what they'd like to do.

---

## Board ID Resolution

Used by View Board, Add Item, and Remove Item flows to determine which item to treat as the board root.

**Resolution order**:

1. **Explicit ID in args** → use directly
2. **`default_board_id` in config is an integer** → use that ID
3. **`default_board_id` in config is `"ask"`** → show the default and ask user to confirm or provide a different ID
4. **`default_board_id` absent from config** → prompt user: "No default board configured. Enter an item ID to use as the board:"

---

## Error Handling

Parse the JSON response from api.sh. Handle these cases:

- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 404` → "Item not found (404)."
- `status: 422` → Show validation error from response body.
- Other non-200 → Show status code and error from response body.

---

## Flow: View Board

**Trigger**: No args, or a single numeric ID

### Step 1: Resolve board ID and fetch columns

Resolve the board ID using Board ID Resolution. Then fetch columns:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/BOARD_ID/children?per_page=50")
echo "$RESPONSE"
```

**Handle response**:
- Error → use Error Handling above
- Success (status 200): Extract `body.data` (columns) and `body.meta`
- **Empty data array** → "No children found for item {id}."
- **Items present** → continue to Step 2

### Step 2: Apply column cap and fetch column items

Take the first 10 columns from the data array. If `body.meta.total` > 10, note the overflow count for display.

For each column (up to 10), fetch its children:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/COLUMN_ID/children?per_page=50")
echo "$RESPONSE"
```

Collect each column's items and meta (for total count).

### Step 3: Display board

Display the board title using the board ID, then each column:

```
Board: {board_id}

## {Column Name} (ID: {column_id})

| ID | Name | Status | Due |
|----|------|--------|-----|
| 42 | Fix login bug | next | 2026-02-20 |
| 88 | Write API tests | not_started | — |

{N} items shown

## {Next Column Name} (ID: {column_id})

(empty)

...
```

**Display rules**:
- Each column header shows name and ID (FR-002)
- Each item shows ID, name, status, due date (FR-003). If due is null, show "—"
- Empty columns show "(empty)"
- If a column has more than 50 items (`meta.total` > 50), show "({total} total, showing first 50)" after the table (FR-006)
- If more than 10 columns exist, show "({overflow_count} more columns not shown)" at the end (FR-008)

---

## Flow: View Single Column

**Trigger**: `{board_id} {column_name_or_id}`

### Step 1: Resolve board and fetch columns

Resolve the board ID from the first argument. Fetch columns:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/BOARD_ID/children?per_page=50")
echo "$RESPONSE"
```

### Step 2: Match column

From the columns data array:

- If the second argument is numeric, match by ID (exact match on `id` field)
- If the second argument is a string, match by case-insensitive substring on column `name`

**Match results**:
- **No match** → "No column matching '{input}' on board {board_id}." Then list available columns with IDs.
- **One match** → use that column, continue to Step 3
- **Multiple matches** → list matching columns with their IDs and ask user to pick. Suggest renaming one to avoid future ambiguity.

### Step 3: Fetch and display column items

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/COLUMN_ID/children?per_page=50")
echo "$RESPONSE"
```

Display using the same single-column format from View Board Step 3 (column header with name/ID, item table, empty/overflow handling).

---

## Flow: Move Item

**Trigger**: `move {item_id} {target_column_id}`

### Step 1: Validate item and target

Fetch both the item and target to confirm they exist:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/TARGET_ID")
echo "$RESPONSE"
```

- If either returns 404 → show error and stop
- If the item's `parent_id` already equals the target ID → "Item {item_id} is already under {target_name} (ID: {target_id})." and stop

### Step 2: Confirm and execute

Describe the move:
> Move item **{item_name}** (ID: {item_id}) to **{target_name}** (ID: {target_id})?

Wait for confirmation. Then execute:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/items/ITEM_ID/move" '{"parent_id": TARGET_ID}')
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: "Moved **{item_name}** (ID: {item_id}) to **{target_name}** (ID: {target_id})."
- **Error** → use Error Handling above

---

## Flow: Add Item

**Trigger**: `add {board_id} {column_id} "name"` or `add {board_id} "name"`

### Step 1: Parse arguments and resolve column

Extract the board ID (first arg after `add`).

- If a column ID is provided (second arg is numeric and a third arg exists as the name): use that column ID directly
- If no column ID (second arg is the item name): fetch columns and prompt user to pick

Fetch columns for picker:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/BOARD_ID/children?per_page=50")
echo "$RESPONSE"
```

List columns with IDs and ask user to choose.

### Step 2: Confirm and execute

Describe the action:
> Create item "**{name}**" under **{column_name}** (ID: {column_id})?

Wait for confirmation. Then execute:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/items" '{"name": "ITEM_NAME", "parent_id": COLUMN_ID}')
echo "$RESPONSE"
```

Escape any double quotes in ITEM_NAME.

### Step 3: Handle response

- **Status 200 or 201**: Extract the new item from `body.data`. Display: "Created item **{id}**: \"{name}\" under **{column_name}** (ID: {column_id})."
- **Status 422** → show validation error
- **Error** → use Error Handling above

---

## Flow: Remove Item

**Trigger**: `remove {item_id}`

### Step 1: Resolve board and validate item

Resolve the board ID using Board ID Resolution. Then validate the item exists:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."
- Extract the item's `parent_id`

Fetch the board's columns:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/BOARD_ID/children?per_page=50")
echo "$RESPONSE"
```

Check that the item's `parent_id` matches one of the column IDs. If not → "Item {item_id} is not on this board."

### Step 2: Prompt user with options

Display the item name and current column, then present options:

> Removing **{item_name}** (ID: {item_id}) from **{column_name}**. Where should it go?
>
> 1. Remove from all projects
> 2. Move to another project
> 3. Move to a one-on-one or other source

Ask user to choose (1, 2, or 3).

### Step 3: Execute chosen option

**Option 1 — Remove from all projects**:

Confirm: "Remove **{item_name}** from all projects?"

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/items/ITEM_ID/move" '{"parent_id": null}')
echo "$RESPONSE"
```

If successful, ask: "Add **{item_name}** to your day plan?"

If user says yes:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/day-plans/today/items/ITEM_ID")
echo "$RESPONSE"
```

Show confirmation: "**{item_name}** removed from all projects and added to today's plan." (or "removed from all projects." if they declined the day plan offer)

**Option 2 — Move to another project**:

Ask: "Enter the target project/parent item ID:"

Confirm: "Move **{item_name}** to item {target_id}?"

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/items/ITEM_ID/move" '{"parent_id": TARGET_ID}')
echo "$RESPONSE"
```

Show confirmation: "Moved **{item_name}** (ID: {item_id}) to item {target_id}."

**Option 3 — Move to a one-on-one or other source**:

Ask: "Enter the target parent item ID:"

Confirm: "Move **{item_name}** to item {target_id}?"

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/items/ITEM_ID/move" '{"parent_id": TARGET_ID}')
echo "$RESPONSE"
```

Show confirmation: "Moved **{item_name}** (ID: {item_id}) to item {target_id}."

**Error handling**: If any PUT returns an error, use Error Handling above.

---

## Edge Cases

- **Item has no children** → "No children found for item {id}."
- **Column has no children** → show column header with "(empty)"
- **Item not found (404)** → "Item {id} not found (404)."
- **No config** → "Config not found. Run `/rkit:setup` first."
- **api.sh not found** → "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **Column has >50 items** → show first 50 with "({total} total, showing first 50)"
- **Board has >10 columns** → show first 10 with "({N} more columns not shown)"
- **Column name/ID not found** → "No column matching '{input}' on board {id}." with list of available columns
- **Duplicate column names** → list matches with IDs, ask user to pick; suggest renaming one to avoid future ambiguity
- **Item already under target column (move)** → warn and skip
- **Item not on board (remove)** → "Item {id} is not on this board."

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
