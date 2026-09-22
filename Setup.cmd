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
::   5. Tests           (TC01-TC08 integration tests, /TestPrecision2)
::
:: NOTE: TC08 (L2 transit benefit) requires T4-Customizing to be completed.
::       Comment TC08 out of Tests\Run.Tests.pecmd if T4 is not yet set up.
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
echo [1/5] Regulation (US.Payroll + 2026 data + test tenant)...
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
echo [2/5] Reports (US.Payslip / US.W2 / US.Form941 / US.Form940 / US.StateW2)...
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
echo [3/5] Tenant cleanup (Apex.DigitalSolutions)...
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
echo [4/5] Bootstrap (tenant + employees + company cases)...
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
echo [5/6] T4 Customizing (L2 Apex.Payroll regulation + payroll layers)...
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
:: Step 6: Integration tests
:: ─────────────────────────────────────────────────────────────────────────────
echo [6/6] Integration tests (TC01-TC08, /TestPrecision2)...
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
