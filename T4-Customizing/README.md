# T4 — Tenant Customizing

> **Duration:** ~25 minutes  
> **Role:** Regulator / Provider  
> **Prerequisite:** T1 Bootstrap completed (T4 is standalone — T2/T3 not required)

Extend US.Payroll with two Apex-specific benefits using a Level 2 regulation.
No modification of the core regulation needed.

---

## What You Will Learn

- Understand the L1/L2 regulation layer concept
- Create a company-specific `Apex.Payroll` regulation
- Add a pre-tax benefit with a statutory limit (§132(f) commuter transit — reduces FIT and FICA
  taxable wages up to the monthly limit, the excess is withheld after tax)
- Add a taxable fringe benefit (WFH stipend — increases gross and all taxable wages)
- Read base-regulation case fields and lookups from an L2 script
- Number L2 deductions so they are included in net pay

---

## The Customizations

| Customization | WT | Collector | Federal treatment | State treatment |
|:---|:---:|:---|:---|:---|
| **§132(f) Transit — up to the limit** | 1250 | `US.EmployeeDeductions` | FIT + FICA exempt | Per state wage base of US.Payroll (lookup `StateTaxableWageBase`): excluded in most states incl. NY, CT and CA; taxable in NJ, PA and MS |
| **§132(f) Transit — excess** | 5520 | `US.EmployeeDeductions` | Taxable, post-tax deduction | Taxable |
| **WFH Equipment Stipend** | 1260 | `US.GrossWages` | Fully taxable | Taxable |

`Apex.TransitBenefitMonthly` is the employee's **monthly** election. The script caps it at the
2026 monthly limit of $340 (lookup `US.FederalTaxParameters`, key `TransitMonthlyLimit`) and
converts both parts to the pay period: monthly × 12 / periods per year.

---

## Design Notes

| Rule | Why |
|:---|:---|
| `Apex.Payroll` has **no namespace**; all objects carry the `Apex.` prefix in their name | Scripts of a regulation with a namespace prefix every case field and lookup name with that namespace. With namespace `Apex`, `US.PayFrequency` would resolve to `Apex.US.PayFrequency` and fail. |
| Base lookups are addressed with their full name (`US.FederalTaxParameters`) | The US data regulations use namespace `US`; the stored lookup name includes it. |
| Employee deductions are numbered **below 6500** (WT 1250, 5520) | NetPay (WT 6500) reads the `US.EmployeeDeductions` collector, which only contains wage types processed before it. A deduction numbered above 6500 would be missing from net pay. |
| Employer-only wage types may use numbers above 6900 | They do not affect net pay. |

---

## Run

```bash
pecmd Customize.pecmd
```

The script runs four imports:

```bash
# Step 1: Import the L2 regulation
pecmd PayrollImport Apex.Payroll.2026.json

# Step 2: Link L2 to all payrolls
pecmd PayrollImport PayrollsWithL2.json

# Step 3: Set transit elections for NYC employees
pecmd PayrollImport CaseValues/TransitBenefit-NYC.json

# Step 4: Set WFH stipend for remote employees
pecmd PayrollImport CaseValues/WFHStipend-Remote.json
```

---

## Files

| File | Description |
|:---|:---|
| `Apex.Payroll.2026.json` | L2 regulation: case `Apex.Benefits`, WT 1250 / 1260 / 5520, script `Apex.WageTypeValueFunction` |
| `PayrollsWithL2.json` | Updated payroll layers (adds L2 to all 3 payrolls) |
| `CaseValues/TransitBenefit-NYC.json` | Monthly transit elections: Sara $315, Carlos $400 (above the limit), Linda $315 |
| `CaseValues/WFHStipend-Remote.json` | $200 per period for Kevin, Jessica |

---

## Going Further

The same L2 pattern supports:
- Custom garnishment priority rules (override WT 5900)
- Higher voluntary supplemental withholding rate (override WT 1110)
- Company-specific 401(k) match formula (override WT 1310)
- Equity compensation (RSU) wage types at Level 2
- Custom payslip groupings and labels

---

## Verify

After completing all four steps, run the L2 integration test:

```bash
cd ../Tests
pecmd PayrunEmployeeTest DEMO-TC08-US-Apex-Transit-L2/DEMO-TC08-US-Apex-Transit-L2.et.json
```

Expected for Carlos (biweekly, $400 monthly election):
- WT 1250 = −$156.92 ($340 × 12 / 26), WT 5520 = −$27.69 ($60 × 12 / 26)
- WT 5050 (FIT taxable) and WT 5051 (FICA taxable) each reduced by $156.92
- WT 5310 = −$354.76: NY and CT wages reduced by $156.92, NJ wages unchanged
- Net pay $4,776.91
