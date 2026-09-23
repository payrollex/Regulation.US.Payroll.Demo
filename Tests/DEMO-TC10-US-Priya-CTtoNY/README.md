# DEMO-TC10 — Priya Patel: CT Resident Working in NY

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Priya Patel (Project Manager, WorkState=NY, ResidentState=CT, HoH)

## Scenario

Validates the biweekly payslip for a CT-resident commuting to NY with no reciprocity
agreement between the two states:

- Works in NY → NY SIT withheld on 100% of NY-sourced income (WT 5310)
- Resident of CT → CT SIT applies as resident tax, with credit for NY tax paid
- No reciprocity: both states tax the same income (NY at source, CT as residence minus NY credit)
- Head of Household filing with W-4 Step 3 credit ($2,000/year)
- 401(k) 4% reduces FIT taxable; health $180 reduces both FIT and FICA taxable

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $3,653.85 | $95k ÷ 26 |
| FIT taxable wages (WT 5050) | $3,327.70 | Gross − 401k − Health |
| FICA taxable wages (WT 5051) | $3,473.85 | Gross − Health |
| Federal income tax (WT 5100) | verify | HoH brackets + Step 3 credit |
| Social Security (WT 5200) | verify | $3,473.85 × 6.2% |
| Medicare (WT 5210) | verify | $3,473.85 × 1.45% |
| State withholding (WT 5300) | null | Multi-state path — WT 5310 used instead |
| Multi-state withholding (WT 5310) | verify | NY tax − CT credit for NY tax paid |
| Net pay (WT 6500) | verify | |

> All `verify` values are pending first PE run. Run with `/OkOnFail ActualOutputFile:...`
> to capture actual values, then update `payrollResults`.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC10-US-Priya-CTtoNY.et.json
```
