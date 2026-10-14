# Tutorial 3 — Payruns & Reports

Demonstrates how to execute payrolls, work with YTD accumulators,
and generate statutory reports for Apex Digital Solutions LLC.

## Prerequisites

- T1-Bootstrap completed (`T1-Bootstrap/Bootstrap.pecmd`)
- T4-Customizing completed (`T4-Customizing/Customize.pecmd`)
- **Seed payruns** executed — create persistent payrun results for reports:
  ```
  # from T3-Payruns/
  PayrollImport Payruns-January.json
  PayrollImport Payruns-March-Biweekly.json
  ```
  Or run `Setup.cmd` from the repo root — Steps 6 and 7 handle this automatically.
- PE backend running

---

## Payrun Execution

Payroll Engine executes payrun jobs via the **`PayrollImport`** command (exchange file
with `payrunJobInvocations`), the **WebApp**, or the **REST API**.

| File | Payrun jobs | Setup.cmd |
|:---|:---|:---:|
| `Payruns-January.json` | January 2026 for all three payrolls and all 10 employees | Step 6 |
| `Payruns-March-Biweekly.json` | Biweekly periods 2–5 (Jan 26 – Mar 22), including Jessica's $10,000 bonus | Step 7 |

**pecmd is also used for:**
- Importing case value scenarios (`PayrollImport`)
- Asserting payrun results (`PayrunEmployeeTest`)
- Generating reports (`Report`)

**WebApp workflow (for subsequent periods / manual runs):**
1. Open the payrun → select period → click **Start**
2. Monitor job status → wait for **Complete**
3. Review payslips, correct errors, re-run if needed
4. Close the period

---

## Payrun Schedule — Apex Digital Solutions 2026

The pay date is the period end plus the pay day offset of the payroll calendar.

| Payroll | Frequency | Periods/Year | First period | Pay date |
|:---|:---|:---:|:---|:---|
| `Apex.Payroll.Monthly` | Monthly | 12 | 2026-01-01 – 2026-01-31 | Last day of the month (Jan 31) |
| `Apex.Payroll.Biweekly` | Biweekly | 26 | 2026-01-12 – 2026-01-25 | Friday after the period end (Jan 30) |
| `Apex.Payroll.Weekly` | Weekly | 52 | 2026-01-05 – 2026-01-11 | Friday after the period end (Jan 16) |

Biweekly periods seeded by `Payruns-March-Biweekly.json`:

| Period | Start – End | Pay date |
|:---:|:---|:---|
| 2 | Jan 26 – Feb 8 | Feb 13 |
| 3 | Feb 9 – Feb 22 | Feb 27 |
| 4 | Feb 23 – Mar 8 | Mar 13 |
| 5 | Mar 9 – Mar 22 | Mar 27 (Jessica bonus) |

---

## Scenario 1 — January: Baseline Payrun

All three payrolls for January 2026. No YTD accumulators active yet.

**What to observe:**
- Sara Chen: $20,000 salary + $450 company car → the car is taxed but not paid out
- Marcus Johnson: NY SIT + NJ SIT on the same payslip (no NJ–NY reciprocity)
- Jessica Torres: no state income tax (TX)
- David Kim: PA SIT + Philadelphia Wage Tax (resident)
- FUTA ER (WT 6700) begins accumulating toward the $7,000 per-employee wage base

**Validate with pecmd (from `Tests/`):**
```
pecmd Run.Tests.pecmd /TestPrecision2
```
Each test imports its own case data, executes a payrun job, and asserts the
expected wage type values (self-contained — works regardless of prior Bootstrap state).

---

## Scenario 2 — March: Supplemental Wages (Jessica Bonus)

Jessica Torres receives a $10,000 performance bonus with the regular wages of the biweekly
period Mar 9–22 (paid Mar 27). The bonus is taxed with the **22% optional flat rate**
(Pub. 15 section 7, IRC §3402(g)); TX has no state income tax. The 401(k) percentage
applies to the salary only.

**Assertion:** [DEMO-TC12](../Tests/DEMO-TC12-US-Jessica-Bonus/) — net pay $9,317.60.

**What to observe:**
- WT 1100 (Supplemental Wages) = $10,000
- WT 5120 (Supplemental FIT) = $2,200.00; WT 5100 (regular FIT) only on the regular wages
- Social Security and Medicare include the bonus

The seeded March payrun also contains Jessica's $200 WFH stipend from T4-Customizing
(WT 1260), so her persistent payslip for Mar 27 shows regular FIT $173.57 and net pay
$9,478.30. DEMO-TC12 runs without the T4 stipend.

---

## Scenario 3 — Sara Chen: Annual Wage Limits

Sara's FICA wages are $19,550 per month ($20,000 salary + $450 company car − $600 pre-tax
health − $300 HSA). Consecutive monthly payruns January–November show the limits:

| Month | Limit | Effect |
|:---|:---|:---|
| May | NY PFL maximum $411.91 | WT 5620 = $74.07 (remainder), none from June |
| October | Social Security wage base $184,500 | YTD $175,950 through September → WT 5200 = $530.10 on the remaining $8,550 |
| November | Additional Medicare 0.9% above $200,000 YTD | No Social Security; WT 5220 = $135.45 on $15,050 |

**Assertion:** [DEMO-TC13](../Tests/DEMO-TC13-US-Sara-WageBase/) — 11 monthly jobs.

The employer side mirrors the Social Security wage base (WT 6600). Additional Medicare has
no employer share; the employer withholds it from the pay period in which YTD wages exceed
$200,000, regardless of the filing status.

---

## Scenario 4 — Robert Stevenson: 401(k) Annual Limit

Robert Stevenson (born 1967, age 59 in 2026) contributes a fixed $2,800 per month.

**2026 elective deferral limits:**
| Age at year end | Catch-up | Total limit |
|:---|:---|:---|
| Under 50 | — | $24,500 |
| 50–59 and 64+ | +$8,000 | $32,500 |
| 60–63 | +$11,250 (SECURE 2.0 §109) | $35,750 |

Robert reaches 60 in 2027; for 2026 the age-50 catch-up applies.

**What to observe:**
- YTD 401(k) through November: 11 × $2,800 = $30,800
- December: WT 1200 is capped at $1,700 — FIT taxable wages rise by $1,100
- FICA wages are unaffected (401(k) deferrals are FICA wages)
- NY PFL maximum $411.91 is reached in November

**Assertion:** [DEMO-TC14](../Tests/DEMO-TC14-US-Robert-401kLimit/) — 12 monthly jobs.

---

## Running All T3 Scenarios

```
# from T3-Payruns/
pecmd Payruns.pecmd
```

Runs DEMO-TC12, DEMO-TC13 and DEMO-TC14 and generates the five reports.

---

## Reports

All reports use the `US.Payroll` regulation (shared with `Apex.DigitalSolutions`
via `RegulationShare`). Reports are parameterized by year, period and employee.

Each report has a dedicated `.pecmd` file in `Reports/`. Run from the `Reports/` directory:

| File | Report | Output file | Prerequisite |
|:---|:---|:---|:---|
| `Payslip-Sara-January.pecmd` | Sara Chen payslip, Jan 2026 | `Payslip-Sara-January.pdf` | January Monthly payrun complete |
| `Payslip-Jessica-March.pecmd` | Jessica Torres payslip, pay date Mar 27 2026 (incl. bonus) | `Payslip-Jessica-March.pdf` | March Biweekly payruns complete |
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

A payslip covers one pay date. Without the `PayDate` parameter, the report uses the single pay
date of the payroll in `Year`/`Month`; weekly and biweekly payrolls can have several pay dates
in a month and require `PayDate`.

| Parameter | Sara — January | Jessica — March |
|:---|:---|:---|
| Employee | `sara.chen@apexdigital.com` | `jessica.torres@apexdigital.com` |
| Payroll | `Apex.Payroll.Monthly` | `Apex.Payroll.Biweekly` |
| Month | 1 | 3 |
| Pay date | — (Jan 31) | `2026-03-27` (March also has Mar 13) |
| Output file | `Payslip-Sara-January.pdf` | `Payslip-Jessica-March.pdf` |
| Key feature | Company car · 401(k) · NYC local tax | $10,000 bonus at 22% flat FIT |

### Form 941 — Quarterly Federal Tax Return

Q1 2026 (wages paid January–March). Covers FIT withheld + Social Security/Medicare EE and ER
across all three payrolls. Parameter file: `Form941-Q1.parameters.json`.

### W-2 — Year-End

All employees, wages paid in 2026 from all payrolls. Run after December year-end close.
YTD accumulators must be final before generating.

### Form 940 — Annual FUTA Return

Full year 2026. Net FUTA rate: 0.6% (gross 6.0% minus 5.4% SUTA credit
for non-credit-reduction states). Wage base: $7,000/employee — exhausted
in Q1 for all Apex employees.

---

## YTD Accumulator Summary

| Accumulator | 2026 Limit | Employee | Month |
|:---|:---|:---|:---|
| FUTA wage base | $7,000/employee | All | Jan–Feb |
| NY PFL maximum | $411.91 (0.432% up to $95,348.76) | Sara / Robert | May / Nov |
| Social Security wage base | $184,500 | Sara | Oct |
| 401(k) age-50 catch-up | $32,500 ($24,500 + $8,000) | Robert | Dec |
| Additional Medicare | 0.9% above $200,000 YTD | Sara | Nov |

> The limits are defined in the US.Payroll data regulations (federal tax, FICA and
> state program lookups). PE enforces them automatically — no custom code required.
