# DEMO-TC07 — David Kim: Philadelphia Weekly (Standard + OT Week)

**Payroll:** Apex.Payroll.Weekly  
**Employee:** David Kim (IT Support Tech, Philadelphia, hourly $32)

## Part A — Standard Week (Period: 2026-01-05 / 2026-01-11)

Validates PA state + Philadelphia Wage Tax with PSD code resolution.
40 regular hours, no overtime.

### Key Assertions — Standard Week

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Regular wages (WT 1000) | $1,280.00 | 40h × $32 |
| Federal income tax (WT 5100) | ~−$95 | Single, weekly annualization ×52 |
| Social Security (WT 5200) | −$79.36 | $1,280 × 6.2% |
| Medicare (WT 5210) | −$18.56 | $1,280 × 1.45% |
| PA SIT (WT 5300) | −$39.30 | $1,280 × 3.07% flat |
| Philadelphia EIT (WT 5400) | −$48.00 | $1,280 × 3.75% (PSD 510101 resident) |
| Net pay (WT 6500) | ~$999 | |

---

## Part B — Overtime Week (Period: 2026-01-12 / 2026-01-18)

47 hours worked (7h FLSA overtime @ 1.5×).

### Key Assertions — OT Week

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Regular wages (WT 1000) | $1,280.00 | 40h × $32 |
| FLSA overtime (WT 1010) | $336.00 | 7h × $48 (1.5×) |
| Gross (WT 5000) | $1,616.00 | |
| PA SIT (WT 5300) | −$49.61 | $1,616 × 3.07% |
| Philadelphia EIT (WT 5400) | −$60.60 | $1,616 × 3.75% |
| Net pay (WT 6500) | ~$1,248 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
# Part A — standard week
pecmd PayrunEmployeeTest DEMO-TC07-US-David-Philadelphia.et.json

# Part B — OT week
pecmd PayrunEmployeeTest DEMO-TC07-US-David-Philadelphia-OT.et.json
```
