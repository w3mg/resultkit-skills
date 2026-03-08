#!/bin/bash
# setup-symlinks.sh
# Creates developer symlinks at session start so dev-only commands are accessible
# locally without being committed to the repo (which would leak them via the plugin).
#
# Symlinks created (all gitignored):
#   .claude/commands/speckit        -> .specify/commands/speckit/
#   .claude/commands/next-issue.md  -> .specify/commands/next-issue.md
#   .claude/commands/ship-it.md     -> .specify/commands/ship-it.md
#   .claude/commands/close-issue.md -> .specify/commands/close-issue.md

set -euo pipefail

INPUT=$(cat)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')

setup_dir_symlink() {
  local link="$1"
  local target="$2"

  if [ -L "$link" ] && [ -e "$link" ]; then
    return 0  # already valid
  fi

  [ -L "$link" ] && rm "$link"  # remove broken symlink

  if [ -d "$target" ]; then
    ln -s "$target" "$link"
    echo "Dev setup: linked $(basename "$link") → $target"
  else
    echo "Warning: target $target not found — $(basename "$link") unavailable" >&2
  fi
}

setup_file_symlink() {
  local link="$1"
  local target="$2"

  if [ -L "$link" ] && [ -e "$link" ]; then
    return 0  # already valid
  fi

  [ -L "$link" ] && rm "$link"  # remove broken symlink

  if [ -f "$target" ]; then
    ln -s "$target" "$link"
    echo "Dev setup: linked $(basename "$link") → $target"
  else
    echo "Warning: target $target not found — $(basename "$link") unavailable" >&2
  fi
}

setup_dir_symlink  "$PROJECT_DIR/.claude/commands/speckit"          "$PROJECT_DIR/.specify/commands/speckit"
setup_file_symlink "$PROJECT_DIR/.claude/commands/next-issue.md"   "$PROJECT_DIR/.specify/commands/next-issue.md"
setup_file_symlink "$PROJECT_DIR/.claude/commands/ship-it.md"      "$PROJECT_DIR/.specify/commands/ship-it.md"
setup_file_symlink "$PROJECT_DIR/.claude/commands/close-issue.md"  "$PROJECT_DIR/.specify/commands/close-issue.md"

exit 0
