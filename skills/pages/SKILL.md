---
name: rkit:pages
description: List, read, create, update, move, and delete team Pages (the team wiki/docs tree) via the ResultMaps API. Use this skill when users ask about pages, team docs, team wiki, team notes, want to list pages, open or read a page, create a new page or doc, write content to a page, rename a page, move or nest a page under another, reorder pages, or delete a page.
user-invocable: true
allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Bash(pandoc *), Bash(npx *), Read, Glob, Grep, AskUserQuestion
---

# rkit:pages

Team-scoped hierarchical document pages ("team wiki"). Pages form a tree via `parent_id`; the list endpoint returns a flat array — build the tree client-side.

## Current State

- Config: !`if [ -f "$HOME/.config/resultkit/config.json" ] && jq empty "$HOME/.config/resultkit/config.json" 2>/dev/null; then echo "EXISTS"; jq '{token_masked: (.api_token[:3] + "..." + .api_token[-4:]), default_team_id, api_base}' "$HOME/.config/resultkit/config.json"; else echo "MISSING — run /rkit:setup"; fi`
- api.sh: !`echo "${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/pages/scripts/api.sh}" | xargs -I{} sh -c '[ -f "{}" ] && echo "{}" && exit 0; for p in "$HOME/.claude/plugins/cache/"*/rkit/*/skills/pages/scripts/api.sh "$HOME/.claude/skills/rkit:pages/scripts/api.sh" "$HOME/.agents/skills/pages/scripts/api.sh" "$HOME/.gemini/skills/pages/scripts/api.sh" "scripts/api.sh"; do [ -f "$p" ] && echo "$p" && exit 0; done; echo "NOT_FOUND"'`

## Rules

- **Confirm writes.** Before any POST/PATCH/DELETE, summarize all planned changes in a single prompt and ask for confirmation. Batch related mutations under one confirmation. GET requests execute immediately.
- **Body is HTML, not markdown.** The API stores sanitized HTML. Raw markdown (`# H1`, `**bold**`) is saved as literal text and renders literally in the app. Convert markdown to HTML before any create/update that includes a body (see Flow: Write Body Content). Images (`img`) are stripped by the sanitizer; links keep only `href`/`target`.
- **Show IDs.** Always include page IDs (and parent IDs) in output.
- **Concise output.** Trees and short summaries. No filler.
- **Direct execution.** Use Bash with api.sh for all API calls. Never use Task agents.
- **Respect the flags.** Use each page's `can_edit` / `can_delete` to gate write suggestions — creating pages needs team admin; editing needs admin or an author/editor/contributor role on that page.

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | List pages for default team as a tree |
| `{team_id}` | List pages for specified team |
| `{page_id}` or `read {page_id}` | Show a single page (title + rendered body) |
| `create "title"` | Create a top-level page (empty body unless content given) |
| `create "title" under {parent_id}` | Create a nested page |
| `write {page_id} <file-or-content>` | Set a page's body from a markdown file or inline text |
| `rename {page_id} "new title"` | Update the title |
| `move {page_id} under {parent_id}` | Re-parent a page (`under top` → `parent_id: null`) |
| `reorder {page_id} to {position}` | Change position among siblings (0-based) |
| `delete {page_id}` | Delete a page **and all its descendants** |

Permissions (share page, grant/revoke editor, list roles) are also available — see the **Pages** section of `references/api-reference.md` for `/pages/{id}/permissions`; author-only.

---

## Flow: List Pages (tree)

### Step 1: Resolve team ID

- Team ID in args → use it; otherwise `default_team_id` from Current State config.
- Neither → "No team specified and no default configured. Run `/rkit:setup`."

### Step 2: Fetch

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/pages")
echo "$RESPONSE"
```

### Step 3: Handle response

Errors → see Error Handling below.

Success (status 200): `body.data` is a **flat array** (no `meta` on this endpoint). Build the tree from `parent_id`, order siblings by `position`, and display as an indented tree:

```
## Pages — Team {team_id}

- 18 Processes
  - 29 BDD Skill
- 15 Platform Development Process
  - 16 Pricing Tool Development
- 32 Platform Design Specs
  - 34 Internal
    - 31 ITAD Check-in BDD

{count} pages
Tip: `/rkit:pages read {id}` to open · `/rkit:pages create "title" under {id}` to add
```

## Flow: Read a Page

```bash
API_SH="<api.sh path>"
RESPONSE=$("$API_SH" GET "/teams/TEAM_ID/pages/PAGE_ID")
echo "$RESPONSE"
```

Success: show title, id, parent (title if known), and the body converted to readable markdown/plain text (strip tags sensibly). Note `can_edit`/`can_delete` if the user is about to modify.

## Flow: Create a Page

**Needs team admin** (403 otherwise — creator automatically gets the `author` role).

Confirm: "Create page **{title}** in team {team_id}{ under **{parent title}** ({parent_id})}?"

```bash
API_SH="<api.sh path>"
PAYLOAD=$(jq -n --arg title "TITLE" --arg body "HTML_BODY" '{title: $title, body: $body}')
# nested: add  --argjson parent PARENT_ID  and  parent_id: $parent
RESPONSE=$("$API_SH" POST "/teams/TEAM_ID/pages" "$PAYLOAD")
echo "$RESPONSE"
```

- Omit `body` for an empty page; omit `parent_id` for top-level.
- **Status 201**: "Created page **{id}**: {title}" (+ parent if nested).

## Flow: Write Body Content

For `write {page_id} <file>` or any create with content — convert markdown to HTML first:

```bash
BODY=$(pandoc -f gfm -t html "FILE.md")        # preferred
# fallback if pandoc missing: BODY=$(npx --yes marked "FILE.md")
PAYLOAD=$(jq -n --arg body "$BODY" '{body: $body}')
RESPONSE=$("$API_SH" PATCH "/teams/TEAM_ID/pages/PAGE_ID" "$PAYLOAD")
```

Limits: body ≤ 100KB after conversion; title ≤ 255 chars. If the source exceeds 100KB, tell the user and suggest splitting into child pages.

## Flow: Rename / Move / Reorder

All are PATCH with only the changed fields:

```bash
"$API_SH" PATCH "/teams/TEAM_ID/pages/PAGE_ID" '{"title": "New Title"}'
"$API_SH" PATCH "/teams/TEAM_ID/pages/PAGE_ID" '{"parent_id": 34}'      # move; null → top-level
"$API_SH" PATCH "/teams/TEAM_ID/pages/PAGE_ID" '{"position": 0}'        # reorder among siblings
```

- Moving to one of the page's own descendants → 400 (cycle detected). Parent must be in the same team.
- After a move/reorder, re-fetch the list and show the affected subtree so the user sees the new shape.

## Flow: Delete a Page

**Cascades to all descendants.** Before confirming, fetch the list and count the page's descendants; the confirmation must state it:

> Delete page **{title}** ({id}) **and its {n} descendant pages**? This cannot be undone.

```bash
"$API_SH" DELETE "/teams/TEAM_ID/pages/PAGE_ID"
```

Allowed for team admin or the page's author (403 otherwise).

## Error Handling

api.sh wraps every response as `{"status": N, "body": {...}}` — always read fields via `.body.…`.

- `"error": "NO_CONFIG"` / `"NO_TOKEN"` → "Config not found. Run `/rkit:setup` first."
- `"error": "CURL_FAILED"` → "Network error. Check your connection."
- `status: 400` → show the validation message (empty title, title > 255, body > 100KB, cross-team parent, cycle).
- `status: 401` → "Unauthorized (401). Run `/rkit:setup` to update your token."
- `status: 403` → "You don't have permission — creating pages needs team admin; editing needs an author/editor/contributor role on the page."
- `status: 404` → "Team or page not found (404)."

## Edge Cases

- **api.sh not found**: "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`"
- **Empty team**: "No pages for team {team_id} yet. `/rkit:pages create \"title\"` to start."
- **Untitled pages**: display as *(untitled)* with the ID so they're still addressable.
- **pandoc and npx both missing**: ask the user before storing raw text as a single `<p>`-wrapped block — never store raw markdown silently.

## References

- [ResultMaps V2 API Reference](references/api-reference.md) — see the **Pages** section for full payloads, the permission model (author > editor > contributor > viewer), and `/pages/{id}/permissions`.
