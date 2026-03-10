# Quickstart: Team Logo URL Support

**Branch**: `033-team-logo-url-27` | **Date**: 2026-03-09

## What Changes

Two files change. Everything else stays the same.

| File | Change |
|------|--------|
| `api-reference.md` | Add `logo_url` field to team response docs; add POST/DELETE logo endpoints |
| `skills/teams/SKILL.md` | Show `logo_url` in team list; add set-logo and remove-logo flows |

After updating, run `/sync-plugin` to copy both master files to all skill subdirectories and bump the plugin version.

---

## Step 1: Update api-reference.md

In the **Teams** section, two changes:

**1a. Add `logo_url` to the team fields list.**

Current line (near `GET /teams` response description):
> `GET /teams` returns the standard data envelope: `{ "data": [...] }`. Response fields per team: `id`, `name`, `description`, ...

Add `logo_url` (string | null) to that list.

**1b. Add two new endpoint rows to the Teams endpoint table:**

```
| POST | `/teams/{id}/logo` | Set team logo URL (body: logo_url* — must be Filestack CDN URL). Admin only. Upsert. | "set team logo", "upload logo", "add logo" | — |
| DELETE | `/teams/{id}/logo` | Remove team logo URL. Admin only. Idempotent. | "remove team logo", "delete logo", "clear logo" | — |
```

---

## Step 2: Update skills/teams/SKILL.md

**2a. Add `logo` argument patterns to Argument Parsing table:**

```markdown
| `logo set {url} [team_id]` | Set logo for a team (admin only) |
| `logo remove [team_id]` | Remove logo for a team (admin only) |
```

**2b. Add `Logo` column to team list table output:**

In the **Flow: List Teams → Step 3** table, add a `Logo` column showing the Filestack handle (last path segment) or "—" if null.

**2c. Add new flow: Set Logo**

**2d. Add new flow: Remove Logo**

See [contracts/team-logo.md](contracts/team-logo.md) for exact flow specs.

---

## Step 3: Sync and ship

```bash
# Sync master files to all skill directories + bump version
/sync-plugin

# Verify the skill works
scripts/api.sh GET /teams | jq '.data[0].logo_url'

# Commit and push
/ship-it
```

---

## Testing

### Verify logo_url in team list
```bash
scripts/api.sh GET /teams | jq '.data[] | {id, name, logo_url}'
```

### Set a logo (replace TEAM_ID and HANDLE)
```bash
scripts/api.sh POST "/teams/TEAM_ID/logo" '{"logo_url":"https://cdn.filestackcontent.com/HANDLE"}'
```

### Remove a logo
```bash
scripts/api.sh DELETE "/teams/TEAM_ID/logo"
```

### Verify 422 on bad URL
```bash
scripts/api.sh POST "/teams/TEAM_ID/logo" '{"logo_url":"https://example.com/logo.png"}'
# Expect: 422 with validation error
```
