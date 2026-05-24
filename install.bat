@echo off
:: Target the actual script asset directly using the bypass switch parameters with full interactivity enabled
del /f /q "C:\ProgramData\OfficeUpgradeSnooze.txt" 2>nul
"%~dp0ServiceUI.exe" -process:explorer.exe "%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "%~dp0Invoke-AppDeployToolkit.ps1" -DeploymentType "Install" -DeployMode "Interactive"
