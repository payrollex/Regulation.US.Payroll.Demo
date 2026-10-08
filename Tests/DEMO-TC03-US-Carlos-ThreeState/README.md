# DEMO-TC03 — Carlos Rivera: Three-State Allocation NY/NJ/CT

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Carlos Rivera (Principal Consultant, NY resident, Single)

## Scenario

Validates multi-state allocation with three work states (`US.StateAllocationCount = 3`):

Each state withholds by its own rules (lookup `MultiStateRules`):

| State | Share | Rule | Withholding per period |
|:---|---:|:---|---:|
| NJ | 25% | Nonresident: NJ-WT rate A (no NJ-W4) on the NJ wages $1,778.85 | $45.69 |
| CT | 15% | Nonresident: 6.99% (no CT-W4) on all wages $497.37 × 15% | $74.61 |
| NY | 60% | Resident: Table II-D biweekly on all wages $421.18, minus NJ and CT withholding | $300.88 |

- NJ withholds on the wages for services in NJ (NJ-WT p.10); CT prorates the tax on all
  wages by the CT share (IP 2026(1) p.11); NY reduces the resident withholding by the
  withholding of the other states (NYS-50 Sec. 3 part F)
- NY NYS-50-T-NYS Table II-D biweekly (no IT-2104: single, 0 allowances):
  $7,115.38 − $284.60 = $6,830.78 → $372.04 + ($6,830.78 − $6,063) × 6.4% = $421.18
- All states are combined in WT 5310 (WT 5300 stays empty)
- No pre-tax deductions → FIT, FICA and gross wages are equal
- No NYC local tax: no `US.LocalTaxJurisdiction` is set for Carlos
- NY Paid Family Leave on full wages

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Salary (WT 1000) | $7,115.38 | $185,000 ÷ 26 |
| Federal income tax (WT 5100) | −$1,274.38 | Single, 24% bracket |
| Social Security (WT 5200) | −$441.15 | $7,115.38 × 6.2% |
| Medicare (WT 5210) | −$103.17 | $7,115.38 × 1.45% |
| Multi-state withholding (WT 5310) | −$421.18 | $45.69 + $74.61 + $300.88 |
| NY PFL (WT 5620) | −$30.74 | $7,115.38 × 0.432% |
| Net pay (WT 6500) | $4,844.76 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC03-US-Carlos-ThreeState/DEMO-TC03-US-Carlos-ThreeState.et.json
```
