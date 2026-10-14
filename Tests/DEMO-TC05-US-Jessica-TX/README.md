# DEMO-TC05 — Jessica Torres: Texas Baseline (No State Income Tax)

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-12 / 2026-01-25 (paid 2026-01-30)  
**Employee:** Jessica Torres (Account Executive, TX, MFJ)

## Scenario

The simplest payslip in the demo:

- Texas has no state income tax and no employee state insurance program
- Only federal lines: FIT + Social Security + Medicare
- 401(k) 4% and health premium reduce FIT taxable wages; only health reduces FICA
- Direct contrast to Sara (NYC) and Carlos (three-state allocation)

The March bonus (flat 22% federal supplemental rate) is covered by
[DEMO-TC12](../DEMO-TC12-US-Jessica-Bonus/README.md).

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $3,076.92 | $80,000 ÷ 26 |
| FIT taxable wages (WT 5050) | $2,643.84 | − 401(k) $123.08 − health $310 |
| Federal income tax (WT 5100) | −$149.57 | MFJ, 12% bracket |
| Social Security (WT 5200) | −$171.55 | $2,766.92 × 6.2% |
| Medicare (WT 5210) | −$40.12 | $2,766.92 × 1.45% |
| Net pay (WT 6500) | $2,282.60 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC05-US-Jessica-TX/DEMO-TC05-US-Jessica-TX.et.json
```
