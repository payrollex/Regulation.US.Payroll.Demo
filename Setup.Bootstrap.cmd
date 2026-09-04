@echo off
setlocal

:: ============================================================
:: Setup.Bootstrap.cmd -- Regulation.US.Payroll.Demo (Windows)
::
:: Full demo setup pipeline:
::   1. Regulation      (US.Payroll packages + 2026 data regulations)
::   2. Tenant cleanup  (TenantDelete Apex.DigitalSolutions)
::   3. Bootstrap       (Apex payrolls + employees + company cases)
::
:: Prerequisites:
::   - .pecmd extension registered (Register-PecmdExtension.ps1)
::   - PE backend running
::   - Regulation.US.Payroll repo at ..\Regulation.US.Payroll
::   - TenantIsolationLevel != None in appsettings (e.g. "Read" or "Write")
::     Required for RegulationShare controller + cross-tenant case resolution
::   - PE backend built with SharedRegulation fix
::     (CaseRepository + CaseFieldRepository)
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
echo   pecmd PayrunPreviewTest T1-Bootstrap\Setup.json
echo   pecmd PayrunEmployeeTest Tests\Run.Tests.pecmd /TestPrecision2 /OkOnFail
echo.
