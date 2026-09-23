# DEMO-TC09 — Robert Stevenson: Monthly January 2026

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-01-31  
**Employee:** Robert Stevenson (VP Engineering, NY, MFJ, age 59)

## Scenario

Validates the monthly payslip for a senior employee with a fixed 401(k) amount
at the age-50+ catch-up tier (SECURE 2.0 §603):

- Fixed `US.Pre401kAmount` $2,708.33/month — not a percentage of salary
- 401(k) reduces FIT taxable but **not** FICA taxable wages
- MFJ filing with W-4 Step 3 child credit ($2,000/year)
- NY SIT applies; no NYC local tax (no `US.LocalTaxJurisdiction` set)
- Born 1967 → age 59 in 2026 → standard + age-50 catch-up limit applies;
  super catch-up (ages 60–63 per SECURE 2.0) starts at age 60 in 2027

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $9,583.33 | $115k ÷ 12 |
| FIT taxable wages (WT 5050) | $6,400.00 | Gross − 401k − Health |
| FICA taxable wages (WT 5051) | $9,108.33 | Gross − Health (401k does not reduce FICA) |
| Federal income tax (WT 5100) | −$238.00 | Annual $44,600 → 10%+12% brackets − Step3 credit |
| Social Security (WT 5200) | −$564.72 | $9,108.33 × 6.2% |
| Medicare (WT 5210) | −$132.07 | $9,108.33 × 1.45% |
| NY SIT (WT 5300) | verify | NYS-50-T graduated on annual FIT taxable |
| Net pay (WT 6500) | verify | |

> WT 5300 and WT 6500 are excluded from initial assertions — run PE to capture
> exact NY SIT values, then add them to `payrollResults`.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC09-US-Robert-Monthly.et.json
```
