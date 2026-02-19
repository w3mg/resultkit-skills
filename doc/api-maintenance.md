# API Reference Maintenance

## Canonical Source

The live Swagger/OpenAPI docs live at:
<https://api.resultmaps.com/api-docs/v2>

Our local reference is `api-reference.md` in the project root.

## When to Update `api-reference.md`

- **New endpoint discovered** — you call something not listed, or the live docs show a route we don't have.
- **Response shape changed** — a field was added, removed, or renamed in the live API.
- **New status values or enums** — e.g. a new item status appears.
- **Auth or pagination behavior changes** — any structural shift in how requests/responses work.
- **A skill hits an unexpected 404/422** — may indicate the endpoint moved or params changed.

## How to Update

1. Open the live docs: <https://api.resultmaps.com/api-docs/v2>
2. Compare the relevant section against `api-reference.md`.
3. Edit `api-reference.md` to match the live API.
4. Note the change in a commit message so the history is searchable.

## Quick Check Routine

When building or debugging a skill, glance at the live docs for the endpoints you're using. If anything looks different from `api-reference.md`, update it before moving on.
