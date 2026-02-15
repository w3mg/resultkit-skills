# ResultKit Constitution

Core principles governing all `rkit:*` skills. Every skill MUST comply.

## I. Claude Code Skill Format

Every rkit skill MUST be built as a Claude Code skill following Anthropic's skill authoring format. Each skill is a `SKILL.md` file installed to `~/.claude/skills/` and invoked via the `/rkit:*` namespace.

- Skills MUST use `SKILL.md` as the entry point.
- Skills MUST be authored for the Claude Code agent runtime — no standalone CLI binaries, no external runtimes.
- Skill behavior is defined declaratively in Markdown with embedded tool-use instructions that Claude Code executes.
- Reference scripts (e.g., `api.sh`) are permitted as supporting files but MUST NOT replace the skill entry point.

## II. Self-Contained

Each skill works without requiring any project context, other skills, or the `rm-api-v2` project-level skill. A user can invoke `/rkit:today` from any directory.

## III. Config-Driven

Auth and defaults live in `~/.config/resultkit/config.json`. Never hardcoded. Structure:

```json
{
  "api_token": "<bearer-token>",
  "default_team_id": "<int>",
  "api_base": "https://api.resultmaps.com"
}
```

If config is missing or invalid, prompt user to run `/rkit:setup`.

## IV. Confirm Writes

- **GET requests** execute immediately without confirmation.
- **POST/PUT/PATCH/DELETE** describe the action and ask for confirmation before executing.

## V. Show IDs

Always include entity IDs (item, team, user, meeting) in output so users can reference them in follow-up commands.

## VI. Framework-Aware

Translate management framework terminology (EOS, OKR, 4DX, V2MOM, SRT) into correct API concepts using the team's `framework` field. Example: "rocks" → items with status context in EOS teams.

## VII. Direct Execution

Use the Bash tool directly for all API calls via the shared `api.sh` script. No Task agents or subagents.

## VIII. Graceful Degradation

- Missing config → suggest `/rkit:setup`
- Missing default team → list teams and ask user to pick
- API errors → show status code, error message, and actionable fix
- 401 → prompt for new token

## IX. Concise Output

Format responses as clean tables or short summaries. No verbose prose. Show what matters: names, statuses, IDs, dates.

---

**Version**: 1.1.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-14
