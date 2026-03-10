# Research: Team Logo URL Support

**Branch**: `033-team-logo-url-27` | **Date**: 2026-03-09

## Summary

No unknowns requiring external research. The API change handoff document (issue #27) provides complete, authoritative endpoint specs. All decisions are documented below.

---

## Decision 1: How does `logo_url` appear in team GET responses?

**Decision**: `logo_url` is a `string | null` field added to every team object in `GET /teams` (list) and `GET /teams/:id` (detail).

**Rationale**: Documented in the change handoff with full JSON examples. Field is `null` when no logo set, or a Filestack CDN URL string when set.

**Source**: Issue #27 — `GET /teams` and `GET /teams/:id` sections.

---

## Decision 2: What is the correct contract for POST /teams/:id/logo?

**Decision**: `POST /teams/:id/logo` accepts `Content-Type: application/json` with body `{ "logo_url": "https://cdn.filestackcontent.com/..." }`. Old multipart/form-data is no longer accepted.

**Rationale**: Breaking change documented in handoff. Old endpoint was non-functional (never stored usable URLs). New endpoint performs an upsert — submitting again replaces the previous URL.

**Validation**: `logo_url` must start with `https://cdn.filestackcontent.com/`. Empty string, HTTP URL, or wrong domain → 422.

**Authorization**: Admin-only. Non-admins receive 403.

**Response 200**:
```json
{ "data": { "logo_url": "https://cdn.filestackcontent.com/abc123handle" } }
```

---

## Decision 3: What is the contract for DELETE /teams/:id/logo?

**Decision**: `DELETE /teams/:id/logo` removes the stored logo URL. Idempotent — returns 200 even if no logo was stored.

**Authorization**: Admin-only. Non-admins receive 403.

**Response 200**:
```json
{ "data": { "logo_url": null } }
```

---

## Decision 4: Which skills display team data and need logo_url shown?

**Decision**: Only `skills/teams/SKILL.md` displays team list/detail data directly. Other skills that reference teams (e.g., `board`, `today`) show team names/IDs but not detailed team fields, so they don't need updates.

**Rationale**: The `rkit:teams` skill is the canonical team management skill. Other skills fetch team data only for context (default team resolution), not for display.

**Scope**: Only `skills/teams/SKILL.md` and `api-reference.md` (master + synced copy) need changes.

---

## Decision 5: How should logo_url appear in the teams list table?

**Decision**: Add a `Logo` column to the team list table. Show the Filestack handle (last path segment of URL, e.g. `abc123handle`) or "—" if null. Full URL is too long for a table cell.

**Rationale**: Displaying the full CDN URL in a table would overflow. The handle is enough to confirm a logo is set. Users who need the full URL can view team detail.

**Alternative considered**: Show the full URL. Rejected — too long for readable table output.

**Alternative considered**: Omit from table, show only in team detail. Rejected — the spec requires teams list to surface logo_url when present.

---

## Decision 6: Where do set-logo and remove-logo flows live?

**Decision**: Both flows are added as new flows in `skills/teams/SKILL.md`, triggered by natural language commands parsed in the Argument Parsing table.

**New argument patterns**:
- `logo set {team_id} {url}` — set logo for a team
- `logo remove {team_id}` — remove logo for a team

**Rationale**: Keeps all team management in one skill (constitution II: self-contained). Follows existing pattern of argument-based flow dispatch in rkit:teams.

---

## Decision 7: How does api.sh send a JSON body for POST?

**Decision**: `api.sh` accepts a JSON body string as the 3rd argument for POST calls:
```bash
"$API_SH" POST "/teams/TEAM_ID/logo" '{"logo_url":"URL"}'
```
This is the same pattern used by other write flows in the skill suite.

**Source**: Existing SKILL.md patterns (e.g., role change uses `"$API_SH" PATCH "/teams/TEAM_ID/members/USER_ID" '{"role":"ROLE"}'`).
