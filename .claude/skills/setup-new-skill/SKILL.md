---
name: setup-new-skill
description: >
  Scaffold a new rkit skill end-to-end: sync API docs, fetch the live OpenAPI spec,
  do a full endpoint accounting, then run the speckit pipeline (specify → plan → tasks → implement).
  Use when: "setup new skill", "add a new skill", "create rkit skill", "new rkit feature",
  "scaffold skill", "start new skill", or when the user provides a skill idea and wants the
  full automated pipeline from spec through implementation.
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebFetch, Agent, AskUserQuestion, Skill
---

# Setup New Skill

Fully automated pipeline to scaffold a new rkit:* skill from idea to implementation.

**Argument**: `$ARGUMENTS` — the name and description of the new skill to create (e.g., `seats - manage org chart seats and accountability assignments`).

## Workflow

### Phase 0: Parse Input

Extract the skill short-name and description from `$ARGUMENTS`. If only a name is provided, ask the user for a brief description of what the skill should do.

### Phase 1: Sync API Reference

1. Run `/rkit-sync-api-doc` to update `api-reference.md` against the live OpenAPI spec.
   - This ensures the master endpoint reference is current before speckit runs.

### Phase 2: Fetch & Account for All Endpoints

1. Fetch the latest OpenAPI spec:
   ```bash
   curl -s https://api.resultmaps.com/openapi-v2.json > /tmp/openapi-v2.json
   ```

2. Extract every endpoint from the spec:
   ```bash
   jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | "\(.key | ascii_upcase) \($path)"' /tmp/openapi-v2.json | sort
   ```

3. Read `api-reference.md` and compare:
   - List endpoints **in the OpenAPI spec but missing from api-reference.md** (new endpoints)
   - List endpoints **in api-reference.md but missing from the OpenAPI spec** (removed endpoints)
   - Print a summary table of the full accounting

4. If there are discrepancies, update `api-reference.md` accordingly (add new, remove stale), then run `/sync-plugin` to distribute the updated reference to all skills.

### Mandatory: Verify Before Writing Skill Logic

During implementation (Phase 3), follow these rules for any API-related code:

1. **Read `api-reference.md`** for the endpoint's documented params, statuses, and response shape.
2. **Call the actual API** with `scripts/api.sh` to verify real behavior — field names, status values, whether query params actually filter, response structure.
3. **Check real data** — look at what the API actually returns, not what you think it returns.

Do not invent status values, field names, or filtering behavior. If the reference is incomplete, test the API first and update the reference.

### Phase 3: Run Speckit Pipeline

Run each phase sequentially. After each phase completes, proceed to the next automatically:

1. **Specify**: `/speckit:specify` with the skill description from `$ARGUMENTS`.
   - This creates the spec branch and `spec.md`.

2. **Plan**: `/speckit:plan`
   - Generates `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`.

3. **Tasks**: `/speckit:tasks`
   - Generates `tasks.md` with dependency-ordered implementation tasks.

4. **Implement**: `/speckit:implement`
   - Executes all tasks phase-by-phase.

### Phase 4: Final Verification

After implementation completes:

1. Verify the new skill directory exists at `skills/<name>/`.
2. Verify `SKILL.md` has proper frontmatter (name, description, allowed-tools) and uses the `rkit:` prefix.
3. Verify `scripts/api.sh` was copied into the skill (never edit copies inside `skills/*/` directly — master lives at repo root).
4. Verify `references/api-reference.md` was copied into the skill.
5. Run `/sync-plugin` to ensure shared files are distributed and version is bumped.

Report the final status: skill path, spec branch, and any issues found.

### Phase 5: Commit & Push

1. **Bump version** in `.claude-plugin/plugin.json` (patch bump unless told otherwise).
2. **Stage all changed files** including the version bump.
3. **Commit** with a descriptive message.
4. **Show the user a summary** of what was committed (files changed, commit message) and ask for confirmation before pushing.
5. Once confirmed: **`git pull --rebase origin main`** then **`git push origin main`**.
6. **Print update instructions**: tell the user to run `/plugin marketplace update`.
