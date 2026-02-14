# ResultKit Constitution

Core principles governing all `rkit:*` skills. Every skill must comply.

## I. Self-Contained

Each skill works without requiring any project context, other skills, or the `rm-api-v2` project-level skill. A user can invoke `/rkit:today` from any directory.

## II. Config-Driven

Auth and defaults live in `~/.config/resultkit/config.json`. Never hardcoded. Structure:

```json
{
  "api_token": "<bearer-token>",
  "default_team_id": <int>,
  "api_base": "https://api.resultmaps.com"
}
```

If config is missing or invalid, prompt user to run `/rkit:setup`.

## III. Confirm Writes

- **GET requests** execute immediately without confirmation.
- **POST/PUT/PATCH/DELETE** describe the action and ask for confirmation before executing.

## IV. Show IDs

Always include entity IDs (item, team, user, meeting) in output so users can reference them in follow-up commands.

## V. Framework-Aware

Translate management framework terminology (EOS, OKR, 4DX, V2MOM, SRT) into correct API concepts using the team's `framework` field. Example: "rocks" → items with status context in EOS teams.

## VI. Direct Execution

Use the Bash tool directly for all API calls via the shared `api.sh` script. No Task agents or subagents.

## VII. Graceful Degradation

- Missing config → suggest `/rkit:setup`
- Missing default team → list teams and ask user to pick
- API errors → show status code, error message, and actionable fix
- 401 → prompt for new token

## VIII. Concise Output

Format responses as clean tables or short summaries. No verbose prose. Show what matters: names, statuses, IDs, dates.

---

**Version**: 1.0 | **Created**: 2026-02-14
