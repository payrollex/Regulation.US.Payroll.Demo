# Apex Digital Solutions — Payroll Architecture

## Tenant Structure

```
Tenant: Apex.DigitalSolutions
│
├── Division: Apex.Division.Monthly
│   ├── Payroll: Apex.Payroll.Monthly  (annualization factor 12)
│   └── Employees: Sara Chen, Robert Stevenson
│
├── Division: Apex.Division.Biweekly
│   ├── Payroll: Apex.Payroll.Biweekly  (annualization factor 26)
│   └── Employees: Marcus Johnson, Priya Patel, Kevin Wu,
│                  Jessica Torres, Carlos Rivera, Linda Okafor
│
└── Division: Apex.Division.Weekly
    ├── Payroll: Apex.Payroll.Weekly  (annualization factor 52)
    └── Employees: David Kim, Ashley Park
```

### Why One Division per Pay Frequency?

`US.PayFrequency` is stored as a **company-level case value** at the division.
In Payroll Engine, all employees in the same payroll share the same company case
values within a division. A single division cannot hold two different
`US.PayFrequency` values simultaneously.

The IRS Pub 15-T annualization factor (12 / 26 / 52) is read from this field
and applied to every FIT, SIT, and HoH bracket calculation. Wrong frequency →
wrong withholding for all employees in that payroll.

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
Payroll Engine separates the regulatory owner (LeddraPay/provider) from the
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
| 1100 | SupplementalWages | GrossWages | Bonus / commission — 22% flat FIT (WT 1110) |
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
| Feb | FUTA $7k cap reached | All low earners | WT 6700 → $0 |
| Sep / Oct | SS wage base $184,500 | Sara, Carlos | WT 5200 → partial then $0 |
| Sep | Additional Medicare triggers | Sara ($250k MFJ threshold) | WT 5220 → active |
| Dec | 401k annual cap | Robert ($32,500 incl. age-50+) | WT 1200 → near cap |
