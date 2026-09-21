@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Run.ps1" -Mode Verify
set "result=%errorlevel%"
pause
exit /b %result%
