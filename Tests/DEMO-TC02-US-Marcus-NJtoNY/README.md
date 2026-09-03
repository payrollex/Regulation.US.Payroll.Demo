# DEMO-TC02 — Marcus Johnson: NJ→NY Split-State Withholding

**Payroll:** Apex.Payroll.Biweekly  
**Period:** 2026-01-06 / 2026-01-19  
**Employee:** Marcus Johnson (Sr. Software Eng., works NY, lives NJ)

## Scenario

Validates automatic split-state withholding for the most common Greater NYC
multi-state pattern — NJ resident commuting to NY with no reciprocity agreement:

- NY work-state withholding (graduated, primary)
- NJ resident withholding (graduated, secondary — WT 5301)
- Both appear on same payslip; NJ gives resident credit at year-end
- No double taxation: effective state burden ≈ max(NY, NJ)

## Key Assertions

| Wage Type | Expected | Notes |
|:---|---:|:---|
| Gross salary (WT 1000) | $5,769.23 | $150k ÷ 26 |
| FIT taxable wages (WT 5050) | $5,223.08 | −401k −health |
| FICA taxable wages (WT 5051) | $5,369.23 | −health only |
| Federal income tax (WT 5100) | ~−$780 | Single, Pub 15-T annualized |
| Social Security (WT 5200) | −$332.89 | $5,369.23 × 6.2% |
| Medicare (WT 5210) | −$77.85 | $5,369.23 × 1.45% |
| NY SIT — work state (WT 5300) | ~−$306 | NYS-50-T graduated |
| NJ SIT — resident (WT 5301) | ~−$180 | NJ graduated on same base |
| Net pay (WT 6500) | ~$3,843 | |

> Values marked `~` are illustrative. Replace with actual PE output after first run.

## Run

```bash
pecmd PayrunEmployeeTest DEMO-TC02-US-Marcus-NJtoNY.et.json
```
