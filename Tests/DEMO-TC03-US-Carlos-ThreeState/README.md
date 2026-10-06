# DEMO-TC03 — Carlos Rivera: Three-State Allocation NY/NJ/CT

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Carlos Rivera (Principal Consultant, NY resident, Single)

## Scenario

Validates multi-state allocation with three work states (`US.StateAllocationCount = 3`):

| Slot | State | Allocation | Annual allocated | Withholding per period |
|:---:|:---|---:|---:|---:|
| 1 | NY (resident + work) | 60% | $111,000 | $213.49 |
| 2 | NJ | 25% | $46,250 | $72.28 (NY tax on the slot, NJ tax credited) |
| 3 | CT | 15% | $27,750 | $38.41 (CT tax higher than NY → CT applies) |

- All three slots are combined in WT 5310 (WT 5300 stays empty)
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
| Multi-state withholding (WT 5310) | −$324.18 | $213.49 + $72.28 + $38.41 |
| NY PFL (WT 5620) | −$30.74 | $7,115.38 × 0.432% |
| Net pay (WT 6500) | $4,941.76 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC03-US-Carlos-ThreeState/DEMO-TC03-US-Carlos-ThreeState.et.json
```
