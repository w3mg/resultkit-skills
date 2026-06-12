# Draft Issue (NOT FILED)

**Target repo:** `w3mg/resultmaps-web-ui-2`
**Proposed labels:** `enhancement`, `Needs clarification`

**Title:** Measurables scorecard CSV export — capability already shipped; confirm which gap prompted the request

---

## Issue body

### Request

We need a CSV export button on the measurables scorecard, so a user can download the scorecard table (measurables, targets, and period values) as a CSV file.

### Current state — verified before filing

The main measurables scorecard **already has CSV export**, shipped to `main` on 2026-03-07:

- `components/components/scorecard/scorecard-view.tsx` renders an icon-only toolbar button (`title="Download scorecard data as CSV"`) next to the scorecard settings gear. Click → `buildCsv()` → browser blob download as `ResultMaps-scorecard.csv`.
- Export is generated client-side from the measures data already loaded via `GET /api/v2/teams/:id/measures` (`use-scorecard.ts`). Columns: Name, Unit, Owner, Target, plus one column per displayed date period. It respects the active weekly/monthly/quarterly toggle and the most-recent-first/oldest-first ordering, with correct CSV quoting (regression-tested in `67ed76fe`).
- Introduced in `da5076b0` "feat(scorecard): add CSV export matching old site".
- The button appears on **both** surfaces that host the scorecard: Components page → Scorecard tab, and the Level 10 meeting scorecard section (toolbar portal).
- The binding design prototype `docs/design-intent/scorecard-grid-redesign/measurables_data_grid_v1.html` specifies this same icon-only Export button (line 411); the built UI matches it.
- The legacy app's scorecard (`resultmaps-web` → `app/views/groups/scorecard.html.erb`, `scorecard_csv_plugin.js`) also has CSV export, which the new UI deliberately mirrors.

### Notes on the originally proposed approach

Recorded so the next person doesn't chase it:

- **"Add a route in api2 that dumps the scorecard table to CSV"** — `resultmaps-api2` has no CSV endpoints anywhere; it is JSON-only. Both existing scorecard exports (legacy and new UI) generate the CSV on the client from data the page already has. A server-side CSV route would be a new pattern in the API, and no requirement found so far needs one. If a real need emerges (e.g., exporting more history than the page loads), that is an architectural question to raise explicitly, not a default.
- **"Copy the export button component we already use on the items list"** — that button is not a component in this repo. It is a legacy Rails ERB link (`resultmaps-web` → `app/views/items/_common_top_buttons.html.erb` → `/items/:id/download_csv`, server-rendered via `items_controller.rb#download_csv`). The new UI's items list has no export affordance at all. There is nothing to copy.

### What this issue needs before work can begin

The stated capability exists, so one of the following is the real gap — needs confirmation from the requester:

1. **Discoverability** — the existing button is icon-only (download glyph, no "Export" label). If it was missed while looking right at the scorecard, that is a UX/discoverability finding, though note the icon-only treatment matches the binding prototype, so changing it is a design-intent question first.
2. **A different surface** — the export exists only on the main scorecard view. It is absent from the user profile Measurables tab (`components/users/measurables-tab.tsx`), the 1-on-1 scorecard grid (`components/1-on-1/scorecard-grid.tsx`), and the home scorecard card. If the request was about one of those, name it and this becomes a scoped issue for that surface.
3. **CSV content** — if the existing export is missing data the requester expected (e.g., status, notes, goal direction, more history than displayed), specify which fields/ranges.
4. **None of the above** — close as already shipped (`da5076b0`, 2026-03-07).

### Acceptance

- Requester confirms which of 1–4 applies.
- If 1–3: re-title and re-scope this issue to that specific gap before implementation; the existing client-side export in `scorecard-view.tsx` is the starting point for any change.
- If 4: close, no code change.

### References

- `components/components/scorecard/scorecard-view.tsx` — `buildCsv`, `downloadCsv`, export button (~line 438)
- `components/components/scorecard/use-scorecard.ts` — data source (`/api/v2/teams/:id/measures`)
- `docs/design-intent/scorecard-grid-redesign/measurables_data_grid_v1.html` — binding prototype, Export button at line 411
- Commits: `da5076b0` (feature), `67ed76fe` (CSV regression test)
- Legacy counterparts: `resultmaps-web/app/views/groups/scorecard.html.erb` (scorecard CSV), `resultmaps-web/app/controllers/items_controller.rb#download_csv` (items list CSV)
