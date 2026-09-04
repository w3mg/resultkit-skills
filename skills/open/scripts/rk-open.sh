#!/usr/bin/env bash
#
# rk-open.sh — build the right ResultKit web URL for a thing, then open it in
# the user's default browser. Companion to the rkit:open skill.
#
# Usage:
#   rk-open.sh <kind> <id> [options]         build the URL for a kind + id, then open it
#   rk-open.sh url <url-or-path> [options]   open a link you already have (legacy hosts converted)
#
# Kinds:
#   item <id>          [--tab details|comments|steps|alignment] [--on <path>]
#   project <id>       [--view overview|board|table|gantt|roadmap]
#   page <id>
#   team <id>
#   l10 <team_id>      [--tab agenda|kanban|extras]
#   target <id>        --team <team_id>      (yearly goal, rock, or milestone)
#   seat <id>
#   user <id>
#   review <id>
#   1on1 <id>
#   roadmap <id>
#   result-update <YYYY-MM-DD>
#   scorecard <team_id>
#   today | prioritizer | home
#
# Options (any kind):
#   --print            print the URL, do not launch a browser
#
# Environment:
#   RESULTKIT_WEB_BASE   web app base URL (default: "web_base" in
#                        ~/.config/resultkit/config.json, else https://resultkit.ai)
#   BROWSER              opener command; "%s" is replaced by the URL, otherwise
#                        the URL is appended (e.g. BROWSER='open -a "Google Chrome"')
#   RKIT_OPEN_DRY_RUN=1  never launch; behaves like --print (used by tests)
#
# Output: exactly one JSON line on stdout, in the spirit of api.sh:
#   {"opened":true,"url":"https://resultkit.ai/items/123","opener":"open"}
#   {"opened":false,"url":"https://resultkit.ai/items/123","reason":"printed"}
#   {"opened":false,"url":"...","reason":"headless"|"no_opener"|"launch_failed","opener":"..."}
#   {"error":"USAGE"|"BAD_ID"|"BAD_OPTION"|"LEGACY_UNMAPPED"|"FOREIGN_HOST","detail":"..."}
# Exit codes: 0 opened or printed; 1 launch failed or no opener; 2 bad arguments.

set -euo pipefail

CONFIG_FILE="$HOME/.config/resultkit/config.json"
DEFAULT_WEB_BASE="https://resultkit.ai"

# --- helpers ---------------------------------------------------------------

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

fail() { # code detail
  printf '{"error":"%s","detail":"%s"}\n' "$1" "$(json_escape "$2")"
  exit 2
}

need_int() { # value label
  [[ "$1" =~ ^[0-9]+$ ]] || fail "BAD_ID" "$2 must be a positive integer, got: $1"
}

web_base() {
  local base="${RESULTKIT_WEB_BASE:-}"
  if [ -z "$base" ] && [ -f "$CONFIG_FILE" ]; then
    base=$(jq -r '.web_base // empty' "$CONFIG_FILE" 2>/dev/null || true)
  fi
  base="${base:-$DEFAULT_WEB_BASE}"
  printf '%s' "${base%/}"
}

# Append a query pair to a path that may or may not already carry a query.
with_query() { # path key value
  case "$1" in
    *\?*) printf '%s&%s=%s' "$1" "$2" "$3" ;;
    *)    printf '%s?%s=%s' "$1" "$2" "$3" ;;
  esac
}

# --- argument parsing ------------------------------------------------------

[ $# -ge 1 ] || fail "USAGE" "rk-open.sh <kind> <id> [--print] [--tab X] [--view X] [--on PATH] [--team ID]"

KIND="$1"; shift
ARG=""
PRINT_ONLY="${RKIT_OPEN_DRY_RUN:-0}"
TAB=""; VIEW=""; ON=""; TEAM=""

while [ $# -gt 0 ]; do
  case "$1" in
    --print) PRINT_ONLY=1 ;;
    --tab)   [ $# -ge 2 ] || fail "BAD_OPTION" "--tab needs a value"; TAB="$2"; shift ;;
    --view)  [ $# -ge 2 ] || fail "BAD_OPTION" "--view needs a value"; VIEW="$2"; shift ;;
    --on)    [ $# -ge 2 ] || fail "BAD_OPTION" "--on needs a path"; ON="$2"; shift ;;
    --team)  [ $# -ge 2 ] || fail "BAD_OPTION" "--team needs a team id"; TEAM="$2"; shift ;;
    --*)     fail "BAD_OPTION" "unknown option: $1" ;;
    *)       [ -z "$ARG" ] && ARG="$1" || fail "BAD_OPTION" "unexpected argument: $1" ;;
  esac
  shift
done

BASE="$(web_base)"
BASE_HOST="${BASE#*://}"; BASE_HOST="${BASE_HOST%%/*}"

# --- build the path --------------------------------------------------------

PATH_PART=""
case "$KIND" in
  item)
    need_int "$ARG" "item id"
    if [ -n "$TAB" ]; then
      case "$TAB" in details|comments|steps|alignment) ;; *) fail "BAD_OPTION" "--tab for an item must be details, comments, steps, or alignment" ;; esac
    fi
    if [ -n "$ON" ] || [ -n "$TAB" ]; then
      # A tab or a chosen surface needs the sheet-on-a-surface shape. /items/{id}
      # normalizes the address to /?item={id} and drops every other parameter.
      SURFACE="${ON:-/prioritizer}"
      case "$SURFACE" in /*) ;; *) SURFACE="/$SURFACE" ;; esac
      PATH_PART="$(with_query "$SURFACE" item "$ARG")"
      [ -n "$TAB" ] && PATH_PART="${PATH_PART}&tab=${TAB}"
    else
      # The one shape that survives a cold load and a login round-trip.
      PATH_PART="/items/$ARG"
    fi
    ;;
  project)
    need_int "$ARG" "project id"
    case "$VIEW" in
      "")        PATH_PART="/plugins/projects/$ARG" ;;   # app applies the project's default view
      roadmap)   PATH_PART="/plugins/projects/$ARG/gantt" ;;
      overview|board|table|gantt) PATH_PART="/plugins/projects/$ARG/$VIEW" ;;
      *) fail "BAD_OPTION" "--view must be overview, board, table, gantt, or roadmap" ;;
    esac
    ;;
  page)    need_int "$ARG" "page id";   PATH_PART="/pages/$ARG" ;;
  team)    need_int "$ARG" "team id";   PATH_PART="/teams/$ARG" ;;
  l10)
    need_int "$ARG" "team id"
    PATH_PART="/level-10-meeting?team=$ARG"
    if [ -n "$TAB" ]; then
      [ "$TAB" = "notes" ] && TAB="extras"
      case "$TAB" in agenda|kanban|extras) PATH_PART="${PATH_PART}&tab=${TAB}" ;; *) fail "BAD_OPTION" "--tab for the L10 must be agenda, kanban, or extras" ;; esac
    fi
    ;;
  target)
    need_int "$ARG" "target id"
    [ -n "$TEAM" ] || fail "BAD_OPTION" "target needs --team <team_id>: the drawer looks the id up in the current team's targets tree"
    need_int "$TEAM" "team id"
    PATH_PART="/components?tab=traction&team=${TEAM}&target=${ARG}"
    ;;
  seat)    need_int "$ARG" "seat id";   PATH_PART="/plugins/accountability-chart?seat=$ARG" ;;
  user)    need_int "$ARG" "user id";   PATH_PART="/users/$ARG" ;;
  review)  need_int "$ARG" "review id"; PATH_PART="/reviews/$ARG" ;;
  1on1)    need_int "$ARG" "1-on-1 id"; PATH_PART="/1-on-1/$ARG" ;;
  roadmap) need_int "$ARG" "roadmap id"; PATH_PART="/roadmaps/$ARG" ;;
  result-update)
    [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "BAD_ID" "result-update needs a YYYY-MM-DD date"
    PATH_PART="/result-update/$ARG"
    ;;
  scorecard) need_int "$ARG" "team id"; PATH_PART="/components?tab=data&team=$ARG" ;;
  today|prioritizer) PATH_PART="/prioritizer" ;;
  home)    PATH_PART="/" ;;
  url)
    [ -n "$ARG" ] || fail "USAGE" "url needs a URL or a path"
    case "$ARG" in
      /*) PATH_PART="$ARG" ;;
      http://*|https://*)
        HOSTPATH="${ARG#*://}"
        HOST="${HOSTPATH%%/*}"
        REST="/${HOSTPATH#*/}"; [ "$REST" = "/$HOSTPATH" ] && REST="/"
        case "$HOST" in
          "$BASE_HOST")
            PATH_PART="$REST"
            ;;
          app.resultmaps.com|www.resultmaps.com|resultmaps.com)
            # Legacy UI. Only shapes with a known counterpart are converted.
            if   [[ "$REST" =~ ^/items/([0-9]+) ]];  then PATH_PART="/items/${BASH_REMATCH[1]}"
            elif [[ "$REST" =~ ^/groups/([0-9]+) ]]; then PATH_PART="/teams/${BASH_REMATCH[1]}"
            elif [[ "$REST" =~ ^/users/([0-9]+) ]];  then PATH_PART="/users/${BASH_REMATCH[1]}"
            else fail "LEGACY_UNMAPPED" "no ResultKit counterpart is known for legacy path $REST"
            fi
            ;;
          *) fail "FOREIGN_HOST" "rk-open.sh only opens $BASE_HOST links, not $HOST" ;;
        esac
        ;;
      *) fail "USAGE" "url needs an absolute URL or a path starting with /" ;;
    esac
    # Repair the one shape that looks right and is not: the root path with ?item=
    # is served the marketing page to a browser without the .resultmaps.com cookie,
    # and its pre-paint bounce to /?app=1 drops the item. Same for ?target= at root.
    if [[ "$PATH_PART" =~ ^/\?item=([0-9]+)$ ]]; then
      PATH_PART="/items/${BASH_REMATCH[1]}"
    fi
    ;;
  -h|--help|help)
    sed -n '2,45p' "$0"; exit 0 ;;
  *) fail "USAGE" "unknown kind: $KIND (item, project, page, team, l10, target, seat, user, review, 1on1, roadmap, result-update, scorecard, today, home, url)" ;;
esac

URL="${BASE}${PATH_PART}"
URL_JSON="$(json_escape "$URL")"

# --- print-only ------------------------------------------------------------

if [ "$PRINT_ONLY" = "1" ]; then
  printf '{"opened":false,"url":"%s","reason":"printed"}\n' "$URL_JSON"
  exit 0
fi

# --- pick an opener --------------------------------------------------------

OS="$(uname -s 2>/dev/null || echo unknown)"
IS_WSL=0
if [ "$OS" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then IS_WSL=1; fi

# Over SSH there is no browser on this end to open. Print instead.
if [ -n "${SSH_TTY:-}${SSH_CONNECTION:-}" ] && [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
  printf '{"opened":false,"url":"%s","reason":"headless"}\n' "$URL_JSON"
  exit 0
fi

OPENER=""
CMD=()
if [ -n "${BROWSER:-}" ]; then
  OPENER="BROWSER"
elif [ "$OS" = "Darwin" ]; then
  OPENER="open"; CMD=(open "$URL")
elif [ "$IS_WSL" = "1" ]; then
  if command -v wslview >/dev/null 2>&1; then OPENER="wslview"; CMD=(wslview "$URL")
  elif command -v rundll32.exe >/dev/null 2>&1; then OPENER="rundll32"; CMD=(rundll32.exe url.dll,FileProtocolHandler "$URL")
  elif command -v powershell.exe >/dev/null 2>&1; then OPENER="powershell"; CMD=(powershell.exe -NoProfile -Command "Start-Process '$URL'")
  fi
elif [ "$OS" = "Linux" ]; then
  if [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    printf '{"opened":false,"url":"%s","reason":"headless"}\n' "$URL_JSON"
    exit 0
  fi
  if command -v xdg-open >/dev/null 2>&1; then OPENER="xdg-open"; CMD=(xdg-open "$URL"); fi
else
  case "$OS" in
    MINGW*|MSYS*|CYGWIN*)
      if command -v rundll32.exe >/dev/null 2>&1; then OPENER="rundll32"; CMD=(rundll32.exe url.dll,FileProtocolHandler "$URL")
      elif command -v cmd.exe >/dev/null 2>&1; then OPENER="cmd"; CMD=(cmd.exe /c start "" "$URL")
      fi
      ;;
  esac
fi

if [ -z "$OPENER" ]; then
  printf '{"opened":false,"url":"%s","reason":"no_opener"}\n' "$URL_JSON"
  exit 1
fi

# --- launch ----------------------------------------------------------------

set +e
if [ "$OPENER" = "BROWSER" ]; then
  case "$BROWSER" in
    *%s*) sh -c "${BROWSER//%s/\"$URL\"}" >/dev/null 2>&1 ;;
    *)    sh -c "$BROWSER \"$URL\"" >/dev/null 2>&1 ;;
  esac
  RC=$?
elif [ "$OPENER" = "xdg-open" ]; then
  # xdg-open can block on some desktops; detach it.
  nohup "${CMD[@]}" >/dev/null 2>&1 &
  RC=0
else
  "${CMD[@]}" >/dev/null 2>&1
  RC=$?
fi
set -e

if [ "$RC" -eq 0 ]; then
  printf '{"opened":true,"url":"%s","opener":"%s"}\n' "$URL_JSON" "$OPENER"
  exit 0
fi
printf '{"opened":false,"url":"%s","reason":"launch_failed","opener":"%s"}\n' "$URL_JSON" "$OPENER"
exit 1
