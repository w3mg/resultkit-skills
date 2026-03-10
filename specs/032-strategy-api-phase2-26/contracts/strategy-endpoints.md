# Strategy API Contracts (Phase 2)

## GET /teams/{id}/strategy

Fetch the team's strategy tree for a given year/quarter.

**Auth**: Bearer token (team member)

**Query params**:
- `year` — integer or `All` (default: current year)
- `quarter` — integer 1-4 or `All` (default: current quarter)

**Removed params** (Phase 2 breaking change):
- ~~`cascade`~~ — cascade is now auto-detected from `is_cascading_goals` team setting

**Response 200**:
```json
{
  "data": {
    "framework": "eos | okr | 4dx",
    "strategy": [StrategyNode],
    "unaligned": [StrategyNode]
  }
}
```

StrategyNode includes `inherited: boolean` and `inherited_from: { team_id, team_name } | null`.

4DX teams may include nodes with `object_type: "action"` (L4 leaf nodes).

---

## POST /teams/{id}/strategy

Create a new strategy object.

**Auth**: Bearer token. Root-level requires team admin; child creation requires admin or node-level assignment on parent.

**Body**:
```json
{
  "name": "string (required)",
  "parent_id": "integer | null",
  "parent_type": "string | null",
  "due": "YYYY-MM-DD | null",
  "status": "string | null",
  "assignees": "[integer] | null",
  "is_focus_area": "boolean | null"
}
```

**Removed fields** (Phase 2 breaking change):
- ~~`object_type`~~ — type is fully inferred from framework + parent context

**Added fields** (Phase 2):
- `is_focus_area` — set `true` to create a root-level OKR/4DX result area (Focus Area)

**Response 201**:
```json
{
  "data": {
    "id": 42,
    "object_type": "rock"
  }
}
```

---

## PUT /strategy/align (team-less)

Align an existing strategy object to a parent. Auto-detects linkage mechanism.

**Auth**: Bearer token

**Body**:
```json
{
  "object_id": "integer (required)",
  "object_type": "string (required)",
  "parent_id": "integer (required)",
  "parent_type": "string (required)"
}
```

**Removed fields** (Phase 2 breaking change):
- ~~`link_type`~~ — linkage auto-detected from object/parent type pair

**Response 200**: Success

---

## PUT /teams/{id}/strategy (team-scoped align)

Delegates to same service as `PUT /strategy/align`. Same body, same behavior.

**Removed fields**: ~~`link_type`~~

---

## PATCH /strategy/{objectType}/{objectId} (team-less)

Update a strategy object. Preferred over team-scoped PATCH.

**Path params**:
- `objectType`: `Goal | Item`
- `objectId`: integer

**Body** (all optional):
```json
{
  "name": "string",
  "description": "string",
  "status": "string",
  "due": "YYYY-MM-DD",
  "assignees": "[integer]"
}
```

**Response 200**: Success

---

## PATCH /teams/{id}/strategy (team-scoped update)

Still functional, unchanged behavior. Prefer team-less route.

---

## DELETE /strategy/{objectType}/{objectId} (team-less)

Remove (unlink) a strategy object from its parent. Default: unlink only (object preserved).

**Path params**:
- `objectType`: `Goal | Item`
- `objectId`: integer

**Body**:
```json
{
  "parent_id": "integer (required)",
  "parent_type": "string (required)",
  "also_archive": "boolean | null"
}
```

**Removed params** (Phase 2 breaking change):
- ~~`?action=archive|unlink`~~ — replaced by `also_archive` boolean in body

**Behavior**:
- Default (no `also_archive`): unlink only — object moved to unaligned
- `also_archive: true`: unlink AND archive the object

**Response 204**: No Content

---

## DELETE /teams/{id}/strategy (team-scoped detach)

**Breaking change from Phase 1**:
- Default changed from **archive** to **unlink**
- Requires `parent_id` and `parent_type` in body (previously only `object_id` and `object_type`)
- Removed `?action=` query parameter
- Added `also_archive` boolean to body

Same body structure as DELETE /strategy/{objectType}/{objectId}.
