---
name: rkit-sync-api
description: >
  Sync the ResultKit api-reference.md with the live ResultMaps OpenAPI spec,
  glossary, and user guide, then deploy updates to all rkit skills. Enriches
  endpoint tables with user-facing synonyms and phrases to help skills
  interpret natural language commands. Use when the user says "sync api",
  "update api reference", "rkit sync", "api reference outdated",
  "check api changes", "refresh api docs", or wants to compare the live
  ResultMaps API against the documented api-reference.md and update it.
---

# Sync API Reference

Fetch three live sources from ResultMaps, compare against `api-reference.md`, update the reference doc with endpoint changes and user-phrase enrichment, and deploy to all rkit skills.

## Prerequisites

- Must be run from the `resultkit-skills` project root (contains `scripts/` and `api-reference.md`)
- Requires `curl` and `jq`

## Sources

| Source | URL | Purpose |
|--------|-----|---------|
| OpenAPI spec | `https://api.resultmaps.com/openapi-v2.json` | Endpoint paths, methods, params, schemas |
| Glossary | `~/projects/resultmaps-api2/docs/v2/api-terminology-glossary.md` | Term mappings, framework terminology, status aliases |
| User Guide | `~/projects/resultmaps-api2/docs/v2/api-user-guide.md` | Endpoint details, request/response examples, field descriptions |

## Workflow

### Step 1: Fetch all three sources

```bash
bash scripts/fetch-openapi.sh > /tmp/openapi-v2.json
```

Verify the OpenAPI spec fetched successfully (non-empty, valid content).

### Step 2: Read sources into context

Read all three files:
- `/tmp/openapi-v2.json` — for endpoint diffing
- `~/projects/resultmaps-api2/docs/v2/api-terminology-glossary.md` — for term mappings and phrase enrichment
- `~/projects/resultmaps-api2/docs/v2/api-user-guide.md` — for endpoint detail updates (params, bodies, responses)

Also read the current `api-reference.md` from the project root.

### Step 3: Compare endpoints

Run the comparison script to identify new/removed endpoints:

```bash
bash ~/.claude/skills/rkit-sync-api/scripts/compare-endpoints.sh /tmp/openapi-v2.json api-reference.md
```

This outputs new endpoints, removed endpoints, excluded endpoints, and a summary.

### Step 4: Inspect changes from all sources

For each difference found, gather details from all three sources:

**From OpenAPI spec** (endpoint structure):
```bash
jq '.paths["/the/path"]' /tmp/openapi-v2.json
jq '.components.schemas.SchemaName' /tmp/openapi-v2.json
```

**From user-guide.md** (request/response details):
- Updated params, body fields, response shapes
- New examples or changed behavior

**From glossary.md** (user phrases):
- What users call this endpoint's action
- Framework-specific terms that map to it
- Related aliases and synonyms

Present all findings to the user as a summary before editing.

### Step 5: Update api-reference.md

After user confirms changes, edit `api-reference.md` in the project root.

#### Table format

Every endpoint table MUST include the `User Phrases` column:

```markdown
| Method | Path | Description | User Phrases |
|--------|------|-------------|--------------|
| GET | `/items` | List user's items | "show my tasks", "list items", "what's on my plate" |
| POST | `/items` | Create item | "add task", "create item", "new to-do" |
```

#### How to populate User Phrases

For each endpoint row, derive phrases from the glossary's "Quick Lookup" table and framework terminology sections. Include:

1. **Common verbs** the user might say for this action (e.g., "show", "list", "get", "add", "create", "mark", "move", "remove", "delete")
2. **Synonym nouns** from the glossary (e.g., item = task = to-do = action item = priority)
3. **Framework terms** where applicable (e.g., "L10 issues" for `/teams/{id}/items/issues` under EOS)
4. **Contextual phrases** (e.g., "put on weekly" for `PUT /teams/{id}/items/{item_id}`)
5. **Related endpoint aliases** from the glossary's "Endpoint Aliases" section

Keep phrases concise — short quoted strings separated by commas. Aim for 3-6 representative phrases per endpoint. Prioritize the most natural, common things a user would say.

#### Update endpoint details

Also update from the user-guide:
- New or changed query parameters
- Updated request body fields
- Changed response shapes or field descriptions
- New status values or enums

#### Update field descriptions

If the user-guide shows new fields, updated types, or changed descriptions for any object (Item, Team, Meeting, DayPlan, etc.), update the field lists below each section.

#### Update or create the Glossary section

At the bottom of `api-reference.md`, maintain a `## Glossary` section. Populate it from the glossary source. Structure:

```markdown
## Glossary

### User Language → API Concept

| User Says | API Concept | Endpoint |
|-----------|-------------|----------|
| task, to-do, action item | Item | `/items` |
| project, todo list | Item (type=TodoList) | `/items`, `/projects` |
| ...

### Status Aliases

| User Says | API Status |
|-----------|-----------|
| next, to-do, priority, up next | `next` |
| blocked, stuck, issue, waiting | `blocked` |
| ...

### Framework Column Names

| API Column | Default | EOS | OKR | 4DX | V2MOM | SRT |
|-----------|---------|-----|-----|-----|-------|-----|
| next | Next | To-Do | Priorities | WIG Actions | Next | Next |
| ...

### Key Distinctions

| Concept A | Concept B | Difference |
|-----------|-----------|------------|
| Owner | Assignee | Owner = creator. Assignees = responsible. |
| ...
```

Keep the glossary current with whatever the live `glossary.md` contains. This section is the primary lookup for skills translating user commands.

### Step 6: Deploy

After edits are saved, ask the user to confirm deployment, then run:

```bash
bash scripts/deploy.sh
```

This copies the updated `api-reference.md` to all skill `references/` directories and reinstalls skills to `~/.claude/skills/`.

## Excluded Endpoints

These exist in the live spec but are excluded by project decision — never add them:

- `/projects` and all `/projects/{id}/*` routes
- `/teams/{id}/projects/next`
- `/teams/{id}/projects/done`
- `/teams/{id}/projects/issues`

## Useful jq Queries

```bash
# All endpoint paths
jq '.paths | keys[]' /tmp/openapi-v2.json

# Methods for a specific path
jq '.paths["/items"]' /tmp/openapi-v2.json

# All schema names
jq '.components.schemas | keys[]' /tmp/openapi-v2.json

# A specific schema
jq '.components.schemas.Item' /tmp/openapi-v2.json

# All parameters for a method
jq '.paths["/items"]["get"].parameters' /tmp/openapi-v2.json
```
