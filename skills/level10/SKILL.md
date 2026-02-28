---
name: rkit:level10
description: View and manage EOS Level 10 meeting artifacts — to-dos, issues, and headlines. Full L10 workflow with native EOS terminology. Use this skill when users mention "level 10", "L10", "EOS meeting", "EOS to-dos", "EOS issues", or want to work with a team's Level 10 board.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:level10

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/level10/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/level10/scripts/api.sh "$HOME/.claude/skills/rkit:level10/scripts/api.sh" "$HOME/.agents/skills/level10/scripts/api.sh" "$HOME/.gemini/skills/level10/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes**: Before any POST/PUT/PATCH/DELETE, describe the action and ask for confirmation. GET requests execute immediately.
- **Show IDs**: Always include entity IDs in output so users can reference them.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls via api.sh. Never use Task agents or subagents.
- **EOS only**: This skill is exclusively for teams using the EOS framework. Non-EOS teams get a clear error.

## Argument Parsing

Parse the user input to determine which flow to follow:

| Input | Flow |
|-------|------|
| *(no args)* | View L10 Board |
| `todos` | View To-Dos Only |
| `issues` | View Issues Only |
| `headlines` | View Headlines Only |
| `add todo "text"` | Create To-Do |
| `add issue "text"` | Create Issue |
| `add headline "text"` | Create Headline |
| `done {item_id}` | Mark Item Done |
| `move {item_id} todos` | Move Item to To-Dos |
| `move {item_id} issues` | Move Item to Issues |
| `remove headline {id}` | Archive Headline |
| `update headline {id} "text"` | Update Headline Text |
| `--team {id}` *(anywhere)* | Override team ID for any flow |

If the input doesn't match any pattern, show this usage summary and ask what they'd like to do.

---

## Team ID Resolution

1. **`--team {id}` flag** in args → use that team ID
2. **`default_team_id` in config** → use that
3. **Neither** → "No default team configured. Run `/rkit:setup` first."

---

## Pre-Flight: EOS Framework Gate

Before any operation, after resolving the team ID:

1. Fetch team detail:

```bash
API_SH="<api.sh path from Current State>"
TEAM=$("$API_SH" GET "/teams/TEAM_ID")
echo "$TEAM"
```

2. Extract the `framework` field from `body.data` (or the top-level object).
3. If `framework` is not `"eos"` → stop and show: "Level 10 is only available for teams using the EOS framework. Use `/rkit:weekly` instead."
4. If EOS, extract `team_name` and `team_id` for use in output headers.

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

## Flow: View L10 Board

**Trigger**: No args (or only `--team {id}`)

### Step 1: Resolve team, run EOS gate, fetch all three sections

Resolve team ID. Run Pre-Flight gate. Then fetch to-dos, issues, and headlines:

```bash
API_SH="<api.sh path from Current State>"
TODOS=$("$API_SH" GET "/teams/TEAM_ID/l10/todos")
ISSUES=$("$API_SH" GET "/teams/TEAM_ID/l10/issues")
HEADLINES=$("$API_SH" GET "/teams/TEAM_ID/l10/headlines")
echo "---TODOS---"
echo "$TODOS"
echo "---ISSUES---"
echo "$ISSUES"
echo "---HEADLINES---"
echo "$HEADLINES"
```

### Step 2: Display L10 board

```
Level 10: {team_name} (ID: {team_id})

## To-Dos ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 42 | Fix login bug | Scott Levy | 2026-03-07 |

## Issues ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 88 | Cash flow concern | Patrick A. | — |

## Headlines ({count} headlines)

| ID | Text | Creator | Expires |
|----|------|---------|---------|
| 201 | New client signed | John Smith | 2026-03-07 |
```

**Display rules**:
- Section headers show count from `meta.total`
- To-Dos and Issues: show ID, name, creator (`first_name last_name` from `creator` field; fall back to `login` if names are empty), due date (or "—" if null)
- Headlines: show ID, text, creator, expires_at date (or "—" if null)
- Empty sections show "(empty)"
- If any section has more items than returned (`meta.total` > returned count), show "Showing {returned} of {total} — more items exist"

---

## Flow: View Single Section

**Trigger**: `todos`, `issues`, or `headlines`

### Step 1: Resolve team, run EOS gate, fetch the requested section

Resolve team ID. Run Pre-Flight gate. Then fetch the single section:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/l10/SECTION")
echo "$RESPONSE"
```

Replace `SECTION` with `todos`, `issues`, or `headlines`.

### Step 2: Display section

Use the same display format as the corresponding section from View L10 Board — section header with count, item table, empty/overflow handling.

---

## Flow: Create To-Do

**Trigger**: `add todo "text"` optionally with `--due YYYY-MM-DD`

### Step 1: Parse and validate

Extract the to-do name (text after `add todo`). If `--due` is provided, use that date.

- If text is empty → "To-do name cannot be empty."

### Step 2: Resolve team, run EOS gate, confirm

Resolve team ID. Run Pre-Flight gate. Describe the action:

> Create to-do "**{name}**" for **{team_name}**{due info}?

Wait for confirmation.

### Step 3: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/teams/TEAM_ID/l10/todos" '{"name": "TODO_NAME"}')
echo "$RESPONSE"
```

If `--due` was provided, include `"due": "YYYY-MM-DD"` in the JSON body. Escape any double quotes in the name.

### Step 4: Handle response

- **Status 200/201**: Extract the new item from `body.data`. Display: `Created to-do **{id}**: "{name}" (due {date})`
- **Error** → use Error Handling

---

## Flow: Create Issue

**Trigger**: `add issue "text"` optionally with `--due YYYY-MM-DD`

### Step 1: Parse and validate

Extract the issue name (text after `add issue`). If `--due` is provided, use that date.

- If text is empty → "Issue name cannot be empty."

### Step 2: Resolve team, run EOS gate, confirm

Resolve team ID. Run Pre-Flight gate. Describe the action:

> Create issue "**{name}**" for **{team_name}**{due info}?

Wait for confirmation.

### Step 3: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/teams/TEAM_ID/l10/issues" '{"name": "ISSUE_NAME"}')
echo "$RESPONSE"
```

If `--due` was provided, include `"due": "YYYY-MM-DD"` in the JSON body. Escape any double quotes in the name.

### Step 4: Handle response

- **Status 200/201**: Extract the new item from `body.data`. Display: `Created issue **{id}**: "{name}"`
- **Error** → use Error Handling

---

## Flow: Create Headline

**Trigger**: `add headline "text"` optionally with `--expires YYYY-MM-DD`

### Step 1: Parse and validate

Extract the headline text (after `add headline`). If `--expires` is provided, use that date. Otherwise compute default: 7 days from today.

- If text is empty → "Headline text cannot be empty."

### Step 2: Resolve team, run EOS gate, confirm

Resolve team ID. Run Pre-Flight gate. Describe the action:

> Create headline "**{text}**" for **{team_name}** (expires {date})?

Wait for confirmation.

### Step 3: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" POST "/teams/TEAM_ID/l10/headlines" '{"text": "HEADLINE_TEXT", "expires_at": "YYYY-MM-DD"}')
echo "$RESPONSE"
```

Escape any double quotes in the text.

### Step 4: Handle response

- **Status 200/201**: Extract the new headline from `body.data`. Display: `Created headline **{id}**: "{text}" (expires {date})`
- **Error** → use Error Handling

---

## Flow: Mark Item Done

**Trigger**: `done {item_id}`

### Step 1: Resolve team, run EOS gate, fetch item

Resolve team ID. Run Pre-Flight gate. Fetch the item to get its name and current status:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."
- If item's `status` is already `done` → "Item **{name}** (ID: {item_id}) is already done." and stop.

### Step 2: Confirm

Map the item's current status to L10 terminology:
- `next` → "To-Do"
- `blocked` → "Issue"

Describe the action:
> Mark {L10_term} **{item_name}** (ID: {item_id}) as done?

Wait for confirmation.

### Step 3: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/teams/TEAM_ID/items/done/ITEM_ID")
echo "$RESPONSE"
```

### Step 4: Handle response

- **Status 200**: "Moved **{item_name}** (ID: {item_id}) to **Done**."
- **Error** → use Error Handling

---

## Flow: Move Item

**Trigger**: `move {item_id} todos` or `move {item_id} issues`

### Step 1: Resolve team, run EOS gate, fetch item

Resolve team ID. Run Pre-Flight gate. Fetch the item:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" GET "/items/ITEM_ID")
echo "$RESPONSE"
```

- If 404 → "Item {item_id} not found."

Map the target section to the API column:
- `todos` → `next`
- `issues` → `blocked`

If the item's current `status` already matches the target → "Item **{name}** (ID: {item_id}) is already in {target_section}." and stop.

### Step 2: Confirm

Map current status to L10 term (`next` → "To-Dos", `blocked` → "Issues", `done` → "Done"). Describe the move:
> Move **{item_name}** (ID: {item_id}) from **{current_section}** to **{target_section}**?

Wait for confirmation.

### Step 3: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PUT "/teams/TEAM_ID/items/API_COLUMN/ITEM_ID")
echo "$RESPONSE"
```

Replace `API_COLUMN` with `next` (for todos) or `blocked` (for issues).

### Step 4: Handle response

- **Status 200**: "Moved **{item_name}** (ID: {item_id}) to **{target_section}**."
- **Error** → use Error Handling

---

## Flow: Archive Headline

**Trigger**: `remove headline {headline_id}`

### Step 1: Resolve team, run EOS gate, confirm

Resolve team ID. Run Pre-Flight gate. Describe the action:

> Archive headline **{headline_id}** from **{team_name}**?

Wait for confirmation.

### Step 2: Execute

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" DELETE "/teams/TEAM_ID/headlines/HEADLINE_ID")
echo "$RESPONSE"
```

### Step 3: Handle response

- **Status 204**: "Archived headline **{headline_id}**."
- **Status 404** → "Headline {headline_id} not found."
- **Error** → use Error Handling

---

## Flow: Update Headline

**Trigger**: `update headline {headline_id} "new text"` and/or `--expires YYYY-MM-DD`

### Step 1: Parse and validate

Extract `headline_id`, new text (if provided), and `--expires` value (if provided).

- If neither text nor `--expires` → "Provide text or --expires to update."

### Step 2: Resolve team, run EOS gate, confirm

Resolve team ID. Run Pre-Flight gate. Describe what will change:
- If text provided: `text → "{new_text}"`
- If `--expires` provided: `expires → {new_date}`

> Update headline **{headline_id}** on **{team_name}**: {changes}?

Wait for confirmation.

### Step 3: Execute

Build the JSON body with only the provided fields:

```bash
API_SH="<api.sh path from Current State>"
RESPONSE=$("$API_SH" PATCH "/teams/TEAM_ID/headlines/HEADLINE_ID" '{"text": "NEW_TEXT"}')
echo "$RESPONSE"
```

Only include `text` if text was provided. Only include `expires_at` if `--expires` was provided.

### Step 4: Handle response

- **Status 200**: Extract the updated headline. Display: `Updated headline **{id}**: "{text}" (expires {date})`
- **Status 404** → "Headline {headline_id} not found."
- **Error** → use Error Handling

---

## Edge Cases

- **No config** → "Config not found. Run `/rkit:setup` first."
- **api.sh not found** → "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **Non-EOS team** → "Level 10 is only available for teams using the EOS framework. Use `/rkit:weekly` instead."
- **Item not found (404)** → "Item {id} not found."
- **Headline not found (404)** → "Headline {id} not found."
- **Item already done (done flow)** → "Item **{name}** (ID: {id}) is already done."
- **Item already in target section (move)** → warn and skip
- **Empty section** → show section header with "(empty)"
- **Empty text for create** → "To-do/Issue/Headline name/text cannot be empty."
- **Unauthorized (401)** → "Unauthorized (401). Run `/rkit:setup` to update your token."
- **Network error** → "Network error. Check your connection."

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
