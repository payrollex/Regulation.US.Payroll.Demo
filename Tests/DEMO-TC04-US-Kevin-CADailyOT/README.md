# DEMO-TC04 — Kevin Wu: CA Daily Overtime (Sprint Week)

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Kevin Wu (Cloud Architect, CA, hourly $60, Single)

## Scenario

Validates CA Labor Code §510 daily overtime. Kevin works a sprint week followed by a
standard week:

| Day (sprint week) | Hours | Daily OT (> 8h) |
|:---|---:|---:|
| Mon | 9 | 1 |
| Tue | 9 | 1 |
| Wed | 8 | — |
| Thu | 9 | 1 |
| Fri | 8 | — |

- Case fields: `US.CADay1Hours`–`US.CADay5Hours` = 9 / 9 / 8 / 9 / 8, `US.RegularHours` = 80
  (straight time of both weeks)
- No federal `US.OvertimeHours` is entered — WT 1020 comes from the CA path only
- Daily OT: 3h × $60 × 1.5 = $270; the 3 weekly OT hours (43h) are already covered by the daily premium
- CA SDI 1.3% on SDI wages without a wage cap (SB 951)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Hourly wages (WT 1010) | $4,800.00 | 80h × $60 |
| Overtime (WT 1020) | $270.00 | CA daily OT 3h × $90 |
| Gross (WT 5000) | $5,070.00 | |
| FIT taxable wages (WT 5050) | $4,596.50 | − 401(k) $253.50 − health $220 |
| FICA taxable wages (WT 5051) | $4,850.00 | − health $220 |
| Federal income tax (WT 5100) | −$671.61 | Single, annualized ×26 |
| Social Security (WT 5200) | −$300.70 | $4,850 × 6.2% |
| Medicare (WT 5210) | −$70.33 | $4,850 × 1.45% |
| CA SIT (WT 5300) | −$297.10 | EDD Method B annualized, no DE 4 (single, 0 allowances): ($4,596.50 × 26 − $5,706) → $7,724.55 ÷ 26 |
| CA SDI (WT 5600) | −$63.05 | $4,850 × 1.3%, no wage cap |
| Net pay (WT 6500) | $3,193.71 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC04-US-Kevin-CADailyOT/DEMO-TC04-US-Kevin-CADailyOT.et.json
```
