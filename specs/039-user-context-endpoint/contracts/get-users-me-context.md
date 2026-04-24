# Contract: GET /users/me/context

**Purpose**: Load a full organizational snapshot for the authenticated user in a single call. Designed for LLM consumption — provides everything needed to resolve team names, find IDs, and navigate to specific data without extra round-trips.

**Used by**: Any skill that needs to disambiguate user intent involving team names, org names, or items across multiple teams (e.g., "find my one-on-ones in Team Alpha", "show me two projects from the Leadership team").

## When to Use This Endpoint

Call `/users/me/context` when:

- The user references a **team by name** and you need the team ID
- The user asks about data **across multiple teams** (rocks, issues, measures, projects)
- The user says something **ambiguous** and you need their full org structure to interpret it
- A skill needs to **orient itself** at the start of a complex, multi-step workflow

Do NOT call this endpoint for:

- Simple operations where the team ID is already known (use `current_team` from config)
- Single-endpoint calls that don't need team context
- Operations that only need the user's profile (use `GET /users/me` instead)

## Request

```
GET /users/me/context
Authorization: Bearer <api_token>
```

No query parameters. No request body.

## Response -- 200 OK

Response is wrapped in a `data` property.

```json
{
  "data": {
    "user": {
      "id": 42,
      "name": "Scott Levy",
      "email": "scott@example.com",
      "login": "scottlevy",
      "avatar_url": "/photos/42/thumb.jpg"
    },
    "organizations": [
      {
        "id": 1,
        "name": "Acme Corp",
        "role": "owner",
        "teams": [
          {
            "id": 10,
            "name": "Leadership Team",
            "framework": "eos",
            "is_root": true,
            "role": {
              "is_admin": true,
              "designation": "visionary",
              "seats_owned": [
                { "id": 100, "name": "CEO" }
              ]
            },
            "vision": {
              "core_values": [
                { "id": 1, "name": "Integrity" },
                { "id": 2, "name": "Innovation" }
              ],
              "core_focus": {
                "purpose": "Help teams win",
                "niche": "Strategic execution software"
              },
              "bhag": "100,000 teams running on ResultMaps by 2030"
            },
            "three_year_plan": {
              "text": "Expand to 10,000 paying teams..."
            },
            "one_year_plan": {
              "goals": [
                { "id": 200, "name": "Launch V2 API", "status": "on_track" }
              ]
            },
            "rocks": [
              {
                "id": 300,
                "name": "Ship new scorecard",
                "status": "on_track",
                "due": "2026-06-30",
                "milestones": [
                  { "id": 301, "name": "Design complete", "status": "complete", "due": "2026-04-15" },
                  { "id": 302, "name": "Beta launch", "status": "on_track", "due": "2026-05-31" }
                ]
              }
            ],
            "measures": [
              {
                "id": 400,
                "name": "Weekly Active Users",
                "current_value": 1250,
                "target_value": 1500,
                "goal": "above",
                "unit": "users"
              }
            ],
            "projects": [
              {
                "id": 500,
                "name": "V2 Migration",
                "status": "on_track",
                "child_count": 3,
                "children": [
                  { "id": 501, "name": "API routes", "status": "complete" },
                  { "id": 502, "name": "Auth layer", "status": "on_track" },
                  { "id": 503, "name": "Data migration", "status": "not_started" }
                ]
              }
            ],
            "todos": [
              {
                "id": 600,
                "name": "Review PR #42",
                "status": "incomplete",
                "due": "2026-04-25"
              }
            ],
            "issues": [
              {
                "id": 700,
                "name": "Onboarding flow is confusing",
                "is_long_term": false,
                "owner": { "id": 42, "name": "Scott Levy" }
              }
            ]
          }
        ]
      }
    ],
    "day_plan": {
      "id": 900,
      "date": "2026-04-24",
      "items": [
        {
          "id": 601,
          "name": "Review PR #42",
          "completed": false,
          "position": 1,
          "team_id": 10,
          "team_name": "Leadership Team"
        }
      ]
    }
  }
}
```

## Field Reference

### Top-level

| Field | Type | Description |
|-------|------|-------------|
| `user` | object | Authenticated user profile |
| `organizations` | array | All orgs the user belongs to |
| `day_plan` | object \| null | Today's day plan (null if none exists) |

### `user`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | User ID |
| `name` | string | Full name |
| `email` | string | Email address |
| `login` | string | Username/handle |
| `avatar_url` | string \| null | Profile photo thumbnail path |

### `organizations[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Account ID |
| `name` | string | Organization name |
| `role` | string | `owner` or `member` |
| `teams` | array | All teams in this org the user belongs to |

### `organizations[].teams[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Team (group) ID |
| `name` | string | Team name |
| `framework` | string | Management framework (`eos`, `okr`, `4dx`, `v2mom`, `srt`, `svep`) |
| `is_root` | boolean | True if this is the org-level root team |
| `role` | object | User's role and permissions in this team |
| `vision` | object \| null | Vision data (may be inherited from root team) |
| `three_year_plan` | object \| null | Three-year picture |
| `one_year_plan` | object \| null | Annual plan with goals |
| `rocks` | array | Current quarter rocks with milestones |
| `measures` | array | Scorecard measures |
| `projects` | array | Active projects with immediate children |
| `todos` | array | Active incomplete to-dos assigned to this user |
| `issues` | array | Open issues in this team |

### `role`

| Field | Type | Description |
|-------|------|-------------|
| `is_admin` | boolean | Whether user is team admin |
| `designation` | string \| null | `visionary`, `integrator`, `leadership_team`, or `front_line` |
| `seats_owned` | array | Seats the user owns: `[{ id, name }]` |

### `vision`

| Field | Type | Description |
|-------|------|-------------|
| `core_values` | array | `[{ id, name }]` |
| `core_focus` | object \| null | `{ purpose, niche }` |
| `bhag` | string \| null | Big Hairy Audacious Goal / 10-year target |

### `rocks[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Rock ID |
| `name` | string | Rock title |
| `status` | string | Status value |
| `due` | string \| null | Due date (ISO date) |
| `milestones` | array | `[{ id, name, status, due }]` |

### `measures[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Measure ID |
| `name` | string | Measure title |
| `current_value` | number \| null | Latest value |
| `target_value` | number \| null | Target/goal value |
| `goal` | string | Tracking direction: `above`, `below`, or `exact` |
| `unit` | string \| null | Unit of measurement |

### `projects[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Project ID |
| `name` | string | Project title |
| `status` | string | Status value |
| `child_count` | integer | Total child count |
| `children` | array | Immediate children: `[{ id, name, status }]` |

### `todos[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | To-do ID |
| `name` | string | To-do title |
| `status` | string | Status value |
| `due` | string \| null | Due date (ISO date) |

### `issues[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Issue ID |
| `name` | string | Issue title |
| `is_long_term` | boolean | `false` = L10 short-term, `true` = VTO long-term |
| `owner` | object \| null | `{ id, name }` of the issue owner |

### `day_plan`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Day plan ID |
| `date` | string | ISO date |
| `items` | array | Ordered list of day plan items |

### `day_plan.items[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Item ID |
| `name` | string | Item title |
| `completed` | boolean | Whether the item is done |
| `position` | integer | Sort order |
| `team_id` | integer \| null | Team this item belongs to |
| `team_name` | string \| null | Team name |

## Disambiguation Patterns

### Resolving a team name to an ID

```
User: "show me the rocks for Product Team"

1. Call GET /users/me/context
2. Search organizations[].teams[] for name matching "Product Team"
3. Use the matched team's rocks[] directly from the response
   — or use the team's id for further API calls
```

### Finding items across teams

```
User: "what are all my open issues?"

1. Call GET /users/me/context
2. Iterate organizations[].teams[].issues[] to collect all issues
3. Group by team name for display
```

### Cross-team navigation

```
User: "let's look at two projects in the Leadership team"

1. Call GET /users/me/context
2. Find the team named "Leadership" (fuzzy match on name)
3. Read projects[] from that team — show the list and let the user pick
4. Use project IDs for follow-up calls (e.g., GET /items/{id}/children)
```

### Meeting context (one-on-ones, L10s)

```
User: "find my one-on-ones in the Sales team"

1. Call GET /users/me/context
2. Resolve "Sales team" to a team ID
3. Call GET /meetings?team_id={id}&meeting_type=one_on_one
   (meetings are NOT included in /context — use the team ID to fetch them)
```

## Response Behavior Notes

- **Empty collections** return `[]`, absent objects return `null`
- **Active-item filtering**: realized, archived, and deleted items are excluded
- **day_plan is root-level**, not nested under a team
- **Vision data may be inherited** from the root team
- **Rocks are current quarter only**
- **Todos are filtered** to active/incomplete items assigned to the authenticated user
- **Projects include immediate children** only (one level deep)

## Response -- 401 Unauthorized

```json
{
  "error": "Invalid or missing token"
}
```

**Skill behavior**: Token is invalid or expired. Prompt user to re-run `/rkit:setup`.

## See Also

- `GET /users/me` — basic profile + `?include=access` for role enrichment on current/default team only
- `PATCH /users/me/team-context` — set active team (changes `current_team` in `/users/me`)
- `GET /meetings` — meetings are NOT in `/context`; use team ID from context to query meetings
