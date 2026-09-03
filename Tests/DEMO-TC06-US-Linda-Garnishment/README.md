# DEMO-TC06 — Linda Okafor: Child Support Garnishment

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Linda Okafor (HR Coordinator, NYC, Single)

## Scenario

Validates CCPA-compliant child support garnishment:

- Court-ordered $500/biweekly child support
- `GarnishmentType = ChildSupport`, `GarnishmentIsSupporting = false`, not in arrears
- CCPA limit: 60% of disposable earnings
- Disposable earnings = gross − mandatory deductions (FIT + FICA + SIT + local)
- Deduction applied **after** net pay calculation, as post-tax withholding
- CCPA check: $500 ≤ 60% × ~$2,048 = $1,229 → within limit → full $500 deducted

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $2,500.00 | $65k ÷ 26 |
| Federal income tax (WT 5100) | ~−$133 | Single, lower bracket |
| Social Security (WT 5200) | −$155.00 | $2,500 × 6.2% |
| Medicare (WT 5210) | −$36.25 | $2,500 × 1.45% |
| NY SIT (WT 5300) | ~−$73 | Graduated |
| NYC local (WT 5400) | ~−$56 | City graduated |
| Disposable earnings | ~$2,048 | After mandatory deductions |
| Child support garnishment (WT 5500) | −$500.00 | CCPA limit: 60% × $2,048 = $1,229 ≥ $500 ✓ |
| Net pay after garnishment (WT 6500) | ~$1,548 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC06-US-Linda-Garnishment.et.json
```
