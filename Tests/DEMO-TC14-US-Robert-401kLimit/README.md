# DEMO-TC14 — Robert Stevenson: 401(k) Annual Limit with Catch-Up

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-12-31 (12 monthly jobs, each paid on the last day of the month)  
**Employee:** Robert Stevenson (VP Engineering, NY, MFJ, age 59 in 2026)

## Scenario

Twelve consecutive monthly payruns with the January payslip of
[DEMO-TC09](../DEMO-TC09-US-Robert-Monthly/README.md) and a fixed 401(k) contribution of $2,800 per month:

- 2026 limit: $24,500 (IRC §402(g)) + age-50 catch-up $8,000 (IRC §414(v)) = $32,500;
  age 59 = 2026 − `US.BirthYear` 1967, outside the age 60-63 catch-up range
- January to November: 11 × $2,800 = $30,800
- December: the contribution is capped at $32,500 − $30,800 = $1,700; FIT and NY taxable wages rise by $1,100
- NY PFL maximum $411.91: $411.91 − 10 × $39.35 = $18.41 in November, none in December

## Key Assertions

| Wage Type | November | December | Notes |
|:---|---:|---:|:---|
| 401(k) (WT 1200) | −$2,800.00 | −$1,700.00 | Annual limit reached |
| FIT taxable wages (WT 5050) | $6,308.33 | $7,408.33 | $9,583.33 − 401(k) − $475 health |
| Federal income tax (WT 5100) | −$227.00 | −$359.00 | Worksheet 1A MFJ, December: $7,408.33 × 12 − $12,900 → $6,308.00/yr; ($6,308.00 − $2,000) ÷ 12 |
| NY SIT (WT 5300) | −$291.17 | −$350.63 | Table II-D monthly married, December: $7,408.33 − $662.50 = $6,745.83 → $349.17 + ($6,745.83 − $6,721) × 5.9% |
| NY PFL (WT 5620) | −$18.41 | — | Annual maximum reached in November |
| Net pay (WT 6500) | $5,074.96 | $6,001.91 | |

A dash means the wage type has no result in that month; it is not asserted.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC14-US-Robert-401kLimit/DEMO-TC14-US-Robert-401kLimit.et.json
```
