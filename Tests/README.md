# Tests — Integration Test Suite

Scenario-based integration tests that validate the demo company setup and document
expected payroll results for each key scenario.

> **Purpose:** Setup validation + scenario documentation + CI regression.
> These are **not** compliance tests (those live in `Regulation.US.Payroll`).

---

## Prerequisites

The test files and READMEs document the expected results and can be read without any setup.
Running the tests requires:

- A licensed US.Payroll installation (see [Running the Demo](../README.md#running-the-demo-licensed-users))
- Payroll Engine backend running and accessible
- Tutorial T1-Bootstrap completed (`Tests/` assumes Apex tenant and all employee cases exist)
- Tutorial T4-Customizing completed (required by DEMO-TC08)
- `pecmd` configured with the correct backend URL

---

## Test Inventory

| Test | Employee | Payroll | Key Feature | Net pay |
|:---|:---|:---|:---|---:|
| [DEMO-TC01](DEMO-TC01-US-Sara-Monthly/) | Sara Chen | Monthly | NYC · company car (taxed, not paid out) · W-4 Steps 3/4(c) · NY PFL | $11,444.03 |
| [DEMO-TC02](DEMO-TC02-US-Marcus-NJtoNY/) | Marcus Johnson | Biweekly | NJ→NY commuter, no reciprocity | $3,662.08 |
| [DEMO-TC03](DEMO-TC03-US-Carlos-ThreeState/) | Carlos Rivera | Biweekly | Three-state allocation NY/NJ/CT | $4,844.76 |
| [DEMO-TC04](DEMO-TC04-US-Kevin-CADailyOT/) | Kevin Wu | Biweekly | CA daily overtime (§510 sprint week) · CA SDI | $3,193.71 |
| [DEMO-TC05](DEMO-TC05-US-Jessica-TX/) | Jessica Torres | Biweekly | TX baseline, no state income tax | $2,282.60 |
| [DEMO-TC06](DEMO-TC06-US-Linda-Garnishment/) | Linda Okafor | Biweekly | Child support garnishment · CCPA 60% limit | $1,468.52 |
| [DEMO-TC07](DEMO-TC07-US-David-Philadelphia/) | David Kim | Weekly | PA SIT + Philadelphia Wage Tax (resident) · PA UC | $982.22 |
| [DEMO-TC08](DEMO-TC08-US-Apex-Transit-L2/) | Carlos Rivera | Biweekly | L2 §132(f) transit benefit with monthly limit | $4,720.53 |
| [DEMO-TC09](DEMO-TC09-US-Robert-Monthly/) | Robert Stevenson | Monthly | Fixed 401(k) amount, age-50 catch-up range · W-4 Step 3 | $5,054.02 |
| [DEMO-TC10](DEMO-TC10-US-Priya-CTtoNY/) | Priya Patel | Biweekly | CT→NY commuter · Head of Household | $2,691.64 |
| [DEMO-TC11](DEMO-TC11-US-Ashley-CAWeekly/) | Ashley Park | Weekly | CA hourly weekly baseline · CA SDI | $1,244.55 |
| [DEMO-TC12](DEMO-TC12-US-Jessica-Bonus/) | Jessica Torres | Biweekly | $10,000 bonus · supplemental FIT 22% | $9,317.60 |
| [DEMO-TC13](DEMO-TC13-US-Sara-WageBase/) | Sara Chen | Monthly × 11 | NY PFL maximum · SS wage base · Additional Medicare | $12,605.14 (Nov) |
| [DEMO-TC14](DEMO-TC14-US-Robert-401kLimit/) | Robert Stevenson | Monthly × 12 | 401(k) annual limit with catch-up · NY PFL maximum | $6,001.91 (Dec) |
| [DEMO-TC15](DEMO-TC15-US-James-NewHire/) | James Lee | Biweekly × 2 | New hire mid-period · CA DE 4 · CA SDI | $1,557.30 / $3,154.91 |
| [DEMO-TC16](DEMO-TC16-US-Marcus-SalaryChange/) | Marcus Johnson | Biweekly × 2 | Salary change mid-period · NJ→NY commuter | $3,849.26 / $3,989.64 |
| [DEMO-TC17](DEMO-TC17-US-Linda-FMLA/) | Linda Okafor | Biweekly × 3 | Unpaid FMLA leave and return · CCPA limit on low wages | $65.66 / $0.00 / $1,202.37 |
| [DEMO-TC18](DEMO-TC18-US-Jessica-Relocation/) | Jessica Torres | Biweekly × 3 | Relocation TX → CA · CA SDI by working days · payrun after the change | $2,282.60 / $2,200.97 / $2,193.78 |

18 tests, 223 asserted wage type results. DEMO-TC13 and DEMO-TC14 run consecutive monthly payruns and
assert the months in which an annual limit takes effect. DEMO-TC15 to DEMO-TC18 assert the lifecycle
events of [T2-Lifecycle](../T2-Lifecycle/) for the affected periods; DEMO-TC15 imports the James Lee
employee record first, because test employees are cloned from an existing employee of the tenant.

---

## Run All Tests

```bash
pecmd Run.Tests.pecmd /TestPrecision2
```

Or run individual tests:

```bash
pecmd PayrunEmployeeTest DEMO-TC01-US-Sara-Monthly/DEMO-TC01-US-Sara-Monthly.et.json /TestPrecision2
```

---

## Expected Values

All `*.et.json` files contain verified `payrollResults` with exact wage type values.
Federal, FICA, state program, garnishment and net pay values were recalculated by hand
from the case data. State and local withholding uses the state withholding certificate of each
employee (`StateWithholdingCertificate`: NY IT-2104, NJ-W4, CT-W4, CA DE 4); the NY, NYC and CT
values were recalculated with the official tables, the others come from US.Payroll, where they are
covered by its regression tests against the official examples. The `reason` field in each
`payrunJobInvocations` entry documents the full calculation chain.

Run the full setup first:

```bash
cd ..
Setup.cmd
```
