#!/usr/bin/env bash
#
# Sync api-reference.md to skill directories and install all skills.
# Usage: bash scripts/deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
API_REF="$REPO_ROOT/api-reference.md"

if [ ! -f "$API_REF" ]; then
  echo "Error: api-reference.md not found at $API_REF"
  exit 1
fi

# Sync api-reference.md to each skill that has a references/ dir
echo "Syncing api-reference.md to skills..."
SYNCED=0
for REF_DIR in "$REPO_ROOT/skills/rkit"/*/references/; do
  [ -d "$REF_DIR" ] || continue
  SKILL_NAME=$(basename "$(dirname "$REF_DIR")")
  cp "$API_REF" "$REF_DIR/api-reference.md"
  echo "  rkit:${SKILL_NAME} ✓"
  SYNCED=$((SYNCED + 1))
done
echo "Synced to $SYNCED skill(s)."
echo ""

# Run install
bash "$REPO_ROOT/scripts/install.sh"
