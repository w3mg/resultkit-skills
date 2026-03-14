# Quickstart: Team Context Endpoint

**Branch**: `037-team-context-endpoint-32`

## What's Changing

1. **api-reference.md** — new endpoint + updated `current_team` note
2. **`rkit:teams` SKILL.md** — new `use {team_id}` action
3. **All skill api-reference copies** — updated via `/sync-plugin`

## Implementation Order

### 1. Update master api-reference.md

**In the Users table** — add after the `POST /users/me/password` row:

```markdown
| PATCH | `/users/me/team-context` | Set the authenticated user's active team (body: team_id*). Returns `{ data: { id, name } }` of the newly active team. Idempotent. | "switch team", "use team", "set active team", "change my team" | — |
```

**Update the `GET /users/me` row** — change:

```
Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`.
```

to:

```
Authenticated user (includes api_token, default_team, current_team). Response wrapped in `{ data: { ... } }`. `current_team` reflects the team last set via `PATCH /users/me/team-context` (was always null before 2026-03-13 API fix).
```

**Update the User fields prose block** — add note that `current_team` is now populated:

```
`current_team` (TeamSimple | null) — reflects the team last set via `PATCH /users/me/team-context`. Non-null after at least one team-context set call.
```

**In the User Phrases lookup table** — add row:

```markdown
| switch team, use team, set active team, change my team, team context | Set Active Team | `PATCH /users/me/team-context` |
```

### 2. Update `skills/teams/SKILL.md`

**In Argument Parsing table** — add row:

```markdown
| `use {team_id}` | Set the server-side active team to the given team ID |
```

**Add new Flow section** (after existing flows):

```markdown
## Flow: Set Active Team

Triggered by: `use {team_id}`

### Step 1: Validate args

- Extract `team_id` from args.
- If missing or not numeric: "Usage: `/rkit:teams use {team_id}`\n  Example: `/rkit:teams use 8`" — stop.

### Step 2: Fetch team name for confirmation

GET /teams/{team_id} to get team name for the confirmation prompt.

- On 404: "Team {team_id} not found." — stop.
- On 401: "Unauthorized (401). Run `/rkit:setup` to update your token." — stop.

### Step 3: Confirm

Show the proposed action and ask for confirmation:

  Set active team to **{name}** (ID: {team_id})?

### Step 4: Execute

PATCH /users/me/team-context with body `{"team_id": team_id}`.

- On 200: "Active team set to **{name}** (ID: {id})."
- On 401: "Unauthorized (401). Run `/rkit:setup` to update your token."
- On 422: "Cannot set team (422): {error from API body}"
- Other: Show status code and error message.
```

### 3. Run `/sync-plugin`

Copies updated api-reference.md to all skill `references/` directories and bumps the plugin version.

## Testing

```bash
# Verify endpoint exists and returns expected shape
bash scripts/api.sh PATCH "/users/me/team-context" '{"team_id": YOUR_TEAM_ID}'
# Expected: {"status":200,"body":{"data":{"id":YOUR_TEAM_ID,"name":"..."}}}

# Verify current_team is now populated
bash scripts/api.sh GET "/users/me"
# Expected: body.data.current_team should match the team just set

# Test 422 — not a member or bad ID
bash scripts/api.sh PATCH "/users/me/team-context" '{"team_id": 999999}'
# Expected: {"status":422,...}
```
