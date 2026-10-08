# DEMO-TC07 — David Kim: Philadelphia Weekly

**Payroll:** Apex.Payroll.Weekly  
**Period:** 2026-01-05 / 2026-01-11  
**Employee:** David Kim (IT Support Tech, Philadelphia PA, hourly $32, Single)

## Scenario

Validates PA state tax and the Philadelphia Wage Tax:

- PA SIT flat rate on gross wages (no pre-tax deductions)
- `US.LocalTaxJurisdiction = PA-Philadelphia` → Philadelphia resident Wage Tax (WT 5400), rate of the
  period from the `PhiladelphiaWageTax` lookup (Philadelphia is exempt from PA Act 32: no PSD codes)
- PA employee unemployment contribution 0.07% (WT 5630, no wage cap)
- 40 regular hours, weekly annualization ×52

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Hourly wages (WT 1010) | $1,280.00 | 40h × $32 |
| Federal income tax (WT 5100) | −$111.79 | Single, 22% bracket reached |
| Social Security (WT 5200) | −$79.36 | $1,280 × 6.2% |
| Medicare (WT 5210) | −$18.56 | $1,280 × 1.45% |
| PA SIT (WT 5300) | −$39.30 | $1,280 × 3.07% |
| Philadelphia Wage Tax (WT 5400) | −$47.87 | $1,280 × 3.74% (resident, edition July 1, 2025) |
| PA employee UC (WT 5630) | −$0.90 | $1,280 × 0.07% |
| Net pay (WT 6500) | $982.22 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC07-US-David-Philadelphia/DEMO-TC07-US-David-Philadelphia.et.json
```
