@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM ================================================================
REM  WSDoM v10.0 - INTUNE INSTALL WRAPPER
REM  Mirrors Deploy-Application.ps1 (PSADT) logic:
REM    - Pre-Install  : create tag folder
REM    - Install      : detect 64-bit Office, call original CMD
REM    - Post-Install : run user-settings VBS, write tag file,
REM                     set IBM Ocelot registry detection key
REM
REM  Place this bat in the same folder as:
REM    01-WORKSAFE-PROD-INSTALL-CM94-Client-v10_0.cmd
REM    WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs
REM ================================================================

REM ----------------------------------------------------------------
REM  PATHS  (all relative to this bat — mirrors PSADT $dirFiles)
REM ----------------------------------------------------------------
SET "DIRFILES=%~dp0"
IF "%DIRFILES:~-1%"=="\" SET "DIRFILES=%DIRFILES:~0,-1%"

SET "INSTALL_CMD=%DIRFILES%\01-WORKSAFE-PROD-INSTALL-CM94-Client-v10_0.cmd"
SET "USER_SETTINGS_VBS=%DIRFILES%\WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs"

REM ----------------------------------------------------------------
REM  DETECTION ARTEFACTS  (mirrors PSADT $KeyPath / $detectionMethod)
REM ----------------------------------------------------------------
SET "TAG_FOLDER=C:\ProgramData\Tagfiles"
SET "TAG_FILE=%TAG_FOLDER%\WSDOM_10_0.tag"
SET "REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\IBM\Ocelot Packages\WSDOM_10.0"

REM ================================================================
REM  PRE-INSTALL
REM  Create tag folder if missing (mirrors: New-Folder -Path $KeyPath)
REM ================================================================
ECHO [PRE-INSTALL] Creating tag folder if required...
IF NOT EXIST "%TAG_FOLDER%" MKDIR "%TAG_FOLDER%"

REM ================================================================
REM  INSTALL — 64-BIT OFFICE DETECTION
REM  Checks file paths (MSI Office) then registry (M365 / C2R).
REM  Mirrors the existing IF EXIST blocks in the original CMD.
REM ================================================================
SET "OFFICE_ARCH=NONE"

REM -- File-path checks (traditional MSI installs) --
IF EXIST "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE"             SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"             SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE"        SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"        SET "OFFICE_ARCH=x64"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"       SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE"       SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office15\WINWORD.EXE"  SET "OFFICE_ARCH=x86"
IF EXIST "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE"  SET "OFFICE_ARCH=x86"

REM -- Registry checks (Microsoft 365 / Click-to-Run) --
REM    Native HKLM key = 64-bit; WOW6432Node key = 32-bit
REG QUERY "HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x64"

REG QUERY "HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" >NUL 2>&1
IF %ERRORLEVEL%==0 SET "OFFICE_ARCH=x86"

ECHO [INSTALL] Detected Office architecture: %OFFICE_ARCH%

IF /I NOT "%OFFICE_ARCH%"=="x64" (
    ECHO [SKIP] 64-bit Office not detected. Installation will not proceed.
    ENDLOCAL
    EXIT /B 0
)

REM -- Verify install CMD exists before calling --
IF NOT EXIST "%INSTALL_CMD%" (
    ECHO [ERROR] Install CMD not found: %INSTALL_CMD%
    ENDLOCAL
    EXIT /B 1
)

ECHO [INSTALL] Launching: %INSTALL_CMD%
REM  CALL preserves SETLOCAL scope and captures exit code
CALL "%INSTALL_CMD%"
SET "INSTALL_EXIT=%ERRORLEVEL%"
ECHO [INSTALL] CMD exited with code: %INSTALL_EXIT%

REM ================================================================
REM  POST-INSTALL
REM  Mirrors PSADT post-install block:
REM    - Run user-settings VBS
REM    - Write tag file
REM    - Set IBM Ocelot registry detection key (Installed = 1 DWORD)
REM  Only runs if install succeeded (exit 0, 1707, 3010, 1641, 1618)
REM ================================================================
SET "GOOD_EXIT=0"
IF "%INSTALL_EXIT%"=="1707" SET "GOOD_EXIT=0"
IF "%INSTALL_EXIT%"=="3010" SET "GOOD_EXIT=0"
IF "%INSTALL_EXIT%"=="1641" SET "GOOD_EXIT=0"
IF "%INSTALL_EXIT%"=="1618" SET "GOOD_EXIT=0"

IF NOT "%INSTALL_EXIT%"=="0" (
    IF NOT "%INSTALL_EXIT%"=="1707" (
        IF NOT "%INSTALL_EXIT%"=="3010" (
            IF NOT "%INSTALL_EXIT%"=="1641" (
                IF NOT "%INSTALL_EXIT%"=="1618" (
                    ECHO [POST-INSTALL] Install failed with exit code %INSTALL_EXIT%. Skipping post-install steps.
                    ENDLOCAL
                    EXIT /B %INSTALL_EXIT%
                )
            )
        )
    )
)

REM -- Run user-settings VBS (mirrors PSADT Execute-Process wscript.exe) --
IF EXIST "%USER_SETTINGS_VBS%" (
    ECHO [POST-INSTALL] Running user settings VBS...
    START /WAIT "" wscript.exe "%USER_SETTINGS_VBS%"
) ELSE (
    ECHO [POST-INSTALL] WARNING: VBS not found at %USER_SETTINGS_VBS% — skipping.
)

REM -- Write tag file (mirrors PSADT "" | out-file -FilePath ($KeyPath + $Keyfile)) --
ECHO [POST-INSTALL] Creating tag file: %TAG_FILE%
ECHO.> "%TAG_FILE%"

REM -- Set registry detection key (mirrors PSADT Set-RegistryKey Installed=1 DWord) --
ECHO [POST-INSTALL] Writing detection registry key...
REG ADD "%REG_KEY%" /V "Installed" /T "REG_DWORD" /D "1" /F >NUL 2>&1

ECHO [POST-INSTALL] Installation complete.
ENDLOCAL
EXIT /B %INSTALL_EXIT%
