---
name: rkit:result-feed
description: View your team's shared daily check-ins (result feeds). Shows what teammates got done, what's next, and what's blocking them. Use this skill when users want to see team updates, daily check-ins, team progress, what the team has been working on, or review result feeds.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion
---

# rkit:result-feed

View team members' submitted check-ins. Read-only.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/result-feed/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/result-feed/scripts/api.sh "$HOME/.claude/skills/rkit:result-feed/scripts/api.sh" "$HOME/.agents/skills/result-feed/scripts/api.sh" "$HOME/.gemini/skills/result-feed/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **GET only.** This skill only reads data — no confirmation needed.
- **Show IDs.** Always include item IDs in output.
- **Concise output.** Tables and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | List shared check-ins for default team |
| `--team {id}` | List shared check-ins for specified team |
| `page {n}` | Fetch page N of results |
| `per_page {n}` | Results per page (1–100, default 100) |

---

## Team ID Resolution

1. **`--team {id}` flag** in args → use that team ID
2. **`default_team_id` in config** → use that
3. **Neither** → "No default team configured. Run `/rkit:setup` first."

---

## Flow: View Team Feeds

### Step 1: Resolve team and build query

Resolve team ID using Team ID Resolution. Build query params from args (page, per_page).

### Step 2: Fetch team result feeds

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/result-feed?PARAMS")
echo "$RESPONSE"
```

Replace `TEAM_ID` with actual value. `PARAMS` = any page/per_page values.

### Step 3: Handle response

Parse the JSON response from api.sh.

**Error responses** (status 0 or non-200):
- Handle per Error Handling table below.
- `status: 404` → "Team not found or you are not a member."

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

  **Blocked**
  - [{id}] {name}
  ```

  After all feeds, show pagination summary:
  > Page {page}/{total_pages} — {total} check-ins

  Empty sections within a feed show "None."

---

## Schemas

**TeamResultFeed:**
```json
{
  "id": 42,
  "date": "2026-02-26",
  "is_completed": true,
  "user": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
  "done": [Item, ...],
  "next": [Item, ...],
  "blocked": [Item, ...]
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
| `status: 404` | "Team not found or you are not a member." |
| Other non-200 | Show status code and error message. |

### Edge Cases

- **No config**: "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **No default_team_id and no --team**: Prompt user for team ID.
- **Empty feed list**: "No shared check-ins found for this team."

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
