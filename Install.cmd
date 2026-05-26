@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE INSTALL WSDoM - Micro Focus Content Manager 9.3.2.0430 (Intune)

REM ============================================================
REM  WSDoM CM94 CLIENT INSTALL - Intune Edition  v10.0
REM  Fixes: START /WAIT on all MSI calls, local log fallback,
REM         reliable Office bit-level detection, proper exit codes
REM ============================================================

REM --- ROOTPATH: folder containing this script and source dirs ---
SET ROOTPATH=%~dp0
IF %ROOTPATH:~-1%==\ SET ROOTPATH=%ROOTPATH:~0,-1%

REM --- LOG PATH: prefer UNC share; fall back to local C:\Temp ---
SET "LOGPATH="
PING -n 1 -w 1000 WPWTWS0204 >NUL 2>&1
IF %ERRORLEVEL%==0 (
    IF NOT EXIST "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\INSTALL"   MKDIR "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\INSTALL"   2>NUL
    IF NOT EXIST "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\UNINSTALL" MKDIR "\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%\UNINSTALL" 2>NUL
    SET "LOGPATH=\\WPWTWS0204\Install-CM93-Logs\%COMPUTERNAME%"
)
IF "%LOGPATH%"=="" (
    SET "LOGPATH=C:\Windows\Logs\WSDoM"
    IF NOT EXIST "%LOGPATH%\INSTALL"   MKDIR "%LOGPATH%\INSTALL"
    IF NOT EXIST "%LOGPATH%\UNINSTALL" MKDIR "%LOGPATH%\UNINSTALL"
)
ECHO [INFO] Log path: %LOGPATH%

REM ============================================================
REM  STEP 1: UNINSTALL PREVIOUS KAPISH ADD-ONS
REM ============================================================

ECHO 01. UNINSTALL Kapish Easy Link
START /WAIT "" MsiExec.exe /X{2F5DEBF0-3F3E-42C7-BDC8-EC3FDD63DDAB} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x64-3.40.3520.log"
START /WAIT "" MsiExec.exe /X{D5EA7DF7-F34E-42DF-B6C4-74A830D4EF35} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x64-3.41.3556.log"
START /WAIT "" MsiExec.exe /X{4218FF6A-1793-4513-8CD2-DF25288C5B61} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x86-3.40.3520.log"
START /WAIT "" MsiExec.exe /X{C6C78ACE-496D-445F-93D5-E5799AA94948} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x86-3.41.3556.log"

ECHO 02. UNINSTALL Kapish Folder Wizard
START /WAIT "" MsiExec.exe /X{7E28F642-69A1-4582-908B-B84F0A841DB9} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x64.log"
START /WAIT "" MsiExec.exe /X{2753C6B7-570E-4211-8F13-9C6249E16620} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x86.log"

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

ECHO 09. UNINSTALL Micro Focus Content Manager (previous versions)
START /WAIT "" MsiExec.exe /X{4E6086CA-B627-4AFA-A41C-8F86363832C7} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-CM-x64-9.3.2.0430.log"
START /WAIT "" MsiExec.exe /X{CEA78427-2FFF-4C38-B6F0-A108724C7421} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-CM-x86-9.3.2.0430.log"

REM --- Cleanup leftover files, folders, registry ---
DEL "%PUBLIC%\Desktop\Kapish Explorer.lnk"    /Q /F 2>NUL
DEL "%PUBLIC%\Desktop\WSDoM Desktop.lnk"      /Q /F 2>NUL
DEL "%PUBLIC%\Desktop\WSDoM Explorer.lnk"     /Q /F 2>NUL
RD  "%PROGRAMFILES%\Kapish"                   /S /Q 2>NUL
RD  "%PROGRAMFILES(x86)%\Kapish"              /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish"          /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager" /S /Q 2>NUL
RD  "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM"           /S /Q 2>NUL
RD  "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}"          /S /Q 2>NUL
RD  /S /Q "%PROGRAMFILES%\Micro Focus\Content Manager"    2>NUL
RD  /S /Q "%PROGRAMFILES(x86)%\Micro Focus\Content Manager" 2>NUL
RD  /S /Q "C:\Micro Focus Content Manager\"               2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish"                              /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish"                              /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager"         /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager"         /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43"            /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43"            /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office"  /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office"  /F /REG:64 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office"  /F /REG:32 2>NUL
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office"  /F /REG:64 2>NUL

REM ============================================================
REM  STEP 2: DETECT MICROSOFT OFFICE BIT LEVEL
REM  Checks file paths first; falls back to registry (handles
REM  Microsoft 365 / Click-to-Run installs reliably)
REM ============================================================
SET "OFFICE_ARCH=x64"

REM --- File-path checks (traditional MSI Office installs) ---
IF EXIST "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE"           SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"           SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE"      SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"      SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"     SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE"     SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office15\WINWORD.EXE" SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE" SET "OFFICE_ARCH=x86"

REM --- Registry fallback for Microsoft 365 / C2R ---
REM   If Bitness key is present in WOW6432Node it is 32-bit; in native HKLM it is 64-bit
REG QUERY "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x86"
REG QUERY "HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x64"
REM  WOW node wins over native if both keys exist (32-bit Office on 64-bit OS)
REG QUERY "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 (
    REG QUERY "HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
    IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x86"
)

ECHO [INFO] Detected Office architecture: %OFFICE_ARCH%

IF /I "%OFFICE_ARCH%"=="x86" GOTO :INSTALL_x86_CM

REM ============================================================
REM  STEP 3A: INSTALL x64 CONTENT MANAGER + KAPISH ADD-ONS
REM ============================================================
:INSTALL_x64_CM
ECHO 10. INSTALL Micro Focus Content Manager 9.3.2.0430 x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\MicroFocus\CM_x64_9300178.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\10-INSTALL-CM-x64-9300178.log" ^
    INSTALLDIR="%PROGRAMFILES%\Micro Focus\Content Manager\" ^
    ADDLOCAL="HPTRIM,Client" ALLUSERS="1" AUTHMECH="0" AUTOGG="1" ^
    DEFAULTDB="43" DEFAULTDBNAME="Corporate Records Production" ^
    EXCEL_ON="1" OUTLOOK_ON="1" POWERPOINT_ON="1" ^
    PRIMARYURL="WPWTWS0203.melb.ad" PROJECT_ON="1" ^
    SECONDARYURL="WPWTWS0204.melb.ad" STARTMENU_NAME="Content Manager" ^
    TRIM_DSK="0" TRIMREF="TRIM" TRIMUserSetup_On="0" WORD_ON="1"

START /WAIT "" MsiExec.exe /UPDATE "%ROOTPATH%\SourceX64\MicroFocus\CM_x64_9320418.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\10-INSTALL-CM-x64-9320418.log"
START /WAIT "" MsiExec.exe /UPDATE "%ROOTPATH%\SourceX64\MicroFocus\CM_x64_9320430.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\10-INSTALL-CM-x64-9320430.log"
REGSVR32 /S "%PROGRAMFILES%\Micro Focus\Content Manager\trimsdk.dll"
REG ADD "HKEY_CLASSES_ROOT\TRIM5.Record.Reference\Shell\open\Command" /V "" /T "REG_SZ" /D "\"%PROGRAMFILES%\Micro Focus\Content Manager\Trim.exe\" \"%%1\"" /F

IF EXIST "%ROOTPATH%\SourceX86\MicroFocus\UIgnore.tlx" COPY "%ROOTPATH%\SourceX86\MicroFocus\UIgnore.tlx" "C:\Micro Focus Content Manager\Lex\UIgnore.tlx" /Y

ECHO 11. INSTALL Kapish Easy Link x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish Easy Link-x64-3.41.3556.msi" DISABLEADVTSHORTCUTS=1 /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Kapish-Easy-Link-x64.log"

ECHO 12. INSTALL Kapish Folder Wizard x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish Folder Wizard-x64-3.52.1910.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\12-INSTALL-Kapish-Folder-Wizard-x64.log"

ECHO 13. INSTALL Kapish PDF Wizard x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish PDF Wizard-x64-2.01.1110.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\13-INSTALL-Kapish-PDF-Wizard-x64.log"

ECHO 14. INSTALL Kapish Record Remover x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish Record Remover-x64-1.60.1400.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\14-INSTALL-Kapish-Record-Remover-x64.log"

ECHO 15. INSTALL Kapish Workflow Wizard x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish Workflow Wizard-x64-1.04.1066.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\15-INSTALL-Kapish-Workflow-Wizard-x64.log"

ECHO 16. INSTALL Kapish Excel Add-In
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Excel Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\16-INSTALL-Kapish-Excel-AddIn.log"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Excel Add-In"          /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F /REG:32
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Excel Add-In" /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F

ECHO 17. INSTALL Kapish Word Add-In
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Word Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\17-INSTALL-Kapish-Word-AddIn.log"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Word Add-In"           /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F /REG:32
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Word Add-In" /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F

ECHO 18. INSTALL Kapish Explorer x64
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX64\Kapish\Kapish_Explorer-x64-5.11.5026.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\18-INSTALL-Kapish-Explorer-x64.log"
REG ADD "HKLM\Software\Kapish\TRIM Explorer" /V "MaxLengthFilepath" /T "REG_DWORD" /D "200" /F /REG:64

REM --- Rebrand Explorer icons (x64) ---
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%PROGRAMFILES%\Kapish\Explorer\WSDoM Explorer.ico" /Y
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%PROGRAMFILES%\Kapish\Explorer\Icons\explorer-48x48.ico" /Y
DEL  "%SYSTEMROOT%\Installer\{3D4414A4-BD4D-4B53-AA99-909E786F6E34}\MSIIcon"           /Q /F 2>NUL
DEL  "%SYSTEMROOT%\Installer\{3D4414A4-BD4D-4B53-AA99-909E786F6E34}\MainShortcutIcon.dll" /Q /F 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%SYSTEMROOT%\Installer\{3D4414A4-BD4D-4B53-AA99-909E786F6E34}\MSIIcon" /Y
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%SYSTEMROOT%\Installer\{3D4414A4-BD4D-4B53-AA99-909E786F6E34}\MainShortcutIcon.dll" /Y
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}"            /V ""        /D "WSDoM Explorer"                      /T "REG_SZ" /F /REG:64
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}"            /V "InfoTip" /D "Browse WSDoM within Windows Explorer" /T "REG_SZ" /F /REG:64
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}\DefaultIcon" /V ""       /D "%PROGRAMFILES%\Kapish\Explorer\WSDoM Explorer.ico" /T "REG_SZ" /F /REG:64

GOTO :UserSettings

REM ============================================================
REM  STEP 3B: INSTALL x86 CONTENT MANAGER + KAPISH ADD-ONS
REM ============================================================
:INSTALL_x86_CM
ECHO 19. INSTALL Micro Focus Content Manager 9.3.2.0430 x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\MicroFocus\CM_x86_9300178.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\19-INSTALL-CM-x86-9300178.log" ^
    INSTALLDIR="%PROGRAMFILES(x86)%\Micro Focus\Content Manager\" ^
    ADDLOCAL="HPTRIM,Client" ALLUSERS="1" AUTHMECH="0" AUTOGG="1" ^
    DEFAULTDB="43" DEFAULTDBNAME="Corporate Records Production" ^
    EXCEL_ON="1" OUTLOOK_ON="1" POWERPOINT_ON="1" ^
    PRIMARYURL="WPWTWS0203.melb.ad" PROJECT_ON="1" ^
    SECONDARYURL="WPWTWS0204.melb.ad" STARTMENU_NAME="Content Manager" ^
    TRIM_DSK="0" TRIMREF="TRIM" TRIMUserSetup_On="0" WORD_ON="1"

START /WAIT "" MsiExec.exe /UPDATE "%ROOTPATH%\SourceX86\MicroFocus\CM_x86_9320418.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\19-INSTALL-CM-x86-9320418.log"
START /WAIT "" MsiExec.exe /UPDATE "%ROOTPATH%\SourceX86\MicroFocus\CM_x86_9320430.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\19-INSTALL-CM-x86-9320430.log"
REGSVR32 /S "%PROGRAMFILES(x86)%\Micro Focus\Content Manager\trimsdk.dll"
REG ADD "HKEY_CLASSES_ROOT\TRIM5.Record.Reference\Shell\open\Command" /V "" /T "REG_SZ" /D "\"%PROGRAMFILES(x86)%\Micro Focus\Content Manager\Trim.exe\" \"%%1\"" /F

IF EXIST "%ROOTPATH%\SourceX86\MicroFocus\UIgnore.tlx" COPY "%ROOTPATH%\SourceX86\MicroFocus\UIgnore.tlx" "C:\Micro Focus Content Manager\Lex\UIgnore.tlx" /Y

ECHO 20. INSTALL Kapish Easy Link x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Easy Link-x86-3.41.3556.msi" DISABLEADVTSHORTCUTS=1 /quiet /norestart /l*vx "%LOGPATH%\INSTALL\20-INSTALL-Kapish-Easy-Link-x86.log"

ECHO 21. INSTALL Kapish Folder Wizard x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Folder Wizard-x86-3.52.1910.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\21-INSTALL-Kapish-Folder-Wizard-x86.log"

ECHO 22. INSTALL Kapish PDF Wizard x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish PDF Wizard-x86-2.01.1110.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\22-INSTALL-Kapish-PDF-Wizard-x86.log"

ECHO 23. INSTALL Kapish Record Remover x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Record Remover-x86-1.60.1400.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\23-INSTALL-Kapish-Record-Remover-x86.log"

ECHO 24. INSTALL Kapish Workflow Wizard x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Workflow Wizard-x86-1.04.1066.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\24-INSTALL-Kapish-Workflow-Wizard-x86.log"

ECHO 25. INSTALL Kapish Excel Add-In (x86 Office)
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Excel Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\25-INSTALL-Kapish-Excel-AddIn-x86.log"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Excel Add-In"          /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F /REG:32
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Excel Add-In" /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F

ECHO 26. INSTALL Kapish Word Add-In (x86 Office)
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish Word Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\26-INSTALL-Kapish-Word-AddIn-x86.log"
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Word Add-In"           /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F /REG:32
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Word Add-In" /V DefaultTabName /T REG_SZ /D "WSDoM Templates" /F

ECHO 27. INSTALL Kapish Explorer x86
START /WAIT "" MsiExec.exe /I "%ROOTPATH%\SourceX86\Kapish\Kapish_Explorer-x86-5.11.5026.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\27-INSTALL-Kapish-Explorer-x86.log"
REG ADD "HKLM\Software\Kapish\TRIM Explorer" /V "MaxLengthFilepath" /T "REG_DWORD" /D "200" /F /REG:64

REM --- Rebrand Explorer icons (x86) ---
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%PROGRAMFILES(x86)%\Kapish\Explorer\WSDoM Explorer.ico" /Y
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%PROGRAMFILES(x86)%\Kapish\Explorer\Icons\explorer-48x48.ico" /Y
DEL  "%SYSTEMROOT%\Installer\{68588BB0-F37B-4A88-BEB6-3D395B322F75}\MSIIcon"           /Q /F 2>NUL
DEL  "%SYSTEMROOT%\Installer\{68588BB0-F37B-4A88-BEB6-3D395B322F75}\MainShortcutIcon.dll" /Q /F 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%SYSTEMROOT%\Installer\{68588BB0-F37B-4A88-BEB6-3D395B322F75}\MSIIcon" /Y
COPY "%ROOTPATH%\WSDoM\WSDoM Explorer.ico" "%SYSTEMROOT%\Installer\{68588BB0-F37B-4A88-BEB6-3D395B322F75}\MainShortcutIcon.dll" /Y
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}"            /V ""        /D "WSDoM Explorer"                      /T "REG_SZ" /F /REG:32
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}"            /V "InfoTip" /D "Browse WSDoM within Windows Explorer" /T "REG_SZ" /F /REG:32
REG ADD "HKEY_CLASSES_ROOT\CLSID\{6EC97137-BE18-44B9-BB5B-92240A8D3481}\DefaultIcon" /V ""       /D "%PROGRAMFILES(x86)%\Kapish\Explorer\WSDoM Explorer.ico" /T "REG_SZ" /F /REG:32

REM ============================================================
REM  STEP 4: REBRAND CM TO WSDoM + USER SETTINGS
REM ============================================================
:UserSettings

REM --- Rebrand Desktop icons ---
DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\trim.exe"              /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDataPortConfig.exe" /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDesktop.exe"       /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMEnterpriseStudio.exe" /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMQueue.exe"         /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\trim.exe"              /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDataPortConfig.exe" /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDesktop.exe"       /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMEnterpriseStudio.exe" /Q /F 2>NUL
DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMQueue.exe"         /Q /F 2>NUL

COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\trim.exe"              /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDataPortConfig.exe" /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDesktop.exe"       /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMEnterpriseStudio.exe" /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMQueue.exe"         /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\trim.exe"              /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDataPortConfig.exe" /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDesktop.exe"       /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMEnterpriseStudio.exe" /Y 2>NUL
COPY "%ROOTPATH%\WSDoM\WSDoM Desktop.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMQueue.exe"         /Y 2>NUL

REM --- Desktop and Start Menu shortcuts ---
COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager.lnk" "%PUBLIC%\Desktop\WSDoM Desktop.lnk" /Y 2>NUL
REN  "%PUBLIC%\Desktop\Kapish Explorer.lnk" "WSDoM Explorer.lnk" 2>NUL

IF NOT EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM" MKDIR "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM"
COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager.lnk"      "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM\WSDoM Desktop.lnk" /Y 2>NUL
COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager User Guide.lnk" "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM\WSDoM Desktop User Guide.lnk" /Y 2>NUL
COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish\Easy Link.lnk"                     "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM\WSDoM Easy Link.lnk" /Y 2>NUL
COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish\Explorer.lnk"                      "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM\WSDoM Explorer.lnk" /Y 2>NUL
RD   "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager" /S /Q 2>NUL
RD   "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish"          /S /Q 2>NUL

REM --- WSDoM User Settings VBS (local copy; no network dependency) ---
IF NOT EXIST "C:\Program Files\Kapish\User Settings" MKDIR "C:\Program Files\Kapish\User Settings"
COPY "%ROOTPATH%\WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs" "C:\Program Files\Kapish\User Settings\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs" /Y
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86-x64" /T "REG_SZ" /D "wscript.exe \"C:\Program Files\Kapish\User Settings\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs\"" /F /REG:64

REM --- Write version stamp (used by Intune detection rule) ---
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /V CM93-WSDoM-Client-INSTALL-Version /T REG_SZ /D "10.0" /F /REG:32
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /V CM93-WSDoM-Client-INSTALL-Version /T REG_SZ /D "10.0" /F /REG:64

REM --- Clear icon cache ---
%SYSTEMROOT%\SYSTEM32\ie4uinit.exe -SHOW

ECHO [INFO] WSDoM installation complete.
ENDLOCAL
EXIT /B 0
