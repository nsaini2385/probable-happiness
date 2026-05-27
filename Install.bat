@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM ================================================================
REM  WSDoM - INTUNE WRAPPER
REM  Detects 64-bit Microsoft Office. If found, calls the main
REM  install CMD. Original CMD is NOT modified.
REM ================================================================

SET "OFFICE_ARCH=NONE"
SET "INSTALL_CMD=%~dp0\01-WORKSAFE-PROD-INSTALL-CM94-Client-v10_0.cmd"

REM ----------------------------------------------------------------
REM  DETECT 64-BIT OFFICE — file path checks (MSI installs)
REM ----------------------------------------------------------------
IF EXIST "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE"            SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"            SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE"       SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"       SET "OFFICE_ARCH=x64"

REM ----------------------------------------------------------------
REM  DETECT 64-BIT OFFICE — registry check (Microsoft 365 / C2R)
REM  Key exists under native HKLM (not WOW6432Node) only for 64-bit
REM ----------------------------------------------------------------
REG QUERY "HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x64"

REM  If 32-bit Office is ALSO registered under WOW6432Node, it wins
REM  (32-bit Office on a 64-bit OS takes priority — don't install x64 CM)
REG QUERY "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x86"

REM ----------------------------------------------------------------
REM  RESULT
REM ----------------------------------------------------------------
ECHO [INFO] Detected Office architecture: %OFFICE_ARCH%

IF /I NOT "%OFFICE_ARCH%"=="x64" (
    ECHO [SKIP] 64-bit Office not detected. Installation will not proceed.
    ECHO [SKIP] This package requires 64-bit Microsoft Office.
    ENDLOCAL
    EXIT /B 0
)

REM ----------------------------------------------------------------
REM  LAUNCH ORIGINAL INSTALL CMD (unchanged)
REM ----------------------------------------------------------------
ECHO [INFO] 64-bit Office confirmed. Starting WSDoM installation...

IF NOT EXIST "%INSTALL_CMD%" (
    ECHO [ERROR] Install CMD not found: %INSTALL_CMD%
    ENDLOCAL
    EXIT /B 1
)

CALL "%INSTALL_CMD%"
SET "INSTALL_EXIT=%ERRORLEVEL%"

ECHO [INFO] Install CMD exited with code: %INSTALL_EXIT%
ENDLOCAL
EXIT /B %INSTALL_EXIT%
