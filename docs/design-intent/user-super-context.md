# User Super Context

## Success Criteria

### 1. Comprehensive User Context Document

The system must produce a single context document for any given user that includes:

- **Teams & Organizations** — every team and organization the user belongs to, with their role in each
- **Visions** — the vision statements for each team/org, scoped so the user sees only what's relevant to them
- **One-Year Plans** — annual plans for each team/org the user is part of
- **One-Year Goals** — the specific goals within those plans that relate to the user
- **Quarterly OKRs & Milestones** — objectives, key results, and milestones for the current quarter, filtered to those the user owns, contributes to, or is accountable for
- **Projects & To-Dos** — the user's active projects and tasks across all their teams
- **Day Plan** — the user's plan for today (or the current working day)
- **Logged Issues** — issues the user has created or been assigned, including where they were logged (which team, which board, which project)

All items must be **context-aware**: each vision, plan, goal, OKR, milestone, project, to-do, and issue must be presented within its team and organization hierarchy so the LLM consumer knows exactly where everything sits.

### 2. Progressive Disclosure Without File Organization

The context document must be structured so that an LLM can progressively disclose information — starting broad (teams, orgs) and drilling into detail (specific OKRs, to-dos, issues) — driven entirely by the shape of the data itself, not by how files are organized on disk. The hierarchy lives in the document structure, not in a directory tree. This means:

- An LLM can start a conversation with just the top-level summary (who the user is, which teams/orgs) and pull in deeper layers only as the conversation demands
- The document's internal structure provides the navigation path — org → team → vision → plan → goal → OKR → project → task — so the LLM knows what's available and can make targeted API calls to fetch deeper detail as needed
- Deeper layers don't need to be pre-loaded into the document; the structure tells the LLM what to ask for, and API calls retrieve it on demand
- No filesystem conventions, folder nesting, or file-splitting schemes are required to achieve this

### Purpose

This document serves as a complete, structured context payload for any LLM layer — enabling personalized, organization-aware responses without requiring the LLM to make additional API calls to understand who the user is and what they're working on.

---

## Suggested Payload Structure (JSON)

The top level is the user. Organizations contain teams. Everything else nests under the team it belongs to. Deeper detail (items within a project, history on a measure) is referenced by ID so the LLM can fetch it via API when needed.

```json
{
  "user": {
    "id": "u_123",
    "name": "Scott Levy",
    "email": "scott@example.com"
  },
  "organizations": [
    {
      "id": "org_1",
      "name": "ResultMaps",
      "role": "owner",
      "teams": [
        {
          "id": "team_1",
          "name": "Product",
          "role": "leader",
          "vision": {
            "id": "vis_1",
            "statement": "..."
          },
          "one_year_plan": {
            "id": "plan_1",
            "name": "FY2026 Product Plan",
            "goals": [
              {
                "id": "goal_1",
                "name": "Launch V2 API",
                "status": "on_track"
              }
            ]
          },
          "quarterly_okrs": [
            {
              "id": "okr_1",
              "objective": "Ship user super context",
              "quarter": "Q2 2026",
              "key_results": [
                {
                  "id": "kr_1",
                  "name": "API endpoint live",
                  "current": 0,
                  "target": 1
                }
              ],
              "milestones": [
                {
                  "id": "ms_1",
                  "name": "Design doc approved",
                  "due": "2026-04-25",
                  "status": "complete"
                }
              ]
            }
          ],
          "projects": [
            {
              "id": "proj_1",
              "name": "User Super Context",
              "status": "active",
              "todo_count": 4,
              "todos": [
                {
                  "id": "todo_1",
                  "title": "Draft JSON schema",
                  "status": "in_progress",
                  "due": "2026-04-18"
                }
              ]
            }
          ],
          "issues": [
            {
              "id": "issue_1",
              "title": "API returns stale team list",
              "status": "open",
              "source": "github",
              "repo": "resultmaps-api2"
            }
          ]
        }
      ]
    }
  ],
  "day_plan": {
    "date": "2026-04-18",
    "items": [
      {
        "id": "dp_1",
        "title": "Finalize super context design doc",
        "team_id": "team_1",
        "linked_todo_id": "todo_1"
      }
    ]
  }
}
```

### Key design choices

- **Org → Team → everything else.** Every item is reachable through its team, which is reachable through its org. No orphaned context.
- **IDs everywhere.** The LLM can use any ID to make a targeted API call for deeper detail without loading the full tree.
- **Day plan at the top level.** It crosses teams, so it sits next to the user rather than inside a single team.
- **Issues carry their source.** `source` and `repo`/`board` tell the LLM where the issue lives without a separate lookup.

---

## Context Inventory

### Organization context (shared across all teams in the org)

1. **Organizations** — the orgs the user belongs to
2. **Teams** — the teams within each org, with the user's role, designations, and permissions
3. **Vision** — the org's vision statement
4. **Three-Year Business Plan** — the org's three-year strategic plan
5. **One-Year Business Plan** — the org's annual plan
6. **One-Year Goals** — specific goals within the one-year plan
7. **Quarterly Rocks** — the rocks for the current quarter, with milestones nested under them
8. **Measurables / Scorecard data** — metrics the user is accountable for within a team

### Team context

9. **Projects** — active projects only, with immediate children (not full item trees)
10. **To-Dos / Items** — active items relevant to the user
11. **Logged Issues** — issues the user has created or been assigned, with their source (which team, board, repo)

### Personal context

12. **Day Plan** — the user's plan for today, including the source of each item (which team/org/project it came from)

---

## Design Constraints

These are tensions and concerns that must be managed as this payload evolves. They're here to keep the design honest.

### Balancing detail for efficiency and effectiveness

Progressive disclosure creates competing concerns: too little context and the LLM makes unnecessary API calls or gives shallow answers; too much context and the payload bloats the context window and drowns signal in noise. The right level of detail depends on what the data is:

- **Go deep where it matters.** A user's measurables, their org's one-year goals, rocks, and milestones — these are the strategic backbone. They should be present as nested JSON arrays with enough detail to reason about without follow-up calls.
- **Go shallow where depth isn't immediately useful.** Projects should be listed, but not every item in every project. Include only the first level of immediate children. The LLM can fetch deeper item trees via API when the conversation calls for it.
- **Filter aggressively at the source.** The payload must exclude closed projects, inactive projects, completed to-dos, and other noise that adds volume without adding context. These filters will need to be specified as part of the endpoint contract — what gets included is as important as what the shape looks like.

The guiding question: _does including this data help the LLM give a better answer in the first exchange, or is it detail that only matters once the user asks about it?_ If the latter, leave it behind an API call.

### Infinite item nesting

Items in ResultMaps can nest arbitrarily deep (sub-items, sub-sub-items, etc.). The payload cannot inline the full tree. Include only immediate children of top-level containers (projects, rocks), with counts or summary indicators for deeper levels, and provide endpoint references so the LLM can drill in on demand.

### Org/team permissions and designations

The user's relationship to an org and its teams is not just a simple role string. Recent spec work defines designations and fine-grained permissions that govern what a user can see and do within rocks, milestones, and other structures. The payload must represent these accurately enough that the LLM can reason about what the user has access to — but the representation needs to stay traversable, not buried in permission matrices.

### Payload size discipline

The whole point of progressive disclosure is that this payload stays lean. Every field included in the initial document is a field that gets loaded into every conversation. The bias should be toward summaries and IDs at the top level, with API calls for depth. If the payload grows large enough to crowd an LLM context window, it has failed its purpose.

### Traversability

Rocks, milestones, OKRs, scorecards, and items all have their own internal structures and relationships. The nesting in the JSON must remain easy to walk — an LLM reading this payload should be able to answer "what is this user working on today?" without parsing deeply nested trees. If the structure requires more than a few hops to reach any piece of information, it needs flattening or cross-referencing.
