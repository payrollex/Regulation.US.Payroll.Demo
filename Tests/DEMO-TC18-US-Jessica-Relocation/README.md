# DEMO-TC18 — Jessica Torres: Relocation TX → CA

**Payroll:** Apex.Payroll.Biweekly  
**Periods:** 2026-06-15 / 2026-06-28 (paid 2026-07-03), 2026-06-29 / 2026-07-12 (paid 2026-07-17)
and 2026-07-13 / 2026-07-26 (paid 2026-07-31)  
**Employee:** Jessica Torres (Account Executive, MFJ, relocates from Texas to California on 2026-07-01)

## Scenario

Asserts the state change event of [T2-Lifecycle](../../T2-Lifecycle/) (`L4-StateChange-Jessica.json`):

- Work and resident state change from TX to CA on 2026-07-01, entered on 2026-06-25, with a
  CA DE 4 certificate (married, 0 allowances)
- Jun 15–28: the payrun runs on Jul 2, after the change takes effect; the period values apply,
  so the period stays in Texas (no state income tax, no SDI)
- Jun 29–Jul 12: the period contains 2 Texas and 8 California working days
  - CA SDI covers the services localized in California (CUIC §§ 602-603, EDD DE 231D): the
    wages are split by working days, SDI applies to the CA share only
  - CA income tax: Jessica is a California resident at the period end; wages paid to a resident
    are subject to withholding in full (EDD DE 44, Wages Paid to California Residents)
- Jul 13–26: first full California period

## Key Assertions

| Wage Type | Jun 15–28 | Jun 29–Jul 12 | Jul 13–26 | Notes |
|:---|---:|---:|---:|:---|
| Salary (WT 1000) | $3,076.92 | | | $80,000 ÷ 26 |
| FICA taxable wages (WT 5051) | | $2,766.92 | | Salary − health |
| Federal income tax (WT 5100) | −$149.57 | | | Worksheet 1A MFJ |
| Social Security (WT 5200) | −$171.55 | | | 6.2% |
| Medicare (WT 5210) | −$40.12 | | | 1.45% |
| CA income tax (WT 5300) | | −$52.85 | −$52.85 | DE 44 Method B, married |
| CA SDI (WT 5600) | | −$28.78 | −$35.97 | 1.3% × $2,213.54 (8 of 10 working days); 1.3% × $2,766.92 |
| Net pay (WT 6500) | $2,282.60 | $2,200.97 | $2,193.78 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC18-US-Jessica-Relocation/DEMO-TC18-US-Jessica-Relocation.et.json /TestPrecision2
```
