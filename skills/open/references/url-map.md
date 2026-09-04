# ResultKit web URL map

Base: `https://resultkit.ai`. Override with `web_base` in `~/.config/resultkit/config.json` or the `RESULTKIT_WEB_BASE` environment variable (a local worktree such as `http://localhost:3001`, or staging). Never link to the legacy `app.resultmaps.com` UI — it is a different application with a different session.

Every path below is relative to the base. `rk-open.sh` builds all of them; this file is the reasoning behind its choices and the long tail it does not cover with a dedicated kind.

## Contents

1. The item link, and why it is `/items/{id}`
2. The item sheet on a surface (`?item=` and `?tab=`)
3. Projects
4. Pages, teams, people
5. Level 10 meeting
6. Goals, rocks, milestones (`?target=`)
7. EOS components, scorecard, accountability chart (`?seat=`)
8. Reviews, 1-on-1s, roadmaps, result updates, meetings
9. Personal surfaces
10. Which parameters exist, and where `?team=` is honored
11. Legacy `app.resultmaps.com` conversions
12. The search API's `url_hint` is not a URL

---

## 1. The item link: `/items/{id}`

`https://resultkit.ai/items/{id}` is the link for an action item, to-do, step, issue, or headline. Three facts make it the only safe shape:

1. **The root path is not the app for a fresh tab.** `/` is served by a middleware that looks for an `rm_api_token` cookie. The app keeps its session in localStorage and that cookie is scoped to `.resultmaps.com`, which browsers never send to `resultkit.ai`. So a signed-in person opening `https://resultkit.ai/?item=123` in a new tab gets the marketing home, whose pre-paint script bounces token holders to `/?app=1` — dropping every other query parameter, the item included. They land on Home with nothing open, and nothing tells them why. (web-ui-2: `middleware.ts`, `public/marketing/home.html`.)
2. **A signed-out person loses the query string.** The auth guard sends them to `/login?returnTo=<pathname>` — pathname only. `/prioritizer?item=123` comes back from login as `/prioritizer`; `/items/123` comes back whole.
3. **`/items/{id}` needs no surface and no team.** The route renders Home with the item sheet already opening over it, then shallowly rewrites the address bar to `/?item={id}` without navigating. The sheet resolves the item's own team from the item, so `?team=` is unnecessary, and an item from another team opens under that team's rules. Spec: https://resultkit.ai/pages/749 (mirror in web-ui-2 at `docs/design-intent/item-url-without-context/`).

One consequence of the rewrite in (3): `/items/{id}` keeps nothing but the id. A tab (`?tab=comments`) or a chosen surface has to use the shape in section 2.

A deleted item, or one the viewer cannot see, still opens the sheet — with "Item not found." and a Dismiss control — rather than a 404 page. Checking `GET /items/{id}` before opening is still worth the call: it gives you the name to report and catches the miss in the terminal instead of in a tab.

## 2. The item sheet on a surface

```
/{surface}?item={id}
/{surface}?item={id}&tab={details|comments|steps|alignment}
```

The sheet is mounted globally in the authenticated layout, so any authenticated path works as `{surface}`. Choose the surface for context, not for the item:

| You want | Surface |
|---|---|
| A tab, nothing else in mind | `/prioritizer` — personal, always accessible, no team prompt |
| The item over its team's meeting | `/level-10-meeting?team={team_id}&tab=kanban` |
| The item over its project board | `/plugins/projects/{project_id}/board` |
| The item over a team home | `/teams/{team_id}` |
| The item over a page | `/pages/{page_id}` |

Two things to know: `?item=` and `?target=` are mutually exclusive (the app clears `target` when `item` is set), and the Level 10 page may ask the viewer to switch teams when the item belongs to a team other than the current one.

## 3. Projects

A project is an Item underneath — `type` comes back `null` in v2 responses — so an ID alone does not say which it is. `GET /projects/{id}` answers: 200 means project, 404 (`"Project not found"`) means plain item.

```
/plugins/projects/{id}                the app redirects to the project's shared default view
/plugins/projects/{id}/overview
/plugins/projects/{id}/board
/plugins/projects/{id}/table
/plugins/projects/{id}/gantt          the API calls this view "roadmap"
/plugins/projects?team={team_id}      the team's project list
```

Prefer the bare `/plugins/projects/{id}`: the app reads `default_view` (`overview`, `board`, `table`, `roadmap` → `gantt`; `outline` and `mindmap` fall back to overview) and switches the viewer to the project's team. Name a view only when the user did.

## 4. Pages, teams, people

```
/pages/{id}                 a page (team wiki/doc); the page carries its own team
/teams/{id}                 team home
/teams/{id}/daily-updates   the team's daily updates
/users/{id}                 a person's profile; "me" → GET /users/me for the id
```

## 5. Level 10 meeting

```
/level-10-meeting?team={team_id}
/level-10-meeting?team={team_id}&tab=agenda      default
/level-10-meeting?team={team_id}&tab=kanban
/level-10-meeting?team={team_id}&tab=extras      "notes" is a legacy alias
```

Always pass `team=`; without it the page shows whichever team the viewer last used. Non-EOS frameworks have the same page under their own meeting name.

## 6. Goals, rocks, milestones: `?target={id}`

```
/components?tab=traction&team={team_id}&target={id}
```

The target drawer is mounted globally, but when it is opened from a URL it looks the id up in the **current team's** targets tree for the **current year and quarter** (`GET /api/v2/teams/{current}/targets`, no period parameters). The wrong current team means "not found", and so does a target from an earlier period. `/components` honors `?team=`, which is what makes this shape reliable; `tab=traction` puts the rocks board behind the drawer. The id is the goal's, rock's, or milestone's own id — the same ids `GET /teams/{id}/targets`, `/teams/{id}/goals`, `/teams/{id}/rocks`, and `/teams/{id}/milestones` return. For a past period there is no drawer deep link; open the period's board instead: `/components?tab=traction&team={team_id}&year={YYYY}` (the traction tab reads `year`). Personal rocks live at `/prioritizer/rocks`.

## 7. EOS components, scorecard, accountability chart

```
/components?tab={vision|people|data|issues|traction|process}&team={team_id}
/components?tab=data&team={team_id}          the scorecard (no per-measure deep link exists)
/vision                                      Vision / V/TO
/plugins/accountability-chart                current team's chart
/plugins/accountability-chart?seat={seat_id} chart with a seat's drawer open
/eos-components                              the tile page linking to all of the above
```

The accountability chart is scoped to the current team and does not read `?team=`; if the seat belongs to another team, tell the user to switch teams in the top bar first.

## 8. Reviews, 1-on-1s, roadmaps, result updates, meetings

```
/reviews/{id}                 /reviews/{id}/results     /reviews/{id}/print
/reviews                      dashboard (my-reviews, team, templates, action-items tabs)
/1-on-1/{id}                  /1-on-1/{id}/print
/roadmaps/{id}                /roadmaps/new             /roadmap (index)
/result-update/{YYYY-MM-DD}   /result-update (today)
/meetings                     hub of meeting types
/team-rhythm-quarterly        /team-business-review
```

## 9. Personal surfaces

```
/                       Home
/prioritizer            day plan (tabs: /day-week, /custom-columns, /quadrants, /rocks, /sequencer, /timeline, /outbox)
/notifications
/customize              profile settings — where the API token lives
/chat                   the AI chat surface
/discover  /progress  /reports  /integrations  /settings
```

## 10. Parameters the app reads from a URL

| Param | Meaning | Read on |
|---|---|---|
| `item={id}` | open the item sheet | every authenticated page |
| `tab=` | sheet tab (`details`, `comments`, `steps`, `alignment`); L10 tab (`agenda`, `kanban`, `extras`); components tab | the surface that owns it |
| `target={id}` | open the goal/rock/milestone drawer (current team's tree) | every authenticated page |
| `seat={id}` | open a seat's drawer | `/plugins/accountability-chart` |
| `team={id}` | switch the viewer's current team | `/level-10-meeting`, `/plugins/projects`, `/components` |
| `year=`, `quarter=` | period selectors | quarterly and traction views |
| `scope=personal`, `filter=` | traction scope and status filter | `/components?tab=traction` |
| `returnTo=` | where login sends the viewer afterwards (pathname only) | `/login` |

Everything else in a URL is ignored by the app. Do not invent parameters.

## 11. Legacy `app.resultmaps.com` conversions

The legacy Rails UI and ResultKit share the same database and ids.

| Legacy | ResultKit |
|---|---|
| `/items/{id}` (and `/items/{id}/overview`) | `/items/{id}` |
| `/groups/{id}` | `/teams/{id}` |
| `/users/{id}` | `/users/{id}` |
| anything else (`/day_plans/…`, `/todolists/…`, `/pages/…` in the old UI, …) | no mapping — say so, then offer the nearest ResultKit surface from this file |

`rk-open.sh url <legacy-url>` performs the three conversions and returns `LEGACY_UNMAPPED` for the rest.

## 12. The search API's `url_hint` is not a URL

`GET /search` returns a `url_hint` per result. It is right for items, pages, people, and reviews (`/items/{id}`, `/pages/{id}`, `/users/{id}`, `/reviews/{id}`) and wrong for the rest: projects come back as `/items/{id}` (the sheet, not the project page), rocks as `/goals/{id}` and measures as `/measures/{id}`, neither of which exists in the app. Route by `entity_type` and build the URL from this file.
