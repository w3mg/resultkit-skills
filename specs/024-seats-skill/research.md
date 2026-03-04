# Research: rkit:seats Skill

**Date**: 2026-03-04 | **Branch**: `024-seats-skill`

## R1: Seats API Endpoints

**Decision**: Use all available seats endpoints from the ResultMaps V2 API.

**Rationale**: Live API testing confirmed the following endpoints respond correctly:

| Method | Path | Purpose | Confirmed |
|--------|------|---------|-----------|
| GET | `/teams/{id}/seats` | Full recursive tree | 200 |
| GET | `/seats/{id}` | Single seat detail | 200 |
| POST | `/seats` | Create seat (body: name, team_id, parent_id?) | 201/422 |
| PATCH | `/seats/{id}` | Update seat fields | 200 |
| DELETE | `/seats/{id}` | Archive seat | 204 |
| PUT | `/seats/{id}/move` | Move seat (body: parent_id) | 200/422 |
| PUT | `/seats/{id}/restore` | Restore archived seat | 200/422 |
| GET | `/seats/{id}/measures` | List aligned measures | 200 |
| PUT | `/seats/{id}/measures` | Align measure (body: measure_id) | 200 |
| DELETE | `/seats/{id}/measures/{mid}` | Remove measure alignment | 204 |
| GET | `/seats/{id}/goals` | List aligned goals | 200 |
| PUT | `/seats/{id}/goals` | Align goal (body: goal_id) | 200 |
| DELETE | `/seats/{id}/goals/{gid}` | Remove goal alignment | 204 |
| GET | `/seats/{id}/links` | List links | 200 |
| POST | `/seats/{id}/links` | Create link (body: url, title?) | 201 |
| DELETE | `/seats/{id}/links/{lid}` | Delete link | 204 |

**Alternatives considered**: None — these are the only API endpoints for seats.

**Notable**: `POST /teams/{id}/seats` returns 405. Must use `POST /seats` with `team_id` in body.

## R2: HTML Accountability Rendering

**Decision**: Strip HTML to plain text using sed for CLI display.

**Rationale**: The `accountabilities` field contains HTML (e.g., `<ul><li>Strategic direction</li></ul>`). For CLI output, strip tags to produce readable text. List items (`<li>`) become bullet points with `- ` prefix. `<br>` and block elements become newlines.

**Approach**:
```bash
echo "$HTML" | sed 's/<li[^>]*>/- /g; s/<br[^>]*>/\n/g; s/<\/li>/\n/g; s/<[^>]*>//g' | sed '/^$/d'
```

**Alternatives considered**:
- `lynx -dump` — heavier dependency, not available everywhere
- `pandoc` — overkill for simple HTML lists
- Raw HTML display — unreadable in terminal

## R3: Tree Rendering

**Decision**: Render the accountability chart as an indented tree with `├──`, `└──`, and `│` box-drawing characters.

**Rationale**: The `GET /teams/{id}/seats` endpoint returns the full tree with recursively nested `children[]`. Each level increments indentation. Format per node: `├── SeatName (Owner Name) [ID: 42]` or `├── SeatName (Vacant) [ID: 42]`.

**Approach**: Use jq recursive function to traverse the tree and output with increasing depth prefix. The tree is fetched in a single API call — no pagination needed.

**Alternatives considered**:
- Flat table — loses hierarchy information
- Numbered indentation (1, 1.1, 1.1.1) — harder to scan visually

## R4: Client-Side Search

**Decision**: No search flow needed. The tree view and detail view cover all use cases.

**Rationale**: The API has no server-side search/filter for seats. Adding client-side jq filtering for "find by name" or "find vacant" would add complexity for marginal value. Users can visually scan the tree (typically <50 seats) or use seat IDs from the tree view.

**Alternatives considered**:
- Client-side jq filtering with `--search` flag — added complexity, tree is small enough to scan
- Separate search flow — over-engineering for typical org chart sizes

## R5: Detail Display Format

**Decision**: Display seat details as a structured block with sections for each data type.

**Rationale**: A single seat has many data facets (accountabilities, measures, goals, links, children). Group them into clear sections with IDs shown.

**Format**:
```
## SeatName [ID: 42]
**Owner**: FirstName LastName (@login) [ID: 5] | Vacant
**Parent**: ParentName [ID: 11]
**Team**: TeamName [ID: 345]
**Associated Team**: TeamName [ID: 1] | None

**Accountabilities**:
- Strategic direction
- Leadership

**Notes**: Optional notes text

**Measures** (3):
| ID | Name |
|----|------|
| 793 | Weekly KPI |

**Goals** (2):
| ID | Name |
|----|------|
| 7315 | Be everywhere |

**Links** (1):
| ID | Title | URL |
|----|-------|-----|
| 2078 | Wiki | https://... |

**Direct Reports** (3):
| ID | Name | Owner |
|----|------|-------|
| 1138 | Executive Assistant | Mary Mejia |
```

**Alternatives considered**:
- Single flat table — too cramped for all the fields
- Multiple API calls for sub-resources — unnecessary, single seat endpoint returns everything

## R6: Response Shape Differences

**Decision**: Handle the two different response envelopes correctly.

**Rationale**:
- `GET /teams/{id}/seats` returns `{data: [Seat, ...]}` — array at top level with full recursive children
- `GET /seats/{id}` returns `{data: Seat}` — single object with children as `{id, name}` only

The tree flow uses the team endpoint (full recursive data). The detail flow uses the seat endpoint (single seat with simplified children — sufficient since we show children as a table of IDs/names).
