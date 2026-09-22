# Tutorial 3 — Payruns & Reports

Demonstrates how to execute payrolls, work with YTD accumulators,
and generate statutory reports for Apex Digital Solutions LLC.

## Prerequisites

- T1-Bootstrap completed (`T1-Bootstrap/Bootstrap.pecmd`)
- **Committed payrun data** in DB — run the integration test suite first:
  ```
  pecmd Tests/Run.Tests.pecmd /TestPrecision2
  ```
  `PayrunEmployeeTest` commits real payrun results. Reports need this data.
  After a fresh Delete+Bootstrap, this step must be repeated.
- PE backend running
- WebApp running (for live payrun execution)

---

## Payrun Execution

Payroll Engine executes payrun jobs via the **WebApp** or **REST API**.
There is no pecmd command to start a live payrun job.

**pecmd is used for:**
- Importing case value scenarios (`PayrollImport`)
- Validating results before/after execution (`PayrunEmployeePreviewTest`)
- Generating reports (`Report`)

**WebApp workflow (per period):**
1. Open the payrun → select period → click **Start**
2. Monitor job status → wait for **Complete**
3. Review payslips, correct errors, re-run if needed
4. Close the period

---

## Payrun Schedule — Apex Digital Solutions 2026

| Payroll | Frequency | Periods/Year | Key months |
|:---|:---|:---:|:---|
| `Apex.Payrun.Monthly` | Monthly | 12 | Jan, Oct (SS cap), Dec (401k cap) |
| `Apex.Payrun.Biweekly` | Biweekly | 26 | Mar (bonus), Dec (401k cap) |
| `Apex.Payrun.Weekly` | Weekly | 52 | Jan, Jun, Dec |

---

## Scenario 1 — January: Baseline Payrun

Run all three payrolls for January 2026. No YTD accumulators active yet.

**Start dates:**
| Payroll | Period Start | Period End |
|:---|:---|:---|
| Monthly | 2026-01-01 | 2026-01-31 |
| Biweekly | 2026-01-06 | 2026-01-19 |
| Weekly | 2026-01-05 | 2026-01-11 |

**What to observe:**
- Sara Chen: $20,000 salary + $450 company car → FITTaxable / FICATaxable split
- Marcus Johnson: NY SIT + NJ SIT both appear on same payslip
- Jessica Torres: TX SIT = $0
- David Kim: PA SIT + Philadelphia EIT (PSD code resolution)
- FUTA ER (WT 6700) begins accumulating toward $7,000 per-employee cap

**Validate with pecmd (run from repo root):**
```
Tests/Run.Tests.pecmd
```
Each test imports its own case data, executes a payrun job, and asserts the
expected wage type values (self-contained — works regardless of prior Bootstrap state).

---

## Scenario 2 — March: Supplemental Wages (Jessica Bonus)

Jessica Torres receives a $10,000 Q1 performance bonus in the March payrun.
Supplemental wages are taxed at the **22% flat FIT rate** (IRC §3402(g)(1)).
TX has no SIT, so the only additional withholding is federal.

**Option A — Validate via pecmd** (self-contained, imports cases + runs payrun):
```
# from T3-Payruns/
PayrunEmployeeTest Scenarios/March-Bonus-Preview.et.json /showall /OkOnFail ActualOutputFile:Scenarios/March-Bonus.actual.json
```
`/OkOnFail` because `payrollResults` are intentionally empty — actual values are
written to `March-Bonus.actual.json` for review. Add assertions once verified.

**Option B — Live payrun via WebApp**
1. Import the bonus case value first:
   ```
   PayrollImport Scenarios/March-Bonus-Jessica.json
   ```
2. Run the March biweekly payrun via WebApp (period 2026-03-17 / 2026-03-30)
3. Open Jessica's payslip to verify WT 1100 and the 22% FIT component

**What to observe:**
- WT 1100 (Supplemental Wages) = $10,000
- WT 5100 (FIT) includes the flat 22% component on $10,000
- WT 5300 (TX SIT) remains $0

---

## Scenario 3 — October: SS Wage Base Cap (Sara Chen)

Sara's annual salary is $240,000. The SS wage base (see `Data.Federal.FICA`
lookup) is exhausted around October. Once exceeded, **WT 5200 (SS Employee)**
drops to $0 for the remainder of the year, increasing her net pay.

**What to observe in the October Monthly payrun:**
- WT 5200 (SS Employee) ≠ $0 in September → $0 in October (or partial cap month)
- WT 6600 (SS Employer) mirrors the cap on the employer side
- Additional Medicare (0.9% on wages > $200,000 YTD MFJ) triggers independently
  of SS cap — check WT 5220

**Run and compare:**
```
# September (SS still running)
PayrunEmployeePreviewTest T3-Payruns/Scenarios/October-SSCap-Preview.et.json /TestPrecision2
```

---

## Scenario 4 — December: 401(k) Annual Cap (Robert Stevenson)

Robert Stevenson (born 1967, age 59 in 2026) contributes a fixed
`US.Pre401kAmount` per period. The 401(k) annual cap applies at year-end.

**SECURE 2.0 catch-up tiers (see `Data.Federal.Tax` / `Data.FICA` lookups):**
| Age range | Extra catch-up | Total limit |
|:---|:---|:---|
| Under 50 | — | Standard limit |
| 50+ | +$7,500 | Standard + $7,500 |
| 60–63 | +$11,250 (super catch-up) | Standard + $11,250 |

Robert is 59 in 2026 (turns 59 on Nov 30) → standard + age-50 catch-up applies.
Super catch-up (ages 60–63 per SECURE 2.0 §603) begins at age 60 in 2027.

**What to observe in December:**
- Pre-tax 401k deduction (WT 1200) stops when YTD reaches the annual cap
- FIT taxable wages increase in the final period(s) after cap is hit
- FICA taxable is unaffected (401k pre-tax reduces FIT but not FICA for employee)

---

## Reports

All reports use the `US.Payroll` regulation (shared with `Apex.DigitalSolutions`
via `RegulationShare`). Reports are parameterized by year, month, and employee.

### Payslip

Generate a payslip PDF for Sara Chen, January 2026:
```
Report tenant:Apex.DigitalSolutions user:apex.admin@apexdigital.com \
  regulation:US.Payroll report:US.Payslip culture:en-US \
  parameterFile:T3-Payruns/Reports/Payslip-Sara-January.parameters.json /pdf /shellopen
```

Generate a payslip PDF for Jessica Torres, March 2026 (with bonus):
```
Report tenant:Apex.DigitalSolutions user:apex.admin@apexdigital.com \
  regulation:US.Payroll report:US.Payslip culture:en-US \
  parameterFile:T3-Payruns/Reports/Payslip-Jessica-March.parameters.json /pdf /shellopen
```

### Form 941 — Quarterly Federal Tax Return

Generate Form 941 for Q1 2026 (January–March):
```
Report tenant:Apex.DigitalSolutions user:apex.admin@apexdigital.com \
  regulation:US.Payroll report:US.Form941 culture:en-US \
  parameterFile:T3-Payruns/Reports/Form941-Q1.parameters.json /pdf /shellopen
```

### W-2 — Year-End

Generate W-2s for all employees after December payruns are complete:
```
Report tenant:Apex.DigitalSolutions user:apex.admin@apexdigital.com \
  regulation:US.Payroll report:US.W2 culture:en-US \
  parameterFile:T3-Payruns/Reports/W2-2026.parameters.json /pdf /shellopen
```

### Form 940 — Annual FUTA Return

```
Report tenant:Apex.DigitalSolutions user:apex.admin@apexdigital.com \
  regulation:US.Payroll report:US.Form940 culture:en-US \
  parameterFile:T3-Payruns/Reports/Form940-2026.parameters.json /pdf /shellopen
```

---

## YTD Accumulator Summary

| Accumulator | Limit | Employee | Approximate Month |
|:---|:---|:---|:---|
| FUTA ($7k/employee) | per-employee | All | Feb |
| SS wage base | `Data.Federal.FICA` lookup | Sara, Carlos | Oct / Dec |
| 401k standard | `Data.Federal.Tax` lookup | All contributors | Dec |
| 401k age-50+ | Standard + $7,500 | Robert (age 59) | Dec |
| Additional Medicare | $200k MFJ YTD | Sara | Sep–Oct |

> Exact cap amounts are defined in the `US.Payroll.Data.Federal.FICA` and
> `US.Payroll.Data.Federal.Tax` regulation data lookups. PE enforces them
> automatically — no custom code required.

---

## Running All T3 Scenarios

```
T3-Payruns/Payruns.pecmd
```
