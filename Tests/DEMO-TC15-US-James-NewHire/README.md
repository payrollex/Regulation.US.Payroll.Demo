# DEMO-TC15 — James Lee: New Hire Mid-Period

**Payroll:** Apex.Payroll.Biweekly  
**Periods:** 2026-03-09 / 2026-03-22 (paid 2026-03-27) and 2026-03-23 / 2026-04-05 (paid 2026-04-10)  
**Employee:** James Lee (Software Engineer, CA, Single, hired 2026-03-17)

## Scenario

Asserts the new hire event of [T2-Lifecycle](../../T2-Lifecycle/) (`L1-NewHire-JamesLee.json`):

- `US.AnnualSalary` $130,000 and `US.PreHealthAmount` $220 start on the hire date; both are
  calendar period fields and are prorated to 6 of 14 days (Mar 17–22) in the first period
- `US.Pre401kPercent` 5% applies to the prorated salary
- CA withholding (EDD DE 44 Method B) with the CA DE 4 certificate (Single, 0 allowances)
- CA SDI 1.3% without wage ceiling
- The second period is the first full period

`DEMO-TC15-US-James-NewHire.employee.json` creates the employee record; the test clones it and
applies the case values of the test file.

## Key Assertions

| Wage Type | Mar 9–22 | Mar 23–Apr 5 | Notes |
|:---|---:|---:|:---|
| Salary (WT 1000) | $2,142.86 | $5,000.00 | $130,000 ÷ 26, first period × 6/14 |
| 401(k) (WT 1200) | −$107.14 | | 5% of the salary |
| Health (WT 1210) | −$94.29 | −$220.00 | §125, first period × 6/14 |
| FIT taxable wages (WT 5050) | $1,941.43 | | |
| FICA taxable wages (WT 5051) | $2,048.57 | | |
| Federal income tax (WT 5100) | −$149.13 | −$656.98 | Worksheet 1A Single |
| Social Security (WT 5200) | −$127.01 | | 6.2% |
| Medicare (WT 5210) | −$29.70 | | 1.45% |
| CA income tax (WT 5300) | −$51.66 | −$290.30 | DE 44 Method B |
| CA SDI (WT 5600) | −$26.63 | −$62.14 | 1.3% |
| Net pay (WT 6500) | $1,557.30 | $3,154.91 | |

## Run

```bash
pecmd PayrollImport DEMO-TC15-US-James-NewHire/DEMO-TC15-US-James-NewHire.employee.json
pecmd PayrunEmployeeTest DEMO-TC15-US-James-NewHire/DEMO-TC15-US-James-NewHire.et.json /TestPrecision2
```
