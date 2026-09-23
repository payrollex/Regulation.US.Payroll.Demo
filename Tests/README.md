# Tests — Integration Test Suite

Scenario-based integration tests that validate the demo company setup and document
expected payroll results for each key scenario.

> **Purpose:** Setup validation + scenario documentation + CI regression.
> These are **not** compliance tests (those live in `Regulation.US.Payroll`).

---

## Prerequisites

- Payroll Engine backend running and accessible
- Tutorial T1-Bootstrap completed (`Tests/` assumes Apex tenant and all employee cases exist)
- `pecmd` configured with the correct backend URL

---

## Test Inventory

| Test | Employee | Payroll | Key Feature |
|:---|:---|:---|:---|
| [DEMO-TC01](DEMO-TC01-US-Sara-Monthly/) | Sara Chen | Monthly | Company car · 401k · W-4 Step3/4c · Add'l Medicare |
| [DEMO-TC02](DEMO-TC02-US-Marcus-NJtoNY/) | Marcus Johnson | Biweekly | NJ→NY split-state withholding |
| [DEMO-TC03](DEMO-TC03-US-Carlos-ThreeState/) | Carlos Rivera | Biweekly | Three-state allocation NY/NJ/CT |
| [DEMO-TC04](DEMO-TC04-US-Kevin-CADailyOT/) | Kevin Wu | Biweekly | CA daily overtime (§510 sprint week) |
| [DEMO-TC05](DEMO-TC05-US-Jessica-TX/) | Jessica Torres | Biweekly | TX no-SIT baseline + supplemental bonus |
| [DEMO-TC06](DEMO-TC06-US-Linda-Garnishment/) | Linda Okafor | Biweekly | Child support garnishment · CCPA limit |
| [DEMO-TC07](DEMO-TC07-US-David-Philadelphia/) | David Kim | Weekly | PA SIT + Philadelphia EIT (PSD codes) |
| [DEMO-TC08](DEMO-TC08-US-Apex-Transit-L2/) | All / Carlos | Biweekly | L2 §132 transit benefit (T4-Customizing) |

---

## Run All Tests

```bash
pecmd PayrunEmployeeTest Run.Tests.pecmd
```

Or run individual tests:

```bash
pecmd PayrunEmployeeTest DEMO-TC01-US-Sara-Monthly/DEMO-TC01-US-Sara-Monthly.et.json
```

---

## Expected Values

All `*.et.json` files contain verified `payrollResults` sections with exact wage type
values confirmed by PE runs. The `reason` field in each `payrunJobInvocations` entry
documents the full calculation chain for transparency and audit.

Run the full setup first:

```bash
cd ../T1-Bootstrap
start /b /wait "" "Bootstrap.pecmd"
cd ../Tests
pecmd PayrunEmployeeTest Run.Tests.pecmd
```
