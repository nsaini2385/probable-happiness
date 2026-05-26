@ECHO OFF
SETLOCAL EnableDelayedExpansion
REM ============================================================
REM  WSDoM CM94 CLIENT UNINSTALL - Intune Edition
REM ============================================================

REM --- LOG PATH: prefer UNC share; fall back to local ---
SET "LOGPATH="
PING -n 1 -w 1000 WPWTWS0204 >NUL 2>&1
IF %ERRORLEVEL%==0 (
    IF NOT EXIST "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\UNINSTALL" MKDIR "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\UNINSTALL" 2>NUL
    SET "LOGPATH=\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%"
)
IF "%LOGPATH%"=="" (
    SET "LOGPATH=C:\Windows\Logs\WSDoM"
    IF NOT EXIST "%LOGPATH%\UNINSTALL" MKDIR "%LOGPATH%\UNINSTALL"
)

ECHO 01. UNINSTALL Kapish Easy Link
START /WAIT "" MsiExec.exe /X{2F5DEBF0-3F3E-42C7-BDC8-EC3FDD63DDAB} /quiet /norestart
START /WAIT "" MsiExec.exe /X{D5EA7DF7-F34E-42DF-B6C4-74A830D4EF35} /quiet /norestart
START /WAIT "" MsiExec.exe /X{4218FF6A-1793-4513-8CD2-DF25288C5B61} /quiet /norestart
START /WAIT "" MsiExec.exe /X{C6C78ACE-496D-445F-93D5-E5799AA94948} /quiet /norestart

ECHO 02. UNINSTALL Kapish Folder Wizard
START /WAIT "" MsiExec.exe /X{7E28F642-69A1-4582-908B-B84F0A841DB9} /quiet /norestart
START /WAIT "" MsiExec.exe /X{2753C6B7-570E-4211-8F13-9C6249E16620} /quiet /norestart

ECHO 03. UNINSTALL Kapish PDF Wizard
START /WAIT "" MsiExec.exe /X{E42BCA13-9B7D-45D8-9066-ED034A5D5526} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x64.log"
START /WAIT "" MsiExec.exe /X{2C2D4712-1818-4EE1-A5D1-F1C23C9EA394} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x86.log"

ECHO 04. UNINSTALL Kapish Record Remover
START /WAIT "" MsiExec.exe /X{E4240372-B832-4154-AB41-182AD829BAF3} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\04-UNINSTALL-Kapish-Record-Remover-x64.log"
START /WAIT "" MsiExec.exe /X{5AF2757F-507D-4C20-A2C8-88A028E9A6DB} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\04-UNINSTALL-Kapish-Record-Remover-x86.log"

ECHO 05. UNINSTALL Kapish Workflow Wizard
START /WAIT "" MsiExec.exe /X{C4E79744-DD36-4E6E-8FC3-18F95F1A748B} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x64.log"
START /WAIT "" MsiExec.exe /X{D1997875-DE4C-4B77-B340-D3FAFD0310E2} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x86.log"

ECHO 06. UNINSTALL Kapish Excel Add-In
START /WAIT "" MsiExec.exe /X{981398A2-0561-4AB5-99D7-B79785345FAD} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\06-UNINSTALL-Kapish-Excel-AddIn.log"
REG DELETE "HKLM\Software\Kapish\Excel Add-In" /V DefaultTabName /F /REG:32 2>NUL

ECHO 07. UNINSTALL Kapish Word Add-In
START /WAIT "" MsiExec.exe /X{6449CADC-497A-47B2-A82A-64590F06586D} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\07-UNINSTALL-Kapish-Word-AddIn.log"
REG DELETE "HKLM\Software\Kapish\Word Add-In" /V DefaultTabName /F /REG:32 2>NUL

ECHO 08. UNINSTALL Kapish Explorer
START /WAIT "" MsiExec.exe /X{D27FC147-2274-4602-8D1C-806C6D18E106} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x64-5.10.5024.log"
START /WAIT "" MsiExec.exe /X{3D4414A4-BD4D-4B53-AA99-909E786F6E34} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x64-5.11.5026.log"
START /WAIT "" MsiExec.exe /X{AB9BF394-2717-41C2-ADAA-847FB2BE2AD8} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x86-5.10.5024.log"
START /WAIT "" MsiExec.exe /X{68588BB0-F37B-4A88-BEB6-3D395B322F75} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x86-5.11.5026.log"
REG DELETE "HKLM\Software\Kapish\TRIM Explorer" /V MaxLengthFilepath /F /REG:64 2>NUL
REG DELETE "HKLM\Software\Kapish\TRIM Explorer" /V MaxLengthFilepath /F /REG:32 2>NUL

ECHO 09. UNINSTALL Micro Focus Content Manager
START /WAIT "" MsiExec.exe /X{4E6086CA-B627-4AFA-A41C-8F86363832C7} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-CM-x64-9.3.2.0430.log"
START /WAIT "" MsiExec.exe /X{CEA78427-2FFF-4C38-B6F0-A108724C7421} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-CM-x86-9.3.2.0430.log"

DEL "%PUBLIC%\Desktop\Kapish Explorer.lnk" /Q /F 2>NUL
DEL "%PUBLIC%\Desktop\WSDoM Desktop.lnk"   /Q /F 2>NUL
DEL "%PUBLIC%\Desktop\WSDoM Explorer.lnk"  /Q /F 2>NUL
RD  "%PROGRAMFILES%\Kapish"                                                          /S /Q 2>NUL
RD  "%PROGRAMFILES(x86)%\Kapish"                                                     /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish"                 /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager"        /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM"                  /S /Q 2>NUL
RD  "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}"                 /S /Q 2>NUL
RD  /S /Q "%PROGRAMFILES%\Micro Focus\Content Manager"                               2>NUL
RD  /S /Q "%PROGRAMFILES(x86)%\Micro Focus\Content Manager"                          2>NUL
RD  /S /Q "C:\Micro Focus Content Manager\"                                          2>NUL

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish"                              /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish"                              /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager"         /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager"         /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43"           /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43"           /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office" /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office" /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office" /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office" /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86-x64"  /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86-x64"  /F /REG:64 2>NUL

ECHO [INFO] WSDoM uninstall complete.
ENDLOCAL
EXIT /B 0
