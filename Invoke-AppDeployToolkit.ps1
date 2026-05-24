<#
.SYNOPSIS
    Main orchestrator for Office 365 deployment.
    Handles deferral prompt, progress window, install, and exit codes for Intune.
    Run via ServiceUI.exe for Intune SYSTEM context, or directly as admin for testing.
#>

[CmdletBinding()]
param(
    [string]$DeploymentType = 'Install',
    [string]$DeployMode     = 'Interactive'
)

# ============================================================
# PSADT stub - lets script run outside full PSADT context
# Logs to C:\Windows\Logs\Software\Office365_Install.log
# ============================================================
if (-not (Get-Command 'Write-ADTLogEntry' -ErrorAction SilentlyContinue)) {
    function Write-ADTLogEntry {
        param([string]$Message, [string]$Source)
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        $line      = "[$timestamp][$Source] $Message"
        Write-Host $line
        $logDir = 'C:\Windows\Logs\Software'
        if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
        $line | Out-File "$logDir\Office365_Install.log" -Append -Encoding UTF8
    }
}

# ============================================================
# Resolve script root correctly whether run via bat or directly
# ============================================================
$scriptRoot = if ($PSScriptRoot -and $PSScriptRoot -ne '') {
    $PSScriptRoot
} else {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}

Write-ADTLogEntry -Message "=== Office 365 Deployment Started === DeploymentType: $DeploymentType | DeployMode: $DeployMode" -Source 'Main'
Write-ADTLogEntry -Message "Script root resolved to: $scriptRoot" -Source 'Main'

# ============================================================
# Paths
# ============================================================
$deferralScript = Join-Path $scriptRoot 'Show-DeferralPrompt.ps1'
$progressScript = Join-Path $scriptRoot 'Show-ProgressWindow.ps1'
$setupExe       = Join-Path $scriptRoot 'Files\setup.exe'
$configXml      = Join-Path $scriptRoot 'Files\configuration.xml'

# Verify all required files exist before doing anything
$missing = @()
if (-not (Test-Path $deferralScript)) { $missing += $deferralScript }
if (-not (Test-Path $progressScript))  { $missing += $progressScript }
if (-not (Test-Path $setupExe))        { $missing += $setupExe }
if (-not (Test-Path $configXml))       { $missing += $configXml }

if ($missing.Count -gt 0) {
    foreach ($m in $missing) {
        Write-ADTLogEntry -Message "ERROR: Required file not found: $m" -Source 'Main'
    }
    exit 1
}

Write-ADTLogEntry -Message "All required files verified." -Source 'Main'

# ============================================================
# Dot-source custom function scripts
# ============================================================
. $deferralScript
. $progressScript
Write-ADTLogEntry -Message "Custom scripts loaded." -Source 'Main'

# ============================================================
# Show deferral prompt
# ============================================================
Write-ADTLogEntry -Message "Launching deferral prompt..." -Source 'Main'
$deferResult = Show-DeferralPrompt
Write-ADTLogEntry -Message "Deferral prompt returned: $deferResult" -Source 'Main'

if ($deferResult -eq -1) {
    Write-ADTLogEntry -Message "User deferred. Exiting cleanly." -Source 'Main'
    exit 0
}

# ============================================================
# User clicked Install Now - show progress and run installer
# ============================================================
Write-ADTLogEntry -Message "User accepted. Showing progress window..." -Source 'Main'
Show-ProgressWindow

Write-ADTLogEntry -Message "Running: $setupExe /configure $configXml" -Source 'Main'

try {
    $installProcess = Start-Process `
        -FilePath    $setupExe `
        -ArgumentList "/configure `"$configXml`"" `
        -Wait -PassThru -NoNewWindow
    $exitCode = $installProcess.ExitCode
} catch {
    Write-ADTLogEntry -Message "ERROR launching installer: $_" -Source 'Main'
    Close-ProgressWindow
    exit 1
}

Write-ADTLogEntry -Message "Installer exited with code: $exitCode" -Source 'Main'
Close-ProgressWindow

# ============================================================
# Clean up deferral registry on success
# ============================================================
if ($exitCode -eq 0 -or $exitCode -eq 3010) {
    $regPath = "HKLM:\SOFTWARE\PSADT_Deferrals\Microsoft_Office365_x64_EN_003"
    try {
        Remove-Item -Path $regPath -Force -Recurse -ErrorAction SilentlyContinue
        Write-ADTLogEntry -Message "Deferral registry cleaned up." -Source 'Main'
    } catch {}
}

Write-ADTLogEntry -Message "=== Deployment Complete. Exit code: $exitCode ===" -Source 'Main'
exit $exitCode
