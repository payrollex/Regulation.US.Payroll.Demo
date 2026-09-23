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
- Add a pre-tax benefit (§132 commuter transit — reduces FIT, FICA, NY/NYC taxable wages)
- Add a taxable fringe benefit (WFH stipend — increases gross and all taxable wages)
- Understand the collector architecture: `EmployeePreTaxDeductions` vs. `GrossWages`

---

## The Two Customizations

| Customization | WT | Collector | Federal treatment | State: NY | State: CA |
|:---|:---:|:---|:---|:---|:---|
| **§132 Transit Benefit** | 1250 | `EmployeePreTaxDeductions` | FIT + FICA exempt | NY/NYC exempt | ⚠️ CA does NOT conform — CA taxable |
| **WFH Equipment Stipend** | 1260 | `GrossWages` | Fully taxable | Taxable | Taxable |

---

## Run

```bash
# Step 1: Import L2 regulation
pecmd RegulationImport Apex.Payroll.2026.json

# Step 2: Link L2 to all payrolls
pecmd Exchange PayrollsWithL2.json

# Step 3: Set case values for NYC employees (transit)
pecmd Exchange CaseValues/TransitBenefit-NYC.json

# Step 4: Set case values for remote employees (WFH stipend)
pecmd Exchange CaseValues/WFHStipend-Remote.json
```

---

## Files

| File | Description |
|:---|:---|
| `Apex.Payroll.2026.json` | L2 regulation: CaseFields + 2 WageTypes |
| `PayrollsWithL2.json` | Updated payroll layers (adds L2 to all 3 payrolls) |
| `CaseValues/TransitBenefit-NYC.json` | $315/month for Sara, Carlos, Linda |
| `CaseValues/WFHStipend-Remote.json` | $200/biweekly for Kevin, Jessica |

---

## Going Further

The same L2 pattern supports:
- Custom garnishment priority rules (override WT 5500)
- Higher voluntary supplemental withholding rate (override WT 1100)
- Company-specific 401(k) match formula (override WT 1310)
- Equity compensation (RSU) wage types at Level 2
- Custom payslip groupings and labels

---

## Verify

After completing all four steps, run the L2 integration test to confirm
that the §132 transit benefit correctly reduces FIT and FICA taxable wages:

```bash
cd ../Tests
pecmd PayrunEmployeeTest DEMO-TC08-US-Apex-Transit-L2/DEMO-TC08-US-Apex-Transit-L2.et.json
```

Expected: WT 1250 returns `−$300.00` (Carlos, biweekly transit benefit),
WT 5050 (FIT taxable) and WT 5051 (FICA taxable) each reduced by $300.
