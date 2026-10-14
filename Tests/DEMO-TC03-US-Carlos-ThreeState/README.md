# DEMO-TC03 — Carlos Rivera: Three-State Allocation NY/NJ/CT

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-12 / 2026-01-25 (paid 2026-01-30)  
**Employee:** Carlos Rivera (Principal Consultant, NY resident, Single)

## Scenario

Validates multi-state allocation with three work states (`US.StateAllocationCount = 3`):

Each state withholds by its own rules (lookup `MultiStateRules`):

| State | Share | Rule | Withholding per period |
|:---|---:|:---|---:|
| NJ | 25% | Nonresident: NJ-W4 single → NJ-WT rate A on the NJ wages $1,778.85 | $45.69 |
| CT | 15% | Nonresident: CT-W4 code F, TPG-211 annualized on all wages $398.08 × 15% | $59.71 |
| NY | 60% | Resident: IT-2104 single, Table II-D biweekly on all wages $421.18, minus NJ and CT withholding | $315.78 |

- NJ withholds on the wages for services in NJ (NJ-WT p.10); CT prorates the tax on all
  wages by the CT share (IP 2026(1) p.11); NY reduces the resident withholding by the
  withholding of the other states (NYS-50 Sec. 3 part F)
- CT TPG-211 code F: $7,115.38 × 26 = $184,999.88, exemption $0, tax $4,750 + 6% × ($184,999.88 − $100,000)
  = $9,849.99, phase-out add-back $250, recapture $250, credit 0% → $10,349.99 ÷ 26 = $398.08
- NY NYS-50-T-NYS Table II-D biweekly (IT-2104 single, 0 allowances):
  $7,115.38 − $284.60 = $6,830.78 → $372.04 + ($6,830.78 − $6,063) × 6.4% = $421.18
- The WT 5310 total does not depend on the CT amount as long as the NY resident tax covers NJ and CT:
  NY withholds the remainder
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
| Multi-state withholding (WT 5310) | −$421.18 | $45.69 + $59.71 + $315.78 |
| NY PFL (WT 5620) | −$30.74 | $7,115.38 × 0.432% |
| Net pay (WT 6500) | $4,844.76 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC03-US-Carlos-ThreeState/DEMO-TC03-US-Carlos-ThreeState.et.json
```
