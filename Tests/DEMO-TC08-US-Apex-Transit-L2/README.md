# DEMO-TC08 — L2 §132 Transit Benefit (T4-Customizing)

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-02-03 / 2026-02-16  
**Employee:** Carlos Rivera (Principal Consultant — used as L2 benefit reference)

## Prerequisites

- Tutorial T4-Customizing must be completed first
- L2 regulation `Apex.Benefits` imported and attached to `Apex.Payroll.Biweekly`
- `Apex.TransitBenefit` company case set to `$300/period`
- Carlos opted in: `Apex.TransitBenefitOptIn = true`

## Scenario

Validates that the L2 `§132TransitBenefit` wage type (WT 2010):

- Reduces FIT taxable wages by $300 (pre-tax transit, IRS §132(f))
- Reduces FICA taxable wages by $300 (transit benefit is also FICA-exempt)
- Does **not** reduce gross wages (benefit shown as a separate deduction line)
- Amount is capped at the IRS 2026 monthly limit ($325/month ≈ $150/biweekly)

> Note: IRS monthly limit $325 → biweekly equivalent ≈ $300 (within the limit).

## Key Assertions

| Wage Type | Expected (without L2) | Expected (with L2) | Delta |
|:---|---:|---:|---:|
| Gross salary (WT 1000) | $7,115.38 | $7,115.38 | — |
| Transit benefit (WT 2010) | $0.00 | −$300.00 | −$300 |
| FIT taxable wages (WT 5050) | $7,115.38 | $6,815.38 | −$300 |
| FICA taxable wages (WT 5051) | $7,115.38 | $6,815.38 | −$300 |
| Federal income tax (WT 5100) | ~−$1,250 | ~−$1,154 | ~+$96 |
| Social Security (WT 5200) | −$441.15 | ~−$422.55 | ~+$18.60 |

> Values marked `~` are illustrative. Replace with actual PE output after first run.  
> The "without L2" column uses T1-Bootstrap setup (no transit benefit).

## Run

```bash
# Requires T4-Customizing completed
pecmd PayrunEmployeeTest DEMO-TC08-US-Apex-Transit-L2.et.json
```
