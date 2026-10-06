# T1 — Bootstrap a Company

Bootstrap **Apex Digital Solutions LLC** from zero to first payrun in under 20 minutes.

---

## What You Will Build

```
Tenant: Apex.DigitalSolutions
├── User: apex.admin@apexdigital.com (TenantAdministrator)
├── Division: Apex.Division.Monthly   → Payroll: Apex.Payroll.Monthly   [Sara, Robert]
├── Division: Apex.Division.Biweekly  → Payroll: Apex.Payroll.Biweekly  [Marcus, Priya, Kevin, Jessica, Carlos, Linda]
└── Division: Apex.Division.Weekly    → Payroll: Apex.Payroll.Weekly    [David, Ashley]
```

Three payrolls, one tenant, one EIN — this is how PE models multiple pay frequencies
for a single legal entity. Each payroll has its own division because `US.PayFrequency`
is a division-level case value and must be unique per division.

---

## Prerequisites

- Payroll Engine backend running (see [payrollengine.org](https://payrollengine.org))
- `pecmd` configured with your backend URL
- US.Payroll regulation packages imported (see note below)

### Regulation Packages

The US regulation packages must be imported once per PE instance. They are distributed
separately (commercial). If your PE instance already has them, skip this step.

```bash
PayrollImport US.Payroll.2026.json
PayrollImport US.Payroll.Data.Federal.Tax.2026.json
PayrollImport US.Payroll.Data.Federal.FICA.2026.json
PayrollImport US.Payroll.Data.State.2026.json
PayrollImport US.Payroll.Data.Local.Tax.2026.json
PayrollImport US.Payroll.Data.Federal.Garnishment.2026.json
```

---

## Quick Run

```bash
cd T1-Bootstrap
pecmd Bootstrap.pecmd
```

Done. Apex Digital Solutions is ready.

---

## Step-by-Step Walkthrough

### Step 1 — Tenant Structure (`Setup.json`)

Creates the full tenant scaffolding in one Exchange file:

| Object | What it creates |
|:---|:---|
| Tenant | `Apex.DigitalSolutions` (en-US) |
| User | `apex.admin@apexdigital.com` (TenantAdministrator) |
| Division | `Apex.Division` |
| Employees | 10 employees (no case data yet — just identity records) |
| Payrolls | `Apex.Payroll.Monthly` · `Apex.Payroll.Biweekly` · `Apex.Payroll.Weekly` |
| Regulation layers | Same 6 layers on all 3 payrolls (L1, priority 1–11) |
| Payruns | One payrun per payroll |

```bash
pecmd PayrollImport Setup.json
```

#### Why Three Payrolls?

`US.PayFrequency` is a **company-level** case value — it cannot differ between employees
in the same payroll. Three payrolls = three different IRS Pub 15-T annualization factors
(12 · 26 · 52). Same EIN, same regulation layers, same tenant.

---

### Step 2 — Company Cases (`CompanyCases/`)

Each payroll needs its own `US.Company` case with the pay frequency set:

| File | PayFrequency | Factor |
|:---|:---|:---:|
| `CompanyCases/Monthly.json` | `Monthly` | 12 |
| `CompanyCases/Biweekly.json` | `BiWeekly` | 26 |
| `CompanyCases/Weekly.json` | `Weekly` | 52 |

All three share: EIN `27-1234567`, CompanyState `NY`, SUIRate `2.1%`, FUTACreditReductionState `false`.

```bash
pecmd PayrollImport CompanyCases/Monthly.json
pecmd PayrollImport CompanyCases/Biweekly.json
pecmd PayrollImport CompanyCases/Weekly.json
```

---

### Step 3 — Employee Cases (`Employees/`)

Each file sets all required cases for one employee. Cases are submitted in this order:

1. `US.PersonalData` — SSN, DateOfBirth
2. `US.Employment` — HireDate, WorkState, ResidentState, WorkLocality (if NYC)
3. `US.Remuneration` — PayType (`Salary` / `Hourly`), AnnualSalary or HourlyRate
4. `US.TaxData` — FilingStatus, W-4 fields, local tax jurisdiction (PA)
5. `US.PreTaxDeductions` — 401k, health, HSA
6. Optional: `US.BenefitsInKind`, `US.MultiStateEmployment`, `US.Garnishment`

#### Employee Overview

| File | Employee | Payroll | Key cases |
|:---|:---|:---|:---|
| `01-SaraChen.json` | Sara Chen | Monthly | PersonalData · Employment(NYC) · Remuneration($240k) · TaxData(MFJ W4Step3=$4k W4Step4c=$500 LocalJurisdiction=NY-NYC) · PreTax(401k8% H$600 HSA$300) · BenefitsInKind(Car$450) |
| `02-RobertStevenson.json` | Robert Stevenson | Monthly | PersonalData(DOB 1967) · Employment(NY) · Remuneration($115k) · TaxData(MFJ W4Step3=$2k) · PreTax(401k$2708.33/mo H$475) |
| `03-MarcusJohnson.json` | Marcus Johnson | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=NJ) · Remuneration($150k) · TaxData(Single) · PreTax(401k6% H$200) |
| `04-PriyaPatel.json` | Priya Patel | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=CT) · Remuneration($95k) · TaxData(HoH W4Step3=$2k) · PreTax(401k4% H$180) |
| `05-KevinWu.json` | Kevin Wu | Biweekly | PersonalData · Employment(CA) · Remuneration(Hourly $60/hr 80hrs) · TaxData(Single) · PreTax(401kAmount$240 H$220) |
| `06-JessicaTorres.json` | Jessica Torres | Biweekly | PersonalData · Employment(TX) · Remuneration($80k) · TaxData(MFJ) · PreTax(401k4% H$310 family) |
| `07-CarlosRivera.json` | Carlos Rivera | Biweekly | PersonalData · Employment(NY/NYC) · Remuneration($185k) · TaxData(Single) · MultiStateEmployment(NY60%/NJ25%/CT15%) |
| `08-LindaOkafor.json` | Linda Okafor | Biweekly | PersonalData · Employment(NYC) · Remuneration($65k) · TaxData(Single) · Garnishment(ChildSupport $500/period) |
| `09-DavidKim.json` | David Kim | Weekly | PersonalData · Employment(PA) · Remuneration(Hourly $32/hr) · TaxData(Single PA-Philadelphia PSD=510101) |
| `10-AshleyPark.json` | Ashley Park | Weekly | PersonalData · Employment(CA) · Remuneration(Hourly $42/hr) · TaxData(Single) |

```bash
pecmd PayrollImport Employees/01-SaraChen.json
# ... (or run Bootstrap.pecmd for all at once)
```

---

## Validation

After Bootstrap, verify the setup:

```bash
# Preview payruns (no payrun created yet — just validates setup)
pecmd PayrunPreviewTest Tests/DEMO-TC01-US-Sara-Monthly/DEMO-TC01-US-Sara-Monthly.et.json
```

Expected results:
- Monthly preview: 2 employees (Sara, Robert), no errors
- Biweekly preview: 6 employees (Marcus, Priya, Kevin, Jessica, Carlos, Linda), no errors
- Weekly preview: 2 employees (David, Ashley), no errors

Run the automated test suite:

```bash
cd ../Tests
pecmd PayrunEmployeeTest Run.Tests.pecmd
```

---

## Key Design Decisions

### Pay Frequency per Payroll

`US.PayFrequency` drives the IRS Pub 15-T annualization factor for FIT calculation.
Since it is a company-level case value, it must be the same for all employees in a payroll.
Three payrolls give three distinct annualization factors in one tenant.

### MultiState via CaseSlot (Carlos)

Carlos's three-state allocation uses the `US.MultiStateEmployment` case with
`US.StateAllocationCount = 3`. This activates WT 5310 (`MultiStateWithholding`) instead
of the standard WT 5300 (`StateWithholding`). The allocation percentages are decimals
(0.6, 0.25, 0.15) — not whole numbers.

### Garnishment (Linda)

The `US.Garnishment` case activates WT 5900 (`Garnishment`). The CCPA limit check (60% of
disposable earnings for child support without arrears) is computed automatically by the
regulation, and the garnishment is deducted before net pay (WT 6500).

### PA Local Tax (David)

`US.LocalTaxJurisdiction = PA-Philadelphia` activates WT 5400 (`LocalTaxWithholding`).
The `US.ResidentPSDCode` and `US.WorkPSDCode` (`510101` = Philadelphia City) resolve
the 3.74% resident rate from the `US.Payroll.Data.Local.Tax` data satellite.

---

## Next Steps

- [T2 — Employee Lifecycle](../T2-Lifecycle/README.md): New hire, salary change, FMLA, state relocation
- [T3 — Payruns & Reports](../T3-Payruns/README.md): Run all three payrolls, YTD caps, W-2, Form 941
