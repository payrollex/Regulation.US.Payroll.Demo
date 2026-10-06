# DEMO-TC08 — L2 §132(f) Transit Benefit (T4-Customizing)

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-02-03 / 2026-02-16  
**Employee:** Carlos Rivera (Principal Consultant, NY, Single — three-state allocation as in TC03)

## Prerequisites

- Tutorial T4-Customizing completed: L2 regulation `Apex.Payroll` attached to all Apex payrolls
- Data regulation `US.Payroll.Data.Federal.Tax` with lookup key `TransitMonthlyLimit`

## Scenario

Validates a company-specific benefit added by the L2 regulation without modifying US.Payroll:

- Carlos elects **$400 per month** (`Apex.TransitBenefitMonthly`)
- IRC §132(f) monthly limit 2026: **$340** (lookup `US.FederalTaxParameters`, key `TransitMonthlyLimit`)
- Pre-tax part (WT 1250): $340 × 12 / 26 = $156.92 — reduces FIT and FICA taxable wages
  through the WT 1250 extensibility slot of US.Payroll
- Excess (WT 5520): $60 × 12 / 26 = $27.69 — taxable, withheld after tax
- WT 5520 is numbered below NetPay (WT 6500), so the deduction is included in net pay
- State withholding is unchanged: US.Payroll does not model state conformity for WT 1250

## Key Assertions

| Wage Type | Without transit (TC03) | With transit | Notes |
|:---|---:|---:|:---|
| Salary (WT 1000) | $7,115.38 | $7,115.38 | |
| Transit pre-tax (WT 1250) | — | −$156.92 | $340 × 12 / 26 |
| FIT taxable wages (WT 5050) | $7,115.38 | $6,958.46 | − $156.92 |
| FICA taxable wages (WT 5051) | $7,115.38 | $6,958.46 | − $156.92 |
| Federal income tax (WT 5100) | −$1,274.38 | −$1,236.72 | 24% × $156.92 saved |
| Social Security (WT 5200) | −$441.15 | −$431.42 | |
| Medicare (WT 5210) | −$103.17 | −$100.90 | |
| Multi-state withholding (WT 5310) | −$324.18 | −$324.18 | unchanged |
| Transit excess post-tax (WT 5520) | — | −$27.69 | $60 × 12 / 26 |
| NY PFL (WT 5620) | −$30.74 | −$30.06 | |
| Net pay (WT 6500) | $4,941.76 | $4,807.49 | |

## Run

```bash
# Requires T4-Customizing completed
pecmd PayrunEmployeeTest DEMO-TC08-US-Apex-Transit-L2/DEMO-TC08-US-Apex-Transit-L2.et.json
```
