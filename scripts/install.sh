#!/usr/bin/env bash
#
# [DEPRECATED] Install rkit skills to ~/.claude/skills/
#
# Prefer the plugin install method:
#   /plugin marketplace add w3mg/resultkit-skills
#   /plugin install rkit@resultkit
#
# This script is kept for backwards compatibility.

set -euo pipefail

echo ""
echo "⚠  DEPRECATED: Use the plugin install method instead:"
echo "     /plugin marketplace add w3mg/resultkit-skills"
echo "     /plugin install rkit@resultkit"
echo ""
echo "Continuing with legacy install..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_ROOT/skills/rkit"
SCRIPTS_SRC="$REPO_ROOT/scripts"
INSTALL_BASE="$HOME/.claude/skills"

echo "Installing rkit skills..."

# Install each skill found in skills/rkit/
for SKILL_DIR in "$SKILLS_SRC"/*/; do
  [ -d "$SKILL_DIR" ] || continue
  SKILL_NAME=$(basename "$SKILL_DIR")
  TARGET_DIR="$INSTALL_BASE/rkit:${SKILL_NAME}"

  echo "  rkit:${SKILL_NAME} → $TARGET_DIR"

  mkdir -p "$TARGET_DIR/scripts"

  # Copy skill files
  cp -R "$SKILL_DIR"/* "$TARGET_DIR/"

  # Copy shared api.sh into skill
  if [ -f "$SCRIPTS_SRC/api.sh" ]; then
    cp "$SCRIPTS_SRC/api.sh" "$TARGET_DIR/scripts/api.sh"
    chmod +x "$TARGET_DIR/scripts/api.sh"
  fi
done

echo "Done. Installed skills:"
for SKILL_DIR in "$SKILLS_SRC"/*/; do
  [ -d "$SKILL_DIR" ] || continue
  SKILL_NAME=$(basename "$SKILL_DIR")
  echo "  /rkit:${SKILL_NAME}"
done
