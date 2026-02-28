# API Calls

## 1. EOS Framework Gate — Fetch Team Details

```
GET /teams/345
```

- **Script**: `/Users/scottilevy/Development/resultkit-skills/skills/level10/scripts/api.sh GET "/teams/345"`
- **Status**: 200
- **Purpose**: Verify team uses EOS framework before proceeding
- **Result**: `framework: "eos"`, team name: "ResultMaps Incorporated"

## 2. Fetch Issues

```
GET /teams/345/l10/issues
```

- **Script**: `/Users/scottilevy/Development/resultkit-skills/skills/level10/scripts/api.sh GET "/teams/345/l10/issues"`
- **Status**: 200
- **Purpose**: Retrieve all L10 issues for the team
- **Result**: 36 issues returned (meta.total: 36, meta.total_pages: 1)
