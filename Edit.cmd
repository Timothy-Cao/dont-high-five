@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Run.ps1" -Mode Edit
if errorlevel 1 pause
