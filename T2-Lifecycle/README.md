# T2 — Employee Lifecycle

> **Duration:** ~30 minutes  
> **Role:** Provider  
> **Prerequisite:** T1 Bootstrap completed

Five lifecycle events using Apex Digital Solutions employees.
Each event demonstrates a specific PE mechanism for handling employee changes.

---

## What You Will Learn

- Onboard a new hire mid-period (automatic proration via `HireDate`)
- Apply an intra-period salary change (time-sliced case values)
- Place an employee on FMLA leave and resume after 12 weeks
- Relocate an employee from Texas to California (full tax regime change)
- Handle re-entry with preserved YTD state

---

## Events

| Event | Employee | Effective | PE Mechanism |
|:---|:---|:---:|:---|
| [L1 New Hire](Events/L1-NewHire-JamesLee.json) | James Lee (new) | Mar 17 | `HireDate` start date → auto proration |
| [L2 Salary Change](Events/L2-SalaryChange-Marcus.json) | Marcus Johnson | Mar 15 | New time-sliced `AnnualSalary` value |
| [L3 FMLA Start](Events/L3-FMLAStart-Linda.json) | Linda Okafor | Apr 7 | `LifecycleStatus = OnLeave` |
| [L4 State Change](Events/L4-StateChange-Jessica.json) | Jessica Torres | Jul 1 | `WorkState / ResidentState` TX→CA |
| [L5 Re-Entry](Events/L5-ReEntry-Linda.json) | Linda Okafor | Jul 1 | `LifecycleStatus = Active` |

---

## Run

```bash
pecmd Lifecycle.pecmd
```

Or apply individual events:

```bash
# L1: Add new hire
pecmd Exchange Events/L1-NewHire-JamesLee.json

# L2: Salary change (apply before March biweekly run)
pecmd Exchange Events/L2-SalaryChange-Marcus.json

# L3: FMLA start
pecmd Exchange Events/L3-FMLAStart-Linda.json

# L4: State change TX→CA
pecmd Exchange Events/L4-StateChange-Jessica.json

# L5: FMLA end / re-entry
pecmd Exchange Events/L5-ReEntry-Linda.json
```

---

## Key Concepts

> *TODO: full tutorial text — see IMPLEMENTATION.md Phase 2*
