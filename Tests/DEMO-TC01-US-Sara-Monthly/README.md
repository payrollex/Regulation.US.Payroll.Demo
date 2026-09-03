# DEMO-TC01 — Sara Chen: Monthly January 2026

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-01-31  
**Employee:** Sara Chen (CFO, NY/NYC, MFJ)

## Scenario

Validates the full monthly payslip for a high-earning NYC executive:

- Company car fringe (+$450) → increases **both** FIT and FICA taxable wages
- 401(k) 8% (−$1,600) → reduces FIT/NY/NYC but **not** FICA
- Three different taxable wage bases on one payslip (FIT ≠ FICA ≠ Gross)
- W-4 Step 3 child credits ($4,000/yr → $333/month tax reduction)
- W-4 Step 4c extra withholding ($500/month)
- Additional Medicare (0.9%) NOT triggered in January (YTD < $200k)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $20,000.00 | |
| Company car fringe (WT 1320) | $450.00 | §61 imputed income |
| FIT taxable wages (WT 5050) | $17,950.00 | Gross+Car−401k−Health−HSA |
| FICA taxable wages (WT 5051) | $19,550.00 | Gross+Car−Health−HSA |
| Federal income tax (WT 5100) | ~$2,645 | incl. $500 Step4c extra |
| Social Security (WT 5200) | −$1,212.10 | $19,550 × 6.2% |
| Medicare (WT 5210) | −$283.48 | $19,550 × 1.45% |
| Add'l Medicare (WT 5220) | $0.00 | YTD < $200k threshold |
| NY SIT (WT 5300) | ~−$940 | NYS-50-T graduated |
| NYC local (WT 5400) | ~−$590 | NYC city graduated |
| Net pay (WT 6500) | ~$14,290 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC01-US-Sara-Monthly.et.json
```
