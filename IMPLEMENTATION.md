# Implementation Plan

*Working document — tracks progress and provides templates for all tutorial files.*

---

## Status

| Tutorial | Status | Files | Notes |
|:---|:---:|:---:|:---|
| T0 Scaffold | ✅ Done | README, LICENSE, .gitignore, .editorconfig | |
| T1 Bootstrap | ✅ Done | Setup.json + CompanyCases (3) + Employees (10) + Bootstrap.pecmd | PayFrequency tenant-scoped; BirthYear (not DateOfBirth) |
| T2 Lifecycle | ✅ Done | README + L1–L5 events + Lifecycle.pecmd | 5 lifecycle scenarios; FMLA via salary=0 |
| T3 Payruns | ✅ Done | README + Scenarios (bonus + preview) + Reports params + Payruns.pecmd | ActualOutputFile pattern for assertions |
| T4 Customizing | 🔲 Open | 1 regulation JSON + 3 case JSON + 1 pecmd | Standalone |
| Tests | ✅ Stubs done | 8 × (README + et.json) + Run.Tests.pecmd | Values: TODO after first PE run |

---

## Technical Decisions (resolved)

### Verified Case Field Names

| Domain | CaseField | Type | Notes |
|:---|:---|:---|:---|
| Company | `US.EIN` | String | |
| Company | `US.CompanyLegalName` | String | |
| Company | `US.CompanyState` | String | 2-char state code |
| Company | `US.PayFrequency` | String | `Weekly` / `BiWeekly` / `SemiMonthly` / `Monthly` |
| Company | `US.SUIRate` | Decimal | e.g. `0.021` |
| Company | `US.FUTACreditReductionState` | Bool | `false` for most states |
| Employment | `US.HireDate` | Date | |
| Employment | `US.TerminationDate` | Date | |
| Employment | `US.LifecycleStatus` | String | `Active` / `OnLeave` / `Terminated` |
| Employment | `US.WorkState` | String | 2-char |
| Employment | `US.ResidentState` | String | 2-char |
| Employment | `US.WorkLocality` | String | e.g. `NYC` |
| Remuneration | `US.PayType` | String | `Salaried` / `Hourly` / `DayRate` / `FWW` |
| Remuneration | `US.AnnualSalary` | Money | |
| Remuneration | `US.HourlyRate` | Decimal | |
| Remuneration | `US.RegularHours` | Decimal | per period |
| Remuneration | `US.OvertimeHours` | Decimal | FLSA weekly OT |
| Remuneration | `US.CADay1Hours`–`US.CADay7Hours` | Decimal | CA daily OT — per workweek |
| Remuneration | `US.SupplementalWages` | Money | Bonus via WT 1100 |
| Remuneration | `US.ShiftDifferentialAmount` | Money | per period |
| TaxData | `US.FilingStatus` | String | `Single` / `MarriedFilingJointly` / `HeadOfHousehold` |
| TaxData | `US.FederalExempt` | Bool | |
| TaxData | `US.W4Step2` | Bool | |
| TaxData | `US.W4Step3` | Money | |
| TaxData | `US.W4Step4a` | Money | |
| TaxData | `US.W4Step4b` | Money | |
| TaxData | `US.W4Step4c` | Money | extra per-period withholding |
| TaxData | `US.StateExempt` | Bool | |
| TaxData | `US.LocalTaxJurisdiction` | String | e.g. `PHL` |
| TaxData | `US.ResidentPSDCode` | String | PA Act 32 PSD code |
| TaxData | `US.WorkPSDCode` | String | PA Act 32 PSD code |
| TaxData | `US.LSTExempt` | Bool | PA LST exemption |
| PreTax | `US.Pre401kAmount` | Money | fixed $ per period |
| PreTax | `US.Pre401kPercent` | Decimal | % of gross |
| PreTax | `US.PreHealthAmount` | Money | per period |
| PreTax | `US.PreHSAAmount` | Money | per period |
| PreTax | `US.PreFSAAmount` | Money | per period |
| PreTax | `US.Roth401kAmount` | Money | SECURE 2.0 Roth catch-up |
| BenefitsInKind | `US.CompanyCarValue` | Money | **Per-period** imputed FMV → GrossBase (FIT + FICA taxable) |
| BenefitsInKind | `US.EmployerHealthAmount` | Money | Employer-paid health → EmployerCosts only |
| BenefitsInKind | `US.Employer401kMatchAmount` | Money | Employer 401k match → EmployerCosts only |
| MultiState | `US.StateAllocationCount` | Integer | triggers WT 5310 instead of 5300 |
| MultiState | `US.AllocationPercent1` | Decimal | % for primary WorkState |
| MultiState | `US.WorkState2` | String | second work state |
| MultiState | `US.AllocationPercent2` | Decimal | % for WorkState2 |
| MultiState | `US.WorkState3` | String | third work state |
| MultiState | `US.AllocationPercent3` | Decimal | % for WorkState3 |
| Garnishment | `US.GarnishmentType` | String | `ChildSupport` / `IRS` / `CreditorGarnishment` |
| Garnishment | `US.GarnishmentAmount` | Money | per-period amount |
| Garnishment | `US.GarnishmentIsSupporting` | Bool | supporting another family (affects CCPA %) |
| Garnishment | `US.GarnishmentIsArrears` | Bool | |
| Garnishment | `US.LevyDependents` | Integer | for IRS levy only |

### CA Daily OT — Biweekly Input Pattern

For a biweekly payroll, `US.CADay1Hours`–`US.CADay7Hours` represent **one workweek** of hours.
⚠️ **Open question:** How are the two weeks within a biweekly period entered?
- Option A: Only one set of `CADay1-7Hours` fields, covering the "OT week"
- Option B: Two separate payrun-specific case value entries with different date ranges

→ **Check with `WT-TC1020-US-StateDailyOT` test for biweekly period handling.**
Until resolved, assume Option A (single set of daily hours).

### Company Car Value

`US.CompanyCarValue` = **per-period** imputed FMV amount:
- Monthly payroll: monthly FMV (Sara: $450/month)
- Biweekly payroll: biweekly equivalent if applicable
- Goes into `GrossBase` → increases **both FIT and FICA** taxable wages
- 401(k) pre-tax deduction does NOT reduce FICA — hence FIT taxable < FICA taxable for Sara

### FUTA Across Three Payrolls

Each payroll generates its own payrun/employer tax data. Year-end Form 940
aggregates across all three payrolls. The `US.FUTACreditReductionState = false`
must be set consistently in all three company cases.

### FIT Standard Deduction 2026

- **Single:** ~$17,000 (verified against ThreeStates test: $120k Single Monthly → $1,464.17/month)
- **MFJ:** ~$34,000 (standard double)
- **HoH:** ~$25,500 (midpoint, approximate)

---

## Phase 1 — T1 Bootstrap

### Files to Create

```
T1-Bootstrap/
├── README.md                    ← tutorial guide (public-facing)
├── Setup.json                   ← tenant + users + division + employees + payrolls + payruns
├── CompanyCases/
│   ├── Monthly.json             ← company case for Apex.Payroll.Monthly
│   ├── Biweekly.json            ← company case for Apex.Payroll.Biweekly
│   └── Weekly.json              ← company case for Apex.Payroll.Weekly
├── Employees/
│   ├── 01-SaraChen.json
│   ├── 02-RobertStevenson.json
│   ├── 03-MarcusJohnson.json
│   ├── 04-PriyaPatel.json
│   ├── 05-KevinWu.json
│   ├── 06-JessicaTorres.json
│   ├── 07-CarlosRivera.json
│   ├── 08-LindaOkafor.json
│   ├── 09-DavidKim.json
│   ├── 10-AshleyPark.json
│   └── all-employees.json       ← combined (Setup.json may already include these)
└── Bootstrap.pecmd
```

### Setup.json Structure

```json
{
  "$schema": "../Schemas/PayrollEngine.Exchange.schema.json",
  "createdObjectDate": "2026-01-01T00:00:00.0Z",
  "tenants": [{
    "identifier": "Apex.DigitalSolutions",
    "culture": "en-US",
    "users": [{
      "identifier": "apex.admin@apexdigital.com",
      "firstName": "Admin", "lastName": "Apex",
      "culture": "en-US",
      "userType": "TenantAdministrator"
    }],
    "divisions": [{
      "name": "Apex.Division",
      "culture": "en-US"
    }],
    "employees": [
      { "identifier": "sara.chen@apexdigital.com",       "firstName": "Sara",    "lastName": "Chen",       "divisions": ["Apex.Division"] },
      { "identifier": "robert.stevenson@apexdigital.com","firstName": "Robert",  "lastName": "Stevenson",  "divisions": ["Apex.Division"] },
      { "identifier": "marcus.johnson@apexdigital.com",  "firstName": "Marcus",  "lastName": "Johnson",    "divisions": ["Apex.Division"] },
      { "identifier": "priya.patel@apexdigital.com",     "firstName": "Priya",   "lastName": "Patel",      "divisions": ["Apex.Division"] },
      { "identifier": "kevin.wu@apexdigital.com",        "firstName": "Kevin",   "lastName": "Wu",         "divisions": ["Apex.Division"] },
      { "identifier": "jessica.torres@apexdigital.com",  "firstName": "Jessica", "lastName": "Torres",     "divisions": ["Apex.Division"] },
      { "identifier": "carlos.rivera@apexdigital.com",   "firstName": "Carlos",  "lastName": "Rivera",     "divisions": ["Apex.Division"] },
      { "identifier": "linda.okafor@apexdigital.com",    "firstName": "Linda",   "lastName": "Okafor",     "divisions": ["Apex.Division"] },
      { "identifier": "david.kim@apexdigital.com",       "firstName": "David",   "lastName": "Kim",        "divisions": ["Apex.Division"] },
      { "identifier": "ashley.park@apexdigital.com",     "firstName": "Ashley",  "lastName": "Park",       "divisions": ["Apex.Division"] }
    ],
    "payrolls": [
      {
        "name": "Apex.Payroll.Monthly",
        "divisionName": "Apex.Division",
        "layers": [
          { "level": 1, "priority": 1,  "regulationName": "US.Payroll" },
          { "level": 1, "priority": 7,  "regulationName": "US.Payroll.Data.Federal.Tax" },
          { "level": 1, "priority": 8,  "regulationName": "US.Payroll.Data.Federal.FICA" },
          { "level": 1, "priority": 9,  "regulationName": "US.Payroll.Data.State" },
          { "level": 1, "priority": 10, "regulationName": "US.Payroll.Data.Local.Tax" },
          { "level": 1, "priority": 11, "regulationName": "US.Payroll.Data.Federal.Garnishment" }
        ]
      },
      {
        "name": "Apex.Payroll.Biweekly",
        "divisionName": "Apex.Division",
        "layers": [ "... same 6 layers ..." ]
      },
      {
        "name": "Apex.Payroll.Weekly",
        "divisionName": "Apex.Division",
        "layers": [ "... same 6 layers ..." ]
      }
    ],
    "payruns": [
      { "name": "Apex.Payrun.Monthly",  "payrollName": "Apex.Payroll.Monthly"  },
      { "name": "Apex.Payrun.Biweekly", "payrollName": "Apex.Payroll.Biweekly" },
      { "name": "Apex.Payrun.Weekly",   "payrollName": "Apex.Payroll.Weekly"   }
    ]
  }]
}
```

### CompanyCases/Monthly.json Structure

```json
{
  "$schema": "../../Schemas/PayrollEngine.Exchange.schema.json",
  "createdObjectDate": "2026-01-01T00:00:00.0Z",
  "tenants": [{
    "identifier": "Apex.DigitalSolutions",
    "updateMode": "NoUpdate",
    "payrolls": [{
      "name": "Apex.Payroll.Monthly",
      "updateMode": "NoUpdate",
      "cases": [{
        "userIdentifier": "apex.admin@apexdigital.com",
        "divisionName": "Apex.Division",
        "case": {
          "caseName": "US.Company",
          "values": [
            { "caseFieldName": "US.EIN",              "value": "27-1234567",                "start": "2026-01-01T00:00:00.0Z" },
            { "caseFieldName": "US.CompanyLegalName", "value": "Apex Digital Solutions LLC","start": "2026-01-01T00:00:00.0Z" },
            { "caseFieldName": "US.CompanyState",     "value": "NY",                        "start": "2026-01-01T00:00:00.0Z" },
            { "caseFieldName": "US.PayFrequency",     "value": "Monthly",                   "start": "2026-01-01T00:00:00.0Z" },
            { "caseFieldName": "US.SUIRate",          "value": "0.021",                     "start": "2026-01-01T00:00:00.0Z" },
            { "caseFieldName": "US.FUTACreditReductionState", "value": "false",             "start": "2026-01-01T00:00:00.0Z" }
          ]
        }
      }]
    }]
  }]
}
```

Biweekly.json: same, `"value": "BiWeekly"` and payroll name `Apex.Payroll.Biweekly`.
Weekly.json: same, `"value": "Weekly"` and payroll name `Apex.Payroll.Weekly`.

### Employee File Structure

Each employee file sets cases for their assigned payroll.
Here: Sara Chen (Monthly, NYC, MFJ, company car):

```json
{
  "$schema": "../../Schemas/PayrollEngine.Exchange.schema.json",
  "createdObjectDate": "2026-01-01T00:00:00.0Z",
  "tenants": [{
    "identifier": "Apex.DigitalSolutions",
    "updateMode": "NoUpdate",
    "payrolls": [{
      "name": "Apex.Payroll.Monthly",
      "updateMode": "NoUpdate",
      "cases": [
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.PersonalData",
            "values": [
              { "caseFieldName": "US.SSN",         "value": "111-22-3001", "created": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.DateOfBirth",  "value": "1975-06-12",  "created": "2026-01-01T00:00:00.0Z" }
            ]
          }
        },
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.Employment",
            "values": [
              { "caseFieldName": "US.HireDate",       "value": "2015-03-01", "start": "2015-03-01T00:00:00.0Z" },
              { "caseFieldName": "US.LifecycleStatus","value": "Active",     "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.WorkState",      "value": "NY",         "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.ResidentState",  "value": "NY",         "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.WorkLocality",   "value": "NYC",        "start": "2026-01-01T00:00:00.0Z" }
            ]
          }
        },
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.Remuneration",
            "values": [
              { "caseFieldName": "US.PayType",     "value": "Salaried", "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.AnnualSalary","value": "240000",   "start": "2026-01-01T00:00:00.0Z" }
            ]
          }
        },
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.TaxData",
            "values": [
              { "caseFieldName": "US.FilingStatus","value": "MarriedFilingJointly","start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.W4Step2",     "value": "false",               "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.W4Step3",     "value": "4000",                "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.W4Step4c",    "value": "500",                 "start": "2026-01-01T00:00:00.0Z" }
            ]
          }
        },
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.PreTaxDeductions",
            "values": [
              { "caseFieldName": "US.Pre401kPercent",  "value": "8",   "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.PreHealthAmount", "value": "600", "start": "2026-01-01T00:00:00.0Z" },
              { "caseFieldName": "US.PreHSAAmount",    "value": "300", "start": "2026-01-01T00:00:00.0Z" }
            ]
          }
        },
        {
          "userIdentifier": "apex.admin@apexdigital.com",
          "employeeIdentifier": "sara.chen@apexdigital.com",
          "divisionName": "Apex.Division",
          "case": {
            "caseName": "US.BenefitsInKind",
            "values": [
              { "caseFieldName": "US.CompanyCarValue", "value": "450", "start": "2026-01-01T00:00:00.0Z" }
            ]
          }
        }
      ]
    }]
  }]
}
```

### Employee Quick Reference — All 10

| # | Identifier | Payroll | Key cases to set |
|:---:|:---|:---|:---|
| 1 | sara.chen@apexdigital.com | Monthly | PersonalData · Employment(NYC) · Remuneration(Salaried $240k) · TaxData(MFJ W4Step3=$4k W4Step4c=$500) · PreTax(401k8% Health$600 HSA$300) · BenefitsInKind(Car$450) |
| 2 | robert.stevenson@apexdigital.com | Monthly | PersonalData(DOB 1967-11-30) · Employment(NY no NYC) · Remuneration(Salaried $115k) · TaxData(MFJ W4Step3=$2k) · PreTax(401kAmount=$2708.33 Health$475) |
| 3 | marcus.johnson@apexdigital.com | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=NJ) · Remuneration(Salaried $150k) · TaxData(Single) · PreTax(401k6% Health$200) |
| 4 | priya.patel@apexdigital.com | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=CT) · Remuneration(Salaried $95k) · TaxData(HoH W4Step3=$2k) · PreTax(401k4% Health$180) |
| 5 | kevin.wu@apexdigital.com | Biweekly | PersonalData · Employment(CA) · Remuneration(Hourly $60/hr) · TaxData(Single) · PreTax(401k5% Health$220) |
| 6 | jessica.torres@apexdigital.com | Biweekly | PersonalData · Employment(TX) · Remuneration(Salaried $80k) · TaxData(MFJ) · PreTax(401k4% Health$310) |
| 7 | carlos.rivera@apexdigital.com | Biweekly | PersonalData · Employment(WorkState=NY ResidentState=NY WorkLocality=NYC) · Remuneration(Salaried $185k) · TaxData(Single) · MultiState(Count=3 Pct1=60 WS2=NJ Pct2=25 WS3=CT Pct3=15) |
| 8 | linda.okafor@apexdigital.com | Biweekly | PersonalData · Employment(NYC) · Remuneration(Salaried $65k) · TaxData(Single) · Garnishment(Type=ChildSupport Amount=$500 IsSupporting=false IsArrears=false) |
| 9 | david.kim@apexdigital.com | Weekly | PersonalData · Employment(WorkState=PA ResidentState=PA) · Remuneration(Hourly $32/hr) · TaxData(Single LocalTaxJurisdiction=PHL ResidentPSDCode=510101 WorkPSDCode=510101) |
| 10 | ashley.park@apexdigital.com | Weekly | PersonalData · Employment(CA) · Remuneration(Hourly $42/hr) · TaxData(Single) |

### Bootstrap.pecmd

```
# Apex Digital Solutions LLC — Bootstrap
# Run from T1-Bootstrap/ directory

# Step 1: Regulation packages (must be imported once per PE instance)
RegulationImport ../Regulations/US.Payroll.2026.json
RegulationImport ../Regulations/US.Payroll.Data.Federal.Tax.2026.json
RegulationImport ../Regulations/US.Payroll.Data.Federal.FICA.2026.json
RegulationImport ../Regulations/US.Payroll.Data.State.2026.json
RegulationImport ../Regulations/US.Payroll.Data.Local.Tax.2026.json
RegulationImport ../Regulations/US.Payroll.Data.Federal.Garnishment.2026.json

# Step 2: Tenant structure
Exchange Setup.json

# Step 3: Company cases
Exchange CompanyCases/Monthly.json
Exchange CompanyCases/Biweekly.json
Exchange CompanyCases/Weekly.json

# Step 4: All employee cases
Exchange Employees/01-SaraChen.json
Exchange Employees/02-RobertStevenson.json
Exchange Employees/03-MarcusJohnson.json
Exchange Employees/04-PriyaPatel.json
Exchange Employees/05-KevinWu.json
Exchange Employees/06-JessicaTorres.json
Exchange Employees/07-CarlosRivera.json
Exchange Employees/08-LindaOkafor.json
Exchange Employees/09-DavidKim.json
Exchange Employees/10-AshleyPark.json
```

### T1 Validation Checklist

- [ ] `pecmd PayrunPreview Apex.Payrun.Monthly /period 2026-01` → 2 employees, no errors
- [ ] `pecmd PayrunPreview Apex.Payrun.Biweekly /period 2026-01-06 2026-01-19` → 6 employees, no errors
- [ ] `pecmd PayrunPreview Apex.Payrun.Weekly /period 2026-01-05 2026-01-11` → 2 employees, no errors
- [ ] Sara Chen payslip shows: company car in gross, 401k in pre-tax, 3 different taxable bases
- [ ] Marcus Johnson payslip shows: NY SIT + NJ SIT both present
- [ ] David Kim payslip shows: PA SIT + Philadelphia EIT
- [ ] Jessica Torres payslip shows: TX SIT = $0

---

## Phase 2 — T2 Lifecycle

### Files to Create

```
T2-Lifecycle/
├── README.md                       ← tutorial guide
├── Events/
│   ├── L1-NewHire-JamesLee.json    ← new employee (March 17 hire)
│   ├── L2-SalaryChange-Marcus.json ← new AnnualSalary value from Mar 15
│   ├── L3-FMLAStart-Linda.json     ← LifecycleStatus = OnLeave
│   ├── L4-StateChange-Jessica.json ← WorkState/ResidentState TX→CA
│   └── L5-ReEntry-Linda.json       ← LifecycleStatus = Active
└── Lifecycle.pecmd
```

### L1 — James Lee (New Hire, March 17)

New employee record + all cases. Key: HireDate as case value `start` date.
Employee identifier: `james.lee@apexdigital.com`
Payroll: `Apex.Payroll.Biweekly` (CA developer)

```json
{
  "caseFieldName": "US.HireDate",
  "value": "2026-03-17",
  "start": "2026-03-17T00:00:00.0Z"
}
```

Must also add James Lee to `Setup.json` employees list OR create a separate
`Setup.Addendum.json` with just the new employee record.

### L2 — Marcus Johnson Salary Change (Mar 15)

Single exchange file updating only one case value:

```json
{
  "caseName": "US.Remuneration",
  "values": [
    {
      "caseFieldName": "US.AnnualSalary",
      "value": "165000",
      "start": "2026-03-15T00:00:00.0Z"
    }
  ]
}
```

### L3 — Linda FMLA Start (Apr 7)

```json
{
  "caseName": "US.Employment",
  "values": [
    {
      "caseFieldName": "US.LifecycleStatus",
      "value": "OnLeave",
      "start": "2026-04-07T00:00:00.0Z"
    }
  ]
}
```

### L4 — Jessica State Change TX→CA (Jul 1)

```json
{
  "caseName": "US.Employment",
  "values": [
    { "caseFieldName": "US.WorkState",    "value": "CA", "start": "2026-07-01T00:00:00.0Z" },
    { "caseFieldName": "US.ResidentState","value": "CA", "start": "2026-07-01T00:00:00.0Z" }
  ]
}
```

### L5 — Linda Re-Entry (Jul 1)

```json
{
  "caseName": "US.Employment",
  "values": [
    {
      "caseFieldName": "US.LifecycleStatus",
      "value": "Active",
      "start": "2026-07-01T00:00:00.0Z"
    }
  ]
}
```

---

## Phase 3 — T3 Payruns

### Files to Create

```
T3-Payruns/
├── README.md                ← tutorial guide incl. YTD cap walkthrough
├── January.pecmd            ← all three payrolls, January 2026
├── March-Bonus.pecmd        ← Jessica supplemental wages
├── October.pecmd            ← Sara SS cap month (highlight)
├── December.pecmd           ← Robert 401k cap month
└── YearEnd.pecmd            ← W-2, Form 941 Q4, Form 940
```

### YTD Cap Scenarios to Document in README

| Cap | Employee | Month triggered | Visible effect |
|:---|:---|:---:|:---|
| FUTA $7,000 | All employees | Jan–Feb | Employer FUTA drops to $0 |
| SS $184,500 | Sara ($234k FICA/yr) | ~Oct | Sara SS drops; net pay +$1,212 |
| SS $184,500 | Carlos ($185k/yr) | Dec | marginal case |
| 401k $24,500 | All standard contrib. | Dec | Pre-tax deduction stops; FIT taxable rises |
| 401k $32,500 | Robert (SECURE 2.0) | Dec | Same pattern, higher threshold |

### Supplemental Wages (March bonus)

```json
{
  "caseName": "US.SupplementaryPay",
  "values": [
    {
      "caseFieldName": "US.SupplementalWages",
      "value": "10000",
      "start": "2026-03-01T00:00:00.0Z",
      "end":   "2026-03-31T00:00:00.0Z"
    }
  ]
}
```

---

## Phase 4 — T4 Customizing

### Files to Create

```
T4-Customizing/
├── README.md                        ← tutorial guide
├── Apex.Payroll.2026.json           ← L2 regulation: TransitBenefit + WFHStipend WTs
├── CaseValues/
│   ├── TransitBenefit-NYC.json      ← Sara, Carlos, Linda: $315/month
│   └── WFHStipend-Remote.json       ← Kevin, Jessica: $200/biweekly
├── PayrollsWithL2.json              ← updated payroll layers (+L2 Apex.Payroll)
└── Customizing.pecmd
```

### Apex.Payroll.2026.json — L2 Regulation Skeleton

```json
{
  "$schema": "../Schemas/PayrollEngine.Exchange.schema.json",
  "createdObjectDate": "2026-01-01T00:00:00.0Z",
  "tenants": [{
    "identifier": "Apex.DigitalSolutions",
    "regulations": [{
      "name":        "Apex.Payroll",
      "displayName": "Apex Digital Solutions — Company Customization",
      "description": "L2 override: §132 transit benefit + WFH equipment stipend",
      "validFrom":   "2026-01-01T00:00:00.0Z",
      "cases": [{
        "name": "Apex.Benefits",
        "caseType": "Employee",
        "caseFields": [
          {
            "name":        "Apex.TransitBenefitMonthly",
            "displayName": "Monthly Transit Benefit (§132)",
            "description": "Pre-tax commuter transit pass, max $315/month (IRC §132(f)). Reduces FIT, FICA, and NY/NYC taxable wages.",
            "valueType":   "Money",
            "timeType":    "CalendarPeriod"
          },
          {
            "name":        "Apex.WFHStipendBiweekly",
            "displayName": "WFH Equipment Stipend",
            "description": "Taxable remote-work stipend per biweekly period. IRC §61 — increases gross, FICA, FIT, and state taxable wages.",
            "valueType":   "Money",
            "timeType":    "CalendarPeriod"
          }
        ]
      }],
      "wageTypes": [
        {
          "name":          "Apex.PreTransitBenefit",
          "wageTypeNumber": 1250.0,
          "displayName":   "Transit Benefit §132",
          "description":   "Pre-tax §132 commuter benefit. Max $315/month. Reduces FIT, FICA, NY/NYC taxable wages.",
          "collectors":    ["EmployeePreTaxDeductions"],
          "valueActions": [
            { "action": "GetCaseValue", "caseFieldName": "Apex.TransitBenefitMonthly" },
            { "action": "Clamp", "maximum": 315 },
            { "action": "Negate" }
          ]
        },
        {
          "name":          "Apex.WFHStipend",
          "wageTypeNumber": 1260.0,
          "displayName":   "WFH Equipment Stipend",
          "description":   "Taxable WFH stipend. Goes into GrossWages → taxable everywhere.",
          "collectors":    ["GrossWages"],
          "valueActions": [
            { "action": "GetCaseValue", "caseFieldName": "Apex.WFHStipendBiweekly" }
          ]
        }
      ]
    }]
  }]
}
```

### PayrollsWithL2.json

Add `{ "level": 2, "priority": 1, "regulationName": "Apex.Payroll" }` to all three payrolls.
Use `"updateMode": "Update"` on the payroll to patch existing configuration.

### T4 Validation Checklist

- [ ] Import Apex.Payroll.2026.json → no errors
- [ ] Import PayrollsWithL2.json → payrolls now have 7 layers
- [ ] Set TransitBenefit case value for Sara → run Monthly payrun → FIT taxable reduced by $315
- [ ] Set WFHStipend for Kevin → run Biweekly payrun → gross +$200, CA SDI increases by $2.60
- [ ] Kevin WFH stipend appears in CA SIT taxable wages (CA does not conform to §132 but WFH stipend is already taxable)

---

## Schemas

Copy from `Regulation.US.Payroll/2026/Schemas/`:
- `PayrollEngine.Exchange.schema.json`
- `PayrollEngine.CaseTest.schema.json`

→ Place in `Schemas/` at repo root so all JSON files can reference `../Schemas/`.

---

---

## Phase 5 — Tests

### Purpose

8 integration tests validate the demo company setup and document expected payroll results.

| Goal | Explanation |
|:---|:---|
| Setup validation | Confirms T1-Bootstrap JSON produces the correct PE payslip output |
| Scenario documentation | Each `README.md` explains the regulation feature being tested |
| CI regression | Prevents regressions if regulation data satellites are updated |
| Living documentation | `et.json` values double as precise specs for the demo scenarios |

> These are **NOT** compliance tests (those live in `Regulation.US.Payroll`).
> Focus: demo correctness and feature illustration, not exhaustive coverage.

---

### Test Inventory

| ID | Employee | Payroll | Feature | Dependency |
|:---|:---|:---|:---|:---|
| DEMO-TC01 | Sara Chen | Monthly | Company car · 401k · W-4 Step3/4c | T1 |
| DEMO-TC02 | Marcus Johnson | Biweekly | NJ→NY split-state (no reciprocity) | T1 |
| DEMO-TC03 | Carlos Rivera | Biweekly | Three-state allocation NY/NJ/CT | T1 |
| DEMO-TC04 | Kevin Wu | Biweekly | CA daily OT §510 (sprint week) | T1 |
| DEMO-TC05 | Jessica Torres | Biweekly | TX no-SIT + supplemental flat 22% | T1 |
| DEMO-TC06 | Linda Okafor | Biweekly | Child support garnishment (CCPA) | T1 |
| DEMO-TC07 | David Kim | Weekly | PA SIT + Philadelphia EIT (PSD codes) | T1 |
| DEMO-TC08 | Carlos Rivera | Biweekly | L2 §132 transit benefit | T1 + T4 |

---

### Folder Structure

```
Tests/
├── README.md                                    ← test suite overview
├── Run.Tests.pecmd                              ← runs all 8 tests in sequence
├── DEMO-TC01-US-Sara-Monthly/
│   ├── README.md                                ← scenario + assertion table
│   └── DEMO-TC01-US-Sara-Monthly.et.json        ← PayrunEmployeeTest assertions
├── DEMO-TC02-US-Marcus-NJtoNY/
│   ├── README.md
│   └── DEMO-TC02-US-Marcus-NJtoNY.et.json
├── DEMO-TC03-US-Carlos-ThreeState/
│   ├── README.md
│   └── DEMO-TC03-US-Carlos-ThreeState.et.json
├── DEMO-TC04-US-Kevin-CADailyOT/
│   ├── README.md
│   └── DEMO-TC04-US-Kevin-CADailyOT.et.json
├── DEMO-TC05-US-Jessica-TX/
│   ├── README.md
│   └── DEMO-TC05-US-Jessica-TX.et.json
├── DEMO-TC06-US-Linda-Garnishment/
│   ├── README.md
│   └── DEMO-TC06-US-Linda-Garnishment.et.json
├── DEMO-TC07-US-David-Philadelphia/
│   ├── README.md
│   └── DEMO-TC07-US-David-Philadelphia.et.json
└── DEMO-TC08-US-Apex-Transit-L2/
    ├── README.md
    └── DEMO-TC08-US-Apex-Transit-L2.et.json
```

---

### et.json Format Reference

Each test file contains:

```json
{
  "$schema": "../../Schemas/PayrollEngine.CaseTest.schema.json",
  "tenantIdentifier": "Apex.DigitalSolutions",
  "payrollName": "Apex.Payroll.Biweekly",
  "employeeIdentifier": "employee@apexdigital.com",
  "testName": "DEMO-TC0x-...",
  "testDescription": "Human-readable description of what is being tested.",
  "period": "2026-01-06T00:00:00.0Z/2026-01-19T00:00:00.0Z",
  "periodCases": [ ... ],  // optional: period-specific case values (hours, bonuses)
  "results": {
    "wageTypeResults": [
      { "wageTypeName": "WageTypeName", "value": 1234.56, "description": "..." }
    ]
  }
}
```

`periodCases` is used for tests that require per-period inputs:
- DEMO-TC04: `US.CADay1-5Hours` for the sprint week daily hour breakdown
- DEMO-TC07: `US.RegularHours` / `US.OvertimeHours` for the weekly schedule

---

### Completing the Test Values

All `et.json` files contain `// TODO: verify` markers where illustrative amounts
were used. After T1-Bootstrap is complete:

1. Run `pecmd PayrunEmployeeTest Run.Tests.pecmd`
2. Note the actual output values for each failing assertion
3. Replace the placeholder values with the actual PE output
4. Re-run to confirm all 8 tests pass

The `Tests/README.md` contains per-test assertion tables to guide this process.

---

### DEMO-TC08 Special Note (L2 Transit — T4 dependency)

DEMO-TC08 requires T4-Customizing to be completed first. The test validates
that the L2 `Apex.Benefits` regulation correctly reduces both FIT and FICA
taxable wages by the transit benefit amount ($300/period):

```
Without L2:  FIT taxable = $7,115.38  FICA taxable = $7,115.38
With L2:     FIT taxable = $6,815.38  FICA taxable = $6,815.38  (−$300 each)
```

This is the clearest demo of the L2 regulation mechanism: same base regulation,
company-specific extension layer, measurable impact on payslip.

---

## Commit Plan

| Commit | Content |
|:---|:---|
| `chore: scaffold` | README, LICENSE, .gitignore, .editorconfig, IMPLEMENTATION.md, Schemas/ |
| `docs: company reference` | US.Payroll-DemoCompany.md, US.Payroll-TutorialPlan.md |
| `feat: test stubs` | Tests/ — all 8 et.json stubs + READMEs + Run.Tests.pecmd |
| `feat: T1 bootstrap` | Setup.json, CompanyCases/, all 10 employee JSONs, Bootstrap.pecmd |
| `feat: T2 lifecycle` | 5 lifecycle event JSONs, Lifecycle.pecmd, T2 README |
| `feat: T3 payruns` | 5 pecmd scripts, T3 README with YTD walkthrough |
| `feat: T4 customizing` | Apex.Benefits regulation JSON, case value JSONs, T4 README |
| `test: verify values` | Replace TODO placeholders with actual PE output values |
| `docs: READMEs` | All tutorial READMEs polished for public release |

---

*Implementation plan · Sep 2026 · Regulation.US.Payroll.Demo*
