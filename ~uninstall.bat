@echo off
echo administrative permissions required, detecting permissions...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo success - administrative permissions confirmed
    echo.
) else (
    echo failure - current permissions inadequate

    pause

    exit
)

set scriptPath=%~dp0scripts\~uninstall.ps1

echo script path = %scriptPath%
echo.

pwsh -noprofile -executionpolicy bypass -file "%scriptPath%"

exit
