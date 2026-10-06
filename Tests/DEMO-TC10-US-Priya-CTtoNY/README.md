# DEMO-TC10 — Priya Patel: CT Resident Working in NY, Head of Household

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Priya Patel (Project Manager, CT resident, NY work state, Head of Household)

## Scenario

Validates the CT→NY commuter path and Head of Household withholding:

- No reciprocity between CT and NY → multi-state path WT 5310 (WT 5300 stays empty)
- WT 5310 combines NY work-state withholding and CT resident withholding with the
  CT credit for taxes paid to NY
- FIT: Head of Household standard deduction $24,150 and W-4 Step 3 credit $2,000
- NY Paid Family Leave (work state NY)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $3,653.85 | $95,000 ÷ 26 |
| 401(k) (WT 1200) | −$146.15 | 4% |
| Health (WT 1210) | −$180.00 | §125 |
| FIT taxable wages (WT 5050) | $3,327.70 | − 401(k) − health |
| FICA taxable wages (WT 5051) | $3,473.85 | − health only |
| Federal income tax (WT 5100) | −$197.32 | HoH: ($7,130.42 − $2,000) ÷ 26 |
| Social Security (WT 5200) | −$215.38 | $3,473.85 × 6.2% |
| Medicare (WT 5210) | −$50.37 | $3,473.85 × 1.45% |
| Multi-state withholding (WT 5310) | −$155.92 | NY work state + CT resident |
| NY PFL (WT 5620) | −$15.01 | $3,473.85 × 0.432% |
| Net pay (WT 6500) | $2,693.70 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC10-US-Priya-CTtoNY/DEMO-TC10-US-Priya-CTtoNY.et.json
```
