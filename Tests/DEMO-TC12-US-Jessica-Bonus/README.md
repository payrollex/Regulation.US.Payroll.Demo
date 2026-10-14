# DEMO-TC12 — Jessica Torres: Bonus with the Regular Wages

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-03-09 / 2026-03-22 (paid 2026-03-27)  
**Employee:** Jessica Torres (Account Executive, TX, MFJ)

## Scenario

Validates a $10,000 performance bonus paid together with the regular biweekly salary:

- `US.SupplementalWages` $10,000 for the period (WT 1100)
- Federal supplemental withholding (WT 5120): optional flat rate method 22% (Pub 15 section 7), because
  income tax is withheld from the regular wages of the period; the regular FIT (WT 5100) is computed
  on the regular wages only
- 401(k) 4% applies to the salary only (`US.Pre401kPercent` × annual salary ÷ 26), not to the bonus
- Social Security and Medicare apply to salary and bonus
- Texas has no state income tax

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $3,076.92 | $80,000 ÷ 26 |
| Bonus (WT 1100) | $10,000.00 | Supplemental wages |
| 401(k) (WT 1200) | −$123.08 | 4% of the salary |
| Health (WT 1210) | −$310.00 | §125 |
| FIT taxable wages (WT 5050) | $12,643.84 | $12,766.92 − 401(k) |
| FICA taxable wages (WT 5051) | $12,766.92 | Salary + bonus − health |
| Federal income tax (WT 5100) | −$149.57 | Worksheet 1A MFJ on the regular wages $2,643.84 × 26 |
| Supplemental FIT (WT 5120) | −$2,200.00 | 22% × $10,000 |
| Social Security (WT 5200) | −$791.55 | $12,766.92 × 6.2% |
| Medicare (WT 5210) | −$185.12 | $12,766.92 × 1.45% |
| Net pay (WT 6500) | $9,317.60 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC12-US-Jessica-Bonus/DEMO-TC12-US-Jessica-Bonus.et.json
```
