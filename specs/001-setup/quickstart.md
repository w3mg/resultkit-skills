# Quickstart: rkit:setup

## Prerequisites

- Claude Code installed and running
- A ResultMaps account with an API token (get it from your ResultMaps
  profile settings)

## First-Time Setup

1. In any Claude Code conversation, type:
   ```
   /rkit:setup
   ```

2. When prompted, paste your API token.

3. The skill verifies your token and shows your account info:
   ```
   Verified: Scott Levy (scott@example.com)
   ```

4. Pick your default team from the list:
   ```
   Teams:
   | # | ID | Name        | Framework |
   |---|----|-------------|-----------|
   | 1 | 1  | Engineering | EOS       |
   | 2 | 2  | Product     | OKR       |

   Enter team number:
   ```

5. Setup confirms and saves:
   ```
   Config saved to ~/.config/resultkit/config.json
   Default team: Engineering (ID: 1)
   ```

## Reconfigure

Run `/rkit:setup` again. It detects the existing config and shows:
```
Current config:
  Token: rm_...xxxx
  Team: Engineering (ID: 1)
  API: https://api.resultmaps.com/api/v2

What would you like to update?
```

Choose token, team, or API base to update selectively.

## Environment Variable

Set `RESULTKIT_TOKEN` before running setup to skip manual token entry:
```bash
export RESULTKIT_TOKEN="rm_your_token_here"
```

Setup will offer to use it automatically.

## Verify It Worked

After setup, try any rkit skill:
```
/rkit:today
```

If config is valid, you'll see your day plan. If something is wrong,
the skill will tell you to re-run `/rkit:setup`.
