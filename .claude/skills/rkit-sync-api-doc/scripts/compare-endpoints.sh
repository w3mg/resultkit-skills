#!/usr/bin/env bash
#
# Compare live OpenAPI spec endpoints against api-reference.md
# Usage: compare-endpoints.sh <openapi-json-file> <api-reference-md-file>
#
# Outputs:
#   - Endpoints in live spec but NOT in api-reference.md
#   - Endpoints in api-reference.md but NOT in live spec
#   - Excluded endpoints (skipped by project decision)

set -euo pipefail

SPEC_FILE="${1:-}"
REF_FILE="${2:-}"

if [ -z "$SPEC_FILE" ] || [ -z "$REF_FILE" ]; then
  echo "Usage: compare-endpoints.sh <openapi-json> <api-reference-md>"
  exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: OpenAPI spec not found at $SPEC_FILE"
  exit 1
fi

if [ ! -f "$REF_FILE" ]; then
  echo "Error: api-reference.md not found at $REF_FILE"
  exit 1
fi

# Excluded endpoints (project decision)
EXCLUSIONS=(
  "/projects"
  "/projects/{id}"
  "/projects/{project_id}"
  "/teams/{id}/projects/next"
  "/teams/{id}/projects/done"
  "/teams/{id}/projects/issues"
)

is_excluded() {
  local path="$1"
  for excl in "${EXCLUSIONS[@]}"; do
    # Normalize: replace {id}, {project_id}, etc. with {id} for matching
    local norm_path
    norm_path=$(echo "$path" | sed 's/{[^}]*}/{id}/g')
    local norm_excl
    norm_excl=$(echo "$excl" | sed 's/{[^}]*}/{id}/g')
    if [[ "$norm_path" == "$norm_excl" ]] || [[ "$path" == "$excl"* ]]; then
      return 0
    fi
  done
  return 1
}

# Extract METHOD PATH pairs from live OpenAPI spec
echo "=== LIVE SPEC ENDPOINTS ==="
LIVE_ENDPOINTS=$(jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.key != "parameters") | "\(.key | ascii_upcase) \($path)"' "$SPEC_FILE" | sort)
echo "$LIVE_ENDPOINTS" | wc -l | xargs -I{} echo "Total: {} endpoints"
echo ""

# Extract METHOD PATH pairs from api-reference.md (from markdown tables)
echo "=== DOCUMENTED ENDPOINTS ==="
DOC_ENDPOINTS=$(grep -E '^\| (GET|POST|PUT|PATCH|DELETE) ' "$REF_FILE" | sed 's/|//g' | awk '{print $1, $2}' | sed 's/`//g' | sort)
echo "$DOC_ENDPOINTS" | wc -l | xargs -I{} echo "Total: {} endpoints"
echo ""

# Find endpoints in live spec but NOT in docs
echo "=== NEW IN LIVE SPEC (not documented) ==="
NEW_COUNT=0
EXCLUDED_COUNT=0
while IFS= read -r endpoint; do
  method=$(echo "$endpoint" | awk '{print $1}')
  path=$(echo "$endpoint" | awk '{print $2}')

  if is_excluded "$path"; then
    EXCLUDED_COUNT=$((EXCLUDED_COUNT + 1))
    continue
  fi

  if ! echo "$DOC_ENDPOINTS" | grep -qF "$method $path"; then
    echo "  + $endpoint"
    NEW_COUNT=$((NEW_COUNT + 1))
  fi
done <<< "$LIVE_ENDPOINTS"

if [ "$NEW_COUNT" -eq 0 ]; then
  echo "  (none)"
fi
echo "Skipped $EXCLUDED_COUNT excluded endpoints"
echo ""

# Find endpoints in docs but NOT in live spec
echo "=== REMOVED FROM LIVE SPEC (still documented) ==="
REMOVED_COUNT=0
while IFS= read -r endpoint; do
  method=$(echo "$endpoint" | awk '{print $1}')
  path=$(echo "$endpoint" | awk '{print $2}')

  if ! echo "$LIVE_ENDPOINTS" | grep -qF "$method $path"; then
    echo "  - $endpoint"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  fi
done <<< "$DOC_ENDPOINTS"

if [ "$REMOVED_COUNT" -eq 0 ]; then
  echo "  (none)"
fi
echo ""

# Summary
echo "=== SUMMARY ==="
echo "New endpoints to document: $NEW_COUNT"
echo "Removed endpoints to clean up: $REMOVED_COUNT"
echo "Excluded (by project decision): $EXCLUDED_COUNT"

if [ "$NEW_COUNT" -eq 0 ] && [ "$REMOVED_COUNT" -eq 0 ]; then
  echo "api-reference.md is up to date."
fi
