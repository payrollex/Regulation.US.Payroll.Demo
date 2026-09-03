# DEMO-TC05 — Jessica Torres: Texas No-SIT + Supplemental Bonus

**Payroll:** Apex.Payroll.Biweekly  
**Employee:** Jessica Torres (Account Executive, TX, MFJ)

## Part A — Standard Biweekly (Period: 2026-01-06 / 2026-01-19)

Validates the simplest payslip in the demo: Texas has no state income tax.
Only 2 tax lines: FIT + FICA. Direct contrast to Sara (NYC, 6 lines) and Carlos (4 state lines).

### Key Assertions — Standard Period

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $3,076.92 | $80k ÷ 26 |
| FIT taxable wages (WT 5050) | $2,643.84 | −401k −health (family) |
| Federal income tax (WT 5100) | ~−$117 | MFJ, low bracket |
| Social Security (WT 5200) | −$190.77 | |
| Medicare (WT 5210) | −$44.62 | |
| TX SIT (WT 5300) | **$0.00** | Texas has no state income tax |
| Net pay (WT 6500) | ~$2,525 | |

---

## Part B — Q1 Supplemental Bonus (Period: 2026-03-03 / 2026-03-16)

Validates supplemental wage withholding at the flat 22% federal rate (IRS Pub 15-T).
The bonus uses a completely different calculation path than the regular paycheck.

### Key Assertions — Bonus Period

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Supplemental wages (WT 1100) | $10,000.00 | Q1 performance bonus |
| FIT on supplemental (WT 5101) | −$2,200.00 | **Flat 22%** — not graduated |
| Social Security (WT 5200) | −$620.00 | $10,000 × 6.2% |
| Medicare (WT 5210) | −$145.00 | $10,000 × 1.45% |
| TX SIT | $0.00 | |
| Net bonus after tax | $7,035.00 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
# Part A — standard
pecmd PayrunEmployeeTest DEMO-TC05-US-Jessica-TX.et.json

# Part B — supplemental (run separately in March period)
pecmd PayrunEmployeeTest DEMO-TC05-US-Jessica-TX-Bonus.et.json
```
