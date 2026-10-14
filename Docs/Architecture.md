# Apex Digital Solutions — Payroll Architecture

## Tenant Structure

```
Tenant: Apex.DigitalSolutions
│
├── Division: Apex.Division.Monthly   (calendar Apex.Monthly, 12 periods)
│   ├── Payroll: Apex.Payroll.Monthly
│   └── Employees: Sara Chen, Robert Stevenson
│
├── Division: Apex.Division.Biweekly  (calendar Apex.Biweekly, 26 periods)
│   ├── Payroll: Apex.Payroll.Biweekly
│   └── Employees: Marcus Johnson, Priya Patel, Kevin Wu,
│                  Jessica Torres, Carlos Rivera, Linda Okafor
│
└── Division: Apex.Division.Weekly    (calendar Apex.Weekly, 52 periods)
    ├── Payroll: Apex.Payroll.Weekly
    └── Employees: David Kim, Ashley Park
```

### Why One Division per Pay Frequency?

The pay frequency is the period of the payroll calendar, and the calendar is assigned
to the division. US.Payroll derives the IRS Pub 15-T pay frequency (Table 3 periods per
year: 12 / 26 / 52) from the calendar period and applies it to every federal, state and
local withholding calculation. One division per calendar keeps the three frequencies
apart in one tenant.

| Calendar | Period | Pay date |
|:---|:---|:---|
| `Apex.Monthly` | Calendar month | Period end (last day of the month) |
| `Apex.Biweekly` | Two weeks from Monday (first demo period Jan 12 – Jan 25) | Period end + 5 days (Friday) |
| `Apex.Weekly` | Week from Monday (first demo period Jan 5 – Jan 11) | Period end + 5 days (Friday) |

Payrun results belong to the year of the pay date (`cycleAssignment: PayDate`).

---

## Regulation Layer Model

Each of the three payrolls uses the same six L1 regulation layers plus one
optional L2 (added by T4-Customizing):

```
Priority │ Level │ Regulation
─────────┼───────┼──────────────────────────────────────────
       1 │  L1   │ US.Payroll               (core engine)
       7 │  L1   │ US.Payroll.Data.Federal.Tax   (FIT brackets, std deductions)
       8 │  L1   │ US.Payroll.Data.Federal.FICA  (SS/Medicare rates, wage bases)
       9 │  L1   │ US.Payroll.Data.State         (SIT brackets, SDI rates)
      10 │  L1   │ US.Payroll.Data.Local.Tax     (local EIT rates, PSD codes)
      11 │  L1   │ US.Payroll.Data.Federal.Garnishment  (CCPA limits)
     100 │  L2   │ Apex.Payroll              (company-specific benefits — T4)
```

Higher priority overrides lower priority for the same wage type or case field.
The L2 regulation (`Apex.Payroll`) wins over any L1 definition for WT 1250/1260.

### Shared Regulations

The six L1 data regulations live in the **US.Payroll** tenant (the provider tenant)
and are shared with `Apex.DigitalSolutions` via `RegulationShare`. This is how
Payroll Engine separates the regulatory owner (provider) from the
employer tenant (Apex) without copying data.

```
US.Payroll tenant  ─── RegulationShare ───►  Apex.DigitalSolutions tenant
 US.Payroll                                    Apex.Payroll.Monthly
 US.Payroll.Data.Federal.Tax                   Apex.Payroll.Biweekly
 US.Payroll.Data.Federal.FICA                  Apex.Payroll.Weekly
 US.Payroll.Data.State
 US.Payroll.Data.Local.Tax
 US.Payroll.Data.Federal.Garnishment
```

---

## Key Wage Types

| WT | Name | Collector | Notes |
|---:|:---|:---|:---|
| 1000 | Salary | GrossWages | Salaried employees |
| 1010 | HourlyWage | GrossWages | Hourly employees (Kevin, David, Ashley) |
| 1020 | Overtime | GrossWages | FLSA 1.5× weekly OT, or CA daily OT (Kevin) |
| 1100 | SupplementalWages | GrossWages | Bonus / commission — supplemental FIT in WT 5120 |
| 1200 | Pre401k | EmployeeDeductions | Pre-tax 401(k) — reduces FIT/SIT, not FICA |
| 1210 | PreHealth | EmployeeDeductions | §125 health — reduces FIT, SIT and FICA |
| 1220 | PreHSA | EmployeeDeductions | §223 HSA — reduces FIT, SIT and FICA |
| 1250 | Apex.PreTransitBenefit | EmployeeDeductions | §132(f) transit up to the monthly limit — L2 only (T4) |
| 1260 | Apex.WFHStipend | GrossWages | Taxable stipend — L2 only (T4) |
| 1320 | CompanyCar | GrossWages + ImputedIncome | §61 imputed income — taxed, not paid out (Sara) |
| 5050 | FitTaxableWages | — | Base for FIT |
| 5051 | FicaTaxableWages | — | Base for Social Security / Medicare |
| 5100 | FitWithholding | EmployeeDeductions | Pub 15-T percentage method |
| 5110 | FitAdditionalWithholding | EmployeeDeductions | W-4 Step 4(c) extra withholding |
| 5120 | FitSupplementalWithholding | EmployeeDeductions | Pub 15 section 7: 22% optional flat rate, 37% above $1 million |
| 5200 | SsWithholding | EmployeeDeductions | 6.2% up to the wage base ($184,500 in 2026) |
| 5210 | MedicareWithholding | EmployeeDeductions | 1.45%, no cap |
| 5220 | AdditionalMedicareWithholding | EmployeeDeductions | 0.9% above $200,000 YTD (employer threshold) |
| 5300 | StateWithholding | EmployeeDeductions | Single-state employees |
| 5310 | MultiStateWithholding | EmployeeDeductions | Multi-state (Marcus, Priya, Carlos) |
| 5400 | LocalTaxWithholding | EmployeeDeductions | NYC (Sara), Philadelphia Wage Tax (David) |
| 5520 | Apex.TransitExcessPostTax | EmployeeDeductions | Transit election above the §132(f) limit — L2 only (T4) |
| 5600 | StateSDI | EmployeeDeductions | CA SDI 1.3%, no wage cap (Kevin, Ashley) |
| 5620 | StatePFL | EmployeeDeductions | NY Paid Family Leave 0.432% |
| 5630 | PAEmployeeUC | EmployeeDeductions | PA employee UC 0.07% (David) |
| 5900 | Garnishment | EmployeeDeductions | Child support, CCPA-limited (Linda) |
| 6500 | NetPay | — | Gross − imputed income − employee deductions |
| 6600 / 6610 | SsWithholdingER / MedicareWithholdingER | EmployerCosts | Employer FICA |
| 6700 / 6710 | FUTA / SUI | EmployerCosts | FUTA 0.6% on first $7,000; SUI state rate and wage base |

All employee deductions are numbered below NetPay (WT 6500): a collector only contains the
wage types processed before the wage type that reads it.

---

## Tax Jurisdiction Resolution

| Employee | WorkState | ResidentState | FIT path | SIT / local / state programs |
|:---|:---|:---|:---|:---|
| Sara | NY | NY | WT 5050 → 5100/5110 | WT 5300 (NY) + 5400 (NYC) + 5620 (NY PFL) |
| Robert | NY | NY | WT 5050 → 5100 | WT 5300 (NY) + 5620 (NY PFL) |
| Marcus | NY | NJ | WT 5050 → 5100 | WT 5310 (NY work + NJ resident, no reciprocity) + 5620 |
| Priya | NY | CT | WT 5050 → 5100 | WT 5310 (NY work + CT resident, no reciprocity) + 5620 |
| Kevin | CA | CA | WT 5050 → 5100 | WT 5300 (CA) + 5600 (CA SDI) |
| Jessica | TX | TX | WT 5050 → 5100 | none (TX has no SIT) |
| Carlos | NY | NY | WT 5050 → 5100 | WT 5310 (NY 60% / NJ 25% / CT 15%) + 5620 |
| Linda | NY | NY | WT 5050 → 5100 | WT 5300 (NY) + 5620; no NYC tax (no `LocalTaxJurisdiction`) |
| David | PA | PA | WT 5050 → 5100 | WT 5300 (PA) + 5400 (Philadelphia 3.74%) + 5630 (PA UC) |
| Ashley | CA | CA | WT 5050 → 5100 | WT 5300 (CA) + 5600 (CA SDI) |

---
## YTD Cap Timeline (2026)

| Month | Event | Employee | Wage Type |
|:---|:---|:---|:---|
| Jan / Feb | FUTA $7,000 wage base reached | All | WT 6700 → $0 |
| May | NY PFL maximum $411.91 | Sara | WT 5620 → remainder, then $0 |
| Oct | SS wage base $184,500 | Sara | WT 5200 → $530.10, then $0 |
| Nov | Additional Medicare above $200,000 YTD | Sara | WT 5220 → active |
| Nov | NY PFL maximum $411.91 | Robert | WT 5620 → remainder, then $0 |
| Dec | 401(k) limit $32,500 incl. age-50 catch-up | Robert | WT 1200 → $1,700 |

Asserted by [DEMO-TC13](../Tests/DEMO-TC13-US-Sara-WageBase/) and
[DEMO-TC14](../Tests/DEMO-TC14-US-Robert-401kLimit/).
