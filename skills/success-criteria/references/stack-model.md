# Stack-Model Process Docs (rkit:success-criteria)

Structural reference for the doc format Success Criteria most often live in. Read this when working inside a stack-model doc and a structure question comes up — where the Success section belongs, what else the doc should contain, or how the criteria relate to the checklist.

A *stack-model* doc describes one process, owned by one seat, from trigger to handoff. It stacks: ownership and context at the top, the work in the middle, open questions at the bottom. It is usually a ResultKit page, but the shape holds for a Google Doc or a markdown file.

## Section order

| # | Section | Contents |
|---|---------|----------|
| 1 | **Title** | The process, named as a process — *Lot Receiving and Teardown*, not *Receiving* |
| 2 | **Success: Results Look Like…** | 3–6 checkbox criteria describing the world after the work |
| 3 | **Team Context** | Owner (individual *and* seat), Background, and a Related Documents table |
| 4 | **THE CHECKLIST** | Checkbox items — the steps someone performs, in order |
| 5 | **Questions and Issues** | Table of open items: what's unresolved, who owns it, what it blocks |
| 6 | **Related Information** *(optional)* | Links, screenshots, exceptions, edge cases that don't fit the checklist |

**Team Context** carries three parts:

- **Owner** — the individual *and* the seat. The seat is what survives turnover; the individual is who to ask today.
- **Background** — why this process exists and what breaks without it. Short.
- **Related Documents** — a table with columns `Title | Importance | What it is / notes`. Importance is the reader's routing hint: read-first, reference-only, superseded.

## Where Success Criteria sits, and why

Second — directly after the title, above everything including the checklist and the owner block. The criteria are the first thing a reader sees because they are the only thing a reader can act on without reading the rest: they tell someone picking up the process what they are aiming at, and they tell someone auditing it what to check. Position also encodes the authoring order. Criteria are written *before* the checklist, and a checklist step that serves none of them is a step nobody needed.

## Criteria vs. checklist

The two sections describe the same process from opposite ends, and keeping them distinct is what makes the doc usable.

| | THE CHECKLIST | Success: Results Look Like… |
|---|---|---|
| Describes | what you **do** | what is **true afterward** |
| Grammar | doing-verbs — *weigh, tag, enter, test* | states — *weighed, tagged, entered, recorded* |
| Read by | the person performing the work, during | the owner, the auditor, and the next seat, after |
| Length | as long as the work requires | 3–6 lines |
| Changes when | the tools or steps change | the definition of done changes |

A criterion is not a summary of the checklist. Several steps usually collapse into one criterion, and one criterion (the handoff) often maps to no step at all — which is precisely why it belongs in the criteria and gets missed when it doesn't.

When the checklist changes, the criteria usually should not. If a tooling change forces a criteria rewrite, the criterion was describing the tool rather than the result.

## Criteria and handoffs

The last criterion states what the next seat receives, phrased from that seat's point of view — "Settlement can review the order without sending anything back", not "notes and grades entered". Written that way, it becomes a check the downstream seat can perform, and rework stops being invisible to the upstream process.

When a doc needs more than one handoff criterion, that is the signal to split it (rule 6). One process, one owner, one downstream seat. Two downstream seats usually means two processes stapled together, and their Success sections are quietly contradicting each other about when the work is done.
