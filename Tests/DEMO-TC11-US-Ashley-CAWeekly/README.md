# DEMO-TC11 — Ashley Park: CA Hourly Weekly Baseline

**Payroll:** Apex.Payroll.Weekly  
**Period:** 2026-01-05 / 2026-01-11  
**Employee:** Ashley Park (QA Engineer, CA, Single, $42/hr)

## Scenario

Validates the weekly baseline payslip for a CA hourly employee with standard hours:

- Hourly $42/hr × 40 regular hours = $1,680.00 gross
- No pre-tax deductions (no 401k, no health)
- CA SIT applies (graduated, DE-4 Single)
- CA SDI withheld (WT 6800) — no wage base cap at this level
- No overtime in this baseline week (standard 5-day, 8-hour week)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Hourly wages (WT 1010) | $1,680.00 | 40 hrs × $42 (WT 1000 is null for hourly employees) |
| FIT taxable wages (WT 5050) | $1,680.00 | No pre-tax deductions |
| FICA taxable wages (WT 5051) | $1,680.00 | No pre-tax deductions |
| Federal income tax (WT 5100) | verify | Single graduated on annual $71,260 |
| Social Security (WT 5200) | −$104.16 | $1,680 × 6.2% |
| Medicare (WT 5210) | −$24.36 | $1,680 × 1.45% |
| CA SIT (WT 5200/5300) | verify | CA DE-4 Single graduated |
| CA SDI (WT 6800) | verify | CA SDI rate on $1,680 |
| Net pay (WT 6500) | verify | |

> FIT, CA SIT, CA SDI, and net pay are pending first PE run.
> Run with `/OkOnFail ActualOutputFile:...` to capture actual values.

## 7th-Day OT Extension

The bootstrap profile for Ashley notes "7th-day OT". A separate scenario with
`US.OvertimeHours` or CA-specific daily/7th-day case fields can be added once
this baseline test passes.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC11-US-Ashley-CAWeekly.et.json
```
