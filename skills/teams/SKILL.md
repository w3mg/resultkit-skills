---
name: rkit:teams
description: List your teams and view team members. Shows teams grouped by organization with framework and default team marked. Search by name or list members for any team.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
---

# rkit:teams

List teams and view team members. Read-only.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/teams/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/teams/scripts/api.sh "$HOME/.claude/skills/rkit:teams/scripts/api.sh" "$HOME/.agents/skills/teams/scripts/api.sh" "$HOME/.gemini/skills/teams/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **GET only.** This skill only reads data — no confirmation needed.
- **Show IDs.** Always include team and member IDs in output.
- **Concise output.** Tables and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | List visible (non-muted) teams grouped by organization |
| `all` | Include muted teams in listing (muted teams marked) |
| `q "search term"` | Search teams by name (min 2 chars) |
| `all q "term"` | Search including muted teams |
| `members` | List members of the default team |
| `members {team_id}` | List members of the specified team |

---

## Flow: List Teams

### Step 1: Resolve API path

- Default: `GET /teams` (excludes muted — server-side filtering confirmed)
- If `all` in args: `GET /teams?include_muted=true`
- If `q "term"` in args: add `q=term` param
- Combine as needed: `/teams?include_muted=true&q=term`

### Step 2: Fetch teams

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams?PARAMS")
echo "$RESPONSE"
```

### Step 3: Handle response

Parse the JSON response from api.sh.

**Error responses** (status 0 or non-200):
- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- Other non-200 → Show status code and error from response body.

**Success (status 200)**:

The `body` is a **flat JSON array** (not wrapped in `data`/`meta`). Each element is a team object.

**Important**: Because the response is a flat array, access it as `body` directly — not `body.data`.

- **Empty array** (or no matches with `q`):
  - With search: "No teams matching '{term}'."
  - Without search: "No teams found."

- **Teams present**: Group by `organization_name` and display:

  ```
  ## Your Teams

  ### {organization_name}

  | ID | Name | Framework | |
  |----|------|-----------|-|
  | 345 | Engineering | eos | (default) |
  | 412 | Product | okr | |

  ### {another_org}

  | ID | Name | Framework | |
  |----|------|-----------|-|
  | 500 | Sales | srt | |

  {count} teams
  ```

  - `Framework` column: show value or "—" if null
  - Mark the team matching `default_team_id` from config with `(default)`
  - If `all` was used, mark muted teams with `(muted)`
  - If only one organization, still show the org header
  - Show total count at the bottom

---

## Flow: List Members

### Step 1: Resolve team ID

- If a team ID is provided in args → use it
- Otherwise → use `default_team_id` from Current State config
- If neither available → "No team specified and no default configured. Run `/rkit:setup`."

### Step 2: Fetch members (all pages)

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/members?per_page=100")
echo "$RESPONSE"
```

Replace `TEAM_ID` with actual value.

### Step 3: Handle response

**Error responses** (status 0 or non-200):
- `"error": "NO_CONFIG"` or `"error": "NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 404` → "Team {id} not found (404)."
- Other non-200 → Show status code and error from response body.

**Success (status 200)**:

Extract `body.data` array (members) and `body.meta` (pagination).

- **Empty data array**: "No members found for team {id}."

- **Members present**: Display as table:

  ```
  ## Members — Team {team_name} ({team_id})

  | Name | Role | User ID |
  |------|------|---------|
  | Jane Doe | admin | 101 |
  | John Smith | member | 205 |

  {count} members
  ```

  - `Name` column: `user.first_name` + `user.last_name`. If both empty, fall back to `user.login`.
  - `Role` column: `role` value (admin/member)
  - `User ID` column: `user.id`

- **Pagination**: If `meta.total_pages > 1`, fetch all remaining pages and combine results before displaying.

---

## Edge Cases

- **No config**: "Config not found. Run `/rkit:setup` first."
- **api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **Search term < 2 chars**: "Search requires at least 2 characters."
- **No teams match search**: "No teams matching '{term}'."
- **Team not found (404) on members**: "Team {id} not found (404)."
- **No members**: "No members found for team {id}."
- **Member with empty names**: Fall back to `login`.

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
