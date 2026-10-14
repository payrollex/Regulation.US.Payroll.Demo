# DEMO-TC09 — Robert Stevenson: Monthly, Fixed 401(k) Amount

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-01-31 (paid 2026-01-31)  
**Employee:** Robert Stevenson (VP Engineering, NY, MFJ, age 59 in 2026)

## Scenario

Validates a fixed monthly 401(k) contribution in the age-50 catch-up range:

- `US.Pre401kAmount` $2,800/month: the 2026 limit $24,500 + age-50 catch-up $8,000 = $32,500 is reached
  in December (asserted in [DEMO-TC14](../DEMO-TC14-US-Robert-401kLimit/README.md))
- Age 59 = 2026 − `US.BirthYear` 1967: regular catch-up, not the age 60-63 catch-up
- `US.PriorYearFICAWages` not set (treated as below $150,000) → catch-up stays pre-tax
  (no mandatory Roth routing under SECURE 2.0 §603)
- 401(k) reduces FIT and NY taxable wages but not FICA
- W-4 Step 3 credit $2,000/year
- NY IT-2104 married, 0 allowances (`StateWithholdingCertificate` slot `NY`)
- No Additional Medicare: YTD Medicare wages below the $200,000 employer threshold

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $9,583.33 | $115,000 ÷ 12 |
| 401(k) (WT 1200) | −$2,800.00 | Fixed amount |
| Health (WT 1210) | −$475.00 | §125 |
| FIT taxable wages (WT 5050) | $6,308.33 | − 401(k) − health |
| FICA taxable wages (WT 5051) | $9,108.33 | − health only |
| Federal income tax (WT 5100) | −$227.00 | Worksheet 1A MFJ: $6,308.33 × 12 − $12,900 = $62,799.96 → $4,724.00/yr; ($4,724.00 − $2,000) ÷ 12 |
| Social Security (WT 5200) | −$564.72 | $9,108.33 × 6.2% |
| Medicare (WT 5210) | −$132.07 | $9,108.33 × 1.45% |
| NY SIT (WT 5300) | −$291.17 | NYS-50-T-NYS Table II-D monthly married: $6,308.33 − $662.50 = $5,645.83 → $48.83 + ($5,645.83 − $1,158) × 5.4% |
| NY PFL (WT 5620) | −$39.35 | $9,108.33 × 0.432% |
| Net pay (WT 6500) | $5,054.02 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC09-US-Robert-Monthly/DEMO-TC09-US-Robert-Monthly.et.json
```
