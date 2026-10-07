# DEMO-TC03 — Carlos Rivera: Three-State Allocation NY/NJ/CT

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Carlos Rivera (Principal Consultant, NY resident, Single)

## Scenario

Validates multi-state allocation with three work states (`US.StateAllocationCount = 3`):

| Slot | State | Allocation | Allocated wages | Withholding per period |
|:---:|:---|---:|---:|---:|
| 1 | NY (resident + work) | 60% | $4,269.23 | $216.20 |
| 2 | NJ | 25% | $1,778.85 | $74.34 (NJ $45.69 lower than NY → NY applies) |
| 3 | CT | 15% | $1,067.31 | $74.60 (CT higher than NY $35.92 → CT applies) |

- Each slot applies the official period method of its state to the allocated wages:
  NY NYS-50-T-NYS Table II-D biweekly (no IT-2104: single, 0 allowances), NJ-WT rate A
  (no NJ-W4), CT 6.99% (no CT-W4)
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
| Multi-state withholding (WT 5310) | −$365.14 | $216.20 + $74.34 + $74.60 |
| NY PFL (WT 5620) | −$30.74 | $7,115.38 × 0.432% |
| Net pay (WT 6500) | $4,900.80 | |

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC03-US-Carlos-ThreeState/DEMO-TC03-US-Carlos-ThreeState.et.json
```
