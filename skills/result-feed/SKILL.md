---
name: rkit:result-feed
description: View and manage daily check-in reports (90-second practice). Build your done/next/issues, submit, share with team, and view team check-ins.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:result-feed

A single skill that handles all result feed (daily check-in) operations by interpreting user intent against a tool routing table.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/result-feed/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/result-feed/scripts/api.sh "$HOME/.claude/skills/rkit:result-feed/scripts/api.sh" "$HOME/.agents/skills/result-feed/scripts/api.sh" "$HOME/.gemini/skills/result-feed/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`
- Today: !`date +%Y-%m-%d`

## Rules

- **Interpret first, act second.** Read the user's message. Match it against the Tool Routing Table below. Pick the best match. If ambiguous, ask.
- **Confirm writes.** GET requests execute immediately. POST/PUT/DELETE: describe the action and ask for confirmation first.
- **Show IDs.** Always include item IDs in output.
- **Concise output.** Tables and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.

---

## Tool Routing Table

Match the user's message against the **Triggers** column. Pick the first matching row.

| Triggers | Intent | Tool/Flow |
|---|---|---|
| "show my check-in", "90 seconds", "result feed", "daily report", "what did I do", "show {date}", "check-in", "what did I get done" | View result feed for today or a date | `get_result_feed` |
| "add done", "add next", "add issue", "new done item", "create done", "add to done", "add to next", "add to issues" | Create a new item in a section | `create_new_item` |
| "add item {id} to done", "put {id} in next", "attach {id} to issues", "attach {id} to done", "move {id} to next" | Attach an existing item to a section by ID | `attach_existing_item` |
| "remove {id} from done", "take {id} off next", "drop {id} from issues", "remove {id}" | Remove an item from a section | `remove_item` |
| "submit", "finalize", "done for the day", "submit check-in", "share check-in" | Submit and share check-in | `submit_check_in` |
| "team check-ins", "team feed", "team result feed", "show team", "team report" | View team members' shared check-ins | `view_team_feeds` |

---

## Tool/Flow

### get_result_feed

Determine the date path segment:
- No args → use `today`
- Date argument → use the resolved date string (see Date Resolution)

#### Step 1: Fetch result feed

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/result-feeds/DATE_SEGMENT")
echo "$RESPONSE"
```

Replace `DATE_SEGMENT` with `today` or the `YYYY-MM-DD` date.

#### Step 2: Handle response

Parse the JSON response from api.sh:

**Error responses** (status 0 or non-200):
- Handle per error handling table below.
- `status: 400` → "Invalid date format. Use YYYY-MM-DD or 'today'."

**Success (status 200)**:

Extract `body.data` object: `id`, `date`, `is_completed`, `done[]`, `next[]`, `issues[]`.

- **All sections empty**: Display:
  > ## Result Feed — {date_label}
  >
  > Status: Not submitted
  >
  > No items yet. Use `add done "task name"` to add items.

- **Items present**: Display as:

  ```
  ## Result Feed — {date_label}

  Status: {Submitted ✓ | Not submitted}

  ### Done
  | # | ID | Name |
  |---|---|---|
  | 1 | 415 | Write proposal |

  ### Next
  | # | ID | Name |
  |---|---|---|
  | 1 | 420 | Review PR |

  ### Issues
  No items.

  **{total} items** — {done_count} done, {next_count} next, {issues_count} issues
  ```

  - `date_label`: "Today" for today segment, or the formatted date
  - `Status`: "Submitted ✓" if `is_completed` is true, "Not submitted" if false
  - Empty sections show "No items."
  - Summary line counts items across all sections

---

### create_new_item

#### Step 1: Extract parameters

Extract the **item name** (quoted text or text after "add done"/"add next"/"add issue") and the **section** (done, next, or issues) from the user's message.

If section is unclear, ask: "Which section — done, next, or issues?"

#### Step 2: Confirm

Display:
> Create item "**{name}**" in **{section}** section?

Wait for confirmation.

#### Step 3: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" POST "/result-feeds/DATE_SEGMENT/SECTION" '{"name":"ITEM_NAME"}')
echo "$RESPONSE"
```

Escape any double quotes in ITEM_NAME. Use `today` as DATE_SEGMENT unless user specified a date.

#### Step 4: Handle response

- **Status 201**: Show:
  > Created item **{id}**: "{name}" in {section}

  Then re-fetch and display the updated check-in using `get_result_feed`.
- **Status 400**: "Invalid section. Use: done, next, or issues."
- **Status 422**: Show validation error from response body.
- **Other errors**: Handle per error handling table.

---

### attach_existing_item

#### Step 1: Extract parameters

Extract the **item ID** (integer) and **section** (done, next, or issues) from the user's message.

#### Step 2: Confirm

Display:
> Add item **{id}** to **{section}** section?

Wait for confirmation.

#### Step 3: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" PUT "/result-feeds/DATE_SEGMENT/SECTION/ITEM_ID")
echo "$RESPONSE"
```

#### Step 4: Handle response

- **Status 200**: Show:
  > Item **{id}** added to {section}.

  Then re-fetch and display the updated check-in using `get_result_feed`.
  Note: already-present items also return 200 (idempotent).
- **Status 400**: "Invalid section. Use: done, next, or issues."
- **Status 404**: "Item {id} not found or not viewable."
- **Other errors**: Handle per error handling table.

---

### remove_item

#### Step 1: Extract parameters

Extract the **item ID** (integer) and **section** (done, next, or issues) from the user's message.

#### Step 2: Confirm

Display:
> Remove item **{id}** from **{section}**? (Item will not be deleted.)

Wait for confirmation.

#### Step 3: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" DELETE "/result-feeds/DATE_SEGMENT/SECTION/ITEM_ID")
echo "$RESPONSE"
```

#### Step 4: Handle response

- **Status 204**: Show:
  > Item **{id}** removed from {section}.

  Then re-fetch and display the updated check-in using `get_result_feed`.
- **Status 400**: "Invalid section. Use: done, next, or issues."
- **Status 404**: "Item {id} not found in {section} section."
- **Other errors**: Handle per error handling table.

---

### submit_check_in

#### Step 1: Determine team

1. If user specified a team ID in their message, use that.
2. Else read `default_team_id` from config:
   ```bash
   TEAM_ID=$(jq -r '.default_team_id // empty' "$HOME/.config/resultkit/config.json")
   ```
3. If no `default_team_id`: prompt user "No default team configured. Which team ID should this be shared with?"

#### Step 2: Fetch team name for display

```bash
API_SH="<api.sh path>"
TEAM_RESPONSE=$("$API_SH" GET "/teams/TEAM_ID")
echo "$TEAM_RESPONSE"
```

Extract team name from `body.data.name`.

#### Step 3: Determine date segment

No args → use `today`. Date argument → use resolved date.

#### Step 4: Confirm

Display:
> Submit check-in for **{date_label}** and share with team "**{team_name}**" (ID: {team_id})?

Wait for confirmation.

#### Step 5: Execute

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" POST "/result-feeds/DATE_SEGMENT/submit" '{"team_id":TEAM_ID}')
echo "$RESPONSE"
```

#### Step 6: Handle response

- **Status 200**: Show:
  > Check-in submitted and shared with **{team_name}**.

  Then re-fetch and display the updated check-in using `get_result_feed`.
  Note: re-submitting an already-completed feed returns 200 (idempotent).
- **Status 404**: "Team not found."
- **Status 422**: Show validation error from response body (likely "Done and Next sections must each have at least one item").
- **Other errors**: Handle per error handling table.

---

### view_team_feeds

#### Step 1: Determine team

1. If user specified a team ID, use that.
2. Else read `default_team_id` from config.
3. If no `default_team_id`: prompt user "No default team configured. Which team ID should this be used?"

#### Step 2: Fetch team result feeds

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/result-feeds")
echo "$RESPONSE"
```

#### Step 3: Handle response

**Error responses**:
- `status: 404` → "Team not found or you are not a member."
- Other errors → handle per error handling table.

**Success (status 200)**:

Extract `body.data` array and `body.meta` pagination.

- **Empty array**: Display:
  > No shared check-ins found for this team.

- **Feeds present**: For each TeamResultFeed in data, display:

  ```
  ### {first_name} {last_name} (@{login}) — {date}

  **Done**
  - [{id}] {name}
  - [{id}] {name}

  **Next**
  - [{id}] {name}

  **Issues**
  - [{id}] {name}
  ```

  After all feeds, show pagination summary:
  > Page {page}/{total_pages} — {total} check-ins

  Empty sections within a feed show "None."

---

## How to Interpret

1. **Read the user's message.** Look for trigger words/phrases from the table.
2. **Extract parameters.** Look for:
   - An **item ID** (integer, e.g., "415", "item 415", "#415")
   - A **date** (e.g., "tomorrow", "Monday", "2026-02-20") → convert to `YYYY-MM-DD`
   - A **name** (quoted text, or text after "add done"/"add next"/"add issue")
   - A **section** (done, next, issues — note "blocked" means "issues")
3. **Pick the matching tool row.** If the user provides an ID with "add"/"attach"/"put", use `attach_existing_item`. If they provide a name/text, use `create_new_item`.
4. **Default to `get_result_feed`** if no clear write intent is detected.
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

### Section Resolution

| User says | Section value |
|---|---|
| "done", "completed", "finished" | `done` |
| "next", "up next", "planned" | `next` |
| "issues", "blocked", "blockers", "stuck" | `issues` |

Always use `done`, `next`, `issues` in API paths — never `blocked`.

---

## Schemas

**ResultFeed:**
```json
{
  "id": 42,
  "date": "2026-02-26",
  "is_completed": false,
  "done": [Item, ...],
  "next": [Item, ...],
  "issues": [Item, ...]
}
```

**TeamResultFeed:**
```json
{
  "id": 42,
  "date": "2026-02-26",
  "is_completed": true,
  "user": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
  "done": [Item, ...],
  "next": [Item, ...],
  "issues": [Item, ...]
}
```

**Item (within sections):**
```json
{
  "id": 415,
  "name": "Write proposal",
  "description": null,
  "due": "2026-02-25",
  "status": "next",
  "on_weekly": true,
  "team": { "id": 1, "name": "Acme Team" },
  "creator": { "id": 1, "login": "patrick", "first_name": "Patrick", "last_name": "Smith" },
  "assignees": [],
  "parent_id": null,
  "created_at": "2026-02-19T08:00:00Z",
  "updated_at": "2026-02-19T08:00:00Z"
}
```

**Pagination:**
```json
{
  "page": 1,
  "per_page": 100,
  "total": 5,
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
| `status: 400` | Show error message from response body. |
| `status: 404` | Context-dependent message (see individual flows). |
| `status: 422` | Show validation error from response body. |
| Other non-200 | Show status code and error message. |

### Edge Cases

- **No config**: Any flow → "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **Item already in section** (PUT/attach): Idempotent — API returns 200.
- **Empty check-in on view**: Show helpful message with add hint.
- **No default_team_id for submit/team view**: Prompt user for team ID.

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
