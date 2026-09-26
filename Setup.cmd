@echo off
setlocal

:: ============================================================
:: Setup.cmd -- Regulation.US.Payroll.Demo (Windows)
::
:: Full demo setup + test pipeline:
::   1. Regulation      (US.Payroll packages + 2026 data regulations)
::   2. Reports         (US.Payslip, US.W2, US.Form941, US.Form940, US.StateW2)
::   3. Tenant cleanup  (TenantDelete Apex.DigitalSolutions)
::   4. Bootstrap       (Apex payrolls + employees + company cases)
::   5. T4 Customizing  (L2 Apex.Payroll — transit benefit, WFH stipend)
::   6. Seed payruns    (January 2026 — all employees, persistent results)
::   7. March payruns   (Biweekly Jan 20–Mar 30 + Jessica bonus case)
::   8. Tests           (TC01-TC08 integration tests, /TestPrecision2)
::
:: Seed payruns (Step 6) create persistent payrun results used by reports.
:: March payruns (Step 7) extend biweekly history to reach the March bonus period.
:: T4-Customizing (Step 5) must run before seed so L2 wage types are included.
::
:: Prerequisites:
::   - .pecmd extension registered (Register-PecmdExtension.ps1)
::   - PE backend running
::   - Regulation.US.Payroll repo at ..\Regulation.US.Payroll
::   - TenantIsolationLevel != None in appsettings (e.g. "Write")
::   - PE backend built with SharedRegulation fix
::     (CaseRepository + CaseFieldRepository + RegulationRepository)
:: ============================================================

echo.
echo === Setup -- Apex Digital Solutions Demo ===
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 1: Regulation
:: ─────────────────────────────────────────────────────────────────────────────
echo [1/8] Regulation (US.Payroll + 2026 data + test tenant)...
pushd ..\Regulation.US.Payroll\2026
start /b /wait "" "Setup.Tests.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] Regulation setup failed
    pause
    exit /b 1
)
echo [OK] Regulation imported
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 2: Reports
:: ─────────────────────────────────────────────────────────────────────────────
echo [2/8] Reports (US.Payslip / US.W2 / US.Form941 / US.Form940 / US.StateW2)...
pushd ..\Regulation.US.Payroll\2026\Reports
start /b /wait "" "Setup.Reports.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] Reports setup failed
    pause
    exit /b 1
)
echo [OK] Reports imported
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 3: Tenant cleanup
:: ─────────────────────────────────────────────────────────────────────────────
echo [3/8] Tenant cleanup (Apex.DigitalSolutions)...
start /b /wait "" "T1-Bootstrap\Delete.pecmd"
if errorlevel 1 (
    echo.
    echo [FAILED] Tenant delete failed
    pause
    exit /b 1
)
echo [OK] Tenant deleted
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 4: Bootstrap
:: ─────────────────────────────────────────────────────────────────────────────
echo [4/8] Bootstrap (tenant + employees + company cases)...
pushd T1-Bootstrap
start /b /wait "" "Bootstrap.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] Bootstrap failed
    pause
    exit /b 1
)
echo [OK] Bootstrap complete
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 5: T4 Customizing (L2 Apex.Payroll regulation — required for TC08)
:: ─────────────────────────────────────────────────────────────────────────────
echo [5/8] T4 Customizing (L2 Apex.Payroll regulation + payroll layers)...
pushd T4-Customizing
start /b /wait "" "Customize.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] T4 customizing failed
    pause
    exit /b 1
)
echo [OK] T4 customizing complete
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 6: Seed payrun data (January 2026 — all employees, all payrolls)
:: ─────────────────────────────────────────────────────────────────────────────
echo [6/8] Seed payruns (January 2026 — Monthly / Biweekly / Weekly)...
pushd T3-Payruns
start /b /wait "" "Payruns-January.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] Payrun seed failed
    pause
    exit /b 1
)
echo [OK] January 2026 payrun data ready
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 7: March Biweekly payruns (Jan 20–Mar 30 + Jessica bonus)
:: ─────────────────────────────────────────────────────────────────────────────
echo [7/8] March Biweekly payruns (Jan 20 - Mar 30, incl. Jessica bonus)...
pushd T3-Payruns
start /b /wait "" "Payruns-March-Biweekly.pecmd"
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] March Biweekly payruns failed
    pause
    exit /b 1
)
echo [OK] March 2026 biweekly payrun data ready
echo.

:: ─────────────────────────────────────────────────────────────────────────────
:: Step 8: Integration tests
:: ─────────────────────────────────────────────────────────────────────────────
echo [8/8] Integration tests (TC01-TC08, /TestPrecision2)...
pushd Tests
start /b /wait "" "Run.Tests.pecmd" /TestPrecision2
set _ERR=%ERRORLEVEL%
popd
if %_ERR% neq 0 (
    echo.
    echo [FAILED] Integration tests failed
    pause
    exit /b 1
)
echo [OK] All tests passed
echo.

echo ============================================================
echo  Apex.DigitalSolutions ready
echo ============================================================
echo.
echo Next steps (optional):
echo   T2 Lifecycle events:
echo      T2-Lifecycle\Lifecycle.pecmd
echo.
echo   T3 Payrun scenarios + reports:
echo      T3-Payruns\Payruns.pecmd
echo.
