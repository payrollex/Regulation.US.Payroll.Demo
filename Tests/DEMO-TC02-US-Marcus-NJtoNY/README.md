# DEMO-TC02 — Marcus Johnson: NJ Resident Working in NY

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-12 / 2026-01-25 (paid 2026-01-30)  
**Employee:** Marcus Johnson (Sr. Software Engineer, NJ resident, NY work state, Single)

## Scenario

Validates the commuter path without reciprocity:

- NJ and NY have no reciprocal agreement — work state NY withholds on all wages
- Resident and work state differ → multi-state path WT 5310 (WT 5300 stays empty)
- Each state taxes its own wage base: NY excludes 401(k) and the §125 health premium ($5,223.08);
  NJ excludes 401(k) but taxes the §125 health premium ($5,423.08; N.J.S.A. 54A:6-24, TB-39(R))
- NJ resident tax ($290.67, NJ-W4 single → NJ-WT rate A) exceeds the NY tax ($287.28) → additional NJ withholding $3.39
- State certificates: NY IT-2104 single and NJ-W4 single, 0 allowances each (`StateWithholdingCertificate` slots `NY`, `NJ`)
- 401(k) 6% reduces FIT, NY and NJ taxable wages but not FICA
- NY Paid Family Leave (work state NY) deducted from net pay

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $5,769.23 | $150,000 ÷ 26 |
| FIT taxable wages (WT 5050) | $5,223.08 | − 401(k) $346.15 − health $200 |
| FICA taxable wages (WT 5051) | $5,569.23 | − health $200 (401(k) does not reduce FICA) |
| Federal income tax (WT 5100) | −$820.23 | Single, annualized ×26 |
| Social Security (WT 5200) | −$345.29 | $5,569.23 × 6.2% |
| Medicare (WT 5210) | −$80.75 | $5,569.23 × 1.45% |
| Multi-state withholding (WT 5310) | −$290.67 | NY Table II-D biweekly: $5,223.08 − $284.60 = $4,938.48 → $227.15 + ($4,938.48 − $4,140) × 7.53% = $287.28; NJ rate A: $113 + ($5,423.08 − $2,885) × 7% = $290.67 → NJ excess $3.39 |
| NY PFL (WT 5620) | −$24.06 | $5,569.23 × 0.432% |
| Net pay (WT 6500) | $3,662.08 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC02-US-Marcus-NJtoNY/DEMO-TC02-US-Marcus-NJtoNY.et.json
```
