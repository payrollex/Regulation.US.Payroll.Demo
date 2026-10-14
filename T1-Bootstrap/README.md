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
for a single legal entity. Each payroll has its own division because the payroll calendar
(period length and pay date) is assigned to the division.

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
PayrollImport US.Payroll.Data.Federal.Tax.2026.json /bulk
PayrollImport US.Payroll.Data.Federal.FICA.2026.json /bulk
PayrollImport US.Payroll.Data.Federal.Garnishment.2026.json /bulk
PayrollImport US.Payroll.Data.State.2026.json /bulk
PayrollImport US.Payroll.Data.State.Withholding.2026.json /bulk
PayrollImport US.Payroll.Data.State.MultiState.2026.json /bulk
PayrollImport US.Payroll.Data.State.WageBase.2026.json /bulk
PayrollImport US.Payroll.Data.Local.Tax.2026.json /bulk
PayrollImport US.Payroll.Data.Local.Tax.WageBase.2026.json /bulk
PayrollImport US.Payroll.Data.Local.Tax.IndianaCounty.2026.json /bulk
PayrollImport US.Payroll.Data.Local.Tax.Philadelphia.2026.json /bulk
PayrollImport US.Payroll.Data.Local.Tax.NewYork.2026.json /bulk
```

The data regulations contain lookups only and are imported in bulk mode.

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
| Calendars | `Apex.Monthly` · `Apex.Biweekly` · `Apex.Weekly` |
| Divisions | `Apex.Division.Monthly` · `Apex.Division.Biweekly` · `Apex.Division.Weekly` (one calendar each) |
| Employees | 10 employees (no case data yet — just identity records) |
| Payrolls | `Apex.Payroll.Monthly` · `Apex.Payroll.Biweekly` · `Apex.Payroll.Weekly` |
| Regulation layers | Same 6 layers on all 3 payrolls (L1, priority 1–11) |
| Payruns | One payrun per payroll |

```bash
pecmd PayrollImport Setup.json
```

#### Why Three Payrolls?

The pay frequency is the period of the payroll calendar — it cannot differ between employees
in the same payroll. Three payrolls = three IRS Pub 15-T pay frequencies (12 · 26 · 52 periods
per year). Same EIN, same regulation layers, same tenant.

| Calendar | Period | First demo period | Pay date |
|:---|:---|:---|:---|
| `Apex.Monthly` | Calendar month | Jan 1 – Jan 31 | Period end (last day of the month) |
| `Apex.Biweekly` | Two weeks from Monday | Jan 12 – Jan 25 | Period end + 5 days (Friday) |
| `Apex.Weekly` | Week from Monday | Jan 5 – Jan 11 | Period end + 5 days (Friday) |

Payrun results belong to the year of the pay date (`cycleAssignment: PayDate`): wages are
reported for the year in which they are paid, also for periods that start in December.

---

### Step 2 — Company Cases (`CompanyCases/`)

Each payroll receives the `US.Company` case of the employer:
EIN `27-1234567`, CompanyState `NY`, SUIRate `2.1%`, FUTACreditReductionState `false`.

```bash
pecmd PayrollImport CompanyCases/Monthly.json
pecmd PayrollImport CompanyCases/Biweekly.json
pecmd PayrollImport CompanyCases/Weekly.json
```

---

### Step 3 — Employee Cases (`Employees/`)

Each file sets all required cases for one employee. Cases are submitted in this order:

1. `US.PersonalData` — SSN, BirthYear
2. `US.Employment` — HireDate, WorkState, ResidentState, WorkLocality (if NYC)
3. `US.Remuneration` — PayType (`Salary` / `Hourly`), AnnualSalary or HourlyRate
4. `US.TaxData` — FilingStatus, W-4 fields, local tax jurisdiction (NYC, Philadelphia)
5. `US.StateWithholdingCertificate` — state filing status and allowances per state (case slot)
6. `US.PreTaxDeductions` — 401k, health, HSA
7. Optional: `US.BenefitsInKind`, `US.MultiStateEmployment`, `US.Garnishment`

#### State Withholding Certificates

Every employee who works or lives in a state with a state withholding certificate has one on
file, matching the federal profile: NY IT-2104, NJ-W4, CT-W4 and CA DE 4. Without a
certificate the state method applies its default status and the payrun logs a warning.
PA has no state certificate; TX has no state income tax.

| Employee | Certificates (state: status, allowances) |
|:---|:---|
| Sara Chen, Robert Stevenson | NY: M, 0 |
| Marcus Johnson | NY: S, 0 · NJ: S, 0 |
| Priya Patel | NY: H, 0 · CT: B (head of household) |
| Kevin Wu, Ashley Park | CA: S, 0 |
| Carlos Rivera | NY: S, 0 · NJ: S, 0 · CT: F (single) |
| Linda Okafor | NY: S, 0 |

#### Employee Overview

| File | Employee | Payroll | Key cases |
|:---|:---|:---|:---|
| `01-SaraChen.json` | Sara Chen | Monthly | PersonalData · Employment(NYC) · Remuneration($240k) · TaxData(MFJ W4Step3=$4k W4Step4c=$500 LocalJurisdiction=NY-NYC) · PreTax(401k8% H$600 HSA$300) · BenefitsInKind(Car$450) |
| `02-RobertStevenson.json` | Robert Stevenson | Monthly | PersonalData(BirthYear 1967) · Employment(NY) · Remuneration($115k) · TaxData(MFJ W4Step3=$2k) · PreTax(401k$2,800/mo H$475) |
| `03-MarcusJohnson.json` | Marcus Johnson | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=NJ) · Remuneration($150k) · TaxData(Single) · PreTax(401k6% H$200) |
| `04-PriyaPatel.json` | Priya Patel | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=CT) · Remuneration($95k) · TaxData(HoH W4Step3=$2k) · PreTax(401k4% H$180) |
| `05-KevinWu.json` | Kevin Wu | Biweekly | PersonalData · Employment(CA) · Remuneration(Hourly $60/hr 80hrs) · TaxData(Single) · PreTax(401kAmount$240 H$220) |
| `06-JessicaTorres.json` | Jessica Torres | Biweekly | PersonalData · Employment(TX) · Remuneration($80k) · TaxData(MFJ) · PreTax(401k4% H$310 family) |
| `07-CarlosRivera.json` | Carlos Rivera | Biweekly | PersonalData · Employment(NY/NYC) · Remuneration($185k) · TaxData(Single) · MultiStateEmployment(NY60%/NJ25%/CT15%) |
| `08-LindaOkafor.json` | Linda Okafor | Biweekly | PersonalData · Employment(NYC) · Remuneration($65k) · TaxData(Single) · Garnishment(ChildSupport $500/period) |
| `09-DavidKim.json` | David Kim | Weekly | PersonalData · Employment(PA) · Remuneration(Hourly $32/hr) · TaxData(Single PA-Philadelphia) |
| `10-AshleyPark.json` | Ashley Park | Weekly | PersonalData · Employment(CA) · Remuneration(Hourly $42/hr) · TaxData(Single) |

```bash
pecmd PayrollImport Employees/01-SaraChen.json
# ... (or run Bootstrap.pecmd for all at once)
```

---

## Validation

After Bootstrap, verify the setup:

Run the automated test suite (18 tests, each imports its own case data and asserts the
wage type results of its payrun jobs):

```bash
cd ../Tests
pecmd Run.Tests.pecmd /TestPrecision2
```

---

## Key Design Decisions

### Pay Frequency per Payroll

The period of the division calendar determines the IRS Pub 15-T pay frequency (Table 3
periods per year) for federal, state and local withholding. It is the same for all employees
in a payroll; three payrolls give three pay frequencies in one tenant.

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

`US.LocalTaxJurisdiction = PA-Philadelphia` activates WT 5400 (`LocalTaxWithholding`) with the
Philadelphia Wage Tax resident rate of the period from the `PhiladelphiaWageTax` lookup of the
`US.Payroll.Data.Local.Tax` data satellite (3.74% until June 30, 2026, 3.735% from July 1, 2026).
Philadelphia is exempt from PA Act 32, so David has no PSD codes.

---

## Next Steps

- [T2 — Employee Lifecycle](../T2-Lifecycle/README.md): New hire, salary change, FMLA, state relocation
- [T3 — Payruns & Reports](../T3-Payruns/README.md): Run all three payrolls, YTD caps, W-2, Form 941
