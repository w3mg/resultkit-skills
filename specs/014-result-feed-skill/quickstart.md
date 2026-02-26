# Quickstart: rkit:result-feed Skill

## Implementation Steps

### Step 1: Update api-reference.md

Add a `## Result Feeds` section to the master `api-reference.md` at the repo root. Place it after `## Day Plans` and before `## Meetings`.

**Content to add**:
- Endpoint table (6 endpoints) matching the format of existing sections
- User Phrases column with natural language triggers
- ResultFeed and TeamResultFeed field documentation
- Section name mapping note
- Glossary entries: "check-in", "90 seconds", "result feed", "daily report"

**Source**: `contracts/result-feeds-api.md` in this spec directory, cross-referenced with the OpenAPI spec at `~/projects/resultmaps-api2/openapi/openapi-v2.yaml`.

### Step 2: Sync shared files

Run `/sync-plugin` to copy updated `api-reference.md` and `api.sh` to all existing skill directories and bump the plugin version.

### Step 3: Create skill directory

```
skills/result-feed/
├── SKILL.md
├── scripts/
│   └── api.sh              # Copy from master scripts/api.sh
└── references/
    └── api-reference.md    # Copy from master api-reference.md
```

### Step 4: Write SKILL.md

Follow the `skills/today/SKILL.md` pattern:

1. **Frontmatter**: name `rkit:result-feed`, description, `disable-model-invocation: true`, `user-invocable: true`, `allowed-tools: Bash, Read, AskUserQuestion`
2. **Current State**: config check + api.sh path resolution (same pattern as today skill)
3. **Rules**: interpret first, confirm writes, show IDs, concise output, direct execution
4. **Tool Routing Table**: map trigger phrases to 7 flows (view, add-new, attach-existing, remove, submit, team-view)
5. **Flow definitions**: step-by-step for each flow with api.sh bash examples
6. **Date Resolution**: natural language → YYYY-MM-DD table
7. **Schemas**: ResultFeed, TeamResultFeed, Item JSON examples
8. **Error Handling**: standard rkit error table
9. **References**: link to api-reference.md

### Step 5: Update plugin manifest

Add the `result-feed` skill entry if needed (auto-discovered from `./skills/` — may not need explicit registration).

### Step 6: Test

Invoke `/rkit:result-feed` and verify:
- View shows today's check-in with 3 sections
- Add creates item in correct section
- Submit shares with default team (displays team name)
- Team view shows members' check-ins with ItemSimple items

## Key Design Decisions

- **Skill name**: `rkit:result-feed` (not `rkit:checkin` — matches API resource name)
- **Section names**: Always use URL names (`done`, `next`, `issues`) — never `blocked`
- **Submit always shares**: Uses `default_team_id` from config, displays team name in confirmation
- **Team view**: Full ItemSimple display (ID + name) for all items in all sections
- **Date resolution**: `today` literal passed directly to API (server resolves timezone); other dates converted to YYYY-MM-DD
