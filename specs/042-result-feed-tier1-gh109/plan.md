# Implementation Plan: Update Result-Feed Skill for Tier 1 Backend API Changes

**Branch**: `042-result-feed-tier1-gh109` | **Date**: 2026-04-28 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/042-result-feed-tier1-gh109/spec.md`

## Summary

Update the `rkit:result-feed` skill and master `api-reference.md` to align with the Tier 1 backend API handoff (issue #109). The SKILL.md already has most flows implemented but has field-name mismatches, a missing `review` section, incorrect attachment schema, and missing endpoints (file upload, GET reactions). The api-reference.md similarly needs corrections and additions.

## Technical Context

**Language/Version**: Bash 5.x + Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`
**Storage**: `~/.config/resultkit/config.json` (read-only at skill runtime)
**Testing**: Manual — invoke skill via Claude Code, verify API responses
**Target Platform**: Claude Code CLI (cross-platform)
**Project Type**: Single (plugin skill)
**Performance Goals**: N/A — interactive CLI skill
**Constraints**: N/A
**Scale/Scope**: 1 SKILL.md file, 1 master api-reference.md, sync to all skills

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | PASS | Skill is SKILL.md with `allowed-tools` frontmatter |
| II | Self-Contained | PASS | No project context required; config-only dependency |
| III | Config-Driven | PASS | Auth/defaults from config.json |
| IV | Confirm Writes | PASS | All POST/PUT/DELETE flows require confirmation |
| V | Show IDs | PASS | All output includes entity IDs |
| VI | Framework-Aware | N/A | Result feed is framework-agnostic |
| VII | Direct Execution | PASS | Uses Bash + api.sh, no subagents |
| VIII | Graceful Degradation | PASS | Error table covers missing config, 401, 403, 404, 422, 502 |
| IX | Concise Output | PASS | Tables and short summaries |

**Gate result: PASS** — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/042-result-feed-tier1-gh109/
├── plan.md              # This file
├── spec.md              # Feature spec
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── checklists/
    └── requirements.md  # Spec quality checklist
```

### Source Code (repository root)

```text
skills/result-feed/
├── SKILL.md              # Main skill file (update)
├── scripts/
│   └── api.sh            # Shared API caller (synced copy)
└── references/
    └── api-reference.md  # API reference (synced copy)

api-reference.md          # Master API reference (update)
scripts/api.sh            # Master API caller (no changes needed)
```

**Structure Decision**: No new files. Updates to 2 existing files (SKILL.md, api-reference.md) plus sync to all skills.

## Identified Gaps (SKILL.md vs API Handoff)

### Critical Mismatches

1. **Reactions endpoint path**: SKILL.md uses `POST /result-feed/DATE/react` → API uses `POST /result-feed/:date/reactions`
2. **Reactions response fields**: SKILL.md reads `high_five_count` + `user_has_reacted` → API returns `reacted` + `count`
3. **Push body field**: SKILL.md uses `team_id` → API uses `group_context_id`
4. **Attachment schema**: SKILL.md has `{ id, filename, url }` → API returns `{ id, filename, content_type, size }`
5. **Comment response field**: API returns `comment` field, not `body`

### Missing Features

6. **`review` section**: Not in schema, not in section rendering, not in update_section_meta valid sections
7. **GET /result-feed/:date/reactions**: Not documented or implemented (only POST toggle)
8. **POST /result-feed/:date/attachments**: File upload endpoint — not in skill at all
9. **`user_id` param on reactions/comments**: Skill doesn't pass `user_id` to specify whose report

### api-reference.md Gaps

10. **Reactions endpoint**: Path is `/react` → should be `/reactions`; response fields wrong
11. **GET reactions**: Missing entirely
12. **File upload endpoint**: Missing entirely
13. **Push body field**: `team_id` → `group_context_id`
14. **`review` section**: Not mentioned as valid section
15. **Attachment shape**: Not documented with `content_type` and `size`
16. **Comment response shape**: Needs `comment` field (not `body`)
17. **Submit side-effects**: Not documented (ObjectMeta upsert, daily recurrence rollover)

## Implementation Approach

### Phase 1: Fix api-reference.md (master)

Update all result-feed entries:
- Fix reactions endpoint path and response shape
- Add GET reactions endpoint
- Add POST attachments (file upload) endpoint
- Fix push body param (`group_context_id`)
- Add `review` as valid section
- Fix attachment document shape
- Fix comment response shape
- Document submit side-effects
- Update glossary/synonym entries

### Phase 2: Fix SKILL.md

1. **Add `review` section** to:
   - Schema (TeamResultFeed, ResultFeedSection description)
   - Section rendering rules (display order: Done, Review, Next, Blocked)
   - update_section_meta valid sections
   - Tool routing table triggers (if needed)

2. **Fix reactions flow**:
   - Endpoint: `/result-feed/DATE/react` → `/result-feed/DATE/reactions`
   - Response parsing: `high_five_count`/`user_has_reacted` → `count`/`reacted`
   - Add `user_id` param support (for reacting to someone else's report)

3. **Fix push flows**:
   - Body field: `team_id` → `group_context_id`

4. **Fix attachment schema**:
   - `{ id, filename, url }` → `{ id, filename, content_type, size }`
   - Update section rendering to show `filename (content_type, size)`

5. **Fix comments**:
   - Add `user_id` param to GET and POST
   - Fix response field: `body` → `comment` in display

6. **Add GET reactions flow** (or merge into existing react flow to show current state)

7. **Add file upload flow** (new routing table entry + flow)

### Phase 3: Sync and ship

- Run `/sync-plugin` to copy master api-reference.md to all skills
- Bump plugin version
- Commit, push, close issue

## Complexity Tracking

No violations — no complexity justification needed.
