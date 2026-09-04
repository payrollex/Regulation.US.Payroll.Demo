@echo off
setlocal

:: ============================================================
:: Delete.cmd -- Regulation.US.Payroll.Demo (Windows)
::
:: Deletes the Apex.DigitalSolutions demo tenant.
::
:: Prerequisites:
::   - .pecmd extension registered (Register-PecmdExtension.ps1)
::   - PE backend running
:: ============================================================

echo.
echo === Delete Apex.DigitalSolutions ===
echo.

start /b /wait "" "T1-Bootstrap\Delete.pecmd"
if errorlevel 1 (
    echo.
    echo [FAILED] Tenant delete failed
    pause
    exit /b 1
)

echo [OK] Tenant deleted
echo.
