# Tutorial 3 — Payruns & Reports

Demonstrates how to execute payrolls, work with YTD accumulators,
and generate statutory reports for Apex Digital Solutions LLC.

## Prerequisites

- T1-Bootstrap completed (`T1-Bootstrap/Bootstrap.pecmd`)
- T4-Customizing completed (`T4-Customizing/Customize.pecmd`)
- **January 2026 payrun seed** executed — creates persistent payrun results for reports:
  ```
  # from T3-Payruns/
  PayrollImport Payruns-January.json
  ```
  Or run `Setup.cmd` from the repo root — Step 6 handles this automatically.
- PE backend running

---

## Payrun Execution

Payroll Engine executes payrun jobs via the **`PayrollImport`** command (exchange file),
the **WebApp**, or the **REST API**.

**`Payruns-January.json`** (this folder) seeds persistent January 2026 results for all
three payrolls and all 10 employees via `payrunJobInvocations` at the tenant level.
It is called automatically by `Setup.cmd` Step 6 after T4-Customizing.

**pecmd is also used for:**
- Importing case value scenarios (`PayrollImport`)
- Validating results before/after execution (`PayrunEmployeePreviewTest`)
- Generating reports (`Report`)

**WebApp workflow (for subsequent periods / manual runs):**
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

Each report has a dedicated `.pecmd` file in `Reports/`. Run from the `Reports/` directory:

| File | Report | Output file | Prerequisite |
|:---|:---|:---|:---|
| `Payslip-Sara-January.pecmd` | Sara Chen payslip, Jan 2026 | `Payslip-Sara-January.pdf` | January Monthly payrun complete |
| `Payslip-Jessica-March.pecmd` | Jessica Torres payslip, Mar 2026 (incl. bonus) | `Payslip-Jessica-March.pdf` | March Biweekly payrun complete |
| `Form941-Q1.pecmd` | Form 941 Q1 2026 | timestamp-based | All Jan–Mar payruns complete |
| `W2-2026.pecmd` | W-2 all employees, 2026 | timestamp-based | All December payruns complete |
| `Form940-2026.pecmd` | Form 940 annual FUTA, 2026 | timestamp-based | All December payruns complete |
| `Reports.pecmd` | All five reports combined | see above | See individual prerequisites above |

Each payslip uses `targetFile:` to write a fixed, employee-named PDF. Running the command a second time overwrites the previous file. All other reports use the default timestamp-based filename.

```bash
cd T3-Payruns/Reports

# Single report
start /b /wait "" "Payslip-Sara-January.pecmd"

# All reports
start /b /wait "" "Reports.pecmd"
```

### Payslip

| Parameter | Sara — January | Jessica — March |
|:---|:---|:---|
| Employee | `sara.chen@apexdigital.com` | `jessica.torres@apexdigital.com` |
| Payroll | `Apex.Payroll.Monthly` | `Apex.Payroll.Biweekly` |
| Month | 1 | 3 |
| Output file | `Payslip-Sara-January.pdf` | `Payslip-Jessica-March.pdf` |
| Key feature | Car fringe · 401k · NYC local | $10k bonus at 22% flat FIT |

### Form 941 — Quarterly Federal Tax Return

Q1 2026 (January–March). Covers FIT withheld + SS/Medicare EE and ER
across all three payrolls. Parameter file: `Form941-Q1.parameters.json`.

### W-2 — Year-End

All employees, full year 2026. Run after December year-end close.
YTD accumulators must be final before generating.

### Form 940 — Annual FUTA Return

Full year 2026. Net FUTA rate: 0.6% (gross 6.0% minus 5.4% SUTA credit
for non-credit-reduction states). Wage base: $7,000/employee — exhausted
in Q1 for most Apex employees.

---

## YTD Accumulator Summary

| Accumulator | 2026 Limit | Employee | Approximate Month |
|:---|:---|:---|:---|
| FUTA wage base | $7,000/employee | All | Feb |
| SS wage base | $184,500 | Sara, Carlos | Oct |
| 401k standard | $24,500 | All contributors | Dec |
| 401k age-50+ catch-up | $32,500 (standard + $8,000) | Robert (age 59) | Dec |
| Additional Medicare | $250,000 YTD (MFJ) | Sara | Sep–Oct |

> Exact cap amounts are defined in the `US.Payroll.Data.Federal.FICA` and
> `US.Payroll.Data.Federal.Tax` regulation data lookups. PE enforces them
> automatically — no custom code required.

---

## Running All T3 Scenarios

```
T3-Payruns/Payruns.pecmd
```
