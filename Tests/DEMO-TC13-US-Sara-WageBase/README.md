# DEMO-TC13 — Sara Chen: Social Security Wage Base and Additional Medicare

**Payroll:** Apex.Payroll.Monthly  
**Period:** 2026-01-01 / 2026-11-30 (11 monthly jobs, each paid on the last day of the month)  
**Employee:** Sara Chen (CFO, NY/NYC, MFJ)

## Scenario

Eleven consecutive monthly payruns with the January payslip of
[DEMO-TC01](../DEMO-TC01-US-Sara-Monthly/README.md) ($19,550 FICA wages per month). The year-to-date
values cross three annual limits:

| Month | Limit | Effect |
|:---|:---|:---|
| May | NY PFL maximum $411.91 (0.432% × $95,348.76) | $411.91 − 4 × $84.46 = $74.07, none from June |
| October | Social Security wage base $184,500 | $184,500 − 9 × $19,550 = $8,550 SS wages → $530.10, none from November |
| November | Additional Medicare threshold $200,000 (employer, any filing status) | 0.9% × ($215,050 − $200,000) = $135.45 |

- The Social Security wage base and the Additional Medicare threshold use the year-to-date wages paid
  (WT 5201, WT 5211), not wages derived from the rounded withholding
- The employer Social Security match (WT 6600) stops with the wage base; the employer Medicare
  match (WT 6610) has no Additional Medicare part

## Key Assertions

| Wage Type | April | May | September | October | November |
|:---|---:|---:|---:|---:|---:|
| FICA wages (WT 5051) | $19,550.00 | $19,550.00 | $19,550.00 | $19,550.00 | $19,550.00 |
| SS wages (WT 5201) | $19,550.00 | $19,550.00 | $19,550.00 | $8,550.00 | — |
| Social Security (WT 5200) | −$1,212.10 | −$1,212.10 | −$1,212.10 | −$530.10 | — |
| Medicare wages (WT 5211) | $19,550.00 | $19,550.00 | $19,550.00 | $19,550.00 | $19,550.00 |
| Medicare (WT 5210) | −$283.48 | −$283.48 | −$283.48 | −$283.48 | −$283.48 |
| Additional Medicare (WT 5220) | — | — | — | — | −$135.45 |
| NY PFL (WT 5620) | −$84.46 | −$74.07 | — | — | — |
| Employer SS (WT 6600) | −$1,212.10 | −$1,212.10 | −$1,212.10 | −$530.10 | — |
| Employer Medicare (WT 6610) | −$283.48 | −$283.48 | −$283.48 | −$283.48 | −$283.48 |
| Net pay (WT 6500) | $11,444.03 | $11,454.42 | $11,528.49 | $12,210.49 | $12,605.14 |

A dash means the wage type has no result in that month; it is not asserted.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC13-US-Sara-WageBase/DEMO-TC13-US-Sara-WageBase.et.json
```
