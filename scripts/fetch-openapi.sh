#!/usr/bin/env bash
#
# Fetch the live OpenAPI spec and output structured endpoint data.
# Usage: fetch-openapi.sh
#
# Outputs JSON with all paths, methods, parameters, and schemas
# from https://api.resultmaps.com/openapi-v2.json

set -euo pipefail

SPEC_URL="https://api.resultmaps.com/openapi-v2.json"

SPEC=$(curl -s "$SPEC_URL" 2>/dev/null) || {
  echo '{"error":"FETCH_FAILED","url":"'"$SPEC_URL"'"}'
  exit 1
}

# Validate it's JSON
if ! echo "$SPEC" | jq empty 2>/dev/null; then
  echo '{"error":"INVALID_JSON","url":"'"$SPEC_URL"'"}'
  exit 1
fi

# Output the full spec
echo "$SPEC"
