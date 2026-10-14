# DEMO-TC17 — Linda Okafor: Unpaid FMLA Leave and Return

**Payroll:** Apex.Payroll.Biweekly  
**Periods:** 2026-04-06 / 2026-04-19 (paid 2026-04-24), 2026-04-20 / 2026-05-03 (paid 2026-05-08)
and 2026-06-29 / 2026-07-12 (paid 2026-07-17)  
**Employee:** Linda Okafor (HR Coordinator, NY/NYC, Single, child support garnishment $500)

## Scenario

Asserts the leave event of [T2-Lifecycle](../../T2-Lifecycle/) (`L3-FMLALeave-Linda.json`):

- Unpaid FMLA leave from 2026-04-07: `US.AnnualSalary` $0; return on 2026-07-01: $65,000
- Apr 6–19: one paid day (Apr 6); FIT and NY tax are zero; the child support order is limited to
  60% of the disposable earnings (CCPA, 15 USC §1673(b)(2)(B))
- Apr 20–May 3: no wages, no withholding, no garnishment
- Jun 29–Jul 12: 12 of 14 days paid; the garnishment is withheld in full

## Key Assertions

| Wage Type | Apr 6–19 | Apr 20–May 3 | Jun 29–Jul 12 | Notes |
|:---|---:|---:|---:|:---|
| Salary (WT 1000) | $178.57 | | $2,142.86 | $2,500 × 1/14 and × 12/14 |
| Federal income tax (WT 5100) | | | −$173.30 | Worksheet 1A Single |
| Social Security (WT 5200) | −$11.07 | | −$132.86 | 6.2% |
| Medicare (WT 5210) | −$2.59 | | −$31.07 | 1.45% |
| NY income tax (WT 5300) | | | −$94.00 | NYS-50-T-NYS |
| NY PFL (WT 5620) | −$0.77 | | −$9.26 | 0.432% |
| Garnishment (WT 5900) | −$98.48 | | −$500.00 | 60% × $164.14; order amount |
| Net pay (WT 6500) | $65.66 | $0.00 | $1,202.37 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC17-US-Linda-FMLA/DEMO-TC17-US-Linda-FMLA.et.json /TestPrecision2
```
