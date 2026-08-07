# The Seven Rules — Full Rubric (rkit:success-criteria)

The depth layer behind the compact list in `SKILL.md`. Read this when the user wants the reasoning, is training someone to write criteria, or disagrees with a verdict.

The examples run through one worked domain — an ITAD (IT asset disposition) warehouse that receives client hardware, tests it, and either resells or recycles it. `Razor` is their ERP; a *sublot* is a subdivision of a received lot. The domain is illustrative. The rules apply to any process doc: a close checklist, an onboarding SOP, a release runbook, a support escalation playbook.

**How to use the pairs.** Show them only to explain a verdict the user is pushing back on. For coaching, rule 7 applies — build the pair from their own doc.

---

## Rule 1 — End state, not activity

A criterion describes the world after the work. Activity phrasing is what a checklist is for, and when it appears in the success section the two sections say the same thing twice — which means neither one is doing its job. The test is grammatical and fast: if the line opens with a doing-verb (test, run, verify, ensure, update, review, complete), it is a step, not a result. Rewrite it by asking "and when that step is finished, what is true?"

| Bad | Good |
|-----|------|
| Test all units | Every unit has a test result recorded — Pass, Fail, or Not Testable |
| Update the manifest | The manifest matches the physical count for every sublot |
| Run the wipe on resale units | Every resale-bound unit shows Data Erasure = Passed |

The second column also tends to reveal missing work. "Test all units" hides the fact that a unit which cannot be tested still needs a disposition; "every unit has a test result recorded, including Not Testable" makes that case visible.

## Rule 2 — Stranger test

Someone outside the team should be able to walk up and answer yes or no by looking at something. That is the whole point of writing criteria down: the process owner already knows when they are done, but the auditor, the covering shift, and the new hire do not. So a criterion has to name the artifact and where it lives — a record in a system, a physical tag, a row in a report, an entry on a calendar.

| Bad | Good |
|-----|------|
| The lot is fully processed | Every pallet in the lot has a printed tag and a matching Razor record |
| The client has been notified | The completion email is in the client's Razor activity log |
| The team knows the new schedule | The schedule is on the shared calendar with all seats invited |

"The team knows" fails because knowledge is not observable. The rewrite does not lower the bar — it points at the evidence the bar produces.

## Rule 3 — Binary

Done or not done, no partial credit. Quality adverbs are where criteria go to die: "properly", "timely", "accurately", "thoroughly", "efficiently", "as needed". Each one moves the judgment from the artifact into someone's head, and two people will read it differently on the same day. Ban the adverb, or attach the measure that makes it checkable.

| Bad | Good |
|-----|------|
| Material processed efficiently | Every pallet received this week has a disposition set in Razor |
| QC completed accurately | Every QC-sampled unit matches its recorded grade — zero discrepancies |
| Photos taken as needed | Every pallet has at least one photo attached in Razor |

Keep the adverb only when a number follows it — "shipped on time" is vague, "shipped within 2 business days of settlement" is binary.

## Rule 4 — Countable scope

State how many. Without a quantifier a criterion is satisfied by a single example, which is how "units are tested" survives a review where nine out of ten pallets were skipped. Use "all", "every", or a hard number, and say what the denominator is.

| Bad | Good |
|-----|------|
| Units are weighed and tagged | All pallets in the lot are weighed and tagged |
| Sublots have been reconciled | Every sublot reconciles to the received manifest |
| Sample the batch for QC | 10% of units per sublot, minimum 5, have a QC record |

Where a real number exists, use it. "A sample" invites a sample of one.

## Rule 5 — Handoff included

Most processes fail at the seam, not in the middle. The upstream seat marks its work done, the downstream seat gets something incomplete, and the rework never shows up in either process doc. Fix it by making the next seat's readiness a condition of *this* process being done — stated from the downstream seat's point of view, since they are the ones who can tell.

| Bad | Good |
|-----|------|
| Notes and grades are entered | Settlement can review the order without sending anything back for grade or notes correction |
| Handed off to shipping | Shipping has the packing list, the destination, and a released pallet count for every pallet in the lot |
| Documentation is complete | The next technician can pick up the lot without asking the previous shift a question |

One handoff criterion per downstream seat, at the end of the set. If a process feeds three seats, that is a strong sign of rule 6.

## Rule 6 — 3–6 criteria

Under three, the process is usually a single step and does not need a doc. Over six, the doc has almost always merged two processes with different owners, different triggers, or different completion times — and the criteria start contradicting each other about what "done" means. Splitting is the fix, not trimming: look for the point where ownership changes hands and cut there.

| Bad | Good |
|-----|------|
| 11 criteria spanning receiving, testing, grading, listing, and shipping | Two docs — *Receiving and Testing* (4 criteria) and *Grading and Settlement* (4 criteria), with a handoff criterion joining them |
| 2 criteria, both about the manifest | One criterion; fold the process into the parent doc's checklist |

When proposing a split, name both processes and their owners. "This is really two processes" without the names is not actionable.

## Rule 7 — Grounded pairs

When coaching, the good/bad pair must come from the user's own document. Canned examples teach the rule in the abstract and get politely agreed with; their own line teaches the habit, because the author can see the exact move that fixed it and recognizes the vocabulary. Quote their wording verbatim in the "bad" column — paraphrasing reads as a strawman and the coaching stops landing.

Format the pair the same way every time:

> **Yours:** "QC done properly"
> **Tighter:** "Every QC-sampled unit matches its recorded grade — zero discrepancies"
> **Why:** "properly" is a judgment, not an observation. The rewrite names what an auditor would compare.

Use the pairs in this file only to explain a rule the user is arguing with — never as a substitute for reading their doc.

---

## Worked rewrite

A real-shaped before and after, from an ITAD warehouse's *Lot Receiving and Teardown* doc.

### Before

```
## Success Criteria

- [ ] Material processed efficiently
- [ ] Test all units
- [ ] Photos taken as needed
- [ ] Update Razor
- [ ] QC done properly
- [ ] Notes and grades entered
- [ ] Handed off to settlement
```

Grade:

| # | Criterion | Verdict | Fails | Why |
|---|-----------|---------|-------|-----|
| 1 | Material processed efficiently | Rewrite | 3 Binary, 2 Stranger | "efficiently" has no measure |
| 2 | Test all units | Rewrite | 1 End state | opens with a doing-verb |
| 3 | Photos taken as needed | Rewrite | 3 Binary, 4 Countable | "as needed" sets no scope |
| 4 | Update Razor | Rewrite | 1 End state, 2 Stranger | no artifact named |
| 5 | QC done properly | Rewrite | 3 Binary, 2 Stranger | "properly" is a judgment |
| 6 | Notes and grades entered | Rewrite | 5 Handoff | entered ≠ usable downstream |
| 7 | Handed off to settlement | Rewrite | 2 Stranger, 5 Handoff | no condition on the receiving seat |

7 criteria · 0 keep · 7 rewrite

### After

```
## Success: Results Look Like…

- [ ] All pallets in the lot are weighed, tagged, photographed, and entered in Razor
- [ ] Every unit has a test result recorded — Pass, Fail, or Not Testable
- [ ] Every resale-bound unit shows Data Erasure = Passed with the tester recorded
- [ ] Every sublot reconciles to the received manifest
- [ ] Settlement can review the order without sending anything back for grade or notes correction
```

Seven lines became five. Nothing was dropped — "update Razor" is absorbed into criterion 1 where the artifact lives, and "QC done properly" became the reconciliation in criterion 4, which is what QC was actually checking. The last line is the handoff, and it is the one that changed behavior: it moved the definition of done from "I entered it" to "they could use it".
