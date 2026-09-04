# Opening a URL in the user's browser

`scripts/rk-open.sh` does the launching. This file explains what it does on each platform, what its output means, and what to tell the user when it cannot open anything.

## What the script prints

Exactly one JSON line on stdout, always:

| Line | Meaning | What to say |
|---|---|---|
| `{"opened":true,"url":…,"opener":"open"}` | A browser tab was launched | Report the name, ID, and URL |
| `{"opened":false,"url":…,"reason":"printed"}` | `--print` or `RKIT_OPEN_DRY_RUN=1`; nothing launched | Give the URL — that is the reply |
| `{"opened":false,"url":…,"reason":"headless"}` | SSH session or Linux with no display | "No browser on this end. Open this: {url}" |
| `{"opened":false,"url":…,"reason":"no_opener"}` | No opener command exists on this machine | Give the URL and the fix below |
| `{"opened":false,"url":…,"reason":"launch_failed","opener":…}` | The opener ran and failed | Give the URL and the fix below |
| `{"error":"BAD_ID"…}` / `BAD_OPTION` / `USAGE` | Your arguments were wrong | Fix the call; the user never sees this |
| `{"error":"FOREIGN_HOST"…}` | The URL is not on the ResultKit host | "I only open ResultKit links" |
| `{"error":"LEGACY_UNMAPPED"…}` | An `app.resultmaps.com` path with no counterpart | Say so; offer the nearest surface from `url-map.md` |

Exit code: 0 opened or printed, 1 could not launch, 2 bad arguments.

## How the opener is chosen

In order:

1. **`$BROWSER`** if set. It is run through `sh -c`; a `%s` in it is replaced by the URL, otherwise the URL is appended. This is how a user picks a specific browser: `BROWSER='open -a "Google Chrome"'` on macOS, `BROWSER=firefox` on Linux, `BROWSER='open -a Safari'`.
2. **macOS** → `open "$url"` (the default browser).
3. **WSL** (Linux with "microsoft" in `/proc/version`) → `wslview` (from the `wslu` package), else `rundll32.exe url.dll,FileProtocolHandler`, else `powershell.exe Start-Process`. Each hands the URL to the Windows default browser; `rundll32` is preferred over `cmd /c start` because `&` in a query string does not survive `cmd`.
4. **Linux desktop** (`DISPLAY` or `WAYLAND_DISPLAY` set) → `xdg-open`, detached with `nohup` so a desktop that blocks on it does not hang the skill.
5. **Git Bash / MSYS / Cygwin on Windows** → `rundll32.exe url.dll,FileProtocolHandler`, else `cmd.exe /c start`.

Before any of that: when `SSH_TTY` or `SSH_CONNECTION` is set and there is no display, the script prints the URL with `reason: headless`. Launching a browser on the far end of an SSH session would open a window nobody is looking at.

## Fixes to offer, one line each

- **Linux, `no_opener`** → `sudo apt install xdg-utils` (or the distro's equivalent), or `export BROWSER=firefox`.
- **WSL, `no_opener`** → `sudo apt install wslu` gives `wslview`; or `export BROWSER='/mnt/c/Windows/System32/rundll32.exe url.dll,FileProtocolHandler'`.
- **`launch_failed` with `opener: BROWSER`** → the `$BROWSER` command is wrong; show it and the URL.
- **Anything else** → hand over the URL. A pasted link is a fine outcome.

## Dry runs and tests

`RKIT_OPEN_DRY_RUN=1` makes every call behave like `--print`. Use it whenever a browser tab on the user's machine would be a surprise — evaluations, demos, scripts that would otherwise open many tabs.

## Pointing at a local or staging app

Set `web_base` in `~/.config/resultkit/config.json` (`"web_base": "http://localhost:3001"`) or export `RESULTKIT_WEB_BASE`. The environment variable wins over the config; both fall back to `https://resultkit.ai`. `rk-open.sh url` accepts full links only on that host, so a pasted production link is refused while `web_base` points at localhost — pass the path (`/items/123`) instead.

## Why the skill never opens two tabs

`open` and `xdg-open` return immediately and give no handle back; there is no way to focus, close, or reuse a tab once launched. A request that names one thing gets one tab. A list of things gets a list of links unless the user explicitly asked for each to open.
