---
name: rkit:weekly
description: View and manage the team weekly board. Shows items grouped by status column (next, done, issues, parked) using framework-specific terminology.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:weekly

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- api.sh: !`for p in "$HOME/.claude/plugins/"*/rkit/skills/weekly/scripts/api.sh "$HOME/.claude/skills/rkit:weekly/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"`

## Rules

- **Confirm writes**: Before any POST/PUT/PATCH/DELETE, describe the action and ask for confirmation. GET requests execute immediately.
- **Show IDs**: Always include item IDs in output so users can reference them.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls via api.sh. Never use Task agents or subagents.

## Framework Terminology

Fetch the team's `framework` field from `GET /teams/{team_id}`. Map the board name and column headers:

| | Default / null | EOS | OKR | 4DX | V2MOM | SRT |
|-------------|----------------|-----|-----|-----|-------|-----|
| **Board name** | Weekly | Level 10 | Weekly | Weekly | Weekly | Weekly |
| next | Next | To-Do | Next | WIG Actions | Next | Next |
| done | Done | Done | Done | Done | Done | Done |
| issues | Issues | Issues | Blockers | Blockers | Obstacles | Issues |
| parked | Parked | Parked | Deferred | Parked | Parked | Parked |

**Always use the framework-mapped board name in all user-facing output and messages.** For EOS teams, say "Level 10" — never "weekly board" or "team weekly."

## Argument Parsing

Parse the user input to determine which flow to follow:

| Input | Flow |
|-------|------|
| *(no args)* | View Weekly |
| `next` / `done` / `issues` / `parked` | View Single Column |
| `move {item_id} {column}` | Move Item |
| `add {item_id}` or `add {item_id} {column}` | Add Item to Weekly |
| `remove {item_id}` | Remove Item from Weekly |
| `--team {id}` (anywhere in args) | Override team ID for any flow |

If the input doesn't match any pattern, show this usage summary and ask what they'd like to do.

---

## Team ID Resolution

1. **`--team {id}` flag** in args → use that team ID
2. **`default_team_id` in config** → use that
3. **Neither** → "No default team configured. Run `/rkit:setup` first."

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

## Flow: View Weekly

**Trigger**: No args (or only `--team {id}`)

### Step 1: Fetch team detail and all four columns

Resolve team ID. Then fetch team detail for framework, and all four columns:

```bash
API_SH="<api.sh path from Current State>"
TEAM=$("$API_SH" GET "/teams/TEAM_ID")
echo "$TEAM"
```

```bash
API_SH="<api.sh path from Current State>"
NEXT=$("$API_SH" GET "/teams/TEAM_ID/items/next?per_page=50")
DONE=$("$API_SH" GET "/teams/TEAM_ID/items/done?per_page=50")
ISSUES=$("$API_SH" GET "/teams/TEAM_ID/items/issues?per_page=50")
PARKED=$("$API_SH" GET "/teams/TEAM_ID/items/parked?per_page=50")
echo "---NEXT---"
echo "$NEXT"
echo "---DONE---"
echo "$DONE"
echo "---ISSUES---"
echo "$ISSUES"
echo "---PARKED---"
echo "$PARKED"
```

### Step 2: Display weekly board

Use the team's `framework` field to look up column headers from the Framework Terminology table.

Display format:

```
{board_name}: {team_name} (ID: {team_id})

## {Next Header} ({next_total} items)

| ID | Name | Owner | Due |
|----|------|-------|-----|
| 42 | Fix login bug | Scott Levy | 2026-02-20 |
| 88 | Write API tests | Patrick Angodung | — |

Showing 50 of {total} — more items exist

## {Done Header} ({done_total} items)

(empty)

## {Issues Header} ({issues_total} items)

...

## {Parked Header} ({parked_total} items)

...
```

**Display rules**:
- Column header shows framework-mapped name and total item count from `meta.total`
- Each item shows: ID, name, owner (`first_name last_name` from `owner` field; show login if names are empty), due date (or "—" if null)
- Empty columns show "(empty)"
- If a column has more than 50 items (`meta.total > 50`), show "Showing 50 of {total} — more items exist" after the table
- Column order: next, done, issues, parked (always this order)

---

## Flow: View Single Column

**Trigger**: `next`, `done`, `issues`, or `parked`

### Step 1: Fetch team detail and the requested column

Resolve team ID. Fetch team detail for framework, then the single column:

```bash
API_SH="<api.sh path from Current State>"
TEAM=$("$API_SH" GET "/teams/TEAM_ID")
echo "$TEAM"
```

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/items/COLUMN?per_page=50")
echo "$RESPONSE"
```

Replace `COLUMN` with the requested column name (next/done/issues/parked).

### Step 2: Display column

Use same display format as a single section from View Weekly — framework-mapped header, item table, overflow indicator.

---

## Flow: Move Item

**Trigger**: `move {item_id} {column}`

Column must be one of: `next`, `done`, `issues`, `parked`.

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
- `blocked` → issues
- `parked` → parked

If the item's current column matches the target → "Item {item_id} is already in {column}." and stop.

If the item is not on the {board_name} (`on_weekly` is false) → "Item {item_id} is not on the {board_name}. Use `add` to put it on first."

### Step 2: Confirm and execute

Resolve team ID. Describe the move:
> Move item **{item_name}** (ID: {item_id}) from **{current_column}** to **{target_column}**?

Wait for confirmation. Then execute:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/teams/TEAM_ID/items/TARGET_COLUMN/ITEM_ID")
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: "Moved **{item_name}** (ID: {item_id}) to **{target_column}**."
- **Error** → use Error Handling above

---

## Flow: Add Item to Weekly

**Trigger**: `add {item_id}` or `add {item_id} {column}`

### Step 1: Check if already on weekly

Fetch the item:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."
- If `on_weekly` is true → "Item **{item_name}** (ID: {item_id}) is already on the {board_name} in **{current_column}**. Move it instead?" If user says yes, switch to Move flow.

### Step 2: Determine column

- If column provided in args → validate it's one of next/done/issues/parked
- If no column → prompt user:
  > Which column for **{item_name}** (ID: {item_id})?
  > 1. Next
  > 2. Done
  > 3. Issues
  > 4. Parked

  (Use framework-mapped names in the prompt.)

### Step 3: Confirm and execute

Resolve team ID. Describe:
> Add **{item_name}** (ID: {item_id}) to the {board_name} in **{column}**?

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/teams/TEAM_ID/items/COLUMN/ITEM_ID")
echo "$RESPONSE"
```

This single call adds the item to the team board (`on_weekly=true`) and sets its status in one step.

### Step 4: Handle response

- **Status 200**: "Added **{item_name}** (ID: {item_id}) to **{column}**."
- **Error** → use Error Handling above

---

## Flow: Remove Item from Weekly

**Trigger**: `remove {item_id}`

### Step 1: Validate item

Fetch the item:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."
- If `on_weekly` is false → "Item {item_id} is not on the {board_name}."

### Step 2: Confirm and execute

Resolve team ID. Describe:
> Remove **{item_name}** (ID: {item_id}) from the {board_name}? (Item will still exist — only removed from the {board_name}.)

Wait for confirmation. Then:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" DELETE "/teams/TEAM_ID/items/ITEM_ID")
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 200**: "Removed **{item_name}** (ID: {item_id}) from the {board_name}."
- **Error** → use Error Handling above

---

## Edge Cases

- **No config** → "Config not found. Run `/rkit:setup` first."
- **api.sh not found** → "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **All columns empty** → show all four column headers with "(empty)"
- **Item not on {board_name} (move)** → "Item {id} is not on the {board_name}. Use `add` to put it on first."
- **Item already in target column (move)** → warn and skip
- **Item already on {board_name} (add)** → warn and offer to move instead
- **Column has >50 items** → show first 50 with "Showing 50 of {total} — more items exist"
- **Invalid column name** → "Invalid column '{input}'. Use: next, done, issues, or parked."
- **Team not found (--team override)** → "Team {id} not found (404)."
- **Owner names empty** → fall back to `login` field

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
