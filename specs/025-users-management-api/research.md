# Research: Users Management API Endpoints

**Branch**: `025-users-management-api` | **Date**: 2026-03-04

## Finding 1: New `rkit:profile` Skill Is the Right Home

**Decision**: Create a new `skills/profile/SKILL.md` for user stats, preferences, password, and account members.

**Rationale**: The `rkit:setup` skill is focused on config.json bootstrapping (token, team, base URL). Adding preferences, password, and account member management there would bloat the setup flow and confuse its purpose. The `rkit:teams` skill handles team-scoped member management — account members are a different scope (account contains teams). A new `rkit:profile` skill cleanly owns: user identity (stats), user settings (preferences/password), and account governance (account members).

**Alternatives considered**:
- Extend `rkit:setup` with preferences and password — rejected: setup skill would grow from ~2 flows to ~5 with different concerns; "setup" implies initial config, not ongoing user management.
- Extend `rkit:teams` with account members — rejected: account members are account-scoped, not team-scoped. Mixing these in the teams skill would confuse the mental model.
- Multiple tiny new skills (rkit:prefs, rkit:account) — rejected: fragmentation with minimal benefit. All flows share the same user/account context.

## Finding 2: Stats, Preferences, Password, Account Members Are the Skill Flows

**Decision**: `rkit:profile` exposes four flows: `stats`, `prefs` (view/update), `password`, and `account members` (list/remove).

**Rationale**: These are the flows with clear CLI use cases:
- `stats`: quick personal performance summary, useful in daily planning context
- `prefs`: view or change notification settings, timezone, preferred team without the web UI
- `password`: security-sensitive operation that power users want in the CLI
- `account members`: list members, remove a member — account owner admin actions

**Alternatives considered**:
- Expose progress dashboard — deferred: progress data is complex and multi-faceted; better as a future `rkit:progress` skill once the endpoint shape is well-understood.
- Expose integrations view/update — deferred: integration management (webhook URLs, external service selections) has limited CLI value vs. web UI form.

## Finding 3: Reference-Only Endpoints

**Decision**: `measurables`, `rocks`, `feedback`, `integrations`, `progress`, and `check-login` endpoints are documented in api-reference.md but have no skill flows.

**Rationale**:
- `measurables` and `rocks` — existing skills (rkit:board) handle item/rock management. Duplicating rock listing in rkit:profile would create overlap.
- `feedback` — niche read-only view; better surfaced in a future rkit:feedback skill if demand exists.
- `integrations` — user-level integration selections (which apps are connected); low CLI value.
- `progress` — aggregated multi-type dashboard data; complex to format well in CLI output.
- `check-login` — utility for registration flows; no standalone user invocation pattern.

## Finding 4: Preferences Update Needs Targeted Confirmation

**Decision**: Preferences PATCH requires a confirmation prompt showing exactly which fields will change.

**Rationale**: Constitution Principle IV requires confirmation for PATCH. The preferences object is large (20+ fields). The confirmation must diff the current values vs. proposed changes — only showing the fields the user is modifying, not the full object.

## Finding 5: Password Change Skips `current_password` for OAuth Users

**Decision**: The skill must detect whether the user has an existing password before requiring `current_password`.

**Rationale**: The API allows OAuth users (no existing password) to set a new password without `current_password`. The skill cannot reliably detect this client-side without an additional API call. Simplest approach: always prompt for `current_password` but clarify it is only required if the user has an existing password. If the API returns a 422 with a message indicating no existing password, show the error and offer to retry without `current_password`.

**Alternatives considered**:
- Always require `current_password` — rejected: would break OAuth users setting their first password.
- Pre-flight call to detect OAuth status — rejected: no endpoint exposes this; adds unnecessary API roundtrip.

## Finding 6: Account Member Removal Is Owner-Only with Confirmation

**Decision**: `DELETE /accounts/{id}/members/{user_id}` is exposed via `rkit:profile account members remove {user_id}`, owner-only, with a confirmation prompt showing the target user's name and email.

**Rationale**: Constitution Principle IV requires confirmation for DELETE. The confirmation must name the member being removed and the account, making the action reversible in the user's mind before execution.

## Finding 7: Profile Endpoints Default to `"me"`

**Decision**: When no user ID is specified, all profile endpoints (`stats`, `measurables`, `rocks`, `feedback`) use `"me"` as the ID.

**Rationale**: The API explicitly supports the `"me"` alias. The vast majority of CLI usage will be self-focused. Requiring a user ID every time would be friction.

## Finding 8: Notification Booleans Are Already Correct in API Response

**Decision**: The skill reads notification values directly from the API response (which inverts the DB `should_suppress` field). No client-side inversion needed.

**Rationale**: The API handles the inversion. `"morning_day_ahead": true` in the response means the notification IS on. The skill displays these values as-is and sends updated values as-is in PATCH requests.
