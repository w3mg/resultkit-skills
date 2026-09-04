# Resolving a name to something you can open

Four endpoints cover everything this skill needs. All calls go through `api.sh`, which returns `{"status": <int>, "body": …}`.

## 1. Full-text search — `GET /search`

```bash
Q=$(jq -rn --arg q "THE NAME" '$q|@uri')
"$API_SH" GET "/search?q=$Q&types=items,projects,pages,rocks,people,reviews&limit=5"
```

- `q` — two characters minimum; 400 below that. URL-encode it; names carry spaces, `#`, `&`, and `@`.
- `types` — comma-separated subset of `items,rocks,measures,projects,people,meetings,pages,reviews`; omit for all eight. Narrow it whenever the user's words name a kind: "the … project" → `projects`; "the … page" → `pages`; "rock"/"goal" → `rocks`; a person's name → `people`.
- `limit` — per type, default 20. Five is plenty for a disambiguation table.

Response body:

```json
{ "groups": { "items": [ … ], "projects": [ … ], "pages": [ … ], "rocks": [ … ], "people": [ … ], "reviews": [ … ], "measures": [ … ], "meetings": [ … ] }, "total": 6 }
```

Each hit: `{ id, entity_type, name, status, assignee, due_date, team_id, team_name, url_hint }`. `entity_type` is one of `Item`, `Project`, `Page`, `Rock`, `Person`, `Review`, `Measure`, `Meeting`. Only the caller's visible objects come back, so a miss can mean "not yours" as well as "not there".

**Ignore `url_hint`.** It is a hint for the legacy UI's routes: right for items, pages, people, and reviews; wrong for projects (points at the sheet, not the project page), rocks (`/goals/{id}`), and measures (`/measures/{id}`), the last two being paths the app does not have. Build the URL from the type — the map is in `url-map.md`.

Flatten for a table:

```bash
… | jq -r '.body.groups | to_entries[] | .value[] | [.entity_type, .id, .name, (.team_name // "—"), (.status // "")] | @tsv'
```

## 2. Disambiguation

One hit → open it and say what you opened. Several → show them and ask:

```
| # | Type | ID | Name | Team |
|---|---|---|---|---|
| 1 | Project | 216967 | Mender Platform Roadmap | Mender |
| 2 | Item | 184642 | 2025 Platform Engineering Roadmap | ResultMaps Incorporated |

Which one?
```

Then "#2", "the second", "the Mender one", or the ID picks a row. Keep the table in your reply so a later "open it" has something to point at. If exactly one hit matches the kind the user named ("the project"), that is the one — no need to ask.

## 3. When search is thin

Search indexes names. When it returns nothing useful:

- **The user's own items** — `GET /items?q=WORD&per_page=10` (their items across teams; `q` is a contains-match, two characters minimum).
- **A team's projects** — `GET /teams/{team_id}/projects?q=WORD` (active, non-parking-lot by default; add `status=` or `include_muted=true` to widen).
- **A team's pages** — `GET /teams/{team_id}/pages` returns the whole flat tree; filter with `jq '.body.data[] | select(.title | test("WORD"; "i")) | {id, title, parent_id}'`.
- **A team's rocks and goals** — `GET /teams/{team_id}/targets` returns the tree; `jq '[.body.data.targets[], (.body.data.unaligned // [])[] | .. | objects | select(.name? // "" | test("WORD"; "i"))] | map({id, name, object_type})'`.
- **A person** — `GET /users/search?q=NAME`.

Use `default_team_id` from config when the user did not name a team.

## 4. Confirming an ID before opening

| Kind | Call | 200 means | 404 means |
|---|---|---|---|
| item | `GET /items/{id}` | exists, you get `name`, `team`, `status` | not found or no access |
| project | `GET /projects/{id}` | it is a project; `default_view` tells you its landing view | it is a plain item (or nothing) |
| team | `GET /teams/{id}` | name for the report | — |
| target | `GET /teams/{team}/targets` then find the id in the tree | name and `object_type` (`yearly_goal`, `rock`, `milestone`) | wrong team or no such target |

An item ID always gets both the `/items` and the `/projects` call: the second one decides whether the sheet or the project page is the better place to open.

## 5. "Open it" after an earlier reply

Other rkit skills always show IDs (constitution rule V). "Open it", "open #2", "open the first one" refer to the last table or list in the conversation. Take the ID from that row and route by what the row was (an item from `rkit:today` or `rkit:board`, a project from `rkit:projects`, a page from `rkit:pages`, a rock from `rkit:strategy`, a person from `rkit:teams`). Ask only when the reference could fit more than one row or the previous reply carried no IDs.
