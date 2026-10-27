@echo off
setlocal EnableExtensions DisableDelayedExpansion
powershell.exe -NoProfile -File "%~dp0start-capture.ps1"
exit /b %errorlevel%
