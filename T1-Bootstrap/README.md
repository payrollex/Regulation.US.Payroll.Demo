# T1 — Bootstrap a Company

> **Duration:** ~20 minutes  
> **Role:** Provider / Automator  
> **Prerequisite:** Payroll Engine Backend running, `pecmd` installed, regulation packages available

Set up **Apex Digital Solutions LLC** from zero to "ready for first payrun"
using the `pecmd` CLI.

---

## What You Will Learn

- Create a tenant for a US company
- Import and layer US regulation packages
- Configure three payrolls with different pay frequencies (Monthly / Biweekly / Weekly)
- Onboard 10 employees across 6 states with diverse tax profiles

---

## Run

```bash
pecmd Bootstrap.pecmd
```

Or step by step — see the sections below.

---

## Step 1 — Import Regulation Packages

> *TODO: full tutorial text — see IMPLEMENTATION.md Phase 1*

## Step 2 — Create Tenant Structure

> *TODO: full tutorial text*

## Step 3 — Set Company Cases

> *TODO: full tutorial text*

## Step 4 — Onboard Employees

> *TODO: full tutorial text*

## Step 5 — Verify

> *TODO: full tutorial text*

---

## Files

| File | Description |
|:---|:---|
| `Setup.json` | Tenant, users, division, 10 employees, 3 payrolls, 3 payruns |
| `CompanyCases/Monthly.json` | Company case for Monthly payroll (`US.PayFrequency = Monthly`) |
| `CompanyCases/Biweekly.json` | Company case for Biweekly payroll |
| `CompanyCases/Weekly.json` | Company case for Weekly payroll |
| `Employees/01-SaraChen.json` | CFO — NYC, company car, 401k, SECURE 2.0 comparable |
| `Employees/02-RobertStevenson.json` | VP — age 58, SECURE 2.0 catch-up |
| `Employees/03-MarcusJohnson.json` | Sr. Engineer — NJ→NY commuter |
| `Employees/04-PriyaPatel.json` | PM — CT→NY commuter, Head of Household |
| `Employees/05-KevinWu.json` | Cloud Architect — CA hourly, daily OT |
| `Employees/06-JessicaTorres.json` | Account Executive — TX, no SIT |
| `Employees/07-CarlosRivera.json` | Principal Consultant — three-state NY/NJ/CT |
| `Employees/08-LindaOkafor.json` | HR Coordinator — NYC, garnishment |
| `Employees/09-DavidKim.json` | IT Support — Philadelphia EIT |
| `Employees/10-AshleyPark.json` | QA Engineer — CA 7th-day OT, SDI uncapped |
| `Bootstrap.pecmd` | Full setup script |
