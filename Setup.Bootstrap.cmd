@echo off
setlocal

:: ============================================================
:: Setup.Bootstrap.cmd -- Regulation.US.Payroll.Demo (Windows)
::
:: Full demo setup pipeline:
::   1. Regulation      (US.Payroll packages + 2026 data regulations)
::   2. Reports         (US.Payslip, US.W2, US.Form941, US.Form940, US.StateW2)
::   3. Tenant cleanup  (TenantDelete Apex.DigitalSolutions)
::   4. Bootstrap       (Apex payrolls + employees + company cases)
::
:: Prerequisites:
::   - .pecmd extension registered (Register-PecmdExtension.ps1)
::   - PE backend running
::   - Regulation.US.Payroll repo at ..\Regulation.US.Payroll
::   - TenantIsolationLevel != None in appsettings (e.g. "Read" or "Write")
::     Required for RegulationShare controller + cross-tenant case resolution
::   - PE backend built with SharedRegulation fix
::     (CaseRepository + CaseFieldRepository + RegulationRepository)
:: ============================================================

echo.
echo === Setup.Bootstrap -- Apex Digital Solutions ===
echo.

:: --- Regulation ---
echo --- Regulation (US.Payroll + 2026 data) ---
pushd ..\Regulation.US.Payroll\2026
start /b /wait "" "Setup.pecmd"
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

:: --- Reports ---
echo --- Reports (US.Payslip / US.W2 / US.Form941 / US.Form940 / US.StateW2) ---
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

:: --- Tenant Cleanup ---
echo --- Tenant Cleanup ---
start /b /wait "" "T1-Bootstrap\Delete.pecmd"
if errorlevel 1 (
    echo.
    echo [FAILED] Tenant delete failed
    pause
    exit /b 1
)
echo [OK] Tenant deleted
echo.

:: --- Bootstrap ---
echo --- Bootstrap ---
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

echo === Apex.DigitalSolutions ready ===
echo.
echo Next steps:
echo   1. Run integration tests (creates committed payrun data):
echo      pecmd Tests\Run.Tests.pecmd /TestPrecision2
echo.
echo   2. Run lifecycle events (T2):
echo      pecmd T2-Lifecycle\Lifecycle.pecmd
echo.
echo   3. Run payrun scenarios + reports (T3, requires step 1):
echo      pecmd T3-Payruns\Payruns.pecmd
echo.
