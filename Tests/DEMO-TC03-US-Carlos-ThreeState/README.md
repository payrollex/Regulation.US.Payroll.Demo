# DEMO-TC03 — Carlos Rivera: Three-State Allocation

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Carlos Rivera (Principal Consultant, NY resident, works NY/NJ/CT)

## Scenario

Flagship multi-state scenario: `US.StateAllocationCount = 3` activates WT 5310
(`MultiStateWithholding`) instead of WT 5300. Four state/local tax lines on one payslip:

- NY SIT on 60% share (primary work state + resident state)
- NJ SIT on 25% share
- CT SIT on 15% share
- NYC local on 60% NY allocation only

Allocation case: `US.AllocationPercent1=60 / WorkState2=NJ / AllocationPercent2=25 / WorkState3=CT / AllocationPercent3=15`

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $7,115.38 | $185k ÷ 26 |
| Multi-state withholding NY (WT 5310 slot 1) | ~−$370 | 60% × $185k graduated |
| Multi-state withholding NJ (WT 5310 slot 2) | ~−$95 | 25% × $185k graduated |
| Multi-state withholding CT (WT 5310 slot 3) | ~−$76 | 15% × $185k, 6.99% flat |
| NYC local (WT 5400) | ~−$200 | On NY-allocated share only |
| Federal income tax (WT 5100) | ~−$1,250 | Single, 32% bracket approaching |
| Social Security (WT 5200) | −$441.15 | |
| Medicare (WT 5210) | −$103.17 | |
| Net pay (WT 6500) | ~$4,480 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC03-US-Carlos-ThreeState.et.json
```
