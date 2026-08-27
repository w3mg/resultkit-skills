# BDD — Page writes through the rkit skills default to markdown

## Update log
| Date | Update description | Issue that led to update |
|---|---|---|
| 2026-08-27 | BDD for markdown-first page writes in the pages and success-criteria skills | (issue to follow) |

## Problem

The pages skill's first rule states "**Body is HTML, not markdown.**" and orders every body
converted to HTML (pandoc, or npx marked) before create/update. The success-criteria skill
repeats the rule. The shared `references/api-reference.md` (identical in all 23 skills) shows
only HTML bodies and no format option.

The API has accepted markdown directly since 2026-07-18: `?format=markdown` on page create,
update, and read, with the markdown source stored so a markdown read returns exactly what was
written. Because the skills never use or mention it, every page they write loses its markdown
source, reads back only as a lossy HTML-to-markdown reconstruction, and the skills refuse or
mangle writes when no converter is installed — costs the API no longer imposes. The skill's
claim that images are stripped is also outdated (images are kept since api2 #426).

Direction (Scott, 2026-08-27, verbatim): "Default to markdown and ask if they want HTML.
Don't make them guess." "You got to tell them the pro and con. Markdown's gonna use less.
You might use HTML for better formatting."

## Screens covered

The behavior lives in the rkit plugin's conversational skills, which are not
screen-and-context-inventory surfaces:

- `skills/pages` (the pages skill)
- `skills/success-criteria` (writes page bodies when applying a rewrite)
- `references/api-reference.md` — the shared pages documentation, identical across all 23 skills

One inventory screen shows the observable result of a write:

- Team · **2.4 Pages — `/pages`** — where a page written through the skills renders

Excluded: every other inventory screen — page bodies render only on 2.4 (the command palette
lists pages in results but never renders a body).

## Desired behavior

Cast (Examp.ly): **Eileen Sharp** (Integrator, system admin, team admin of the Leadership
Team), using the rkit plugin in Claude Code with her own ResultKit token; **Evan Opsnopolis**
(Development lead), reading the plugin's shared API reference.

Feature 1: Writing a page through the pages skill defaults to markdown

### Scenario 1: Create from markdown, sent as markdown (F1.S1)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), using the rkit pages skill with her ResultKit token, holding meeting notes written in markdown
- **When** she asks to create the Leadership Team page "Q3 Planning Notes" from those notes, naming no format
- **Then** the skill sends her markdown exactly as written using the API's markdown option — no pandoc, no local conversion — and its reply says the page was saved as markdown

### Scenario 2: The choice is stated with the pro and con — never guessed (F1.S2)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), asking the pages skill to write body content, having named no format
- **When** the skill replies about the write
- **Then** it states the default and the alternative in plain terms — markdown is the default (it uses less, and reads back as the same markdown); HTML is available for finer control of formatting — and if she answers "use HTML", the write is sent as HTML

### Scenario 3: The written page renders formatted — Team Pages (2.4) (F1.S3)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), whose markdown created "Q3 Planning Notes" through the pages skill
- **When** she opens "Q3 Planning Notes" on the Team Pages screen (2.4)
- **Then** headings render as headings and bold as bold — no literal `#` or `**` characters anywhere

### Scenario 4: Reading back returns the same markdown (F1.S4)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), whose markdown created "Q3 Planning Notes" through the pages skill
- **When** she asks the skill to read "Q3 Planning Notes" as markdown
- **Then** she receives the markdown she saved — the stored source, not a reconstruction from HTML

### Scenario 5: Asking for HTML is honored (F1.S5)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), holding an HTML body for the Leadership Team page "Board Update"
- **When** she says to write it as HTML
- **Then** the skill sends the HTML unchanged without the markdown option, and "Board Update" renders it on the Team Pages screen (2.4)

### Scenario 6: Images in markdown survive (F1.S6)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), whose markdown for "Q3 Planning Notes" includes `![pipeline chart](https://example.ly/chart.png)`
- **When** the page is created through the pages skill and she opens it on the Team Pages screen (2.4)
- **Then** the chart renders as an image in the page body — it is not dropped, and the skill makes no claim that images are stripped

### Scenario 7: No converter installed, the write still succeeds (F1.S7)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), on a machine with neither pandoc nor npx installed
- **When** she asks the pages skill to write markdown to "Q3 Planning Notes"
- **Then** the write succeeds — the markdown goes as-is with the markdown option; no refusal, and no wrapping her text into a single paragraph

Feature 2: The success-criteria skill writes its rewrites as markdown

### Scenario 1: An applied rewrite goes as markdown (F2.S1)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), having the success-criteria skill rewrite the Success section of the Leadership Team page "Q3 Rocks"
- **When** she approves applying the rewrite
- **Then** the composed page content is sent as markdown using the API's markdown option — no pandoc — and the updated section renders formatted on the Team Pages screen (2.4)

### Scenario 2: An applied rewrite needs no converter (F2.S2)
- **Given** Eileen Sharp (Integrator, system admin, team admin of the Leadership Team), on a machine with neither pandoc nor npx installed
- **When** she approves applying a success-criteria rewrite to "Q3 Rocks"
- **Then** the page is updated — the skill does not hand the markdown back and refuse the write

Feature 3: The shared API reference documents the markdown option

### Scenario 1: The pages section shows the format option (F3.S1)
- **Given** Evan Opsnopolis (Development lead), reading the pages section of `references/api-reference.md` in any of the 23 skills
- **When** he reads the create, update, and read entries for pages
- **Then** the markdown format option is documented — its default, and that a markdown write stores the source a markdown read returns — matching the published API spec, with every one of the 23 copies identical
