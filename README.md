# Regulation.US.Payroll.Demo

Demo company and tutorials for [US.Payroll](https://github.com/payrollex/Regulation.US.Payroll)
on [Payroll Engine](https://payrollengine.org).

---

## Dependency: Regulation.US.Payroll

This demo requires **[Regulation.US.Payroll](https://github.com/payrollex/Regulation.US.Payroll)**
to be checked out as a sibling folder:

```
Repos/
  Regulation.US.Payroll/      ← required
  Regulation.US.Payroll.Demo/ ← this repo
```

`Setup.cmd` first deletes the tenants `Apex.DigitalSolutions` and `US.Payroll` (Step 1),
then calls `Regulation.US.Payroll\2026\Setup.Tests.pecmd` (Step 2) to install
all US.Payroll packages and data regulations into the running PE backend before the demo
tenant is created. The demo tenant (`Apex.DigitalSolutions`) then consumes
`US.Payroll` as a shared regulation — no separate package import is needed.

> Step 1 makes the setup repeatable: the US.Payroll test fixtures cannot be imported
> twice into the same tenant. If the backend is already loaded with a current
> `US.Payroll` installation you can skip Steps 1 and 2 and run the remaining setup
> steps manually from the tutorial READMEs.

---

## What This Demo Covers

| Topic | Where |
|:---|:---|
| **Multiple payroll frequencies** — monthly, biweekly, and weekly payrolls in one tenant, each with its own payroll calendar and pay dates (12 / 26 / 52 periods per year) | T1, T3 |
| **W-4 2020+** — Steps 2–4, additional withholding, Head of Household filing status | T1, T2 |
| **Federal income tax** — IRS Pub 15-T percentage method, supplemental flat rate (22%) on a bonus | T3 |
| **FICA** — Social Security wage base cap ($184,500), Additional Medicare Tax (0.9% above $200k) | T3 |
| **Multi-state withholding** — six states (NY, NJ, CT, CA, TX, PA) with NY City and Philadelphia local tax | T1, T3 |
| **Commuter withholding** — NJ→NY reciprocity gap, CT→NY credit method, three-state allocation | T1, T3 |
| **California specifics** — daily overtime (8h/day), SDI uncapped (7th-day double-time is supported by the regulation, not shown in the demo) | Tests (TC04, TC11) |
| **Pre-tax benefits** — §401(k) traditional + SECURE 2.0 age-50+ / age-60–63 catch-up, §125 health premium, §223 HSA | T1, T3 |
| **Fringe benefits** — company car (imputed income per pay period, taxed but not paid out, Box 1 inclusion) | T1, T3 |
| **Garnishment** — child support order, disposable earnings calculation, CCPA cap | T1, T3 |
| **Employee lifecycle** — new hire, mid-period salary change, FMLA leave, state relocation, re-entry | T2 |
| **YTD caps and FUTA** — SS wage base, FUTA $7,000/employee base, 401(k) limits, Additional Medicare threshold, NY PFL maximum | T3 |
| **Reports** — payslip per pay date, W-2, Form 941 (quarterly), Form 940 (annual FUTA), State W-2 | T3 |
| **Tenant customizing** — L2 regulation extending US.Payroll without modifying it (§132 transit benefit, WFH stipend) | T4 |

---

## Demo Company: Apex Digital Solutions LLC

A fictional IT consulting company that exercises the full breadth of US payroll complexity:

| Dimension | Coverage |
|:---|:---|
| Pay frequencies | Monthly · Biweekly · Weekly (3 payrolls) |
| Pay types | Salaried · Hourly |
| States | NY (incl. NYC local) · NJ · CT · CA · TX · PA (incl. Philadelphia Wage Tax) |
| Multi-state | NJ→NY commuter · CT→NY commuter · Three-state allocation (NY/NJ/CT) |
| Benefits | 401(k) · §125 health · §223 HSA · Company car fringe |
| Special | SECURE 2.0 catch-up · Garnishment · Supplemental wages · CA daily OT |
| Reports | Payslip · W-2 · State W-2 · Form 941 · Form 940 |

**Employees:**

| # | Name | Role | Payroll | Key Feature |
|:---:|:---|:---|:---|:---|
| 1 | Sara Chen | CFO | Monthly | NYC · company car · 401(k) · W-4 extras |
| 2 | Robert Stevenson | VP Engineering | Monthly | Age 59 · 401(k) limit with age-50 catch-up |
| 3 | Marcus Johnson | Sr. Software Eng. | Biweekly | NJ→NY commuter · no reciprocity |
| 4 | Priya Patel | Project Manager | Biweekly | CT→NY commuter · Head of Household |
| 5 | Kevin Wu | Cloud Architect | Biweekly | CA hourly · daily overtime · SDI |
| 6 | Jessica Torres | Account Executive | Biweekly | TX · no SIT · March bonus |
| 7 | Carlos Rivera | Principal Consultant | Biweekly | Three-state allocation NY/NJ/CT |
| 8 | Linda Okafor | HR Coordinator | Biweekly | NY · garnishment (child support) |
| 9 | David Kim | IT Support Tech | Weekly | PA hourly · Philadelphia Wage Tax · PA UC |
| 10 | Ashley Park | QA Engineer | Weekly | CA hourly · SDI uncapped |

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
  - `US.Payroll.Data.State.Withholding.2026.json`
  - `US.Payroll.Data.State.MultiState.2026.json`
  - `US.Payroll.Data.State.WageBase.2026.json`
  - `US.Payroll.Data.Local.Tax.2026.json`
  - `US.Payroll.Data.Local.Tax.WageBase.2026.json`
  - `US.Payroll.Data.Local.Tax.IndianaCounty.2026.json`
  - `US.Payroll.Data.Local.Tax.Philadelphia.2026.json`
  - `US.Payroll.Data.Local.Tax.NewYork.2026.json`
  - `US.Payroll.Data.Federal.Garnishment.2026.json`

---

## Key Design Decisions

| Decision | Why |
|:---|:---|
| One division per pay frequency | The pay frequency is the period of the division calendar (monthly, biweekly, weekly) and sets the IRS Pub 15-T periods per year (12/26/52). Three payrolls × three divisions = three pay frequencies in one tenant. |
| L2 regulation for customization | `Apex.Payroll` extends `US.Payroll` without modifying it. Any future update to `US.Payroll` is automatically inherited. |
| Integration tests as documentation | Each `*.et.json` in `Tests/` documents the expected payslip values with a full calculation trace in the `reason` field. |

---

## Tests

The [`Tests/`](Tests/) folder contains 18 integration tests (223 asserted wage type results) — one per key demo scenario,
including the March bonus, the annual limits over consecutive monthly payruns and the T2 lifecycle events.
Run them after T1-Bootstrap to validate your setup and confirm expected payslip values.

```bash
cd Tests
pecmd Run.Tests.pecmd /TestPrecision2
```

Each test folder has a `README.md` with the scenario description and assertion table.

---

## Quick Start

Run the full setup from the repo root — this bootstraps the tenant,
imports all employee data, sets up T4 customizing, and runs all 14 integration tests:

```bash
Setup.cmd
```

Or step through the tutorials manually, starting with
[T1-Bootstrap/README.md](T1-Bootstrap/README.md).

---

## License

[MIT](LICENSE) — free to use for any purpose.
