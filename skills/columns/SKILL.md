---
name: rkit:columns
description: Day Plan Columns — read the custom columns on the Custom tab of your personal Prioritizer — which columns you have, what's open in each, and what you've completed in them. Use this skill whenever someone asks about their day plan columns, custom columns, planner columns, or planner buckets — "show me my columns", "show me my columns and what's in each", "what's in my columns", "what's in each column", "list my columns", "show custom columns", "show planner columns", "what are my planner buckets", "my day plan columns", "what's done in my columns", "what have I completed in my columns". Follow-ups inside an already-open columns conversation ("the 3 from each", "the complete list", "the rest of {column}", "3 months", "6 months") are routed by this skill's Tool Routing Table once it is loaded — they are deliberately not listed here, because on their own they say nothing about columns. Read-only — it never adds, completes, moves, renames, or deletes anything.
# NOTE: `disable-model-invocation` is deliberately absent here, unlike the other 20 rkit skills — the locked BDD (https://resultkit.ai/pages/55) has the user invoke this skill by typing a plain sentence, so it must stay model-invocable. Do not "fix" this to match the siblings.
user-invocable: true
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep
---

# rkit:columns

Reads the personal planner's day-plan custom columns. **Read-only.**

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/columns/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/columns/scripts/api.sh "$HOME/.claude/skills/rkit:columns/scripts/api.sh" "$HOME/.agents/skills/columns/scripts/api.sh" "$HOME/.gemini/skills/columns/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **The templates are law.** Every reply below is locked wording — https://resultkit.ai/pages/55, 8 scenarios locked 2026-08-02. Reproduce the wording, punctuation, blank lines, and ordering exactly. Substitute counts and names; change nothing else. No preamble, no sign-off, no extra commentary, no headings, no bold, no item IDs, no dates, no emoji.
- **Emit as plain lines**, not inside a code fence and not as a table. The fences below mark where each template starts and stops.
- **Read-only skill.** GETs only. Never POST, PATCH, PUT, or DELETE. The closing offers ("check anything off", "add anything new", "create") are conversational — if the user takes one up, hand off to the skill that owns that action (`rkit:today` for day-plan writes). No rkit skill owns column creation (`POST /day-plan-columns`), so the "create" offer has no handoff target — that is an uncovered case, listed in `references/day-plan-columns-api.md`. This skill never writes.
- **Never ask before reading.** GETs execute immediately. Never use AskUserQuestion — the offers are literal reply lines, not prompts.
- **No fan-out.** One `GET /day-plan-columns` and, for done flows, one `GET /day-plan-completions`. Never one call per date, per column, or per month.
- **Board order everywhere.** `/day-plan-columns` returns columns already sorted by `position` — that is the Custom-tab order the user sees. Render columns in the order returned, in every reply. Within a column, render items in the order returned.

---

## Tool Routing Table

Match the user's message against the **Triggers** column. Pick the first matching row.

| Triggers | Intent | Flow |
|---|---|---|
| "show me my columns", "show me my columns and what's in each", "what's in my columns", "what's in each column", "list my columns", "show custom columns", "show planner columns", "what are my planner buckets", "my day plan columns" | Summary of columns with open counts | `summary` |
| "the 3 from each", "the 3 from each column", "3 from each", "show me the 3" — **only** as a reply to the summary offer in this session | Drill in — first 3 open per column | `three_from_each` |
| "the complete list", "the complete list from each", "the full list", "everything", "all of them", "the complete list from every column" — **only** as a reply to the summary offer in this session | Drill in — every open item per column | `complete_list` |
| "what's done in my columns", "what's done in my columns?", "what have I completed", "what did I finish", "show me what's done", "completed in my columns" | Completions, last 30 days | `whats_done` |
| "3 months", "the last 3 months", "6 months", "the past 6 months", "extend it", "go back further" — **only** as a reply to a done offer | Completions, extended window | `extend_done` |
| "the rest of {column}" — **only** as a reply to a truncated `three_from_each` | Not locked by any scenario | `rest_of_column` |

**Cold entry.** Only two rows can fire with no prior columns reply in this session — `summary` (Scenarios 1 and 5) and `whats_done` (Scenario 4). Those are the locked cold entries. Any other columns-related ask arriving cold, including one shaped like a drill-in follow-up, runs `summary` first — it is the only locked cold entry into the open-item ladder. The four session-guarded rows never fire on their own: with no reply for them to answer, a bare "the 3 from each", "the complete list", "everything", "all of them", "the rest of X", "3 months", or "6 months" is not a trigger for this skill at all.

**Never ask which option the user meant.** This skill never uses AskUserQuestion, and no locked scenario supplies a clarifying-question template. Route an ambiguous follow-up to the closest matching flow. If it is genuinely unresolvable, it is an uncovered case — see "Cases the locked spec does not cover" in `references/day-plan-columns-api.md`.

---

## Conversation ladder

```
summary ──┬─→ three_from_each ──(only if a column was truncated, which
          │                       offers both branches below)──┬─→ rest_of_column ──→ (renders the
          │                                                    │                       complete_list reply)
          │                                                    └─→ complete_list
          └─→ complete_list ──→ (ends the ladder — offers actions, never more listing)

whats_done ──→ extend_done (3 months) ──→ extend_done (6 months)
```

The done flows are a **separate branch**. They are entered by an explicit done ask only — never offered from the summary or drill-in replies, and never mixed into them.

---

## Flows

### Shared step — fetch the columns

Every flow starts here.

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/day-plan-columns")
echo "$RESPONSE"
```

Read columns from `body.data`. Then:

- `body.data` is **empty** → run `no_columns`. Stop.
- Otherwise, for each column, **open items = `items` where `completed == false`**. Completed items are dropped here, once, and are invisible to every open-item flow below.

---

### summary

Fetch the columns. Let `TOTAL` = the sum of open items across all columns.

Split the columns, keeping board order in both groups:
- **With open items** — one line each in the top list.
- **With no open items** — named in the "no open items" chunk. This covers a column holding nothing *and* a column holding only completed items. They read identically.

```
Your day plan columns — TOTAL open items total

- COLUMN — N open
- COLUMN — N open

These columns have no open items:
- COLUMN
- COLUMN

Want the 3 from each column (names/descriptions), or the complete list from each?
```

Omit the "These columns have no open items:" chunk and its preceding blank line when every column has at least one open item. **Inferred, not locked** — every locked scenario has at least one column with no open items, so no scenario shows what the reply looks like without that chunk. Keep this behavior until a scenario locks it.

**Locked example** (Scenario 1 — Deep Work 3 open + 1 completed, Code Review 2, Quick Hits 1, Waiting On 1 completed only, Someday empty):

```
Your day plan columns — 6 open items total

- Deep Work — 3 open
- Code Review — 2 open
- Quick Hits — 1 open

These columns have no open items:
- Waiting On
- Someday

Want the 3 from each column (names/descriptions), or the complete list from each?
```

The total reads 6, not 7 — the completed "Review Alya's ops intake spec" is neither shown nor counted.

---

### three_from_each

Fetch the columns. Same `TOTAL` and same split as `summary`.

For each column with open items, in board order: a header line, then **at most the first 3** open items in the order returned.

- 3 or fewer open → header `COLUMN — N open`, list all of them.
- More than 3 open → header `COLUMN — N open (showing 3)`, list the first 3 only. `N` is the full open count, not 3.

```
Your day plan columns — TOTAL open items total

COLUMN — N open
- ITEM
- ITEM

COLUMN — N open (showing 3)
- ITEM
- ITEM
- ITEM

These columns have no open items:
- COLUMN
- COLUMN

Want the rest of COLUMN, or the complete list from every column?
```

The closing offer appears **only when at least one column was truncated**. With nothing truncated the reply ends after the "no open items" chunk — no closing line at all.

Scenario 2b locks that closing line for **exactly one** truncated column ("Want the rest of Deep Work, or the complete list from every column?"). With two or more truncated columns in the same reply, the wording is **not locked** — that is an open spec question, not a rendering decision. See "Cases the locked spec does not cover" in `references/day-plan-columns-api.md`.

**Locked example, nothing truncated** (Scenario 2):

```
Your day plan columns — 6 open items total

Deep Work — 3 open
- Finish sprint API contract
- Draft Q1 dev process rock plan
- Refactor auth middleware

Code Review — 2 open
- Review Gregor's delivery checklist PR
- Review onboarding SOP draft

Quick Hits — 1 open
- Reply to Sue re: defect report

These columns have no open items:
- Waiting On
- Someday
```

**Locked example, one column truncated** (Scenario 2b — Deep Work holds 7 open):

```
Your day plan columns — 10 open items total

Deep Work — 7 open (showing 3)
- Finish sprint API contract
- Draft Q1 dev process rock plan
- Refactor auth middleware

Code Review — 2 open
- Review Gregor's delivery checklist PR
- Review onboarding SOP draft

Quick Hits — 1 open
- Reply to Sue re: defect report

These columns have no open items:
- Waiting On
- Someday

Want the rest of Deep Work, or the complete list from every column?
```

Deep Work's other four open items are not listed, though the count reads "7 open (showing 3)".

---

### complete_list

Fetch the columns. Same `TOTAL` and same split as `summary`.

For each column with open items, in board order: header `COLUMN — N open`, then **every** open item in the order returned. Nothing is truncated and nothing ever reads "(showing 3)".

```
Your day plan columns — TOTAL open items total

COLUMN — N open
- ITEM
- ITEM

COLUMN — N open
- ITEM

These columns have no open items:
- COLUMN
- COLUMN

Want to check anything off or add anything new?
```

**Locked example** (Scenario 3):

```
Your day plan columns — 6 open items total

Deep Work — 3 open
- Finish sprint API contract
- Draft Q1 dev process rock plan
- Refactor auth middleware

Code Review — 2 open
- Review Gregor's delivery checklist PR
- Review onboarding SOP draft

Quick Hits — 1 open
- Reply to Sue re: defect report

These columns have no open items:
- Waiting On
- Someday

Want to check anything off or add anything new?
```

**Locked example, a column holding 7** (Scenario 3b) — all seven listed, header reads `Deep Work — 7 open`, no "(showing 3)", same closing line:

```
Your day plan columns — 10 open items total

Deep Work — 7 open
- Finish sprint API contract
- Draft Q1 dev process rock plan
- Refactor auth middleware
- Spec retry logic for sync jobs
- Pair with Gregor on delivery handoff
- Update dev process playbook
- Write migration rollback notes

Code Review — 2 open
- Review Gregor's delivery checklist PR
- Review onboarding SOP draft

Quick Hits — 1 open
- Reply to Sue re: defect report

These columns have no open items:
- Waiting On
- Someday

Want to check anything off or add anything new?
```

The closing line offers **actions**, never more listing. A complete-list reply never ends with a drill-in offer.

---

### whats_done

Fetch the columns (for board order and for the empty-columns check), then fetch the completions for the default window — **no `months` param**:

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/day-plan-completions")
echo "$RESPONSE"
```

Read completions from `body.data`. Then:

- **Drop every completion whose `column` is `null`** *(interim — spec question pending)* — it sits in no day plan column, so it belongs to no group and is not counted. No locked scenario presents one; this is the interim rule, recorded as an open spec question in "Cases the locked spec does not cover" in `references/day-plan-columns-api.md`.
- Group the rest by `column.name`. Order the groups by **board order** from `/day-plan-columns`. Within a group keep the order returned (most recent first).
- `TOTAL` = the number of completions left after the drop.

```
Done in your day plan columns — TOTAL completed items in the last 30 days

COLUMN — N completed
- ITEM

COLUMN — N completed
- ITEM

Would you like me to extend my search to the last 3 or 6 months?
```

**Locked example** (Scenario 4):

```
Done in your day plan columns — 2 completed items in the last 30 days

Deep Work — 1 completed
- Review Alya's ops intake spec

Waiting On — 1 completed
- Confirm staging access with Alya

Would you like me to extend my search to the last 3 or 6 months?
```

Only columns with completions appear. There is **no** "These columns have no completed items" chunk. No open item is named or counted. No "Want to check anything off or add anything new?" offer.

---

### extend_done

Only from a done offer. Re-fetch with the window the user named:

| The user says | Request | Window words in the header | Closing line |
|---|---|---|---|
| "3 months" | `GET /day-plan-completions?months=3` | `in the last 3 months` | `Would you like me to extend my search to the past 6 months?` |
| "6 months" † | `GET /day-plan-completions?months=6` | `in the last 6 months` | *(none — the ladder ends)* |

† The 6-month row is a **number-substitution inference, not locked**. Scenario 4b locks `months=3` only — the header "in the last 3 months" and the closing "…the past 6 months?". The 6-month reply substitutes `6` into that same locked header phrase and closes with nothing, since no further extension is offered. Substitution only, never new wording.

Same grouping, same drop of `column: null`, same board order as `whats_done`.

```
Done in your day plan columns — TOTAL completed items in the last 3 months

COLUMN — N completed
- ITEM
- ITEM

COLUMN — N completed
- ITEM

Would you like me to extend my search to the past 6 months?
```

**Locked example** (Scenario 4b — an item completed 40 days ago now falls inside the window):

```
Done in your day plan columns — 3 completed items in the last 3 months

Deep Work — 2 completed
- Review Alya's ops intake spec
- Close out Q2 sprint retro actions

Waiting On — 1 completed
- Confirm staging access with Alya

Would you like me to extend my search to the past 6 months?
```

Note the wording shift the spec locks: the 30-day reply offers "**the last** 3 or 6 months"; the 3-month reply offers "**the past** 6 months". Reproduce both exactly.

---

### no_columns

`GET /day-plan-columns` returned `200` with an empty `data` array. One sentence, and nothing else — no summary, no total, no list of the user's day-plan items, and nothing that reads as an error:

```
I don't see that you've created any custom columns for organizing your day plan items yet. Would you like to learn how that can help you, or do you have some you'd like to create?
```

**Locked example** (Scenario 5 — Sue has never created a column; her two open day-plan items are not listed).

This same sentence is the answer whichever way the user asked, including a done ask — there are no columns to report on either way. **Inferred, not locked** — Scenario 5 locks this sentence only for "show me my columns and what's in each"; no scenario shows a done ask from an account with no columns. Reuse the locked sentence, never new wording.

If the user takes up the "create" half of that offer, that is an **uncovered case** — no rkit skill owns `POST /day-plan-columns`, and this skill never writes. See "Cases the locked spec does not cover" in `references/day-plan-columns-api.md`.

---

### rest_of_column

Offered by a truncated `three_from_each`, but **no scenario locks a reply for it**. The nearest locked behavior is `complete_list` (Scenario 3/3b) — render that. Do not invent a partial "just the remaining four" variant.

---

## Invariants

These hold in every reply. A reply that breaks one is wrong even if it looks right.

1. **Open counts exclude completed items.** Filter `completed == false` once at fetch, then count and list from that. A column's count and the running total are both open-only.
2. **No column ever renders "— 0 open".** A column with no open items is named only under "These columns have no open items:" — never as a zero-count line, never with an empty item list.
3. **Completed items are invisible to the open-item flows.** `summary`, `three_from_each`, and `complete_list` never name a completed item, never count one, and never mark one as done.
4. **Truncation is exactly 3.** More than 3 open in `three_from_each` → first 3 only, header `— N open (showing 3)` with the full `N`. Exactly 3 or fewer → no "(showing 3)" on that column. The closing line is a property of the whole reply, not of one column: `Want the rest of COLUMN, or the complete list from every column?` appears when **at least one** column in the reply was truncated, and when **no** column was truncated the reply carries no closing line at all.
5. **`complete_list` never truncates and never offers more listing.** It closes `Want to check anything off or add anything new?` — an action offer, never a drill-in.
6. **The summary always closes** `Want the 3 from each column (names/descriptions), or the complete list from each?`
7. **Done replies show only completed items.** No open item is named or counted. No "no completed items" chunk exists. No check-off/add offer.
8. **Done replies never say history is gone.** Never state or imply that completed history is cleared, deleted, expired, or unavailable. An empty or short window means the search window, not the record.
9. **Months language is exact.** Default window: "in the last 30 days", closing "Would you like me to extend my search to the last 3 or 6 months?". After extending: "in the last 3 months", closing "Would you like me to extend my search to the past 6 months?".
10. **The no-columns fallback lists nothing.** One sentence, verbatim, and no day-plan items.
11. **Names render verbatim.** Column names and item names exactly as the API returns them — no trimming, re-casing, re-wrapping, truncating, or tidying.
12. **Nothing is written.** No endpoint outside the two GETs is ever called by this skill.

---

## Error Handling

| Status | Response |
|---|---|
| `error: NO_CONFIG` | "Config not found. Run `/rkit:setup` first." |
| `error: NO_TOKEN` | "No API token. Run `/rkit:setup` to configure." |
| `error: CURL_FAILED` | "Network error. Check your connection." |
| `status: 401` | "Unauthorized. Run `/rkit:setup` to update your token." |
| `status: 404` | "Not found." |
| Other non-200 | Show status code and error message from the response body. |

`200` with an empty `data` array is not an error. On `/day-plan-columns` it means `no_columns`.

**api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"

---

## Out of scope

- **Writes of any kind** — creating, renaming, archiving, or repositioning columns; adding, completing, moving, or removing items. Those live in other skills.
- **The `column` / `column_id` filter** on `/day-plan-completions`. One unfiltered request already returns every column's completions carrying its column.
- **"Help me organize my todos" routing** (Scenario Family 2 on page 55) — deferred, not specced, build nothing for it.

## References

- [Day Plan Columns — Endpoint Reference](references/day-plan-columns-api.md) — both GETs, live-verified field names, the window→param mapping, and the cases the locked spec does not cover.
- [ResultMaps V2 API Reference](references/api-reference.md) — the whole V2 surface, including the write verbs on `/day-plan-columns` that this skill never calls. `/day-plan-completions` is **not** in the master yet; it is documented only in `references/day-plan-columns-api.md`.
- Binding BDD: https://resultkit.ai/pages/55 — 8 scenarios, locked 2026-08-02. Never edit it.
