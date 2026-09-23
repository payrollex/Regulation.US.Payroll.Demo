# Regulation.US.Payroll.Demo

Demo company and tutorials for [US.Payroll](https://github.com/Payroll-Engine/Regulation.US.Payroll)
on [Payroll Engine](https://payrollengine.org).

---

## Demo Company: Apex Digital Solutions LLC

A fictional IT consulting company that exercises the full breadth of US payroll complexity:

| Dimension | Coverage |
|:---|:---|
| Pay frequencies | Monthly · Biweekly · Weekly (3 payrolls) |
| Pay types | Salaried · Hourly |
| States | NY (incl. NYC local) · NJ · CT · CA · TX · PA (incl. Philadelphia EIT) |
| Multi-state | NJ→NY commuter · CT→NY commuter · Three-state allocation (NY/NJ/CT) |
| Benefits | 401(k) · §125 health · §223 HSA · Company car fringe |
| Special | SECURE 2.0 catch-up · Garnishment · Supplemental wages · CA daily OT |
| Reports | Payslip · W-2 · Form 941 · Form 940 |

**Employees:**

| # | Name | Role | Payroll | Key Feature |
|:---:|:---|:---|:---|:---|
| 1 | Sara Chen | CFO | Monthly | NYC · company car · 401(k) · W-4 extras |
| 2 | Robert Stevenson | VP Engineering | Monthly | Age 58 · SECURE 2.0 catch-up |
| 3 | Marcus Johnson | Sr. Software Eng. | Biweekly | NJ→NY commuter · no reciprocity |
| 4 | Priya Patel | Project Manager | Biweekly | CT→NY commuter · Head of Household |
| 5 | Kevin Wu | Cloud Architect | Biweekly | CA hourly · daily overtime · SDI/PFL |
| 6 | Jessica Torres | Account Executive | Biweekly | TX · no SIT · Q1 bonus |
| 7 | Carlos Rivera | Principal Consultant | Biweekly | Three-state allocation NY/NJ/CT |
| 8 | Linda Okafor | HR Coordinator | Biweekly | NYC · garnishment (child support) |
| 9 | David Kim | IT Support Tech | Weekly | Philadelphia · local EIT · OT |
| 10 | Ashley Park | QA Engineer | Weekly | CA hourly · 7th-day OT · SDI uncapped |

---

## Tutorials

| # | Tutorial | What you learn |
|:---:|:---|:---|
| [T1](T1-Bootstrap/) | **Bootstrap a Company** | Set up Apex from zero to first payrun in 20 min |
| [T2](T2-Lifecycle/) | **Employee Lifecycle** | New hire · salary change · FMLA · state relocation · re-entry |
| [T3](T3-Payruns/) | **Payruns & Reports** | Monthly/biweekly/weekly runs · YTD caps · W-2 · Form 941/940 |
| [T4](T4-Customizing/) | **Tenant Customizing** | Add §132 transit benefit + WFH stipend via L2 regulation |

---

## Prerequisites

- **Payroll Engine Backend** running (local or hosted) — see [payrollengine.org](https://payrollengine.org)
- **pecmd** CLI installed — see [PayrollConsole](https://github.com/Payroll-Engine/PayrollEngine.PayrollConsole)
- **Regulation packages** installed:
  - `US.Payroll.2026.json` (core)
  - `US.Payroll.Data.Federal.Tax.2026.json`
  - `US.Payroll.Data.Federal.FICA.2026.json`
  - `US.Payroll.Data.State.2026.json`
  - `US.Payroll.Data.Local.Tax.2026.json`
  - `US.Payroll.Data.Federal.Garnishment.2026.json`

---

## Key Design Decisions

| Decision | Why |
|:---|:---|
| One division per pay frequency | `US.PayFrequency` is a division-level case value — it must be unique per division. Three payrolls × three divisions = three annualization factors (12/26/52) in one tenant. |
| L2 regulation for customization | `Apex.Payroll` extends `US.Payroll` without modifying it. Any future update to `US.Payroll` is automatically inherited. |
| Integration tests as documentation | Each `*.et.json` in `Tests/` documents the expected payslip values with a full calculation trace in the `reason` field. |

---

## Tests

The [`Tests/`](Tests/) folder contains 8 integration tests — one per key demo scenario.
Run them after T1-Bootstrap to validate your setup and confirm expected payslip values.

```bash
cd Tests
pecmd PayrunEmployeeTest Run.Tests.pecmd
```

Each test folder has a `README.md` with the scenario description and assertion table.

---

## Quick Start

Run the full setup from the repo root — this bootstraps the tenant,
imports all employee data, sets up T4 customizing, and runs all 8 integration tests:

```bash
Setup.cmd
```

Or step through the tutorials manually, starting with
[T1-Bootstrap/README.md](T1-Bootstrap/README.md).

---

## License

[MIT](LICENSE) — free to use for any purpose.
