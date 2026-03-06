---
name: rkit:scorecard
description: View and manage your team's weekly KPI scorecard (measures/measurables). Shows current-year measures with recent weekly history values, and supports recording values, creating, updating, and archiving measures. Use when users mention scorecard, KPIs, measurables, weekly metrics, measures, recording values, or team scorecard management.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Bash(date *), Read, Glob, Grep, AskUserQuestion
---

# rkit:scorecard

View and manage the team weekly KPI scorecard.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/scorecard/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/scorecard/scripts/api.sh "$HOME/.claude/skills/rkit:scorecard/scripts/api.sh" "$HOME/.agents/skills/scorecard/scripts/api.sh" "$HOME/.gemini/skills/scorecard/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes.** GET requests execute immediately. POST/PATCH/DELETE require user confirmation before executing.
- **Show IDs.** Always include measure IDs in output for follow-up reference.
- **Concise output.** Tables and short summaries. No filler prose.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents or subagents.
- **Framework-aware.** Use the team's `framework` field: EOS teams use "Measurables" instead of "Measures" in labels. "Scorecard" is universal.
- **Scoped tools.** Use `Bash(scripts/api.sh *)` and `Bash(jq *)` — never raw curl.

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | List scorecard for default team, current year |
| `--year YYYY` | Show history for specified year |
| `--include-archived` | Include archived measures in list view |
| `--team {id}` | Use specified team instead of default |
| `record "NAME" VALUE [date=YYYY-MM-DD]` | Record a weekly value for a measure |
| `add "NAME" [unit=...] [direction=...] [target=...]` | Create a new measure |
| `update "NAME" [name=...] [unit=...] [direction=...] [target=...]` | Update measure fields |
| `archive "NAME"` | Archive (soft-delete) a measure |

---

## Team ID Resolution

1. **`--team {id}` flag** in args → use that team ID
2. **`default_team_id` in config** → use that
3. **Neither** → error: "No default team configured. Run `/rkit:setup` first."

---

## Measure Name Resolution

Used by: `record`, `update`, `archive` subcommands.

### Step 1: Fetch full measure list

```bash
API_SH="<resolved api.sh path>"
TEAM_ID="<resolved team ID>"
MEASURES_RESP=$("$API_SH" GET "/teams/$TEAM_ID/measures?include_archived=true")
```

Extract `MEASURES_RESP.body.data` as the candidate list.

### Step 2: Match

Given user input NAME:

1. **Case-insensitive exact match**: find measures where `lower(measure.name) == lower(NAME)`. If exactly one → use it.
2. **Case-insensitive substring match**: find measures where `lower(measure.name)` contains `lower(NAME)`. If exactly one → use it.
3. **Multiple matches** → show disambiguation list and stop:
   ```
   Multiple measures match "NAME". Which did you mean?
   1. Measure Alpha (ID: 1)
   2. Measure Beta (ID: 2)
   ```
4. **No match** → error: "No measure found matching '{NAME}'." and stop.

Use jq for matching:
```bash
# Exact match (case-insensitive)
MATCH=$(echo "$MEASURES_RESP" | jq --arg name "$NAME" \
  '[.body.data[] | select((.name | ascii_downcase) == ($name | ascii_downcase))]')

# If empty, substring match
if [ "$(echo "$MATCH" | jq 'length')" -eq 0 ]; then
  MATCH=$(echo "$MEASURES_RESP" | jq --arg name "$NAME" \
    '[.body.data[] | select((.name | ascii_downcase) | contains($name | ascii_downcase))]')
fi

COUNT=$(echo "$MATCH" | jq 'length')
```

---

## Flow: List Scorecard

Triggered when: no args, or only `--year`/`--include-archived`/`--team` flags.

### Step 1: Resolve team ID

Use Team ID Resolution. Error if not configured.

Verify config and api.sh are present:
- If config missing: "Config not found. Run `/rkit:setup` first."
- If api.sh shows `NOT_FOUND`: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"

### Step 2: Resolve year and flags

```bash
YEAR=$(date +%Y)  # default current year
INCLUDE_ARCHIVED="false"
# Parse from args: if --year YYYY present, set YEAR; if --include-archived present, set INCLUDE_ARCHIVED=true
```

### Step 3: Fetch team info (for framework-aware terminology)

```bash
API_SH="<resolved api.sh path>"
TEAM_RESP=$("$API_SH" GET "/teams/$TEAM_ID")
FRAMEWORK=$(echo "$TEAM_RESP" | jq -r '.body.data.framework // ""')
TEAM_NAME=$(echo "$TEAM_RESP" | jq -r '.body.data.name // "Team"')
MEASURE_LABEL=$([ "$FRAMEWORK" = "eos" ] && echo "Measurables" || echo "Measures")
```

### Step 4: Fetch measures

```bash
RESPONSE=$("$API_SH" GET "/teams/$TEAM_ID/measures?year=$YEAR&include_archived=$INCLUDE_ARCHIVED")
STATUS=$(echo "$RESPONSE" | jq -r '.status // "error"')
ERROR=$(echo "$RESPONSE" | jq -r '.error // ""')
```

**Handle errors**: See Error Handling table at bottom.

Handle API errors first:
- `error` field non-empty → check ERROR HANDLING table
- `status: 401` → "Auth failed. Run `/rkit:setup` to update your token."
- `status: 403` → "You don't have permission to view this team's scorecard."
- `status: 404` → "Team ID $TEAM_ID not found."
- Other non-200 status → "API error ($STATUS): $(echo "$RESPONSE" | jq -r '.body.error.message // .body // ""')"

### Step 5: Compute the 4 most recent calendar-week columns

```bash
TODAY=$(date +%Y-%m-%d)
DOW=$(date +%u)  # 1=Monday, 7=Sunday
OFFSET=$((DOW - 1))

# Monday of current week (Linux)
THIS_MON=$(date -d "$TODAY - ${OFFSET} days" +%Y-%m-%d 2>/dev/null)
# macOS fallback
if [ -z "$THIS_MON" ]; then
  THIS_MON=$(date -v-${OFFSET}d +%Y-%m-%d)
fi

# 4 week columns (oldest first: W1, W2, W3, W4)
W4=$THIS_MON
W3=$(date -d "$THIS_MON - 7 days" +%Y-%m-%d 2>/dev/null || date -j -v-7d -f "%Y-%m-%d" "$THIS_MON" +%Y-%m-%d)
W2=$(date -d "$THIS_MON - 14 days" +%Y-%m-%d 2>/dev/null || date -j -v-14d -f "%Y-%m-%d" "$THIS_MON" +%Y-%m-%d)
W1=$(date -d "$THIS_MON - 21 days" +%Y-%m-%d 2>/dev/null || date -j -v-21d -f "%Y-%m-%d" "$THIS_MON" +%Y-%m-%d)

# Format for display (e.g. "Jan 5")
fmt_date() {
  date -d "$1" "+%b %-d" 2>/dev/null || date -j -f "%Y-%m-%d" "$1" "+%b %e" | sed 's/  / /'
}
H1=$(fmt_date "$W1")
H2=$(fmt_date "$W2")
H3=$(fmt_date "$W3")
H4=$(fmt_date "$W4")
```

### Step 6: Display

**If `data` array is empty and `--include-archived` is not set**:
```
No active measures on this scorecard. Use `/rkit:scorecard add "Name"` to create one.
```

**Otherwise**, display:

```
Team Scorecard — {TEAM_NAME} ({FRAMEWORK_UPPER}) — {YEAR}
Showing last 4 weeks

ID   Name                  Unit  Dir     Target  Owner       {H1}    {H2}    {H3}    {H4}
──   ────────────────────  ────  ──────  ──────  ──────────  ──────  ──────  ──────  ──────
...
```

Use jq to extract and format each row:

```bash
echo "$RESPONSE" | jq -r \
  --arg w1 "$W1" --arg w2 "$W2" --arg w3 "$W3" --arg w4 "$W4" \
  '.body.data[] |
   . as $m |
   ($m.histories | map({(.date): (.value // "—")}) | add // {}) as $h |
   [
     ($m.id | tostring),
     ($m.name + (if $m.is_archived then " [archived]" else "" end)),
     ($m.unit // ""),
     $m.direction,
     ($m.target_value // "—"),
     (if $m.owner then ($m.owner.first_name + " " + $m.owner.last_name[0:1] + ".") else "(none)" end),
     ($h[$w1] // "—"),
     ($h[$w2] // "—"),
     ($h[$w3] // "—"),
     ($h[$w4] // "—")
   ] | @tsv'
```

Format the tsv output as a readable table. Align columns by padding with spaces. Display the header row with column names and separator line before the data rows.

---

## Flow: Record Value

Triggered when: first arg is `record`.

### Step 1: Parse args

Extract:
- `NAME` = arg 2 (measure name, required)
- `VALUE` = arg 3 (numeric value, required)
- `DATE` = from `date=YYYY-MM-DD` if present in args (optional)

If NAME is missing: "Usage: `/rkit:scorecard record \"Measure Name\" VALUE [date=YYYY-MM-DD]`" and stop.
If VALUE is missing: "Value is required. Usage: `/rkit:scorecard record \"Name\" VALUE`" and stop.

### Step 2: Validate value (client-side)

Check that VALUE matches `^-?[0-9]+(\.[0-9]+)?$`. If not numeric:
```
Value must be a number. Got: "{VALUE}"
```
Stop — do not call the API.

### Step 3: Compute date

If `date=YYYY-MM-DD` was provided, use that.

Otherwise compute current Monday:
```bash
TODAY=$(date +%Y-%m-%d)
DOW=$(date +%u)
OFFSET=$((DOW - 1))
RECORD_DATE=$(date -d "$TODAY - ${OFFSET} days" +%Y-%m-%d 2>/dev/null)
if [ -z "$RECORD_DATE" ]; then
  RECORD_DATE=$(date -v-${OFFSET}d +%Y-%m-%d)
fi
```

### Step 4: Resolve measure name

Use Measure Name Resolution. Stop on disambiguation or no-match.

Extract `MEASURE_ID` and `MEASURE_NAME` from the matched measure.

### Step 5: Confirm

```
Record value "{VALUE}" for "{MEASURE_NAME}" (ID: {MEASURE_ID}) for week of {RECORD_DATE}? [y/N]
```

Ask for confirmation using AskUserQuestion. If user says anything other than `y`/`yes`, cancel and show "Cancelled."

### Step 6: Execute

```bash
API_SH="<resolved api.sh path>"
RESPONSE=$("$API_SH" POST "/measures/$MEASURE_ID/history" \
  "{\"date\": \"$RECORD_DATE\", \"value\": \"$VALUE\"}")
STATUS=$(echo "$RESPONSE" | jq -r '.status // "error"')
```

### Step 7: Handle response

- **200**: "Recorded: {MEASURE_NAME} — {VALUE} for week of {RECORD_DATE}."
- **422**: Show API error message: `$(echo "$RESPONSE" | jq -r '.body.error.message // .body // "Validation error"')`
- **403**: "You don't have permission to record values for this team."
- **404**: "Measure ID {MEASURE_ID} not found."
- Other: "API error ($STATUS): $(echo "$RESPONSE" | jq -r '.body.error.message // ""')"

---

## Flow: Create Measure

Triggered when: first arg is `add`.

### Step 1: Parse args

Extract from args:
- `NAME` = arg 2 (required, the measure name)
- `UNIT` = value from `unit=...` if present (default: `""`)
- `DIRECTION` = value from `direction=...` if present (default: `"higher"`)
- `TARGET` = value from `target=...` if present (default: none)

If NAME is missing or blank:
```
Measure name is required. Usage: `/rkit:scorecard add "Name" [unit=...] [direction=higher|lower] [target=...]`
```
Stop.

### Step 2: Resolve team ID

Use Team ID Resolution.

### Step 3: Confirm

```
Create measure "{NAME}" (unit: {UNIT or "none"}, direction: {DIRECTION}, target: {TARGET or "none"})? [y/N]
```

Ask for confirmation. If not `y`/`yes`, show "Cancelled."

### Step 4: Execute

Build JSON body. Include only fields that were provided. Always include `name`. Include `unit` and `direction` with their defaults if not provided:

```bash
API_SH="<resolved api.sh path>"
# Build body with provided fields
BODY="{\"measure\": {\"name\": \"$NAME\", \"unit\": \"$UNIT\", \"direction\": \"$DIRECTION\""
if [ -n "$TARGET" ]; then
  BODY="$BODY, \"target_value\": \"$TARGET\""
fi
BODY="$BODY}}"

RESPONSE=$("$API_SH" POST "/teams/$TEAM_ID/measures" "$BODY")
STATUS=$(echo "$RESPONSE" | jq -r '.status // "error"')
```

### Step 5: Handle response

- **201**: Show: "Created: {name} (ID: {id}, unit: {unit or "none"}, direction: {direction}, target: {target_value or "none"})."
  Extract from `RESPONSE.body.data`.
- **422**: Show API error message: `$(echo "$RESPONSE" | jq -r '.body.error.message // "Validation error"')`
- **403**: "You don't have permission to add measures to this team."
- Other: "API error ($STATUS): $(echo "$RESPONSE" | jq -r '.body.error.message // ""')"

---

## Flow: Update Measure

Triggered when: first arg is `update`.

### Step 1: Parse args

Extract:
- `NAME` = arg 2 (measure name to look up, required)
- `NEW_NAME` = value from `name=...` if present
- `UNIT` = value from `unit=...` if present
- `DIRECTION` = value from `direction=...` if present
- `TARGET` = value from `target=...` if present

If NAME is missing: "Usage: `/rkit:scorecard update \"Name\" [name=...] [unit=...] [direction=...] [target=...]`" and stop.
If no update fields provided: "No fields to update. Specify at least one of: name, unit, direction, target." and stop.

### Step 2: Resolve measure name

Use Measure Name Resolution. Stop on disambiguation or no-match.

Extract `MEASURE_ID` and `MEASURE_NAME`.

### Step 3: Build change summary

List only the fields being changed:
```
name → "{NEW_NAME}"
unit → "{UNIT}"
direction → "{DIRECTION}"
target → "{TARGET}"
```

### Step 4: Confirm

```
Update "{MEASURE_NAME}" (ID: {MEASURE_ID}) — set {change summary}? [y/N]
```

Ask for confirmation. If not `y`/`yes`, show "Cancelled."

### Step 5: Execute

Build partial PATCH body with only provided fields:

```bash
API_SH="<resolved api.sh path>"
FIELDS=""
[ -n "$NEW_NAME" ] && FIELDS="$FIELDS\"name\": \"$NEW_NAME\","
[ -n "$UNIT" ] && FIELDS="$FIELDS\"unit\": \"$UNIT\","
[ -n "$DIRECTION" ] && FIELDS="$FIELDS\"direction\": \"$DIRECTION\","
[ -n "$TARGET" ] && FIELDS="$FIELDS\"target_value\": \"$TARGET\","
FIELDS="${FIELDS%,}"  # remove trailing comma
BODY="{\"measure\": {$FIELDS}}"

RESPONSE=$("$API_SH" PATCH "/measures/$MEASURE_ID" "$BODY")
STATUS=$(echo "$RESPONSE" | jq -r '.status // "error"')
```

### Step 6: Handle response

- **200**: "Updated: {name from response} (ID: {MEASURE_ID}) — {change summary}."
- **403**: "You don't have permission to edit this measure."
- **404**: "Measure ID {MEASURE_ID} not found."
- **422**: Show API error message: `$(echo "$RESPONSE" | jq -r '.body.error.message // "Validation error"')`
- Other: "API error ($STATUS): $(echo "$RESPONSE" | jq -r '.body.error.message // ""')"

---

## Flow: Archive Measure

Triggered when: first arg is `archive`.

### Step 1: Parse args

Extract `NAME` = arg 2 (required).

If NAME is missing: "Usage: `/rkit:scorecard archive \"Name\"`" and stop.

### Step 2: Resolve measure name

Use Measure Name Resolution (fetches all including archived). Stop on disambiguation or no-match.

Extract `MEASURE_ID` and `MEASURE_NAME`.

### Step 3: Confirm

```
Archive "{MEASURE_NAME}" (ID: {MEASURE_ID})? It will be hidden from the default scorecard view. [y/N]
```

Ask for confirmation. If not `y`/`yes`, show "Cancelled."

### Step 4: Execute

```bash
API_SH="<resolved api.sh path>"
RESPONSE=$("$API_SH" DELETE "/measures/$MEASURE_ID")
STATUS=$(echo "$RESPONSE" | jq -r '.status // "error"')
```

### Step 5: Handle response

- **200**: "Archived: {MEASURE_NAME} (ID: {MEASURE_ID}). It will no longer appear in the default scorecard view."
- **403**: "You don't have permission to archive this measure."
- **404**: "Measure ID {MEASURE_ID} not found."
- Other: "API error ($STATUS): $(echo "$RESPONSE" | jq -r '.body.error.message // ""')"

---

## Error Handling

| Status | Response |
|--------|----------|
| `error: NO_CONFIG` | "Config not found. Run `/rkit:setup` first." |
| `error: NO_TOKEN` | "No API token. Run `/rkit:setup` to configure." |
| `error: CURL_FAILED` | "Network error. Check your connection." |
| `status: 401` | "Unauthorized. Run `/rkit:setup` to update your token." |
| `status: 403` | "Not authorized for this operation. Check your team membership." |
| `status: 404` | "Not found. Check the ID or name and try again." |
| `status: 422` | Show the validation error message from the response body. |
| `api.sh = NOT_FOUND` | "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`" |
| Other non-200 | Show status code and error message from response body. |

### Edge Cases

- **No config**: "Config not found. Run `/rkit:setup` first."
- **No default_team_id and no --team**: "No default team configured. Run `/rkit:setup` first."
- **Empty measures array**: "No active measures on this scorecard. Use `/rkit:scorecard add \"Name\"` to create one."
- **Measure owner is null**: Display "(none)" in table.
- **Non-numeric record value**: Catch client-side before API call. "Value must be a number."
- **Measure name matches multiple**: Show numbered disambiguation list. Do not proceed.
- **Measure name matches none**: "No measure found matching '{name}'."
- **API 422 on record**: Surface the API error message (e.g. "Date must be a Monday").

## References

- [ResultMaps V2 API Reference](references/api-reference.md)
