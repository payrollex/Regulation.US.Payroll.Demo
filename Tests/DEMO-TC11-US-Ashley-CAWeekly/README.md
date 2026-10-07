# DEMO-TC11 — Ashley Park: CA Hourly Weekly Baseline

**Payroll:** Apex.Payroll.Weekly  
**Period:** 2026-01-05 / 2026-01-11  
**Employee:** Ashley Park (QA Engineer, CA, hourly $42, Single)

## Scenario

Weekly baseline for a California hourly employee:

- 40 regular hours, no overtime, no pre-tax deductions → gross = FIT = FICA wages
- Weekly annualization ×52
- CA SIT (EDD Method B) and CA SDI 1.3% without a wage cap

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Hourly wages (WT 1010) | $1,680.00 | 40h × $42 |
| FIT taxable wages (WT 5050) | $1,680.00 | |
| FICA taxable wages (WT 5051) | $1,680.00 | |
| Federal income tax (WT 5100) | −$199.79 | Single, $10,389.20 ÷ 52 |
| Social Security (WT 5200) | −$104.16 | $1,680 × 6.2% |
| Medicare (WT 5210) | −$24.36 | $1,680 × 1.45% |
| CA SIT (WT 5300) | −$85.30 | EDD Method B annualized, no DE 4 (single, 0 allowances): ($1,680 × 52 − $5,706) → $4,435.71 ÷ 52 |
| CA SDI (WT 5600) | −$21.84 | $1,680 × 1.3% |
| Net pay (WT 6500) | $1,244.55 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC11-US-Ashley-CAWeekly/DEMO-TC11-US-Ashley-CAWeekly.et.json
```
