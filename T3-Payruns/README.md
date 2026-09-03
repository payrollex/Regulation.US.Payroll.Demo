# T3 — Payruns & Reports

> **Duration:** ~25 minutes  
> **Role:** Provider / Automator  
> **Prerequisite:** T1 Bootstrap completed

Run all three Apex payrolls, explore payslips, track YTD cap dynamics, and generate
year-end reports (W-2, Form 941, Form 940).

---

## What You Will Learn

- Execute Monthly, Biweekly, and Weekly payruns
- Read payslip structure: gross → deductions → taxes → net → employer side
- Understand mid-year YTD cap events (SS, FUTA, 401k)
- Process a supplemental wage (bonus at flat 22% FIT)
- Apply a retroactive correction
- Generate Form 941, Form 940, and W-2

---

## January Payruns

```bash
# Monthly (executives)
pecmd PayrunStart Apex.Payrun.Monthly /period 2026-01

# Biweekly (professionals) — period Jan 6–19
pecmd PayrunStart Apex.Payrun.Biweekly /period 2026-01-06 2026-01-19

# Weekly (hourly) — week Jan 5–11
pecmd PayrunStart Apex.Payrun.Weekly /period 2026-01-05 2026-01-11
```

---

## YTD Cap Events to Watch

| Month | Event | Employee | Effect |
|:---:|:---|:---|:---|
| Jan–Feb | FUTA cap ($7,000) | All 10 | Employer FUTA → $0 after cap |
| ~Oct | SS cap ($184,500) | Sara Chen, Carlos Rivera | Net pay increases ~$1,212/month |
| Dec | 401k cap ($24,500) | Most employees | Pre-tax deduction stops, FIT taxable rises |
| Dec | 401k cap ($32,500) | Robert Stevenson (age 58) | SECURE 2.0 cap |

---

## Scripts

| Script | Description |
|:---|:---|
| `January.pecmd` | All three payrolls, January 2026 |
| `March-Bonus.pecmd` | Jessica Torres Q1 bonus (supplemental wages) |
| `October.pecmd` | Sara Chen — SS cap month |
| `December.pecmd` | Robert Stevenson — 401k cap month |
| `YearEnd.pecmd` | W-2, Form 941 Q4, Form 940 annual |

---

## Key Reports

```bash
# Individual payslip
pecmd ReportGet Payslip /employee sara.chen@apexdigital.com /period 2026-01

# Form 941 Q1
pecmd ReportGet Form941 /period Q1-2026

# Form 940 annual
pecmd ReportGet Form940 /period 2026

# W-2 Sara Chen
pecmd ReportGet W2 /employee sara.chen@apexdigital.com /period 2026
```

---

> *TODO: full tutorial text — see IMPLEMENTATION.md Phase 3*
