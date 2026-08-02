# Day Plan Columns — Endpoint Reference (rkit:columns)

**Source**: https://api.resultmaps.com/api-docs/v2 — refresh from here when endpoints change or docs seem stale.

Base URL: `https://api.resultmaps.com/api/v2`
Web App: `https://resultkit.ai` — Web URL column values are paths relative to this base. NEVER link users to the legacy `app.resultmaps.com` UI.
Auth: Bearer token in `Authorization` header (handled by `scripts/api.sh`). Find your token at https://resultkit.ai/customize.

This reference covers only the two reads `rkit:columns` uses. The skill is **read-only** — it issues GETs and nothing else. Verified live against production on 2026-08-02 (both endpoints returned 200).

---

## Day Plan Columns (Custom Columns / Personal Planner Buckets)

Personal Planner custom column lanes — the **Custom tab** of the Prioritizer (`/prioritizer`, Personal context). All endpoints require auth. Items embedded in column responses are automatically scoped to the caller's **today** DayPlan — no filter param needed.

`rkit:columns` uses **only the GET**. The other verbs on this resource (POST, PATCH, DELETE, reposition, drop-action) exist but are out of scope for this skill — see the sibling [`api-reference.md`](api-reference.md) if you need them. That sibling is this skill's copy of the repo-root master; `/day-plan-completions` is **not** in the master yet, so it is documented here and only here until the master gains it.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plan-columns` | List all active (non-archived) columns owned by the caller, with embedded items scoped to today's plan. Priority-tag filter applied to embedded items (same rule as `/day-plans/today`): non-active priority-tagged items are excluded. Returns `{ data: DayPlanColumn[] }`. | "show me my columns", "what's in my columns", "list my columns", "show custom columns", "what are my planner buckets", "show planner columns" | `/prioritizer/custom-columns` |

### Response envelope

```json
{ "status": 200, "body": { "data": [ /* DayPlanColumn */ ] } }
```

`api.sh` wraps the HTTP response — read the columns from `body.data`. No pagination meta on this endpoint.

### DayPlanColumn fields

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Column id. Use as `column_id` on `/day-plan-completions`. |
| `name` | string | Column name as the user typed it on the Custom tab. Render verbatim. |
| `position` | integer | 0-indexed board order. **The array comes back already sorted by `position`** — render columns in the order returned. |
| `is_archived` | boolean | Always `false` in this response; archived columns are excluded server-side. |
| `color` | string \| null | 6-digit hex (e.g. `#2563EB`) or `null`. Not rendered by this skill. |
| `created_at` | ISO 8601 string | |
| `updated_at` | ISO 8601 string | |
| `items` | DayPlanColumnItem[] | Items in this column that are on **today's** plan. Empty array when the column holds nothing today. |

### DayPlanColumnItem fields (verified live 2026-08-02)

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Item id. |
| `name` | string | **This is what the reply templates render.** |
| `completed` | boolean | **The open/done discriminator.** `false` = open, `true` = completed. Open counts and all listing come from `completed == false` only. |
| `position` | integer | 0-indexed within the column. **The array comes back already sorted by `position`** — render items in the order returned; that is the order the user sees on the Custom tab. |
| `due` | `YYYY-MM-DD` \| null | Not rendered by this skill. |
| `recur_daily` | boolean | Not rendered by this skill. |
| `is_top` | boolean | Not rendered by this skill. |
| `assignees` | array | Not rendered by this skill. |

**No `description` field is returned on embedded column items.** The locked summary offer says "the 3 from each column (names/descriptions)", but every locked drill-in template renders **names only**. Render names only — do not invent, fetch, or synthesize descriptions.

### Sample (shape only, live 2026-08-02)

```json
{
  "id": 183,
  "name": "Mender",
  "position": 0,
  "is_archived": false,
  "color": null,
  "created_at": "2025-01-01T00:00:00.000Z",
  "updated_at": "2026-08-02T00:00:00.000Z",
  "items": [
    { "id": 206568, "name": "Performance review write up process", "completed": false, "position": 3, "due": null, "recur_daily": false, "is_top": false, "assignees": [] }
  ]
}
```

A user with no custom columns gets `200` with `{ "data": [] }` — **not** a 404. That empty array is the trigger for the no-columns fallback reply.

---

## Day Plan Completions (Historical "what's done")

Historical completions from the signed-in person's **own** day plans, most recent first. Added 2026-08-02 (w3mg/resultmaps-api2#478, PR #479) specifically to serve this skill's "what's done in my columns" scenarios; the current day-plan reads only ever surface today's plan and cannot answer them.

Binding spec: `docs/design-intent/day-plan-completions/day-plan-completions-spec.md` in `w3mg/resultmaps-api2`.

| Method | Path | Description | User Phrases | Web URL |
|--------|------|-------------|--------------|---------|
| GET | `/day-plan-completions` | Historical day-plan completions for the caller, most recent first. Params (all optional): `months`, `column`, `column_id`. Default window is the last 30 days. Returns `{ data: DayPlanCompletion[] }`. | "what's done in my columns", "what have I completed", "what did I finish", "3 months", "6 months" | — |

### Query parameters

| Param | Type | Description |
|-------|------|-------------|
| `months` | positive integer | Window length in **calendar months**. **Omit for the last 30 days** (the default window). A non-positive or non-numeric value is treated as not supplied. |
| `column` | string | Only completions whose item **currently sits** in this column, matched by name, case-insensitive. Optional. |
| `column_id` | positive integer | The same filter by column id. **Wins over `column` when both are sent.** Optional. |

**Scenario → parameter mapping (this is the whole mapping — do not invent others):**

| The user's window | Request |
|---|---|
| "the last 30 days" (default, first done reply) | `GET /day-plan-completions` — **no `months` param** |
| "3 months" | `GET /day-plan-completions?months=3` |
| "6 months" | `GET /day-plan-completions?months=6` |

**No fan-out.** One request serves the entire window at every window size. Never issue one call per date, per column, or per month to assemble an answer. The column filter is optional and this skill does not use it — one unfiltered request returns every column's completions, already carrying the column each item sits in.

### Response envelope

```json
{ "status": 200, "body": { "data": [ /* DayPlanCompletion */ ] } }
```

### DayPlanCompletion fields (verified live 2026-08-02)

| Field | Type | Notes |
|-------|------|-------|
| `item_id` | integer | The completed item's id. Note the name — it is `item_id`, **not** `id`. |
| `name` | string | **This is what the reply templates render.** |
| `completed_on` | `YYYY-MM-DD` | Date-only, in the person's own timezone. Not rendered by this skill's templates — used only for ordering, which the API already applies. |
| `column` | `{ id, name }` \| **null** | The day-plan column the item **currently** sits in, or `null` if it sits in none (never placed, or its only placement was in a column the user has since archived). |

Ordering: **most recent first** by `completed_on`. The array is already sorted — within a column group, keep the order returned.

A completion is per-day: the same item finished on two different days is two entries.

`column: null` is common in live data — of 5 completions in the default 30-day window on a real account, 2 carried it. No locked scenario presents one, so how it renders is an open spec question, not a rendering decision: see **Cases the locked spec does not cover**, case 8, for the interim rule.

### Sample (shape only, live 2026-08-02)

```json
[
  { "item_id": 222747, "name": "Write Mender annual reviews (Gus)", "completed_on": "2026-07-30", "column": null },
  { "item_id": 222571, "name": "Updated Billing Milestones to John", "completed_on": "2026-07-19", "column": { "id": 155, "name": "GTM" } }
]
```

---

## Error handling

`api.sh` returns `{ "status": <int>, "body": <object> }`, or `{ "status": 0, "error": "<CODE>" }`.

| Status | Response |
|---|---|
| `error: NO_CONFIG` | "Config not found. Run `/rkit:setup` first." |
| `error: NO_TOKEN` | "No API token. Run `/rkit:setup` to configure." |
| `error: CURL_FAILED` | "Network error. Check your connection." |
| `status: 401` | "Unauthorized. Run `/rkit:setup` to update your token." |
| `status: 404` | "Not found." |
| Other non-200 | Show status code and error message from the response body. |

`200` with `{ "data": [] }` is **not** an error on either endpoint — it is the normal answer for "nothing there".

---

## Cases the locked spec does not cover

The 8 locked scenarios at https://resultkit.ai/pages/55 are law. These situations fall outside them. They are recorded here, not silently absorbed into the templates — if one comes up in real use, it is a spec question, not a rendering decision.

1. **Singular counts in the header lines.** The locked headers read "— 6 open items total" and "— 2 completed items in the last 30 days". No scenario shows a total of 1. Substitute the number and change nothing else; do not re-word to "item".
2. **More than one column truncated in the "3 from each" reply.** Scenario 2b locks the closing line for **exactly one** truncated column, and that single-column form — "Want the rest of Deep Work, or the complete list from every column?" — is the only locked wording there is. **No wording is locked for two or more truncated columns**, and none is prescribed here: how the sentence should name several columns is a spec question for Scott, not a rendering decision. Until it is answered, treat a multi-column truncation as an uncovered case rather than inventing a join.
3. **"the rest of &lt;column&gt;".** Scenario 2b offers it; no scenario locks the reply. Nearest locked behavior is the complete-list reply (Scenario 3/3b template).
4. **The done ask when the user has no custom columns at all.** Scenario 5 locks the fallback for "show me my columns and what's in each". Reuse that same locked sentence — there are no columns to report on either way. No new wording.
5. **A done window that returns nothing.** No scenario shows an empty done reply. Whatever is shown, Scenario 4's invariant still binds: never state or imply that completed history is gone, cleared, or deleted.
6. **Every column empty of open items.** No scenario shows a summary where no column has an open item. The templates still substitute mechanically — a `0` total, an empty top list, every column under "These columns have no open items:", and the locked drill-in offer that now has nothing to drill into.
7. **The 6-month header.** Scenario 4b locks "in the last 3 months" for `months=3`. `months=6` substitutes the number into that same phrase — "in the last 6 months" — and closes with nothing, since no further extension is offered. Substitution only, no new wording.
8. **A completion whose `column` is `null`.** The live endpoint returns them, and often — 2 of 5 in one real 30-day window. No scenario presents one, so nothing about them is locked: whether they should be dropped, grouped under an "unfiled" heading, or counted in the total is a spec question for Scott. **Interim behavior, in force until he answers:** a `column: null` completion is **dropped — neither listed nor counted**. The reasoning is that every group in a reply headed "Done in your day plan columns" is a column, an item in no column has no group to sit in, and counting it would make the total disagree with the sum of the groups. `SKILL.md` marks this rule "(interim — spec question pending)".
9. **The user takes up the "create" offer after Scenario 5.** The locked no-columns sentence ends by offering to create columns, but nothing is specced past that point and **no rkit skill owns `POST /day-plan-columns`** — `rkit:columns` is read-only, and the create/rename/archive/reposition verbs documented in the sibling [`api-reference.md`](api-reference.md) have no skill behind them. Which skill should own them, and what that reply reads like, is a spec question for Scott. **Interim behavior:** the request is uncovered — do not write, and do not improvise a create flow inside this skill.
10. **An ambiguous follow-up to the summary.** The summary offers two paths ("the 3 from each" / "the complete list"); no scenario covers a reply that clearly answers the offer but picks neither cleanly. This skill never uses AskUserQuestion and no locked template supplies a clarifying question, so asking is not available. **Interim behavior:** route to the closest matching flow. A follow-up that stays genuinely unresolvable is an uncovered case, and what should happen then is a spec question for Scott.
