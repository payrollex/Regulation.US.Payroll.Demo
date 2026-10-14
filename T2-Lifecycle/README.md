# Tutorial 2 — Employee Lifecycle

Demonstrates how Payroll Engine handles employee lifecycle events through
**time-segmented case values**. Every change carries a `start` date, so the
system always knows which value was active in any given pay period — including
mid-period changes (intra-period segmentation).

## Demo Company — Apex Digital Solutions LLC

All events use employees from the T1 Bootstrap. Run `T1-Bootstrap/Bootstrap.pecmd`
before executing any lifecycle events.

All events affect the biweekly payroll (periods of two weeks from Monday, paid on the
Friday after the period end):

| Period | Pay date | Event |
|:---|:---|:---|
| Mar 9 – Mar 22 | Mar 27 | L1 hire James Lee (Mar 17), L2 raise Marcus Johnson (Mar 15) |
| Apr 6 – Apr 19 | Apr 24 | L3 FMLA leave Linda Okafor (Apr 7) |
| Jun 29 – Jul 12 | Jul 17 | L4 TX → CA Jessica Torres (Jul 1), L5 return Linda Okafor (Jul 1) |

---

## Lifecycle Events

| # | Event | Employee | Effective |
|:---:|:---|:---|:---|
| L1 | New Hire | James Lee (CA Developer) | March 17, 2026 |
| L2 | Salary Change | Marcus Johnson | March 15, 2026 |
| L3 | FMLA Leave (unpaid) | Linda Okafor | April 7, 2026 |
| L4 | State Transfer | Jessica Torres (TX → CA) | July 1, 2026 |
| L5 | Return from Leave | Linda Okafor | July 1, 2026 |

---

## L1 — New Hire: James Lee

**Scenario:** Apex hires James Lee as a Software Engineer in the San Francisco
office, starting March 17, 2026. He joins the Biweekly payroll.

**What this shows:**
- Adding a new employee record + initial case values in a single import
- The first pay period Mar 9–22 covers 6 of 14 days (Mar 17–22): the salary and the
  health premium are prorated by calendar days (`CalendarPeriod` case fields)

**Employee data:**

| Field | Value |
|:---|:---|
| Payroll | `Apex.Payroll.Biweekly` |
| Work State / Resident State | CA / CA |
| Pay Type | Salary |
| Annual Salary | $130,000 |
| Filing Status | Single |
| State certificate | CA DE 4: single, 0 allowances |
| Pre-tax 401k | 5% |
| Health Insurance | $220/period |

**Run:**
```
PayrollImport T2-Lifecycle/Events/L1-NewHire-JamesLee.json
```

---

## L2 — Salary Change: Marcus Johnson

**Scenario:** Marcus receives a merit increase from $150,000 to $165,000
effective March 15, 2026.

**What this shows:**
- A single case value update with a new `start` date
- PE keeps both values: $150k before March 15, $165k from March 15 onward
- The biweekly period that straddles March 15 (Mar 9–22) is split by calendar days:
  6 days at $150,000 and 8 days at $165,000

**Run:**
```
PayrollImport T2-Lifecycle/Events/L2-SalaryChange-Marcus.json
```

---

## L3 — FMLA Leave (Unpaid): Linda Okafor

**Scenario:** Linda takes unpaid FMLA leave starting April 7, 2026.
Her salary is set to $0 for the leave period.

**What this shows:**
- Time-segmented case values: $65k up to April 6, $0 from April 7
- The biweekly period Apr 6–19 pays one day (April 6)
- The child support garnishment is limited to 60% of disposable earnings (CCPA) in that
  period; without wages there is no deduction, and the regulation carries no arrears forward

**Run:**
```
PayrollImport T2-Lifecycle/Events/L3-FMLALeave-Linda.json
```

---

## L4 — State Transfer: Jessica Torres (TX → CA)

**Scenario:** Jessica relocates from Texas to California, effective July 1, 2026.

**What this shows:**
- WorkState and ResidentState update — two fields, same start date — plus her CA DE 4
  (married, one income, 0 allowances)
- The period Jun 29–Jul 12 (paid Jul 17) contains 2 Texas and 8 California working days:
  - CA SDI covers the services localized in California (CUIC §§ 602-603, EDD DE 231D); the
    wages are split by working days and SDI applies to the CA share only
  - CA income tax applies to all wages of the period, because Jessica is a California resident
    at the period end (EDD DE 44, Wages Paid to California Residents)
- The period Jun 15–28 stays in Texas, even when its payrun runs after July 1: payruns use the
  case values of the period, not those of the run date

**Run:**
```
PayrollImport T2-Lifecycle/Events/L4-StateChange-Jessica.json
```

---

## L5 — Return from Leave: Linda Okafor

**Scenario:** Linda returns from FMLA on July 1, 2026. Her original salary
of $65,000 is restored.

**What this shows:**
- Reverting a case value by setting the original amount with a new start date
- The period Jun 29–Jul 12 pays 12 of 14 days (July 1–12)
- The child support garnishment resumes in full ($500)

**Run:**
```
PayrollImport T2-Lifecycle/Events/L5-ReEntry-Linda.json
```

---

## Running All Events

```
cd T2-Lifecycle
pecmd Lifecycle.pecmd
```

Or run individual events in order (from the repo root):

```
PayrollImport T2-Lifecycle/Events/L1-NewHire-JamesLee.json
PayrollImport T2-Lifecycle/Events/L2-SalaryChange-Marcus.json
PayrollImport T2-Lifecycle/Events/L3-FMLALeave-Linda.json
PayrollImport T2-Lifecycle/Events/L4-StateChange-Jessica.json
PayrollImport T2-Lifecycle/Events/L5-ReEntry-Linda.json
```

---

## Observing Results

After importing the events, run the affected biweekly periods. `Setup.cmd` already completes
the biweekly payruns up to Mar 22 (Step 7); to observe the March events in their pay period,
import them before `T3-Payruns/Payruns-March-Biweekly.pecmd`.

| Period (pay date) | Employee | What to observe |
|:---|:---|:---|
| Mar 9 – Mar 22 (Mar 27) | James Lee | Salary $2,142.86 ($5,000 × 6/14), health $94.29 ($220 × 6/14), net $1,557.30 |
| Mar 9 – Mar 22 (Mar 27) | Marcus Johnson | Salary $6,098.90 (($150,000 × 6 + $165,000 × 8) ÷ 14 ÷ 26), net $3,849.26 |
| Mar 23 – Apr 5 (Apr 10) | James Lee / Marcus Johnson | Full period: salary $5,000.00 / $6,346.15 |
| Apr 6 – Apr 19 (Apr 24) | Linda Okafor | Salary $178.57 (1 day), garnishment $98.48 (60% CCPA limit), net $65.66 |
| Apr 20 – May 3 (May 8) | Linda Okafor | No wages, no garnishment |
| Jun 29 – Jul 12 (Jul 17) | Linda Okafor | Salary $2,142.86 (12 days), garnishment $500.00 |
| Jun 29 – Jul 12 (Jul 17) | Jessica Torres | CA SIT $52.85, CA SDI $28.78 (1.3% of the 8 CA working days), net $2,200.97 |

The values apply to the employees' T1 case data without the T4 benefits (transit, WFH stipend).
They are asserted by [DEMO-TC15](../Tests/DEMO-TC15-US-James-NewHire/) (James Lee),
[DEMO-TC16](../Tests/DEMO-TC16-US-Marcus-SalaryChange/) (Marcus Johnson),
[DEMO-TC17](../Tests/DEMO-TC17-US-Linda-FMLA/) (Linda Okafor) and
[DEMO-TC18](../Tests/DEMO-TC18-US-Jessica-Relocation/) (Jessica Torres).

---

## Key Concept: Time-Segmented Case Values

Every case value in Payroll Engine carries a `start` (and optional `end`) date.
When you import a new value for an existing field, PE does not overwrite the
old value — it **ends the previous period** and **starts a new one**:

```
US.AnnualSalary
  [2026-01-01 → 2026-03-14]  value = 150000  ← original
  [2026-03-15 → ∞         ]  value = 165000  ← after raise
```

This is the foundation of PE's intra-period proration, retroactive correction,
and audit trail — all without custom code.
