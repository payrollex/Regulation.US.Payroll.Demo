# DEMO-TC01 — Sara Chen: Monthly January 2026

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-01-31 (paid 2026-01-31)  
**Employee:** Sara Chen (CFO, NY/NYC, MFJ)

## Scenario

Validates the full monthly payslip for a high-earning NYC executive:

- Company car fringe (+$450) → increases **both** FIT and FICA taxable wages, but is
  **not paid out** (imputed income is deducted again from net pay)
- 401(k) 8% (−$1,600) → reduces FIT/NY/NYC but **not** FICA
- NY Paid Family Leave (0.432%) deducted from net pay
- Three different taxable wage bases on one payslip (FIT ≠ FICA ≠ Gross)
- W-4 Step 3 child credits ($4,000/yr → $333/month tax reduction)
- W-4 Step 4c extra withholding ($500/month)
- NY IT-2104 married, 0 allowances (`StateWithholdingCertificate` slot `NY`) → NY and NYC withholding
  with the married tables (NYS-50-T-NYS, NYS-50-T-NYC)
- Additional Medicare (0.9%) NOT triggered in January (YTD < $200k)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $20,000.00 | $240k ÷ 12 |
| Company car fringe (WT 1320) | $450.00 | §61 imputed income |
| FIT taxable wages (WT 5050) | $17,950.00 | Gross+Car−401k−Health−HSA |
| FICA taxable wages (WT 5051) | $19,550.00 | Gross+Car−Health−HSA (401k does not reduce FICA) |
| Federal income tax (WT 5100) | −$2,144.00 | Base FIT only — W-4 Step 3 credit applied |
| Additional FIT / Step 4c (WT 5110) | −$500.00 | W-4 Step 4c extra withholding |
| Social Security (WT 5200) | −$1,212.10 | $19,550 × 6.2% |
| Medicare (WT 5210) | −$283.48 | $19,550 × 1.45% |
| Add'l Medicare (WT 5220) | — | Not triggered: YTD Medicare wages < $200,000 (employer threshold, any filing status) |
| NY SIT (WT 5300) | −$1,114.70 | NYS-50-T-NYS Method II, Table II-D monthly married: $17,950 − $662.50 = $17,287.50 → $782.33 + ($17,287.50 − $13,138) × 8.01% |
| NYC local (WT 5400) | −$717.23 | NYS-50-T-NYC Method II, Table II-D monthly married, 0 New York City allowances: $17,950 − $458.30 = $17,491.70 → $186.33 + ($17,491.70 − $5,000) × 4.25% |
| NY PFL (WT 5620) | −$84.46 | $19,550 × 0.432% |
| Net pay (WT 6500) | $11,444.03 | $20,450 − $450 car (not paid out) − $2,500 pre-tax − $5,971.51 taxes − $84.46 PFL |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC01-US-Sara-Monthly/DEMO-TC01-US-Sara-Monthly.et.json
```
