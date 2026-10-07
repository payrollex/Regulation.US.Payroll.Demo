# Tests — Integration Test Suite

Scenario-based integration tests that validate the demo company setup and document
expected payroll results for each key scenario.

> **Purpose:** Setup validation + scenario documentation + CI regression.
> These are **not** compliance tests (those live in `Regulation.US.Payroll`).

---

## Prerequisites

- Payroll Engine backend running and accessible
- Tutorial T1-Bootstrap completed (`Tests/` assumes Apex tenant and all employee cases exist)
- Tutorial T4-Customizing completed (required by DEMO-TC08)
- `pecmd` configured with the correct backend URL

---

## Test Inventory

| Test | Employee | Payroll | Key Feature | Net pay |
|:---|:---|:---|:---|---:|
| [DEMO-TC01](DEMO-TC01-US-Sara-Monthly/) | Sara Chen | Monthly | NYC · company car (taxed, not paid out) · W-4 Steps 3/4(c) · NY PFL | $11,482.38 |
| [DEMO-TC02](DEMO-TC02-US-Marcus-NJtoNY/) | Marcus Johnson | Biweekly | NJ→NY commuter, no reciprocity | $3,662.08 |
| [DEMO-TC03](DEMO-TC03-US-Carlos-ThreeState/) | Carlos Rivera | Biweekly | Three-state allocation NY/NJ/CT | $4,900.80 |
| [DEMO-TC04](DEMO-TC04-US-Kevin-CADailyOT/) | Kevin Wu | Biweekly | CA daily overtime (§510 sprint week) · CA SDI | $3,193.71 |
| [DEMO-TC05](DEMO-TC05-US-Jessica-TX/) | Jessica Torres | Biweekly | TX baseline, no state income tax | $2,282.60 |
| [DEMO-TC06](DEMO-TC06-US-Linda-Garnishment/) | Linda Okafor | Biweekly | Child support garnishment · CCPA 60% limit | $1,468.52 |
| [DEMO-TC07](DEMO-TC07-US-David-Philadelphia/) | David Kim | Weekly | PA SIT + Philadelphia Wage Tax (PSD codes) · PA UC | $982.22 |
| [DEMO-TC08](DEMO-TC08-US-Apex-Transit-L2/) | Carlos Rivera | Biweekly | L2 §132(f) transit benefit with monthly limit | $4,776.91 |
| [DEMO-TC09](DEMO-TC09-US-Robert-Monthly/) | Robert Stevenson | Monthly | Age-50+ 401(k) catch-up · W-4 Step 3 | $5,127.26 |
| [DEMO-TC10](DEMO-TC10-US-Priya-CTtoNY/) | Priya Patel | Biweekly | CT→NY commuter · Head of Household | $2,617.01 |
| [DEMO-TC11](DEMO-TC11-US-Ashley-CAWeekly/) | Ashley Park | Weekly | CA hourly weekly baseline · CA SDI | $1,244.55 |

11 tests, 102 asserted wage type results.

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
from the case data. State and local withholding values (NY, CA, CT, PA) come from
US.Payroll, where they are covered by its regression tests — NY and CA also against the
official NYS-50-T and DE 44 examples. The `reason` field in each `payrunJobInvocations` entry documents
the full calculation chain.

Run the full setup first:

```bash
cd ..
Setup.cmd
```
