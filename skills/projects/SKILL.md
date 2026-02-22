---
name: rkit:projects
description: List active projects for a team. Shows project name, status, due date, and owner.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:projects

List active projects for a team.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/projects/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/projects/scripts/api.sh "$HOME/.claude/skills/rkit:projects/scripts/api.sh" "$HOME/.agents/skills/projects/scripts/api.sh" "$HOME/.gemini/skills/projects/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **GET only.** This skill only reads data — no confirmation needed.
- **Show IDs.** Always include project IDs in output.
- **Concise output.** Tables and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | List projects for default team |
| `{team_id}` | List projects for specified team |
| `all` | List all team members' projects (passes `all=true`) |
| `{team_id} all` | List all projects for specified team |
| `q "search term"` | Filter projects by name |

---

## Flow: List Projects

### Step 1: Resolve team ID

- If a team ID is provided in args → use it
- Otherwise → use `default_team_id` from Current State config
- If neither available → "No team specified and no default configured. Run `/rkit:setup`."

### Step 2: Build query params

Start with `per_page=50`.

- If `all` is in args → add `all=true`
- If `q "term"` is in args → add `q=term`

### Step 3: Fetch projects

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/projects?per_page=50&EXTRA_PARAMS")
echo "$RESPONSE"
```

Replace `TEAM_ID` and `EXTRA_PARAMS` with actual values.

### Step 4: Handle response

Parse the JSON response from api.sh:

**Error responses** (status 0 or non-200):
- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 404` → "Team not found (404)."
- Other non-200 → Show status code and error from response body.

**Success (status 200)**:

Extract `body.data` array (the projects) and `body.meta` (pagination info).

- **Empty array**: "No active projects for team {team_id}."

- **Projects present**: Display as a table:

  ```
  ## Projects — Team {team_id}

  | ID | Name | Status | Due | Owner |
  |----|------|--------|-----|-------|
  | 201 | Q1 Product Launch | next | 2026-03-31 | Jane D. |
  | 205 | API Migration | not_started | — | John S. |

  {total} projects
  ```

  - `Due` column: show date if present, "—" if null
  - `Owner` column: show `owner.first_name` + last initial (e.g., "Jane D.")
  - If `meta.total` > 50: show "({total} total, showing first 50)"
  - If `meta.total_pages` > 1: show "(page 1 of {total_pages})"

---

## Edge Cases

- **No config**: "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **No projects**: "No active projects for team {team_id}."
- **Team not found (404)**: "Team {team_id} not found."

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
