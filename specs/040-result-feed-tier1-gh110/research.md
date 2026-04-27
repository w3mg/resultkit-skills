# Research: Daily Update API v2 — Tier 1 Backend Gap Coverage

**Date**: 2026-04-27 | **Branch**: `040-result-feed-tier1-gh110`

## R1: Section Shape Breaking Change Impact

**Decision**: Update both `rkit:today` and `rkit:result-feed` skills to parse the new object shape.

**Rationale**: The `rkit:today` skill does NOT currently parse result-feed sections (it uses `/day-plans/` endpoints, not `/result-feed/`). Only `rkit:result-feed` directly parses the `done`/`next`/`blocked` section arrays. However, `rkit:today` may add result-feed viewing capabilities with the new endpoints.

**Alternatives considered**: None — this is a mandatory breaking change fix.

**Findings from codebase review**:
- `skills/today/SKILL.md` — uses `/day-plans/` endpoints exclusively. Does NOT read result-feed sections. No breaking change impact on this skill's existing functionality.
- `skills/result-feed/SKILL.md` — reads `done`, `next`, `blocked` as flat arrays (lines 81-88). This MUST be updated to `section.items`.

## R2: Where to Add New Endpoint Capabilities

**Decision**: Extend `rkit:result-feed` to handle all new result-feed endpoints (section meta updates, reactions, comments, push-to-slack/discord, team-feed detail view). Add group-context to `rkit:today` or a shared location.

**Rationale**: The result-feed skill is the natural home for result-feed-scoped endpoints. The `rkit:today` skill stays focused on day-plan operations.

**Alternatives considered**:
- Create a new `rkit:checkin` skill — rejected because `rkit:result-feed` already exists and handles this domain.
- Split across multiple new skills — rejected per Constitution II (self-contained) and to avoid skill proliferation.

## R3: Webhook Push UX

**Decision**: Add push-to-slack and push-to-discord as triggers in the result-feed skill's routing table. Check `has_slack_webhook`/`has_discord_webhook` from team data before offering.

**Rationale**: The team endpoint already returns these flags. Skills should use them to give clear feedback before attempting a push.

**Alternatives considered**: Always attempt the push and handle 422 — rejected because proactive feedback is better UX.

## R4: Group Context Endpoint Placement

**Decision**: Add `set_group_context` as a trigger in `rkit:result-feed` since it's used in the share/submit flow.

**Rationale**: Group context is used when sharing check-ins, which is result-feed domain. It mirrors the existing `team-context` PATCH endpoint.

**Alternatives considered**: Add to `rkit:today` — rejected because today manages day-plans, not result-feed sharing.
