# DEMO-TC09 — Robert Stevenson: Monthly, 401(k) Catch-Up

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-01-31  
**Employee:** Robert Stevenson (VP Engineering, NY, MFJ, age 59 in 2026)

## Scenario

Validates the age-50+ 401(k) catch-up with a fixed monthly contribution:

- `US.Pre401kAmount` $2,708.33/month × 12 = $32,500 = $24,500 limit + $8,000 catch-up (SECURE 2.0)
- `US.PriorYearFICAWages` not set (treated as below $150,000) → catch-up stays pre-tax
  (no mandatory Roth routing under SECURE 2.0 §603)
- 401(k) reduces FIT and NY taxable wages but not FICA
- W-4 Step 3 credit $2,000/year → $166.67 per month
- No Additional Medicare: YTD Medicare wages below the $200,000 employer threshold

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $9,583.33 | $115,000 ÷ 12 |
| 401(k) (WT 1200) | −$2,708.33 | Fixed amount incl. catch-up |
| Health (WT 1210) | −$475.00 | §125 |
| FIT taxable wages (WT 5050) | $6,400.00 | − 401(k) − health |
| FICA taxable wages (WT 5051) | $9,108.33 | − health only |
| Federal income tax (WT 5100) | −$238.00 | MFJ $404.67 − Step 3 $166.67 |
| Social Security (WT 5200) | −$564.72 | $9,108.33 × 6.2% |
| Medicare (WT 5210) | −$132.07 | $9,108.33 × 1.45% |
| NY SIT (WT 5300) | −$294.08 | NYS-50-T on $76,800 annual |
| NY PFL (WT 5620) | −$39.35 | $9,108.33 × 0.432% |
| Net pay (WT 6500) | $5,131.78 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC09-US-Robert-Monthly/DEMO-TC09-US-Robert-Monthly.et.json
```
