# Contract: rkit:level10 Skill Interface

## Frontmatter

```yaml
name: rkit:level10
description: View and manage EOS Level 10 meeting artifacts — to-dos, issues, and headlines. Full L10 workflow with native EOS terminology.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, AskUserQuestion
```

## Argument Parsing Contract

| Input | Flow | API Route(s) | Method |
|-------|------|-------------|--------|
| *(no args)* | View L10 Board | `GET /teams/{id}/l10/todos`, `GET /teams/{id}/l10/issues`, `GET /teams/{id}/l10/headlines` | GET |
| `todos` | View To-Dos Only | `GET /teams/{id}/l10/todos` | GET |
| `issues` | View Issues Only | `GET /teams/{id}/l10/issues` | GET |
| `headlines` | View Headlines Only | `GET /teams/{id}/l10/headlines` | GET |
| `add todo "text"` | Create To-Do | `POST /teams/{id}/l10/todos` | POST |
| `add issue "text"` | Create Issue | `POST /teams/{id}/l10/issues` | POST |
| `add headline "text"` | Create Headline | `POST /teams/{id}/l10/headlines` | POST |
| `done {item_id}` | Mark To-Do/Issue Done | `PUT /teams/{id}/items/done/{item_id}` | PUT |
| `move {item_id} todos` | Move to To-Dos | `PUT /teams/{id}/items/next/{item_id}` | PUT |
| `move {item_id} issues` | Move to Issues | `PUT /teams/{id}/items/blocked/{item_id}` | PUT |
| `remove headline {id}` | Archive Headline | `DELETE /teams/{id}/headlines/{id}` | DELETE |
| `update headline {id} "text"` | Update Headline Text | `PATCH /teams/{id}/headlines/{id}` | PATCH |
| `--team {id}` *(anywhere)* | Override team ID | — | — |

## Pre-Flight Gate

Before any operation, the skill MUST:
1. Resolve team ID (--team flag → config default_team_id → error)
2. Fetch team detail: `GET /teams/{id}`
3. Check `framework == "eos"` — if not, error and stop

## Write Confirmation Contract

All POST/PUT/PATCH/DELETE operations MUST:
1. Describe the action in plain language with entity names and IDs
2. Wait for user confirmation via AskUserQuestion
3. Only execute after affirmative response

## Display Contracts

### View L10 Board (no args)

```
Level 10: {team_name} (ID: {team_id})

## To-Dos ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 42 | Fix login bug | Scott Levy | 2026-03-07 |

## Issues ({count} items)

| ID | Name | Creator | Due |
|----|------|---------|-----|
| 88 | Cash flow concern | Patrick A. | — |

## Headlines ({count} headlines)

| ID | Text | Creator | Expires |
|----|------|---------|---------|
| 201 | New client signed | John Smith | 2026-03-07 |
```

### Create Response

```
Created to-do **{id}**: "{name}" (due {date})
```

### Move/Done Response

```
Moved **{item_name}** (ID: {item_id}) to **{target_section}**.
```

## Error Contract

| Condition | Response |
|-----------|----------|
| No config | "Config not found. Run `/rkit:setup` first." |
| api.sh not found | "api.sh not found. Install via: `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit`" |
| Non-EOS team | "Level 10 is only available for teams using the EOS framework. Use `/rkit:weekly` instead." |
| 401 | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 404 | "Not found (404)." |
| 422 | Show validation error from response body. |
| Network error | "Network error. Check your connection." |
