---
name: rkit:setup
description: First-run configuration for ResultKit. Creates and manages ~/.config/resultkit/config.json with API token, default team, and API base URL. Use when setting up rkit skills for the first time or reconfiguring.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Write
---

# rkit:setup

## Current State

- Config status: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING"; fi`
- Env var: !`[ -n "${RESULTKIT_TOKEN:-}" ] && echo "RESULTKIT_TOKEN is set" || echo "RESULTKIT_TOKEN not set"`
- api.sh: !`for p in "$HOME/.claude/skills/rkit:setup/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && break; done || echo "NOT_FOUND"`

## Rules

- **Confirm writes**: Before writing config, describe what will be written and ask for confirmation.
- **Show IDs**: Always include entity IDs (team ID, user ID) in output.
- **Concise output**: Tables and short summaries. No verbose prose.
- **Direct execution**: Use Bash for all API calls. Never use Task agents or subagents.

## Flow

Use the **Current State** above to determine which flow to follow:

- Config **MISSING** → First-Time Setup (Step 1)
- Config **EXISTS** → Reconfigure (Step 10)

---

### Step 1: Check for environment variable token

If `RESULTKIT_TOKEN` is set (see Current State above):
> "Found `RESULTKIT_TOKEN` environment variable. Use this token for setup?"
- Yes → use env var value, go to Step 3.
- No → go to Step 2.

If not set → go to Step 2.

### Step 2: Ask for API token

> "Enter your ResultMaps API token (find it in your ResultMaps profile settings):"

Wait for user input.

### Step 3: Verify token

Call `GET /users/me` with the token. Use curl directly (config doesn't exist yet):

```bash
RESPONSE=$(curl -s -w '\n%{http_code}' \
  -H "Authorization: Bearer TOKEN_HERE" \
  -H "Accept: application/json" \
  "https://api.resultmaps.com/users/me")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
echo "Status: $HTTP_CODE"
echo "$RESP_BODY"
```

Replace `TOKEN_HERE` with the actual token.

- **200**: Extract `id`, `name`, `email`. Display:
  > Verified: **{name}** ({email})
  Proceed to Step 4.

- **401**: Display error, go back to Step 2.

- **Other**: Show status code and error. Ask to retry or change API base URL.

### Step 4: List user's teams

Call `GET /users/{id}/teams` using the `id` from Step 3:

```bash
RESPONSE=$(curl -s -w '\n%{http_code}' \
  -H "Authorization: Bearer TOKEN_HERE" \
  -H "Accept: application/json" \
  "https://api.resultmaps.com/users/USER_ID/teams")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')
echo "Status: $HTTP_CODE"
echo "$RESP_BODY"
```

- **Teams found**: Display as table:

  | # | ID | Name | Framework |
  |---|----|------|-----------|
  | 1 | 1 | Engineering | EOS |
  | 2 | 2 | Product | OKR |

  Ask: "Enter the number of your default team:"

- **No teams** (empty `data` array):
  > You don't have any teams yet. Default team will be set to none.
  Set `default_team_id` to `null`. Continue.

- **API error**: Show error. Offer to save config without team, retry later.

### Step 5: Confirm and write config

Present summary for confirmation:

> **Ready to save configuration:**
> - Token: {first 3}...{last 4}
> - Default team: {team_name} (ID: {team_id})
> - API base: https://api.resultmaps.com
>
> Save this configuration?

On confirmation, write:

```bash
mkdir -p "$HOME/.config/resultkit"
cat > "$HOME/.config/resultkit/config.json" << 'JSONEOF'
{
  "api_token": "ACTUAL_TOKEN",
  "default_team_id": ACTUAL_TEAM_ID,
  "api_base": "https://api.resultmaps.com"
}
JSONEOF
```

Replace placeholders. Use `null` (no quotes) for `default_team_id` if no team.

### Step 6: Done

> **Setup complete!**
> - User: {name} ({email})
> - Team: {team_name} (ID: {team_id})
> - Config: ~/.config/resultkit/config.json
>
> Try `/rkit:today` to see your day plan.

---

### Step 10: Reconfigure Flow

Config exists (see Current State for current values).

Display:

> **Current configuration:**
> - Token: {masked from Current State}
> - Default team: ID {team_id}
> - API base: {api_base}
>
> What would you like to update?
> 1. API token
> 2. Default team
> 3. API base URL
> 4. Cancel

#### Option 1: Update token

Ask for new token → verify via `GET /users/me` (same as Step 3) → on success:

```bash
CONFIG_FILE="$HOME/.config/resultkit/config.json"
jq --arg token "NEW_TOKEN" '.api_token = $token' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
```

Confirm the change.

#### Option 2: Update default team

Use current token → `GET /users/me` → get user ID → `GET /users/{id}/teams` → display table (same as Step 4). Mark current default with `(current)`.

On selection:

```bash
CONFIG_FILE="$HOME/.config/resultkit/config.json"
jq --argjson team TEAM_ID '.default_team_id = $team' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
```

Confirm the change.

#### Option 3: Update API base URL

Ask for new URL. Default: `https://api.resultmaps.com`.

```bash
CONFIG_FILE="$HOME/.config/resultkit/config.json"
jq --arg base "NEW_BASE" '.api_base = $base' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
```

Confirm the change.

#### Option 4: Cancel

> No changes made.

---

## Edge Cases

- **Corrupted config**: File exists but invalid JSON → treat as missing, offer to recreate with confirmation.
- **No teams**: Set `default_team_id` to `null`. Setup completes successfully.
- **Config dir fails**: Display filesystem error with path.
- **Token OK but teams fail**: Save token + api_base, set `default_team_id` to `null`, suggest retry later.

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
