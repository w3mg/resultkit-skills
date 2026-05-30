# Research: Result Feed API 077 Tier 1 Update

**Branch**: `041-result-feed-tier1-gh109`
**Date**: 2026-04-28

## Summary

No NEEDS CLARIFICATION markers were present in the spec. All decisions are driven directly by the API 077 handoff document (`077-daily-update-tier1-backend`). This file documents the findings from reviewing the current state of `api-reference.md` and `skills/result-feed/SKILL.md` against the handoff.

---

## Finding 1: Reactions Endpoint Renamed

**Decision**: Update all references from `/result-feed/{date}/react` to `/result-feed/{date}/reactions`.

**Current state**:
- `api-reference.md` line 732: `POST /result-feed/{date}/react`
- `SKILL.md` react_to_report step 3: calls `POST "/result-feed/DATE/react"`
- `api-reference.md` line 748 and glossary line 1549: reference `/react`

**API 077 says**:
- `POST /result-feed/:date/reactions` — body: `{ user_id }`, returns `{ reacted: boolean, count: integer }`
- `GET /result-feed/:date/reactions` — param `?user_id=N`, returns `{ reacted: boolean, count: integer }`

**Response shape change**:
- Old: `{ data: { high_five_count, user_has_reacted } }`
- New: `{ data: { reacted, count } }`

**Skill impact**:
- `react_to_report` step 3: endpoint path must change
- `react_to_report` step 4: parse `body.data.reacted` and `body.data.count` instead of `high_five_count`/`user_has_reacted`
- New `get_reactions` flow needed for `GET /reactions`

---

## Finding 2: `review` Section Missing

**Decision**: Add `review` as a valid section name everywhere `done`, `next`, `blocked` are listed.

**Current state**:
- `api-reference.md` line 726: DELETE from section — no mention of `review`
- `api-reference.md` line 729: PUT section metadata — valid sections not listed
- `SKILL.md` line 164: `update_section_meta` says "must be `done`, `next`, or `blocked`"
- `SKILL.md` routing table trigger for notes: lists `done`, `next`, `blocked` only

**API 077 says**:
- `PUT /result-feed/:date/:section/:item_id` — valid sections: `done`, `review`, `next`, `blocked`
- GET response now includes `review` section with same `{ items, notes, attachments }` shape

**Skill impact**:
- `update_section_meta`: add `review` to valid section list
- Routing table triggers: add `review` variants (e.g., "set notes on review")
- `view_team_feeds` and schema: add `review` to `TeamResultFeed`

---

## Finding 3: File Upload Endpoint Missing

**Decision**: Add `POST /result-feed/{date}/attachments` to api-reference and new `upload_attachment` flow to SKILL.md.

**Current state**: Not present in api-reference.md or SKILL.md.

**API 077 says**:
- `POST /result-feed/:date/attachments` — multipart/form-data, field: `file`
- Max 4.5 MB. Returns 201: `{ data: { id, filename, content_type, filesize } }`
- Errors: 400 (missing file), 413 (oversized)
- The returned document ID is used in `attachment_ids` in section PUT calls

---

## Finding 4: Push-to-Slack/Discord Body Param

**Decision**: Change `team_id` to `group_context_id` in push-to-slack and push-to-discord calls.

**Current state**:
- `api-reference.md` line 730-731: `body: team_id*`
- `SKILL.md` push_to_slack step 4: sends `{"team_id":TEAM_ID,"exclude_item_ids":[IDS]}`

**API 077 says**:
- Body: `{ "group_context_id": 42, "exclude_item_ids": [5, 7] }`

**Note**: `group_context_id` is the same value as the team ID resolved from config — just a renamed parameter.

---

## Finding 5: Comments Response Field Name

**Decision**: Use `comment` (not `body`) as the text field in comment response objects.

**Current state**:
- `api-reference.md` line 733: `{ id, body, user_id, created_at }` in GET comments response

**API 077 says**:
- POST 201 response: `{ "id": 99, "comment": "...", "user_id": 1, "created_at": "..." }`
- The field is `comment`, not `body` (`body` is only the request field name)

**Skill impact**: The `list_comments` table header/row labels use `Comment` already — the display is fine. The api-reference description needs updating.

---

## Finding 6: PUT Section/Item — New Body Fields

**Decision**: Document that `PUT /result-feed/{date}/{section}/{item_id}` now optionally accepts `notes` (string) and `attachment_ids` (integer array) in the request body.

**Current state**:
- `api-reference.md` line 725: describes this endpoint as "Add existing item to section (idempotent)" with no body fields mentioned.

**API 077 says**:
- Body: `{ "notes": "text", "attachment_ids": [101, 102] }` (both optional)

---

## No Research Needed

All decisions are fully specified by the API 077 handoff. No ambiguities, no architecture choices, no technology decisions to make. This is a targeted update to two files (+ sync).
