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
| 1000 | GrossSalary | GrossWages | Salaried employees only |
| 1010 | HourlyWages | GrossWages | Hourly employees (Kevin, David, Ashley) |
| 1020 | OvertimeWages | GrossWages | FLSA 1.5× OT; or CA daily OT |
| 1100 | SupplementalWages | GrossWages | Bonus / commission — 22% flat FIT |
| 1200 | Pre401k | EmployeeDeductions | Pre-tax 401k — reduces FIT/SIT, not FICA |
| 1210 | PreHealth | EmployeeDeductions | §125 health — reduces FIT and FICA |
| 1220 | PreHSA | EmployeeDeductions | §223 HSA — reduces FIT and FICA |
| 1250 | PreTransitBenefit | EmployeeDeductions | §132(f) transit — L2 only (T4) |
| 1260 | WFHStipend | GrossWages | Taxable stipend — L2 only (T4) |
| 1310 | CompanyCarFringe | GrossWages | §61 imputed income — taxable |
| 5050 | FITTaxable | — | Base for FIT calculation |
| 5051 | FICATaxable | — | Base for SS/Medicare calculation |
| 5100 | FIT | FederalTax | Graduated withholding per IRS Pub 15-T |
| 5110 | AdditionalFIT | FederalTax | W-4 Step 4c extra withholding |
| 5200 | SocialSecurity | FederalTax | 6.2% up to SS wage base ($184,500 in 2026) |
| 5210 | Medicare | FederalTax | 1.45% uncapped |
| 5220 | AdditionalMedicare | FederalTax | 0.9% above $200k/$250k YTD threshold |
| 5300 | StateWithholding | StateTax | Single-state employees |
| 5310 | MultiStateWithholding | StateTax | Multi-state (Carlos, Marcus, Priya) |
| 5400 | LocalTaxWithholding | LocalTax | NYC, Philadelphia EIT |
| 6500 | NetPay | NetPay | Gross − all deductions |
| 6505 | Garnishment | Garnishments | Linda — child support, CCPA-limited |
| 6700 | FUTA | EmployerTax | 0.6% net on first $7,000/employee |
| 6800 | SDI | StateTax | CA/NJ state disability insurance |

---

## Tax Jurisdiction Resolution

| Employee | WorkState | ResidentState | FIT path | SIT path |
|:---|:---|:---|:---|:---|
| Sara | NY | NY | WT 5050 → 5100/5110 | WT 5300 (NY) + 5400 (NYC) |
| Robert | NY | NY | WT 5050 → 5100 | WT 5300 (NY) |
| Marcus | NY | NJ | WT 5050 → 5100 | WT 5310 (NY work + NJ resident, no reciprocity) |
| Priya | NY | CT | WT 5050 → 5100 | WT 5310 (NY work + CT resident, no reciprocity) |
| Kevin | CA | CA | WT 5050 → 5100 | WT 5300 (CA) + WT 6800 (SDI) |
| Jessica | TX | TX | WT 5050 → 5100 | WT 5300 = null (TX no SIT) |
| Carlos | NY | NY | WT 5050 → 5100 | WT 5310 (NY 60% / NJ 25% / CT 15%) |
| Linda | NY | NY | WT 5050 → 5100 | WT 5300 (NY) + 5400 (NYC) |
| David | PA | PA | WT 5050 → 5100 | WT 5300 (PA) + 5400 (Philadelphia EIT 3.74%) |
| Ashley | CA | CA | WT 5050 → 5100 | WT 5300 (CA) + WT 6800 (SDI) |

---

## YTD Cap Timeline (2026)

| Month | Event | Employee | Wage Type |
|:---|:---|:---|:---|
| Feb | FUTA $7k cap reached | All low earners | WT 6700 → $0 |
| Sep / Oct | SS wage base $184,500 | Sara, Carlos | WT 5200 → partial then $0 |
| Sep | Additional Medicare triggers | Sara ($250k MFJ threshold) | WT 5220 → active |
| Dec | 401k annual cap | Robert ($32,500 incl. age-50+) | WT 1200 → near cap |
