@echo off

:: ------------------------------------------------------------
::  Show popup to logged‑in user (must use ServiceUI for Intune)
:: ------------------------------------------------------------
:: %~dp0ServiceUI.exe -process:explorer.exe %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File %~dp0Start-Upgrade1.ps1


:: :: --- Your existing logic below 
if exist "%ProgramFiles(x86)%\Microsoft Office\root\Office16\Visio.exe" "%~dp0setup.exe" /configure "%~dp0RemoveVisioStd.xml"
if exist "%ProgramFiles%\Microsoft Office\root\Office16\Visio.exe" "%~dp0setup.exe" /configure "%~dp0RemoveVisioStd.xml"

if exist "%ProgramFiles(x86)%\Microsoft Office\root\Office16\Winproj.exe" "%~dp0setup.exe" /configure "%~dp0Uninstall-ProjStdXVolume.xml"
if exist "%ProgramFiles%\Microsoft Office\root\Office16\Winproj.exe" "%~dp0setup.exe" /configure "%~dp0Uninstall-ProjStdXVolume.xml"

if exist "C:\Program Files (x86)\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe" (
    "C:\Program Files (x86)\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe" /uninstall PROPLUS /config "%~dp0O2016\remove2016.xml"
)

if exist "C:\Program Files\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe" (
    "C:\Program Files\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe" /uninstall PROPLUS /config "%~dp0O2016\remove2016.xml"
)

if exist "%ProgramFiles(x86)%\Microsoft Office\root\Office16\winproj.exe" "%~dp0setup.exe" /configure "%~dp0removeprj.xml"

if exist "%ProgramFiles(x86)%\Microsoft Office\root\Office16\Visio.exe" "%~dp0setup.exe" /configure "%~dp0RemoveVisioStd2021.xml"

if exist "%ProgramFiles(x86)%\Microsoft Office\root\Office16\outlook.exe" "%~dp0setup.exe" /configure "%~dp0remove.xml"


::"%~dp0ServiceUI.exe" -process:explorer.exe %~dp0setup.exe /configure %~dp0configuration.xml

%~dp0setup.exe /configure %~dp0configuration.xml

:: Explicitly exit with success code for Intune
exit /b 0
