# ResultMaps App — Screen & Context Inventory (current app)

## Part 1 — What this is

A hierarchical list of the **current app's screens (resultmaps-web-ui-2)**, grouped by the **context** each one belongs to. Legacy is out of scope.

The grouping is not invented — it follows the context model already defined in `rk-permission-expert/knowledge/shared-contexts.md` (Individual / Team / Project / Meeting) plus the org boundary from `organization-expert`. Read as:

- **Personal** = only you see it (the Individual context).
- **Team** = shared with everyone on the team (includes the Meeting surfaces).
- **Project** = scoped to one project; lives inside a team.
- **Global** = spans the whole organization.

Numbering is hierarchical (1, 1.1, 1.1.1) — a screen's number tells you its context and its parent. The top-level nav spine comes from the real sidebar (`components/layout/unified-sidebar.tsx`); tabs come from each page's own tab code.

## Part 2 — The hierarchy

### 1. Personal context — only the individual sees it
- 1.1 Prioritizer — `/prioritizer` (tabs: Sequencer, Day/Week, Timeline, Custom, Quadrants, Inbox, Outbox)
- 1.2 Notifications — `/notifications`
- 1.3 Profile — `/users/{id}`
- 1.4 Personal Settings — `/settings`
- 1.5 Change Password — `/change-password`
- 1.6 Customize — `/customize` (like settings)

### 2. Team context — shared with the team
- 2.1 EOS Components — `/components`
  - 2.1.1 Vision
  - 2.1.2 People (accountability chart, quarterly conversations, teams)
  - 2.1.3 Data (scorecard)
  - 2.1.4 Issues
  - 2.1.5 Traction (one-year goals, quarterly Rocks, milestones)
  - 2.1.6 Process
- 2.2 Meetings — `/meetings`
  - 2.2.1 Level 10 Meeting — `/level-10-meeting` (tabs: Agenda, Kanban, To-Do Ownership, Notes)
  - 2.2.2 1-on-1 — `/1-on-1`
  - 2.2.3 Quarterly — `/team-rhythm-quarterly`
- 2.3 Projects
  - 2.3.1 Swimlane Roadmap builder — `/roadmaps/{id}` and `/roadmaps/new` (appears where Projects do; same context; `/roadmap` redirects to `/roadmaps/new`). Three views, chosen in the
    roadmap toolbar (`components/roadmap/roadmap-toolbar.tsx`: `RoadmapView = "timeline" | "status" | "calendar"`):
    - 2.3.1.1 Roadmap — Timeline view
    - 2.3.1.2 Roadmap — Status view
    - 2.3.1.3 Roadmap — Calendar view, which has four sub-views
      (`CALENDAR_SUB_VIEWS = ["day_grid", "agenda", "spans", "deadlines"]`). **Each sub-view is its own
      surface for spec purposes** — they organize items by different date axes (a single day, a week, a
      start/end range, a due date), so a behavior that holds on one does not follow on the others:
      - 2.3.1.3.a Calendar — Day grid
      - 2.3.1.3.b Calendar — Agenda
      - 2.3.1.3.c Calendar — Spans
      - 2.3.1.3.d Calendar — Deadlines
      - Calendar — Unscheduled tray
  - 2.3.2 Swimlane Roadmaps list — `/plugins/projects?tab=swimlane-roadmaps` (the **"Swimlane Roadmaps"** tab of the Projects plugin page; sibling tab **"Projects"**). A scope pill group — **"This team" · "Organization" · "All ResultKit"** — filters which teams' saved roadmaps the list gathers; rows link to the builder (2.3.1).
  - 2.3.3 Project detail — `/plugins/projects/{id}` (views: Board `/board`, Table `/table`, Gantt `/gantt`, Overview `/overview`). The bare `/plugins/projects/{id}` route redirects to the project's default view; each view is its own route segment and its own surface for spec purposes.
- 2.4 Pages — `/pages`
- 2.5 Teams — `/teams`
- 2.6 Reviews — `/reviews` (team scope, like Projects)
- 2.7 Quarterly Business Review (a.k.a. Quarterly/Monthly Business Review) — `/team-business-review`
  (the team's business review report; year + quarter chosen in the toolbar)
- 2.8 Daily Updates — `/teams/{id}/daily-updates` (the team's daily-update feed; the team whose
  updates are shown is identified in the URL)

### 3. Global context — across the whole organization
- 3.1 Reports — `/reports`

### 4. Settings bucket — parked for now (low priority)
- 4.1 Discover — `/discover`
- 4.2 Integrations — `/integrations`, `/plugins`

## Part 3 — Shared surfaces (open over any context)

Not nav-spine pages — these open on top of whatever page you're on, and their layout is the same regardless of which context launched them.

### Item sheet — the single-item detail view
Reached by opening any action item from an item list in any context — e.g. the Personal **Prioritizer**, the Team **Level 10 Meeting** (Agenda, Kanban, or To-Do Ownership tab), or **Projects**.

#### Label dropdown (a subsection of the item sheet)
Opened by the **`+Label`** control (tag icon + "+Label") on the item sheet. Appears as a bordered card anchored under that control (the mechanism — popover vs. inline expansion — is not asserted here). Layout, top to bottom:

```
+-------------------------------------------------+
|  (search)  Search labels...                     |
+-------------------------------------------------+
|  Personal                                       |
|  + New label                                    |
+-------------------------------------------------+
|  Team: {Team Name}                              |
|  [ ]  (o)  {Label name}           [edit] [del]  |
|  [ ]  (o)  {Label name}           [edit] [del]  |
|  [ ]  (o)  {Label name...}        [edit] [del]  |
|  + New label                                    |
+-------------------------------------------------+
|  Project: {Project Name}   (only in a project)  |
|  [ ]  (o)  {Label name}           [edit] [del]  |
|  + New label                                    |
+-------------------------------------------------+

  legend:  (search) magnifier    (o) label color dot
           [ ] checkbox to apply the label to this item
           [edit] pencil icon    [del] trash icon
```

- **Up to three self-contained sections** — **Personal** (top), **`Team: {team name}`**, and **`Project: {project name}`** — each with its own header and its own **`+ New label`** at its foot. The **Project** section renders **only when the item is in a project** (`custom-label-filter.tsx`: "Project section — only when projectId is provided"); Personal and Team always show. Each section's `+ New label` creates a label in that scope — personal (every user manages their own, no admin gate), team (team-admin gated), project (project-admin gated).
- **Label row (Team or Project), left → right:** checkbox (apply the label to this item) · color dot · label name (**truncates with `...`** when long) · **edit** (pencil) · **delete** (trash). The edit/delete controls show only to that scope's admin.
- **Search row** at top filters the list by name.
- The **Personal** section can be empty (only its `+ New label` shows).
- The same picker (`custom-label-picker`) is reached both from the item sheet's **`+Label`** control and from the **project item-detail sidebar** (`components/projects/item-detail-sidebar/`, opened for an item inside a project).

**Sample values below are illustrative only** — captured from a 2026-07-05 screenshot of the item sheet label dropdown; they are not part of the spec and vary by account:
- Team header read `Team: Platform Team`.
- Team labels: **Customers - New Deals** (red), **Needs clarification** (yellow), **Throughput/friction removal** (purple).
- Personal section: empty (only `+ New label`).
- This screenshot was a **non-project** item, so no `Project: {project name}` section appeared — that section renders only for an item inside a project.

The **structure** above is binding; the specific label names, team name, and colors are not.

### Measure edit sheet — the single edit surface for a Measurable
Added 2026-07-12 (measurable-data-sources project — prototypes are binding). A right-side
sheet reached by opening a Measurable from the **Data (scorecard)** screen (2.1.3) or the
**1:1** Measures section (2.2.2). Header is the click-to-edit Measurable name (no divider).
Tabs: **Settings · Description · Data Source · History**.

- **Data Source tab** — source type (Manual, or Connected via an account-level Connection),
  request path under the connection's base, response field picker + aggregation, test
  preview, weekly sync schedule + Refresh now. Binding prototype:
  `app-design-projects/measurable-data-sources/measurable_data_source_setup_v2.html`.
- **History tab** — day-grouped change feed for the Measurable (synced values, manual
  overrides with old → new, settings changes, connection events) with All/Values/Settings/
  Connection filters. Binding prototype:
  `app-design-projects/measurable-data-sources/measurable_history_tab_v2.html`.

Related: **Integrations (4.2)** hosts the account-level **Connections** section (create/
test/disconnect/reconnect; credential entered once, admin-managed). Binding prototype:
`app-design-projects/measurable-data-sources/connection_manager_v1.html`.

### Command palette (global search) — added 2026-07-17
Opened from anywhere in the app with **Cmd+K** (Ctrl+K on Windows) — a modal over whatever page is open. Three tabs, cycled with **Tab**: **Search · History · Hotkeys**. Typing in Search returns results across entity types — Items, Rocks, Measures, Projects, People, Meetings (1-on-1), Pages, Reviews — and selecting a result navigates to that entity's screen or surface. Layout is the same regardless of which context launched it.

### Global team selector (top-bar "Switch team") — added 2026-07-23
The global top-bar **"Switch team"** control (aria-label **"Switch team"**), present on every authenticated page. It shows the current team's name and opens a searchable list (**"Search teams..."**, empty text **"No teams found"**) of every team the viewer belongs to, the current organization's tree first. A team in **another** organization is labeled **"{Organization}/{team}"**; an organization's **root** team is labeled with just its name. Selecting a team switches the global team context, and every team-scoped surface follows. The control is also switched **programmatically** when a viewer drills into — or deep-links — a roadmap that belongs to a different team (see 2.3.2 and the swimlane-roadmaps-scope spec).
