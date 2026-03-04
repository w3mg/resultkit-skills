# Research: 1on1 Skill — Filter Archived Items from Output

**Phase**: 0 — Pre-design
**Feature**: 028-1on1-archive-filter

## Summary

The bug is fully explained by the API's behavior on `GET /meetings/{id}`. No external research required. All decisions derived from the api-reference.md and the existing SKILL.md.

---

## Decision: Root Cause of the Bug

**Decision**: The View One-on-One Detail flow calls `GET /meetings/{id}`, which returns `next`, `done`, and `blocked` arrays directly in the response body. This endpoint does **not** support `include_archived` — it returns all items in those arrays regardless of their archived status. The fix must be **client-side filtering**: after receiving the response, exclude items where `status == "archived"` before rendering.

**Rationale**: The api-reference.md explicitly states that `include_archived` is supported on `GET /meetings/{id}/items` and `GET /meetings/{id}/items/{section}`, but NOT on `GET /meetings/{id}`. There is no server-side mechanism to suppress archived items from the detail endpoint.

**Alternatives considered**:
- Switch View Detail to use `GET /meetings/{id}/items` instead of `GET /meetings/{id}`: Rejected — would require two API calls (one per column), restructure the display logic, and potentially break the item count shown in headers. Client-side filtering on the existing response is minimal and safe.

---

## Decision: View Single Column Already Correct (No Fix Needed)

**Decision**: The View Single Column flow calls `GET /meetings/{id}/items/{section}?per_page=50`. Per the api-reference: "by default, archived items are excluded from all list endpoints." Since `include_archived` is not passed, the API already excludes archived items from this endpoint. No code change needed for this flow.

**Rationale**: The bug report only describes `/rkit:1on1 {id}` (the detail view). The single-column view (`/rkit:1on1 {id} next`) uses a different endpoint that already has the correct default behavior.

**Alternatives considered**:
- Apply redundant client-side filtering to the single-column flow as a defensive measure: Could be added, but adds unnecessary code for behavior the API already guarantees. Kept out of scope.

---

## Decision: Filter Logic

**Decision**: After receiving the `GET /meetings/{id}` response, filter each of the three arrays (`next`, `done`, `blocked`) to exclude any item where `status == "archived"`. Items with null/missing `status` are treated as active (not filtered out), per the spec edge case.

**Rationale**: The `status` field is well-defined in the API (values: `not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`). Filtering on the exact string `"archived"` is precise and safe.

---

## API Fields Reference (confirmed from api-reference.md)

### GET /meetings/{id} — Response

```json
{
  "id": 14,
  "type": "one_on_one",
  "next": [
    { "id": 42, "name": "...", "status": "next", "creator": {...}, "due": null },
    { "id": 17, "name": "...", "status": "archived", "creator": {...}, "due": null }
  ],
  "done": [...],
  "blocked": [...]
}
```

Items in `next`/`done`/`blocked` include their `status` field. Filter: keep only items where `status != "archived"`.

### GET /meetings/{id}/items/{section} — Already filtered server-side

`include_archived` defaults to `false`. No fix needed.
