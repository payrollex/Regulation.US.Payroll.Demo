# DEMO-TC02 — Marcus Johnson: NJ Resident Working in NY

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Marcus Johnson (Sr. Software Engineer, NJ resident, NY work state, Single)

## Scenario

Validates the commuter path without reciprocity:

- NJ and NY have no reciprocal agreement — work state NY withholds on all wages
- Resident and work state differ → multi-state path WT 5310 (WT 5300 stays empty)
- NJ resident tax is fully offset by the credit for tax paid to NY → $0 NJ withholding
- 401(k) 6% reduces FIT and NY taxable wages but not FICA
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
| Multi-state withholding (WT 5310) | −$284.35 | NY work-state tax; NJ fully credited |
| NY PFL (WT 5620) | −$24.06 | $5,569.23 × 0.432% |
| Net pay (WT 6500) | $3,668.40 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC02-US-Marcus-NJtoNY/DEMO-TC02-US-Marcus-NJtoNY.et.json
```
