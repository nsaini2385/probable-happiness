@ ECHO OFF
TITLE INSTALL PROD Environment Micro Focus Content Manager 9.3.2.0430 Patch 2 Hotfix 4 and Kapish Explorer for Office 64 and 32 bit Version 22.0
REM Version 22.0
REM - Worksafe client deployment package developed for Micro Focus Content Manager 9.3.2.0430 Patch 2 Hotfix 4 and Kapish Explorer

REM DYNAMICALLY DETECT THE ROOTPATH FOR INSTALL PACKAGE
    SET ROOTPATH=%~dp0
REM DOES STRING HAVE A TRAINING SLASH? IF SO, REMOVE IT
    IF %ROOTPATH:~-1%==\ SET ROOTPATH=%ROOTPATH:~0,-1%

	:SETLOGPATH	
	SET LOGPATH=c:\temp\Install-CM93-Logs-V22\%COMPUTERNAME%

REM UNINSTALL KAPISH ADD-ONS 
    ECHO 01. UNINSTALL Kapish Easy Link
REM UNINSTALL KAPISH EASY LINK 3.41.3556 x64
	MsiExec.exe /X{D5EA7DF7-F34E-42DF-B6C4-74A830D4EF35} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x64-3.41.3556.log"
REM UNINSTALL KAPISH EASY LINK 3.41.3556 x86
	MsiExec.exe /X{C6C78ACE-496D-445F-93D5-E5799AA94948} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x86-3.41.3556.log"
REM UNINSTALL KAPISH EASY LINK 3.53.1016 x64
	MsiExec.exe /X{7D0D0691-1AB0-4F8C-99D9-143A10E72D43} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x64-3.53.1016.log"
REM UNINSTALL KAPISH EASY LINK 3.53.1016 x86
	MsiExec.exe /X{AD40AD72-E55F-4D50-8BF4-6ED30392EB69} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\01-UNINSTALL-Kapish-Easy-Link-x86-3.53.1016.log"

	ECHO 02. UNINSTALL Kapish Folder Wizard
REM UNINSTALL KAPISH FOLDER WIZARD 3.52.1910 x64
	MsiExec.exe /X{7E28F642-69A1-4582-908B-B84F0A841DB9} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x64-3.52.1910.log"
REM UNINSTALL KAPISH FOLDER WIZARD 3.52.1910 x86
	MsiExec.exe /X{2753C6B7-570E-4211-8F13-9C6249E16620} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x86-3.52.1910.log"
REM UNINSTALL KAPISH FOLDER WIZARD 3.63.1042 x64
	MsiExec.exe /X{ABF8C4AD-8BCD-496D-91BC-82806B5D38F2} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x64-3.63.1042.log"
REM UNINSTALL KAPISH FOLDER WIZARD 3.63.1042 x86
	MsiExec.exe /X{FEE33659-78A7-4087-80EA-C29DA366F420} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\02-UNINSTALL-Kapish-Folder-Wizard-x86-3.63.1042.log"
	
	ECHO 03. UNINSTALL Kapish PDF Wizard
REM UNINSTALL KAPISH PDF WIZARD 2.01.1110 x64
	MsiExec.exe /X{E42BCA13-9B7D-45D8-9066-ED034A5D5526} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x64-2.01.1110.log"
REM UNINSTALL KAPISH PDF WIZARD 2.01.1110 x86
	MsiExec.exe /X{2C2D4712-1818-4EE1-A5D1-F1C23C9EA394} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x86-2.01.1110.log"
REM UNINSTALL KAPISH PDF WIZARD 2.05.1130 x64
	MsiExec.exe /X{F514E71B-986C-4200-9EA1-AD38A8A49DBB} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x64-2.05.1130.log"
REM UNINSTALL KAPISH PDF WIZARD 2.05.1130 x86
	MsiExec.exe /X{57208E53-D147-4531-BC08-39DAB16B5446} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\03-UNINSTALL-Kapish-PDF-Wizard-x86-2.05.1130.log"

	ECHO 04. UNINSTALL Kapish Record Remover
REM UNINSTALL Kapish RECORD REMOVER 1.60.1400 x64
	MsiExec.exe /X{E4240372-B832-4154-AB41-182AD829BAF3} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\04-UNINSTALL-Kapish-Record-Remover-x64-1.60.1400.log"
REM UNINSTALL Kapish RECORD REMOVER 1.60.1400 x84
	MsiExec.exe /X{5AF2757F-507D-4C20-A2C8-88A028E9A6DB} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\04-UNINSTALL-Kapish-Record-Remover-x86-1.60.1400.log"

	ECHO 05. UNINSTALL Kapish Workflow Wizard
REM UNINSTALL KAPISH WORKFLOW WIZARD 1.04.1066 x64
	MsiExec.exe /X{C4E79744-DD36-4E6E-8FC3-18F95F1A748B} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x64-1.04.1066.log"
REM UNINSTALL KAPISH WORKFLOW WIZARD 1.04.1066 x86 
	MsiExec.exe /X{D1997875-DE4C-4B77-B340-D3FAFD0310E2} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x86-1.04.1066.log"
REM UNINSTALL KAPISH WORKFLOW WIZARD 1.07.1076 x64
	MsiExec.exe /X{ABC620E7-CDA8-4FB1-86AD-99D6BBE2E867} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x64-1.07.1076.log"
REM UNINSTALL KAPISH WORKFLOW WIZARD 1.07.1076 x86 
	MsiExec.exe /X{57E6FF51-4450-496D-9748-7AF97E604C01} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\05-UNINSTALL-Kapish-Workflow-Wizard-x86-1.07.1076.log"

	ECHO 06. UNINSTALL Kapish Excel Add-In
REM UNINSTALL KAPISH EXCEL ADD-IN 4.20.1434 x64 and x86
	MsiExec.exe /X{981398A2-0561-4AB5-99D7-B79785345FAD} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\06-UNINSTALL-Kapish-Excel-AddIn-4.20.1434.log"
REM UNINSTALL KAPISH EXCEL ADD-IN 4.22.1458 x64 and x86
	MsiExec.exe /X{21C817A3-2D4B-475A-A565-8BAC2D6C8D41} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\06-UNINSTALL-Kapish-Excel-AddIn-4.22.1458.log"
	REG DELETE "HKLM\Software\Kapish\Excel Add-In" /V DefaultTabName /F /REG:32

	ECHO 07. UNINSTALL Kapish Word Add-In
REM UNINSTALL KAPISH WORD ADD-IN 4.20.1434 x64 and x86
	MsiExec.exe /X{6449CADC-497A-47B2-A82A-64590F06586D} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\07-UNINSTALL-Kapish-Word-AddIn-4.20.1434.log"
REM UNINSTALL KAPISH WORD ADD-IN 4.22.1458 x64 and x86
	MsiExec.exe /X{58DE3DD0-0437-49C4-855F-22E3F7A17FE8} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\07-UNINSTALL-Kapish-Word-AddIn-4.22.1458.log"
	REG DELETE "HKLM\Software\Kapish\Word Add-In" /V DefaultTabName /F /REG:32
	
	ECHO 08. UNINSTALL Kapish Explorer 
REM UNINSTALL KAPISH EXPLORER 5.11.5026 x64
	MsiExec.exe /X{3D4414A4-BD4D-4B53-AA99-909E786F6E34} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x64-5.11.5026.log"
REM UNINSTALL KAPISH EXPLORER 5.11.5026 x86
	MsiExec.exe /X{68588BB0-F37B-4A88-BEB6-3D395B322F75} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x86-5.11.5026.log"
REM UNINSTALL KAPISH EXPLORER 5.16.5064 x64
	MsiExec.exe /X{7CDB24FD-54C8-464D-B8A7-E5C3E96A6D1E} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x64-5.16.5064.log"
REM UNINSTALL KAPISH EXPLORER 5.16.5064 x86
	MsiExec.exe /X{0906646D-4BB8-4695-897B-4D29D5E2F056} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x86-5.16.5064.log"
REM UNINSTALL KAPISH EXPLORER 5.18.5108 x64
	MsiExec.exe /X{1170A349-CEAD-4084-AE43-F5B82EBD5E39} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x64-5.18.5108.log"
REM UNINSTALL KAPISH EXPLORER 5.18.5108 x86
	MsiExec.exe /X{D3ACC4A2-1F7C-4321-9985-61CDFDB71FC2} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\08-UNINSTALL-Kapish-Explorer-x86-5.18.5108.log"
	REG DELETE "HKLM\Software\Kapish\TRIM Explorer" /V MaxLengthFilepath /F /REG:64
	REG DELETE "HKLM\Software\Kapish\TRIM Explorer" /V MaxLengthFilepath /F /REG:32
	START EXPLORER.EXE
	
	ECHO 09. UNINSTALL Kapish Record Form Filler 
	REM UNINSTALL KAPISH RECORD FORM FILLER 1.30.0012 x64 
	MsiExec.exe /X{ADA5D827-16D1-4495-A200-36DF8C2070A5} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-Kapish-Record-Form-Filler-x64-1.30.0012.log"
	REM UNINSTALL KAPISH RECORD FORM FILLER 1.30.0012 x86 
	MsiExec.exe /X{EDC72825-F858-40FE-85B0-DEE336925279} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\09-UNINSTALL-Kapish-Record-Form-Filler-x86-1.30.0012.log"
	
REM UNINSTALL MICRO FOCUS CONTENT MANAGER
    ECHO 10. UNINSTALL Micro Focus Content Manager
REM UNINSTALL MICRO FOCUS CONTENT MANAGER 9.3.2.0430 x64
	MsiExec.exe /X{4E6086CA-B627-4AFA-A41C-8F86363832C7} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\10-UNINSTALL-Micro-Focus-Content-Manager-x64-9.3.2.0430.log"
REM UNINSTALL MICRO FOCUS CONTENT MANAGER 9.3.2.0430 x86
	MsiExec.exe /X{CEA78427-2FFF-4C38-B6F0-A108724C7421} /quiet /norestart /l*vx "%LOGPATH%\UNINSTALL\10-UNINSTALL-Micro-Focus-Content-Manager-x86-9.3.2.0430.log"

REM DELETE UNWANTED MICRO FOCUS CONTENT MANAGER FILES, FOLDERS AND REGISTRY KEYS
	DEL "%PUBLIC%\Desktop\Kapish Explorer.lnk" /Q /F
	DEL "%PUBLIC%\Desktop\WSDoM Desktop.lnk" /Q /F
	DEL "%PUBLIC%\Desktop\WSDoM Explorer.lnk" /Q /F
	RD /S /Q "%PROGRAMFILES%\Kapish" 
	RD /S /Q "%PROGRAMFILES(x86)%\Kapish" 
	RD /S /Q "%PROGRAMFILES%\Micro Focus\Content Manager"
	RD /S /Q "%PROGRAMFILES(x86)%\Micro Focus\Content Manager"
	RD /S /Q "C:\Micro Focus Content Manager\"
	RD /S /Q "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish" 
	RD /S /Q "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager"
	RD /S /Q "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\WSDoM" 
	RD /S /Q "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}" 
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish" /F /REG:32
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish" /F /REG:64
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /F /REG:32
    REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /F /REG:64
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43" /F /REG:32
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43" /F /REG:64
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office" /F /REG:32
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x64Office" /F /REG:64
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office" /F /REG:32
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86Office" /F /REG:64
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86-X64" /F /REG:32
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-WSDoM-User-Settings-PROD-43-x86-X64" /F /REG:64

:INSTALL64BIT
REM INSTALL MICRO FOCUS CONTENT MANAGER     
    ECHO 11. INSTALL Micro Focus Content Manager 9.3.2.0430 Patch 2 Hotfix 4 x64
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.0.0178 Base x64  
	MsiExec.exe /I "%~dp0\SourceX64\MicroFocus\CM_x64_9300178.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x64-9.30.0178.log" INSTALLDIR="%PROGRAMFILES%\Micro Focus\Content Manager\" ADDLOCAL="HPTRIM,Client" ALLUSERS="1" AUTHMECH="0" AUTOGG="1" DEFAULTDB="43" DEFAULTDBNAME="Corporate Records Production" EXCEL_ON="1" OUTLOOK_ON="1" POWERPOINT_ON="1" PRIMARYURL="WPWTWS0203.melb.ad" PROJECT_ON="1" SECONDARYURL="WPWTWS0204.melb.ad" STARTMENU_NAME="Content Manager" TRIM_DSK="0" TRIMREF="TRIM" TRIMUserSetup_On="0" WORD_ON="1"
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.2.0418 Patch 2 x64
	MsiExec.exe /UPDATE "%~dp0\SourceX64\MicroFocus\CM_x64_9320418.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x64-9.32.0418.log"
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.2.0430 Hotfix 4 for Patch 2 x64
	MsiExec.exe /UPDATE "%~dp0\SourceX64\MicroFocus\CM_x64_9320430.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x64-9.32.0430.log" 

REM MANUALLY REGISTER TRIMSDK.DLL x64
    REGSVR32 /S "%PROGRAMFILES%\Micro Focus\Content Manager\trimsdk.dll"

REM SET TR5's TO OPEN IN MICRO FOCUS CONTENT MANAGER
	REG ADD "HKEY_CLASSES_ROOT\TRIM5.Record.Reference\Shell\open\Command" /V "" /T "REG_SZ" /D "\"%PROGRAMFILES%\Micro Focus\Content Manager\Trim.exe\" \"%%1\"" /F

REM CHANGE MICRO FOCUS ICON TO CUSTOM ICON
REM DELETE EXISTING ICON FILES x64
	DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\trim.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDataPortConfig.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDesktop.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMEnterpriseStudio.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMQueue.exe" /Q /F

REM COPY NEW ICON FILES x64
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\trim.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDataPortConfig.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMDesktop.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMEnterpriseStudio.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{4E6086CA-B627-4AFA-A41C-8F86363832C7}\TRIMQueue.exe" /Y

REM INSTALL KAPISH ADD-ONS
    ECHO 12. INSTALL Kapish Easy Link
REM INSTALL KAPISH EASY LINK 3.41.3556 x64
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\Kapish Easy Link-x64-3.41.3556.msi" DISABLEADVTSHORTCUTS=1 /quiet /norestart /l*vx "%LOGPATH%\INSTALL\12-INSTALL-Kapish-Easy-Link-x64.log"

	ECHO 13. INSTALL Kapish Folder Wizard 
REM INSTALL KAPISH FOLDER WIZARD 3.52.1910 x64
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\Kapish Folder Wizard-x64-3.52.1910.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\13-INSTALL-Kapish-Folder-Wizard-x64.log"

	ECHO 14. INSTALL Kapish PDF Wizard 
REM INSTALL KAPISH PDF WIZARD 2.01.1110 x64
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\Kapish PDF Wizard-x64-2.01.1110.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\14-INSTALL-Kapish-PDF-Wizard-x64.log"
	
	ECHO 15. INSTALL Kapish Record Form Filler
REM INSTALL KAPISH RECORD FORM FILLER 1.30.0012 x64
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\KapishFormFillerAddIn_1.30.0012_x64.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\15-INSTALL-Kapish-Form-Filler-x64.log"

	ECHO 16. INSTALL Kapish Record Remover
REM INSTALL KAPISH RECORD REMOVER 1.60.1400 x64
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\Kapish Record Remover-x64-1.60.1400.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\16-INSTALL-Kapish-Record-Remover-x64.log"

	ECHO 17. INSTALL Kapish Excel Add-In 
REM INSTALL KAPISH EXCEL ADD-IN 4.20.1434 
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Excel Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\17-INSTALL-Kapish-Excel-AddIn.log"
REM RENAME RIBBON TAB IN MS EXCEL
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Excel Add-In" /V DefaultTabName /T REG_SZ /D "CM Templates" /F /REG:32
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Excel Add-In" /V DefaultTabName /T  "REG_SZ" /D "CM Templates" /F 
	
	ECHO 18. INSTALL Kapish Word Add-In
REM INSTALL KAPISH WORD ADD-IN 4.20.1434 
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Word Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\18-INSTALL-Kapish-Word-AddIn.log"
	REM RENAME RIBBON TAB IN MS WORD
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Word Add-In" /V DefaultTabName /T REG_SZ /D "CM Templates" /F /REG:32
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Word Add-In" /V DefaultTabName /T "REG_SZ" /D "CM Templates" /F 

	ECHO 19. INSTALL Kapish Explorer 
REM INSTALL Kapish Explorer 5.18.5108
	MsiExec.exe /I "%~dp0\SourceX64\Kapish\Kapish_Explorer-x64-5.18.5108.1839.0.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\19-INSTALL-Kapish-Explorer-x64.log"
	REM SET MAX LENGTH FOR DISPLAYING FILE NAMES IN WINDOWS EXPLORER
	REG ADD "HKLM\Software\Kapish\TRIM Explorer" /V "MaxLengthFilepath" /T "REG_DWORD" /D "200" /F /REG:64

REM INSTALL USER SETTINGS PACKAGE VIA WINDOWS RUN REGISTRY KEY
	COPY "%~dp0\UserSettings\CM93-User-Settings-PROD-43-x86-x64.vbs" "%PROGRAMFILES%\Micro Focus\Content Manager\CM93-User-Settings-PROD-43-x86-x64.vbs" /Y
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-User-Settings-PROD-43-x86-x64" /T "REG_SZ" /D "wscript.exe \"C:\Program Files\Micro Focus\Content Manager\CM93-User-Settings-PROD-43-x86-x64.vbs"" /F 

REM CHECK MICROSOFT OFFICE BIT LEVEL (32BIT OR 64BIT)
	IF EXIST "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE" GOTO UserSettings
	IF EXIST "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE" GOTO UserSettings
	IF EXIST "C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE" GOTO UserSettings
	IF EXIST "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" GOTO UserSettings
	IF EXIST "C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE" GOTO INSTALL32BIT
	IF EXIST "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE" GOTO INSTALL32BIT
	IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office15\WINWORD.EXE" GOTO INSTALL32BIT
	IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE" GOTO INSTALL32BIT
		
:INSTALL32BIT
REM INSTALL MICRO FOCUS CONTENT MANAGER     
    ECHO 11. INSTALL Micro Focus Content Manager 9.3.2.0430 Patch 2 Hotfix 4 x86
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.0.0178 Base x86
	MsiExec.exe /I "%~dp0\SourceX86\MicroFocus\CM_x86_9300178.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x86-9.30.0178.log" INSTALLDIR="%PROGRAMFILES(x86)%\Micro Focus\Content Manager\" ADDLOCAL="HPTRIM,Client" ALLUSERS="1" AUTHMECH="0" AUTOGG="1" DEFAULTDB="43" DEFAULTDBNAME="Corporate Records Production" EXCEL_ON="1" OUTLOOK_ON="1" POWERPOINT_ON="1" PRIMARYURL="WPWTWS0203.melb.ad" PROJECT_ON="1" SECONDARYURL="WPWTWS0204.melb.ad" STARTMENU_NAME="Content Manager" TRIM_DSK="0" TRIMREF="TRIM" TRIMUserSetup_On="0" WORD_ON="1"
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.2.0418 Patch 2 x86
	MsiExec.exe /UPDATE "%~dp0\SourceX86\MicroFocus\CM_x86_9320418.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x86-9.32.0418.log"
REM INSTALL MICRO FOCUS CONTENT MANAGER CLIENT 9.3.2.0430 Hotfix 4 for Patch 2 x86
	MsiExec.exe /UPDATE "%~dp0\SourceX86\MicroFocus\CM_x86_9320430.msp" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\11-INSTALL-Micro-Focus-Content-Manager-x86-9.32.0430.log" 

REM MANUALLY REGISTER TRIMSDK.DLL x86
    REGSVR32 /S "%PROGRAMFILES(x86)%\Micro Focus\Content Manager\trimsdk.dll"

REM SET TR5's TO OPEN IN MICRO FOCUS CONTENT MANAGER
	REG ADD "HKEY_CLASSES_ROOT\TRIM5.Record.Reference\Shell\open\Command" /V "" /T "REG_SZ" /D "\"%PROGRAMFILES(x86)%\Micro Focus\Content Manager\Trim.exe\" \"%%1\"" /F

REM CHANGE MICRO FOCUS ICON TO CUSTOM ICON
REM DELETE EXISTING ICON FILES x86
	DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\trim.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDataPortConfig.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDesktop.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMEnterpriseStudio.exe" /Q /F
	DEL "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMQueue.exe" /Q /F
REM COPY NEW ICON FILES x86
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\trim.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDataPortConfig.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMDesktop.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMEnterpriseStudio.exe" /Y
	COPY "%~dp0\UserSettings\Content Manager.ico" "%SYSTEMROOT%\Installer\{CEA78427-2FFF-4C38-B6F0-A108724C7421}\TRIMQueue.exe" /Y

REM INSTALL KAPISH ADD-ONS
    ECHO 12. INSTALL Kapish Easy Link
REM INSTALL KAPISH EASY LINK 3.41.3556 x86
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Easy Link-x86-3.41.3556.msi" DISABLEADVTSHORTCUTS=1 /quiet /norestart /l*vx "%LOGPATH%\INSTALL\12-INSTALL-Kapish-Easy-Link-x86.log"

	ECHO 13. INSTALL Kapish Folder Wizard 
REM INSTALL KAPISH FOLDER WIZARD 3.52.1910 x86
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Folder Wizard-x86-3.52.1910.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\13-INSTALL-Kapish-Folder-Wizard-x86.log"

	ECHO 14. INSTALL Kapish PDF Wizard 
REM INSTALL KAPISH PDF WIZARD 2.01.1110 x86
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish PDF Wizard-x86-2.01.1110.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\14-INSTALL-Kapish-PDF-Wizard-x86.log"

	ECHO 15. INSTALL Kapish Record Form Filler
REM INSTALL KAPISH RECORD FORM FILLER 1.30.0012 x86
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\KapishFormFillerAddIn_1.30.0012_x86.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\15-INSTALL-Kapish-Form-Filler-x86.log"
	
	ECHO 16. INSTALL Kapish Record Remover
REM INSTALL KAPISH RECORD REMOVER 1.60.1400 x86
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Record Remover-x86-1.60.1400.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\16-INSTALL-Kapish-Record-Remover-x86.log"

	ECHO 17. INSTALL Kapish Excel Add-In 
REM INSTALL KAPISH EXCEL ADD-IN 4.20.1434 
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Excel Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\17-INSTALL-Kapish-Excel-AddIn.log"
REM RENAME RIBBON TAB IN MS EXCEL
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Excel Add-In" /V DefaultTabName /T REG_SZ /D "CM Templates" /F /REG:32
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Excel Add-In" /V DefaultTabName /T  "REG_SZ" /D "CM Templates" /F 
	
	ECHO 18. INSTALL Kapish Word Add-In
REM INSTALL KAPISH WORD ADD-IN 4.20.1434 
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish Word Add-In v4.20.1434.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\18-INSTALL-Kapish-Word-AddIn.log"
	REM RENAME RIBBON TAB IN MS WORD
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Kapish\Word Add-In" /V DefaultTabName /T REG_SZ /D "CM Templates" /F /REG:32
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kapish\Word Add-In" /V DefaultTabName /T "REG_SZ" /D "CM Templates" /F 

	ECHO 19. INSTALL Kapish Explorer 
REM INSTALL Kapish Explorer 5.18.5108
	MsiExec.exe /I "%~dp0\SourceX86\Kapish\Kapish_Explorer-x86-5.18.5108.1839.0.msi" /quiet /norestart /l*vx "%LOGPATH%\INSTALL\19-INSTALL-Kapish-Explorer-x86.log"
	REM SET MAX LENGTH FOR DISPLAYING FILE NAMES IN WINDOWS EXPLORER
	REG ADD "HKLM\Software\Kapish\TRIM Explorer" /V "MaxLengthFilepath" /T "REG_DWORD" /D "200" /F /REG:64

REM INSTALL USER SETTINGS PACKAGE VIA WINDOWS RUN REGISTRY KEY
	COPY "%~dp0\UserSettings\CM93-User-Settings-PROD-43-x86-x64.vbs" "%PROGRAMFILES(x86)%\Micro Focus\Content Manager\CM93-User-Settings-PROD-43-x86-x64.vbs" /Y
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "CM93-User-Settings-PROD-43-x86-x64" /T "REG_SZ" /D "wscript.exe \"C:\Program Files (x86)\Micro Focus\Content Manager\CM93-User-Settings-PROD-43-x86-x64.vbs"" /F 

GOTO UserSettings

:UserSettings
REM COPY CONTENT MANAGER START MENU SHORTCUT TO PUBLIC (ALL USERS) DESKTOP
	COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager.lnk" "%PUBLIC%\Desktop\Content Manager.lnk" /Y
	
REM CREATE NEW START MENU FOLDER AND COPY SHORTCUTS FOR CONTENT MANAGER AND KAPISH PRODUCTS
	IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager Desktop.lnk" DEL "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager Desktop.lnk" /Q /F
	IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager Queue Processor.lnk" DEL "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager Queue Processor.lnk" /Q /F
	IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager DataPort.lnk" DEL "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager DataPort.lnk" /Q /F
	IF EXIST "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager ImageScanner.lnk" DEL "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Content Manager ImageScanner.lnk" /Q /F
	COPY "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish\Easy Link.lnk" "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Content Manager\Easy Link.lnk" /Y
REM DELETE KAPISH START MENU FOLDERS
	RD "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Kapish" /S /Q
	
REM WRITE TO THE REGISTRY TO SAY THIS VERSION OF THE CMD HAS RAN 
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /V CM93-Client-INSTALL-Version /T REG_SZ /D "22.0" /F /REG:32
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Micro Focus\Content Manager" /V CM93-Client-INSTALL-Version /T REG_SZ /D "22.0" /F /REG:64

REM CLEAR WINDOWS 10 ICON CACHE
	%SYSTEMROOT%\SYSTEM32\ie4uinit.exe -SHOW
	
EXIT
