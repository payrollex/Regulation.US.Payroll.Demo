# DEMO-TC06 — Linda Okafor: Child Support Garnishment

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Linda Okafor (HR Coordinator, NY, Single)

## Scenario

Validates a child support order under the CCPA limit (15 USC §1673(b)):

- Order: $500 per period, Linda does not support another family, no arrears → 60% limit
- Disposable earnings = gross − legally required deductions (FIT, FICA, NY SIT, NY PFL)
  = $2,500 − $216.15 − $155.00 − $36.25 − $111.22 − $10.80 = **$1,970.58**
- Limit: 60% × $1,970.58 = $1,182.35 ≥ $500 → the full order is withheld
- Garnishment (WT 5900) runs before net pay and reduces it
- No NYC local tax: no `US.LocalTaxJurisdiction` is set for Linda

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $2,500.00 | $65,000 ÷ 26 |
| Federal income tax (WT 5100) | −$216.15 | Single, 12% bracket |
| Social Security (WT 5200) | −$155.00 | $2,500 × 6.2% |
| Medicare (WT 5210) | −$36.25 | $2,500 × 1.45% |
| NY SIT (WT 5300) | −$111.22 | NYS-50-T |
| NY PFL (WT 5620) | −$10.80 | $2,500 × 0.432% |
| Garnishment (WT 5900) | −$500.00 | Within the 60% CCPA limit |
| Net pay (WT 6500) | $1,470.58 | $1,970.58 − $500 |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC06-US-Linda-Garnishment/DEMO-TC06-US-Linda-Garnishment.et.json
```
