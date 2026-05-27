#Requires -RunAsAdministrator
<#
.SYNOPSIS
    WSDoM v10.0 - Standalone Install Wrapper (no PSADT required)
    Mirrors Deploy-Application.ps1 logic. Place next to the CMD file.
.NOTES
    Intune install command:
        powershell.exe -ExecutionPolicy Bypass -File "Install.ps1"
#>

# ----------------------------------------------------------------
# PATHS — all relative to this script (mirrors PSADT $dirFiles)
# ----------------------------------------------------------------
$DirFiles         = $PSScriptRoot
$InstallCmd       = Join-Path $DirFiles '01-WORKSAFE-PROD-INSTALL-CM94-Client-v10_0.cmd'
$UserSettingsVbs  = Join-Path $DirFiles 'WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs'
$TagFolder        = 'C:\ProgramData\Tagfiles'
$TagFile          = Join-Path $TagFolder 'WSDOM_10_0.tag'
$RegKey           = 'HKLM:\SOFTWARE\IBM\Ocelot Packages\WSDOM_10.0'

# ----------------------------------------------------------------
# LOGGING — mirrors PSADT Write-Log to same location as PS1
# ----------------------------------------------------------------
$LogDir  = "$env:WinDir\Logs\Software\WSDOM 10.0"
$LogFile = "$LogDir\Install_WSDOM_10.0.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Severity = 'INFO')
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Severity, $Message
    Write-Host $line
    $line | Out-File -FilePath $LogFile -Append -Encoding utf8
}

Write-Log "===== WSDoM v10.0 Install Wrapper Starting ====="
Write-Log "Script root : $DirFiles"
Write-Log "Install CMD : $InstallCmd"

# ----------------------------------------------------------------
# PRE-INSTALL — create tag folder (mirrors: New-Folder $KeyPath)
# ----------------------------------------------------------------
Write-Log "PRE-INSTALL: Ensuring tag folder exists: $TagFolder"
if (-not (Test-Path $TagFolder)) {
    New-Item -ItemType Directory -Path $TagFolder -Force | Out-Null
}

# ----------------------------------------------------------------
# 64-BIT OFFICE DETECTION
# File-path checks first, then registry for M365 / Click-to-Run
# ----------------------------------------------------------------
$OfficeArch = 'NONE'

$x64Paths = @(
    'C:\Program Files\Microsoft Office\Office15\WINWORD.EXE'
    'C:\Program Files\Microsoft Office\Office16\WINWORD.EXE'
    'C:\Program Files\Microsoft Office\root\Office15\WINWORD.EXE'
    'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE'
)
$x86Paths = @(
    'C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE'
    'C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE'
    'C:\Program Files (x86)\Microsoft Office\root\Office15\WINWORD.EXE'
    'C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE'
)

foreach ($p in $x64Paths) { if (Test-Path $p) { $OfficeArch = 'x64'; break } }
foreach ($p in $x86Paths) { if (Test-Path $p) { $OfficeArch = 'x86'; break } }

# Registry fallback for Click-to-Run (native HKLM = 64-bit; WOW6432Node = 32-bit)
$c2r64 = 'HKLM:\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot'
$c2r32 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot'
if (Test-Path $c2r64) { $OfficeArch = 'x64' }
if (Test-Path $c2r32) { $OfficeArch = 'x86' }   # 32-bit wins if both exist

Write-Log "INSTALL: Detected Office architecture: $OfficeArch"

if ($OfficeArch -ne 'x64') {
    Write-Log "SKIP: 64-bit Office not detected. Installation will not proceed." 'WARN'
    exit 0
}

# ----------------------------------------------------------------
# INSTALL — call cmd.exe /c exactly as PSADT Execute-Process does
# ----------------------------------------------------------------
if (-not (Test-Path $InstallCmd)) {
    Write-Log "ERROR: Install CMD not found at: $InstallCmd" 'ERROR'
    exit 1
}

Write-Log "INSTALL: Launching: $InstallCmd"

$proc = Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" `
                      -ArgumentList "/c `"$InstallCmd`"" `
                      -Wait -PassThru -WindowStyle Hidden

$InstallExit = $proc.ExitCode
Write-Log "INSTALL: CMD exited with code: $InstallExit"

# ----------------------------------------------------------------
# POST-INSTALL — mirrors PSADT good-exit-code check
# ----------------------------------------------------------------
$goodExits = @(0, 1707, 3010, 1641, 1618)

if ($InstallExit -notin $goodExits) {
    Write-Log "ERROR: Install failed (exit $InstallExit). Post-install skipped." 'ERROR'
    exit $InstallExit
}

# Run user-settings VBS (mirrors PSADT Execute-Process wscript.exe)
if (Test-Path $UserSettingsVbs) {
    Write-Log "POST-INSTALL: Running user settings VBS..."
    $vbs = Start-Process -FilePath "$env:SystemRoot\System32\wscript.exe" `
                         -ArgumentList "`"$UserSettingsVbs`"" `
                         -Wait -PassThru -WindowStyle Hidden
    Write-Log "POST-INSTALL: VBS exited with code: $($vbs.ExitCode)"
} else {
    Write-Log "POST-INSTALL: VBS not found at $UserSettingsVbs — skipping." 'WARN'
}

# Write tag file (mirrors PSADT "" | out-file -FilePath ($KeyPath + $Keyfile))
Write-Log "POST-INSTALL: Writing tag file: $TagFile"
'' | Out-File -FilePath $TagFile -Force -Encoding ascii

# Set registry detection key (mirrors PSADT Set-RegistryKey Installed=1 DWord)
Write-Log "POST-INSTALL: Writing registry detection key: $RegKey"
if (-not (Test-Path $RegKey)) {
    New-Item -Path $RegKey -Force | Out-Null
}
Set-ItemProperty -Path $RegKey -Name 'Installed' -Value 1 -Type DWord -Force

Write-Log "===== WSDoM v10.0 Install Wrapper Complete (exit $InstallExit) ====="
exit $InstallExit
