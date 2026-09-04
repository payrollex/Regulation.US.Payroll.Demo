# Tutorial 2 — Employee Lifecycle

Demonstrates how Payroll Engine handles employee lifecycle events through
**time-segmented case values**. Every change carries a `start` date, so the
system always knows which value was active in any given pay period — including
mid-period changes (intra-period segmentation).

## Demo Company — Apex Digital Solutions LLC

All events use employees from the T1 Bootstrap. Run `T1-Bootstrap/Bootstrap.pecmd`
before executing any lifecycle events.

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
- `US.HireDate` with `start = hire date` activates `LifecycleStatus = 1` automatically
- First payrun is the biweekly period containing March 17

**Employee data:**

| Field | Value |
|:---|:---|
| Payroll | `Apex.Payroll.Biweekly` |
| Work State / Resident State | CA / CA |
| Pay Type | Salary |
| Annual Salary | $130,000 |
| Filing Status | Single |
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
- The biweekly period that straddles March 15 (March 10–23) is automatically
  split and prorated at each rate

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
- The biweekly period containing April 7 is prorated: days before = paid,
  days after = $0
- Garnishment (child support) continues to accrue, but the CCPA cap means
  no deduction when gross pay is zero

**Run:**
```
PayrollImport T2-Lifecycle/Events/L3-FMLALeave-Linda.json
```

---

## L4 — State Transfer: Jessica Torres (TX → CA)

**Scenario:** Jessica relocates from Texas to California, effective July 1, 2026.

**What this shows:**
- WorkState and ResidentState update — two fields, same start date
- State income tax switches from $0 (TX has no SIT) to CA SDI + CA SIT
- YTD SIT resets conceptually: TX YTD = $0; CA SIT starts accumulating from July 1
- FUTA/SUTA credit reduction unaffected (no change for 2026)

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
- Child support garnishment resumes deduction
- YTD gross picks up from where it left off before the leave

**Run:**
```
PayrollImport T2-Lifecycle/Events/L5-ReEntry-Linda.json
```

---

## Running All Events

```
T2-Lifecycle/Lifecycle.pecmd
```

Or run individual events in order:

```
PayrollImport T2-Lifecycle/Events/L1-NewHire-JamesLee.json
PayrollImport T2-Lifecycle/Events/L2-SalaryChange-Marcus.json
PayrollImport T2-Lifecycle/Events/L3-FMLALeave-Linda.json
PayrollImport T2-Lifecycle/Events/L4-StateChange-Jessica.json
PayrollImport T2-Lifecycle/Events/L5-ReEntry-Linda.json
```

---

## Observing Results

After importing the events, run the affected payrolls to observe the changes.
The following periods are most informative:

| Period | Payroll | What to observe |
|:---|:---|:---|
| 2026-03-10 / 2026-03-23 | Biweekly | Marcus proration at $150k / $165k |
| 2026-03-17 / 2026-03-30 | Biweekly | James Lee first payslip (partial period) |
| 2026-04-07 / 2026-04-20 | Biweekly | Linda proration: paid days vs. zero |
| 2026-07-01 / 2026-07-14 | Biweekly | Jessica: CA SIT appears; Linda: salary restored |

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
