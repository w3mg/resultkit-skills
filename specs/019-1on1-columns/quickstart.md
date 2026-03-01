# Quickstart: 1:1 Columns

## Prerequisites

- ResultKit config at `~/.config/resultkit/config.json` with valid token and default_team_id
- At least one team with one-on-one meetings

## Verification Scenarios

### V1: API Team Filtering (must verify first)

```bash
API_SH="scripts/api.sh"

# Check if team_id param filters meetings
RESPONSE=$("$API_SH" GET "/meetings?team_id=TEAM_ID&per_page=5")
echo "$RESPONSE" | jq '.body.data | length'

# Compare with unfiltered
ALL=$("$API_SH" GET "/meetings?per_page=100")
echo "$ALL" | jq '[.body.data[] | select(.type == "one_on_one")] | length'
```

Expected: Filtered count <= unfiltered count. If team_id param has no effect, inspect meeting objects for team fields.

### V2: List 1:1s with default team

```
/rkit:1on1
```

Expected: Table showing only 1:1s for the default team. Header includes team name.

### V3: List 1:1s with --team override

```
/rkit:1on1 --team 5
```

Expected: Table showing only 1:1s for team 5.

### V4: List 1:1s with no team (fallback)

Remove `default_team_id` from config temporarily, then:

```
/rkit:1on1
```

Expected: All 1:1s shown, with hint to set a default team.

### V5: View 1:1 columns

```
/rkit:1on1 {meeting_id}
```

Expected: Header with both participants, three column sections (Next, Done, Blocked) with item tables.

### V6: Empty team

```
/rkit:1on1 --team {team_with_no_1on1s}
```

Expected: "No one-on-ones found for {team_name}."

### V7: Existing flows unchanged

```
/rkit:1on1 {meeting_id} next
/rkit:1on1 {meeting_id} move {item_id} done
/rkit:1on1 {meeting_id} add "Test item"
/rkit:1on1 {meeting_id} remove {item_id}
```

Expected: All existing flows work exactly as before.
