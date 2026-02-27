---
name: rkit:1on1
description: View and manage one-on-one meetings for a team. Shows meetings filtered by type and team, with items grouped by column (next, done, blocked). Supports move, add, and remove.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:1on1

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/1on1/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/1on1/scripts/api.sh "$HOME/.claude/skills/rkit:1on1/scripts/api.sh" "$HOME/.agents/skills/1on1/scripts/api.sh" "$HOME/.gemini/skills/1on1/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes**: Before any POST/PUT/PATCH/DELETE, describe the action and ask for confirmation. GET requests execute immediately.
- **Show IDs**: Always include item and meeting IDs in output so users can reference them.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls via api.sh. Never use Task agents or subagents.

## Argument Parsing

Parse the user input to determine which flow to follow:

| Input | Flow |
|-------|------|
| *(no args)* | List One-on-Ones |
| `{meeting_id}` or `show {meeting_id}` | View One-on-One Detail |
| `{meeting_id} next` / `done` / `blocked` | View Single Column |
| `{meeting_id} move {item_id} {column}` | Move Item |
| `{meeting_id} add "text"` | Add New Item |
| `{meeting_id} add {item_id}` | Add Existing Item |
| `{meeting_id} remove {item_id}` | Remove Item |

If the input doesn't match any pattern, show this usage summary and ask what they'd like to do.

---

---

## Error Handling

Parse the JSON response from api.sh. Handle these cases:

- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 404` → "Not found (404)."
- `status: 422` → Show validation error from response body.
- Other non-200 → Show status code and error from response body.

---

## Flow: List One-on-Ones

**Trigger**: No args (or only `--team {id}`)

### Step 1: Fetch meetings

Fetch all meetings:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/meetings?per_page=100")
echo "$RESPONSE"
```

### Step 2: Filter and display

Filter the response client-side:
- `type` must be `one_on_one`
- If `--team {id}` is provided, additionally filter to only meetings where at least one participant belongs to that team

Display as a table:

```
## One-on-Ones

| ID | With | Date |
|----|------|------|
| 15 | Patrick Angodung | 2026-02-20 |
| 22 | Mary Mejia | 2026-02-18 |

{count} one-on-ones
```

- `With` column: show the other participant (`person1` or `person2` — whichever is not the current user). Show `first_name last_name`; fall back to `login` if names are empty.
- `Date` column: show date if present, "—" if null

**Empty result**: "No one-on-ones found."

---

## Flow: View One-on-One Detail

**Trigger**: `{meeting_id}` or `show {meeting_id}`

### Step 1: Fetch meeting detail

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/meetings/MEETING_ID")
echo "$RESPONSE"
```

### Step 2: Display meeting

The response includes `next`, `done`, and `blocked` arrays directly.

Display format:

```
## One-on-One: {person1} & {person2} (ID: {meeting_id})

### Next ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 42 | Discuss hiring plan | Scott Levy | 2026-02-25 |

### Done ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 38 | Review Q4 results | Patrick Angodung | — |

### Blocked ({count} items)

(empty)
```

**Display rules**:
- Each item shows: ID, name, creator (`first_name last_name` from `creator` field; fall back to `login` if names empty), due date (or "—" if null)
- Empty columns show "(empty)"
- Column order: next, done, blocked (always this order)

---

## Flow: View Single Column

**Trigger**: `{meeting_id} next`, `{meeting_id} done`, or `{meeting_id} blocked`

### Step 1: Fetch the requested column

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/meetings/MEETING_ID/items/COLUMN?per_page=50")
echo "$RESPONSE"
```

Replace `COLUMN` with:
- `next` for next
- `done` for done
- `blocked` for blocked items

### Step 2: Display column

Use same display format as a single section from View Detail — column header, item table, overflow indicator if more than 50 items.

---

## Flow: Move Item

**Trigger**: `{meeting_id} move {item_id} {column}`

Column must be one of: `next`, `done`, `blocked`.

### Step 1: Check current status

Fetch the item to check its current status:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

Map the item's `status` to a column:
- `next` → next
- `done` → done
- `blocked` → blocked

If the item's current column matches the target → "Item {item_id} is already in {column}." and stop.

### Step 2: Confirm and execute

Map target column to API status:
- `next` → `next`
- `done` → `done`
- `blocked` → `blocked`

Describe the move:
> Move item **{item_name}** (ID: {item_id}) from **{current_column}** to **{target_column}**?

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PATCH "/items/ITEM_ID" '{"status":"TARGET_STATUS"}')
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: "Moved **{item_name}** (ID: {item_id}) to **{target_column}**."
- **Error** → use Error Handling above

---

## Flow: Add Item to One-on-One

**Trigger**: `{meeting_id} add "text"` or `{meeting_id} add {item_id}`

### Step 1: Determine if new or existing

- If arg is a quoted string → create new item
- If arg is a number → add existing item

### Step 2 (new item): Confirm and execute

Describe:
> Add **"{text}"** to one-on-one {meeting_id}?

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/meetings/MEETING_ID/items" '{"name":"TEXT"}')
echo "$RESPONSE"
```

- **Status 201**: "Added **{item_name}** (ID: {item_id}) to one-on-one {meeting_id}."
- **Error** → use Error Handling above

### Step 2 (existing item): Fetch, confirm, and execute

Fetch the item to confirm it exists:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."

Describe:
> Add **{item_name}** (ID: {item_id}) to one-on-one {meeting_id}?

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/meetings/MEETING_ID/items/ITEM_ID")
echo "$RESPONSE"
```

- **Status 200**: "Added **{item_name}** (ID: {item_id}) to one-on-one {meeting_id}."
- **Error** → use Error Handling above

---

## Flow: Remove Item

**Trigger**: `{meeting_id} remove {item_id}`

### Step 1: Confirm and execute

Describe:
> Remove item {item_id} from one-on-one {meeting_id}? (Item will still exist — only detached from this meeting.)

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" DELETE "/meetings/MEETING_ID/items/ITEM_ID")
echo "$RESPONSE"
```

### Step 2: Handle response

- **Status 200/204**: "Removed item {item_id} from one-on-one {meeting_id}."
- **Error** → use Error Handling above

---

## Edge Cases

- **No config** → "Config not found. Run `/rkit:setup` first."
- **api.sh not found** → "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **No one-on-ones** → "No one-on-ones found."
- **Meeting not found (404)** → "Meeting {id} not found."
- **All columns empty** → show all three column headers with "(empty)"
- **Item already in target column (move)** → warn and skip
- **Item not found (add existing)** → "Item {id} not found."
- **Creator names empty** → fall back to `login` field

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
