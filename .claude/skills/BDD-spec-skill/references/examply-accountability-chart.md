# Examp.ly — the example organization (accountability chart)

Examp.ly is the canonical fictional organization for BDD scenarios in ResultMaps repos. When a
scenario needs a named person, a role, a seat, a manager/report pair, or real scorecard data, cast
it from this chart instead of inventing placeholder users.

**Contents:** [How to use in scenarios](#how-to-use-in-scenarios) ·
[People roster](#people-roster) · [Org chart](#org-chart) · [Seat details](#seat-details)

**Provenance.** Transcribed 2026-07-08 from two PDFs (originals on
`~/Desktop`): `Examp.ly-ResultMaps-accountability-chart-full-summaries.pdf` (19 pages, one seat per
page — the detailed source) and `Examp.ly-ResultMaps-accountability-chart.pdf` (5-page visual
chart, used to confirm the reporting lines). The two agree on all 19 seats, every name, and the
full hierarchy.

**Presumptions and source quirks:**

- **Eileen Sharp (Integrator) is also the system admin.** This is a locked-in presumption for
  scenario-writing; it is not printed in the PDFs.
- The chart PDF truncates one seat label as "Customer support + succe"; the summaries PDF carries
  the full label, **Customer support + success** — use that.
- "Alya" (Operations) has no surname in the source.
- "second seat" and "New Seat" are literal seat names in the demo data — use them exactly as
  written, quirky as they are.
- Delivery's and Customer Support's accountabilities are run-on lines in the source PDF; they are
  split at word boundaries below, with the original strings preserved in notes.

## How to use in scenarios

- **Cast the actor from the seat that carries the behavior.** A finance behavior belongs to Lisa
  Thompson, a support-ticket behavior to Sue Baylor, a dev-work behavior to Evan Opsnopolis — never
  a made-up name.
- **Admin scenarios use Eileen Sharp** — she is the Integrator and (by presumption) the system
  admin. Vic Vixon is the top of the chart (reports to no one) for owner/leadership behaviors.
- **Manager/report pairs** for visibility and permission scenarios: Eileen → Art Foster, Alya,
  Lisa Thompson, Gregor Vorbarra, Sue Baylor; Alya → Evan Opsnopolis; Evan → (vacant Development
  seat).
- **Multi-seat people** are ready-made for seat-switching and multi-role behaviors: Gregor Vorbarra
  holds three seats under two different managers; Art Foster and Lisa Thompson each hold a second
  seat that reports to their own first seat.
- **Vacant seats** (7 of them) are ready-made for empty-state and unassigned-seat behaviors.
- **Measurables and rocks are real data** for scorecard, measurable, and rock scenarios — use the
  exact names and goals from the seat details (e.g. Sue Baylor: "Defects to clients | Goal: 0").
- **Keep the cast consistent** across all scenarios of one Feature — the same person plays the
  same role throughout.

## People roster

| Person | Seat(s) | Reports to | Notes |
|---|---|---|---|
| Vic Vixon | Visionary | — (top of chart) | |
| Eileen Sharp | Integrator | Visionary | **Also the system admin (presumed)** |
| Art Foster | Sales/Mktg; Marketing Manager | Integrator; Sales/Mktg | Second seat reports to his own first seat |
| Alya | Operations | Integrator | First name only in source |
| Lisa Thompson | Finance; AP/AR | Integrator; Finance | Second seat reports to her own first seat |
| Evan Opsnopolis | Development lead | Operations | |
| Gregor Vorbarra | Delivery; Customer support + success; second seat | Integrator; Operations; Operations | Three seats under two managers |
| Sue Baylor | Customer Support | Integrator | |

Vacant seats (7): Sales (under Sales/Mktg); Account Management and Project Management (under
Operations); Development (under Development lead); HR, IT, and New Seat (under Finance).

## Org chart

- **Visionary** — Vic Vixon
  - **Integrator** — Eileen Sharp *(also system admin — presumed)*
    - **Sales/Mktg** — Art Foster
      - **Marketing Manager** — Art Foster
      - **Sales** — *Vacant*
    - **Operations** — Alya
      - **Account Management** — *Vacant*
      - **Project Management** — *Vacant*
      - **Development lead** — Evan Opsnopolis
        - **Development** — *Vacant*
      - **Customer support + success** — Gregor Vorbarra
      - **second seat** — Gregor Vorbarra
    - **Finance** — Lisa Thompson
      - **AP/AR** — Lisa Thompson
      - **HR** — *Vacant*
      - **IT** — *Vacant*
      - **New Seat** — *Vacant*
    - **Delivery** — Gregor Vorbarra
    - **Customer Support** — Sue Baylor

## Seat details

One section per seat, in the source PDF's page order. "Reporting Seats" are that seat's direct
reports, as `Seat — Person`. Measurable rows use `|` between the measurable's name and its goal.
---

### Visionary

- **Seat Owner:** Vic Vixon
- **Reports To:** None
- **Reporting Seats (direct reports):**
  - Integrator — Eileen Sharp

**Accountabilities**
1. Big ideas
2. Big relationships
3. Solving big problems
4. Culture
5. Industry trends

**Measurables**
- Total services clients | Goal: 15
- Cash balance | Goal: 75000

**Process / Playbook Inventory**
- None listed

**Rocks | Q3 2023**
- Assess direction + opportunities [active]

---

### Integrator

- **Seat Owner:** Eileen Sharp
- **Reports To:** Visionary
- **Reporting Seats (direct reports):**
  - Sales/Mktg — Art Foster
  - Operations — Alya
  - Finance — Lisa Thompson
  - Delivery — Gregor Vorbarra
  - Customer Support — Sue Baylor

**Accountabilities**
1. LMA
2. Achieve P&L, business plan
3. Remove Obstacles & barriers
4. Special projects
5. Legal & Compliance

**Measurables**
- Contracts ($) | Goal: 150000
- Projects late | Goal: 1

**Process / Playbook Inventory**
- Special projects process.png
- Legal documentation.png

**Rocks | Q1 2026**
- ResultMaps in place as our system of action [active]

---

### Sales/Mktg

- **Seat Owner:** Art Foster
- **Reports To:** Integrator
- **Reporting Seats (direct reports):**
  - Marketing Manager — Art Foster
  - Sales — Vacant

**Accountabilities**
1. LMA for the Austin Office
2. Set & achieve revenue goals (Checklist attached)
3. Sales process (Checklist attached)
4. Selling ("A" prospects)
5. Set reasonable client expectations (Checklist attached)

**Measurables**
- # Proposals | Goal: 4
- $ Proposals | Goal: 300000

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Marketing Manager

- **Seat Owner:** Art Foster
- **Reports To:** Sales/Mktg
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. Build-out of the new company brand guide
2. Development of the 2026 company marketing plan
3. Lead generation
4. Market research & demographic case studies
5. Marketing tool stack
6. Company website & landing page

**Measurables**
- Gross monthly revenue | Goal: 500000
- New leads | Goal: 40
- Initial sales meetings | Goal: 13
- 30-day pipeline | Goal: 1500000

**Process / Playbook Inventory**
- None listed

**Rocks | Q3 2023**
- Deliver our 3 key marketing assets [active]

---

### Sales

- **Seat Owner:** Vacant
- **Reports To:** Sales/Mktg
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Operations

- **Seat Owner:** Alya
- **Reports To:** Integrator
- **Reporting Seats (direct reports):**
  - Account Management — Vacant
  - Project Management — Vacant
  - Development lead — Evan Opsnopolis
  - Customer support + success — Gregor Vorbarra
  - second seat — Gregor Vorbarra

**Accountabilities**
1. LMA
2. Client satisfaction
3. Delivering on projects (on time, to spec and under budget)
4. Resource management
5. Operations process

**Measurables**
- None listed

**Process / Playbook Inventory**
- Onboarding contractors SOP.pdf
- Weekly operational reviews.pdf
- Project intake and scoping process.pdf

**Rocks | Q1 2026**
- Complete 10 key account plans [active]

---

### Account Management

- **Seat Owner:** Vacant
- **Reports To:** Operations
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Project Management

- **Seat Owner:** Vacant
- **Reports To:** Operations
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Development lead

- **Seat Owner:** Evan Opsnopolis
- **Reports To:** Operations
- **Reporting Seats (direct reports):**
  - Development — Vacant

**Accountabilities**
1. LMA
2. Quality development
3. Utilization
4. Development process

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Development

- **Seat Owner:** Vacant
- **Reports To:** Development lead
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Customer support + success

- **Seat Owner:** Gregor Vorbarra
- **Reports To:** Operations
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### second seat

- **Seat Owner:** Gregor Vorbarra
- **Reports To:** Operations
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- leadership measurable | Goal: 0

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Finance

- **Seat Owner:** Lisa Thompson
- **Reports To:** Integrator
- **Reporting Seats (direct reports):**
  - AP/AR — Lisa Thompson
  - HR — Vacant
  - IT — Vacant
  - New Seat — Vacant

**Accountabilities**
1. LMA
2. Budgeting and reporting
3. Accounts payable
4. Accounts receivable
5. HR
6. IT
7. Office management

**Measurables**
- Billing errors | Goal: 2

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### AP/AR

- **Seat Owner:** Lisa Thompson
- **Reports To:** Finance
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. Accounts payable
2. Accounts receivable
3. Invoicing
4. Supplies
5. Equipment

**Measurables**
- AR > 60 Days | Goal: 30000

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### HR

- **Seat Owner:** Vacant
- **Reports To:** Finance
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### IT

- **Seat Owner:** Vacant
- **Reports To:** Finance
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### New Seat

- **Seat Owner:** Vacant
- **Reports To:** Finance
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**
1. None listed

**Measurables**
- None listed

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Delivery

- **Seat Owner:** Gregor Vorbarra
- **Reports To:** Integrator
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**

> Note: In the source, this seat's accountabilities are rendered as a single run-on line numbered "1." with no separators: "Client satisfactionDelivering on projects (on time, to spec and under budget)Resource managementOperations processProject timeline management". Split below at the obvious word boundaries.

1. Client satisfaction
2. Delivering on projects (on time, to spec and under budget)
3. Resource management
4. Operations process
5. Project timeline management

**Measurables**
- Projects over budget | Goal: 1

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed

---

### Customer Support

- **Seat Owner:** Sue Baylor
- **Reports To:** Integrator
- **Reporting Seats (direct reports):**
  - None

**Accountabilities**

> Note: In the source, this seat's accountabilities are rendered as a single run-on line numbered "1." with no separators: "Client satisfactionIssue resolutionCustomer experienceResponse time targets". Split below at the obvious word boundaries.

1. Client satisfaction
2. Issue resolution
3. Customer experience
4. Response time targets

**Measurables**
- Defects to clients | Goal: 0
- Utilization rate | Goal: 80

**Process / Playbook Inventory**
- None listed

**Rocks**
- None listed
