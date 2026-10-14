# DEMO-TC16 — Marcus Johnson: Salary Change Mid-Period

**Payroll:** Apex.Payroll.Biweekly  
**Periods:** 2026-03-09 / 2026-03-22 (paid 2026-03-27) and 2026-03-23 / 2026-04-05 (paid 2026-04-10)  
**Employee:** Marcus Johnson (Sr. Software Engineer, NJ resident, NY work state, Single)

## Scenario

Asserts the salary change event of [T2-Lifecycle](../../T2-Lifecycle/) (`L2-SalaryChange-Marcus.json`):

- Merit increase from $150,000 to $165,000 effective 2026-03-15
- `US.AnnualSalary` is a calendar period field: the period Mar 9–22 is split into 6 days at
  $150,000 and 8 days at $165,000
- 401(k) 6% follows the prorated salary
- Multi-state withholding (WT 5310): NY nonresident tax, NJ resident tax on NJ wages; the NJ tax
  exceeds the NY tax, the difference is withheld for NJ
- The second period is the first full period at the new salary

## Key Assertions

| Wage Type | Mar 9–22 | Mar 23–Apr 5 | Notes |
|:---|---:|---:|:---|
| Salary (WT 1000) | $6,098.90 | $6,346.15 | ($150,000 × 6 + $165,000 × 8) ÷ 14 ÷ 26; $165,000 ÷ 26 |
| 401(k) (WT 1200) | −$365.93 | | 6% of the salary |
| FIT taxable wages (WT 5050) | $5,532.97 | | |
| FICA taxable wages (WT 5051) | $5,898.90 | | |
| Federal income tax (WT 5100) | −$894.61 | −$950.38 | Worksheet 1A Single |
| Social Security (WT 5200) | −$365.73 | | 6.2% |
| Medicare (WT 5210) | −$85.53 | | 1.45% |
| State income tax (WT 5310) | −$312.36 | −$328.63 | NY $310.61 / $328.11 + NJ difference |
| NY PFL (WT 5620) | −$25.48 | | 0.432% |
| Net pay (WT 6500) | $3,849.26 | $3,989.64 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC16-US-Marcus-SalaryChange/DEMO-TC16-US-Marcus-SalaryChange.et.json /TestPrecision2
```
