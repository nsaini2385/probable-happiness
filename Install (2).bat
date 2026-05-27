@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM ================================================================
REM  WSDoM v10.0 - INTUNE INSTALL WRAPPER (BAT)
REM  Calls cmd.exe /c to launch the install CMD — same pattern
REM  as PSADT Execute-Process. Place next to the CMD file.
REM ================================================================

SET "DIRFILES=%~dp0"
IF "%DIRFILES:~-1%"=="\" SET "DIRFILES=%DIRFILES:~0,-1%"

SET "INSTALL_CMD=%DIRFILES%\01-WORKSAFE-PROD-INSTALL-CM94-Client-v10_0.cmd"
SET "USER_SETTINGS_VBS=%DIRFILES%\WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs"
SET "TAG_FOLDER=C:\ProgramData\Tagfiles"
SET "TAG_FILE=%TAG_FOLDER%\WSDOM_10_0.tag"
SET "REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\IBM\Ocelot Packages\WSDOM_10.0"

REM ----------------------------------------------------------------
REM  PRE-INSTALL
REM ----------------------------------------------------------------
IF NOT EXIST "%TAG_FOLDER%" MKDIR "%TAG_FOLDER%"

REM ----------------------------------------------------------------
REM  64-BIT OFFICE DETECTION
REM ----------------------------------------------------------------
SET "OFFICE_ARCH=NONE"

IF EXIST "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE"            SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"            SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE"       SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"       SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"      SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE"      SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office15\WINWORD.EXE" SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE" SET "OFFICE_ARCH=x86"

REM  Registry fallback for Microsoft 365 Click-to-Run
REG QUERY "HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x64"
REG QUERY "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x86"

ECHO [INFO] Office architecture: %OFFICE_ARCH%

IF /I NOT "%OFFICE_ARCH%"=="x64" (
    ECHO [SKIP] 64-bit Office not detected. Exiting.
    ENDLOCAL & EXIT /B 0
)

IF NOT EXIST "%INSTALL_CMD%" (
    ECHO [ERROR] CMD not found: %INSTALL_CMD%
    ENDLOCAL & EXIT /B 1
)

REM ----------------------------------------------------------------
REM  INSTALL - use cmd.exe /c exactly as PSADT Execute-Process does
REM ----------------------------------------------------------------
ECHO [INSTALL] Launching install CMD...
cmd.exe /c "%INSTALL_CMD%"
SET "INSTALL_EXIT=%ERRORLEVEL%"
ECHO [INSTALL] Exited with code: %INSTALL_EXIT%

REM ----------------------------------------------------------------
REM  POST-INSTALL - only on good exit codes (mirrors PSADT check)
REM ----------------------------------------------------------------
IF "%INSTALL_EXIT%"=="0"    GOTO :PostInstall
IF "%INSTALL_EXIT%"=="1707" GOTO :PostInstall
IF "%INSTALL_EXIT%"=="3010" GOTO :PostInstall
IF "%INSTALL_EXIT%"=="1641" GOTO :PostInstall
IF "%INSTALL_EXIT%"=="1618" GOTO :PostInstall

ECHO [ERROR] Install failed (%INSTALL_EXIT%). Post-install skipped.
ENDLOCAL & EXIT /B %INSTALL_EXIT%

:PostInstall
IF EXIST "%USER_SETTINGS_VBS%" (
    ECHO [POST-INSTALL] Running user settings VBS...
    START /WAIT "" wscript.exe "%USER_SETTINGS_VBS%"
) ELSE (
    ECHO [POST-INSTALL] WARNING: VBS not found, skipping.
)

ECHO [POST-INSTALL] Writing tag file and registry detection key...
ECHO.> "%TAG_FILE%"
REG ADD "%REG_KEY%" /V "Installed" /T "REG_DWORD" /D "1" /F >NUL 2>&1

ECHO [POST-INSTALL] Done.
ENDLOCAL & EXIT /B %INSTALL_EXIT%
