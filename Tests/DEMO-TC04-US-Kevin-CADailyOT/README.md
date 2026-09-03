# DEMO-TC04 — Kevin Wu: CA Daily Overtime (Sprint Week)

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Kevin Wu (Cloud Architect, CA remote, hourly $60)

## Scenario

Validates CA Labor Code §510 daily overtime calculation:

- Mon: 9h → 1h daily OT @ $90 (1.5×)
- Tue: 9h → 1h daily OT @ $90
- Thu: 9h → 1h daily OT @ $90
- Week 2: 40h standard (no OT trigger)
- CA SDI (1.3%, uncapped per SB 951) applied on full gross
- No 7th-day trigger in this period (5-day weeks)

Case fields set for this period:
`CADay1Hours=9, CADay2Hours=9, CADay3Hours=8, CADay4Hours=9, CADay5Hours=8`

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Regular wages (WT 1000) | $4,800.00 | 80h × $60 |
| CA daily overtime (WT 1020) | $270.00 | 3h × $90 (1.5×) |
| Gross (WT 5000) | $5,070.00 | |
| FIT taxable wages (WT 5050) | $4,596.50 | −401k −health |
| CA SIT (WT 5300) | ~−$280 | EDD DE44 Method B |
| CA SDI (WT 5410) | −$65.91 | $5,070 × 1.3% — **no wage base cap** |
| Net pay (WT 6500) | ~$3,335 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC04-US-Kevin-CADailyOT.et.json
```
