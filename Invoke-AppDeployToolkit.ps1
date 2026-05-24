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
# PSADT stub - allows script to run outside full PSADT context
# ============================================================
if (-not (Get-Command 'Write-ADTLogEntry' -ErrorAction SilentlyContinue)) {
    function Write-ADTLogEntry {
        param([string]$Message, [string]$Source)
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Write-Host "[$timestamp][$Source] $Message"
        $logDir = "C:\Windows\Logs\Software"
        if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
        "[$timestamp][$Source] $Message" | Out-File "$logDir\Office365_Install.log" -Append -Encoding UTF8
    }
}

# ============================================================
# Resolve script root correctly whether run via bat or directly
# ============================================================
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-ADTLogEntry -Message "=== Office 365 Deployment Started === DeploymentType: $DeploymentType | DeployMode: $DeployMode" -Source 'Invoke-AppDeployToolkit'
Write-ADTLogEntry -Message "Script root: $scriptRoot" -Source 'Invoke-AppDeployToolkit'

# ============================================================
# Clear stale DeferUntil so manual runs always show the prompt
# ============================================================
$AppKey  = 'Microsoft_Office365_x64_EN_003'
$regPath = "HKLM:\SOFTWARE\PSADT_Deferrals\$AppKey"
if (Test-Path $regPath) {
    $existingDefer = (Get-ItemProperty -Path $regPath -Name 'DeferUntil' -ErrorAction SilentlyContinue).DeferUntil
    if ($existingDefer) {
        try {
            $deferUntil = [DateTime]::Parse($existingDefer)
            if ((Get-Date) -ge $deferUntil) {
                Remove-ItemProperty -Path $regPath -Name 'DeferUntil' -ErrorAction SilentlyContinue
                Write-ADTLogEntry -Message "Cleared expired DeferUntil: $existingDefer" -Source 'Invoke-AppDeployToolkit'
            } else {
                Write-ADTLogEntry -Message "Active DeferUntil found: $existingDefer - will be checked in deferral prompt" -Source 'Invoke-AppDeployToolkit'
            }
        } catch {
            Remove-ItemProperty -Path $regPath -Name 'DeferUntil' -ErrorAction SilentlyContinue
        }
    }
}

# ============================================================
# Dot-source custom function scripts
# ============================================================
$deferralScript  = Join-Path $scriptRoot 'Show-DeferralPrompt.ps1'
$progressScript  = Join-Path $scriptRoot 'Show-ProgressWindow.ps1'

if (-not (Test-Path $deferralScript)) {
    Write-ADTLogEntry -Message "ERROR: Show-DeferralPrompt.ps1 not found at $deferralScript" -Source 'Invoke-AppDeployToolkit'
    exit 1
}
if (-not (Test-Path $progressScript)) {
    Write-ADTLogEntry -Message "ERROR: Show-ProgressWindow.ps1 not found at $progressScript" -Source 'Invoke-AppDeployToolkit'
    exit 1
}

. $deferralScript
. $progressScript

Write-ADTLogEntry -Message "Scripts loaded successfully" -Source 'Invoke-AppDeployToolkit'

# ============================================================
# Show deferral prompt - user decides to install or defer
# ============================================================
Write-ADTLogEntry -Message "Launching deferral prompt..." -Source 'Invoke-AppDeployToolkit'

$deferResult = Show-DeferralPrompt

Write-ADTLogEntry -Message "Deferral prompt returned: $deferResult" -Source 'Invoke-AppDeployToolkit'

if ($deferResult -eq -1) {
    # User deferred - registry already written by Show-DeferralPrompt
    # Detection script will return Exit 0 during deferral window
    Write-ADTLogEntry -Message "User deferred. Exiting cleanly. Intune will retry when DeferUntil expires." -Source 'Invoke-AppDeployToolkit'
    exit 0
}

# ============================================================
# User clicked Install Now - proceed with installation
# ============================================================
Write-ADTLogEntry -Message "User accepted. Starting Office 365 installation..." -Source 'Invoke-AppDeployToolkit'

# Show progress window in background
Show-ProgressWindow

# -------------------------------------------------------
# YOUR OFFICE INSTALL COMMAND GOES HERE
# Examples - uncomment/edit the one that matches your setup:
# -------------------------------------------------------

# Option A - setup.exe with XML config (most common for M365)
$setupPath = Join-Path $scriptRoot 'setup.exe'
$configPath = Join-Path $scriptRoot 'configuration.xml'

if (Test-Path $setupPath) {
    Write-ADTLogEntry -Message "Running: $setupPath /configure $configPath" -Source 'Invoke-AppDeployToolkit'
    $installProcess = Start-Process -FilePath $setupPath `
        -ArgumentList "/configure `"$configPath`"" `
        -Wait -PassThru -NoNewWindow
    $exitCode = $installProcess.ExitCode
} else {
    Write-ADTLogEntry -Message "ERROR: setup.exe not found at $setupPath" -Source 'Invoke-AppDeployToolkit'
    Close-ProgressWindow
    exit 1
}

# Option B - MSI installer (uncomment if using MSI)
# $msiPath = Join-Path $scriptRoot 'Office365.msi'
# $installProcess = Start-Process -FilePath 'msiexec.exe' `
#     -ArgumentList "/i `"$msiPath`" /qn /norestart" `
#     -Wait -PassThru -NoNewWindow
# $exitCode = $installProcess.ExitCode

# -------------------------------------------------------

Write-ADTLogEntry -Message "Install process exited with code: $exitCode" -Source 'Invoke-AppDeployToolkit'

# Close progress window
Close-ProgressWindow

# ============================================================
# Clean up deferral registry on successful install
# ============================================================
if ($exitCode -eq 0 -or $exitCode -eq 3010) {
    try {
        Remove-Item -Path $regPath -Force -Recurse -ErrorAction SilentlyContinue
        Write-ADTLogEntry -Message "Deferral registry cleaned up after successful install." -Source 'Invoke-AppDeployToolkit'
    } catch {}
}

# ============================================================
# Exit with installer exit code for Intune
# 0    = success
# 3010 = success, reboot required
# anything else = failure
# ============================================================
Write-ADTLogEntry -Message "=== Deployment Complete. Exit code: $exitCode ===" -Source 'Invoke-AppDeployToolkit'
exit $exitCode
