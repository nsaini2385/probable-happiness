<#
.SYNOPSIS
    Detection script for Microsoft 365 Apps for enterprise - en-us
    Minimum required build: 16.0.19929.20172

    Logic:
    - Primary check: Click-to-Run registry (most reliable for M365)
    - Fallback check: Uninstall registry
    - Returns Exit 0 if installed version >= required minimum
    - Returns Exit 0 if Office missing BUT active defer window exists (stops Intune retrying)
    - Returns Exit 0 if Office missing BUT stale registry from previous day (prevents false fail on restart)
    - Returns Exit 1 if not installed, no defer active, and no stale registry
#>

$RequiredDisplayName = 'Microsoft 365 Apps for enterprise - en-us'
$MinVersion          = [Version]'16.0.19929.20172'
$AppKey              = 'Microsoft_Office365_x64_EN_003'
$RegPath             = "HKLM:\SOFTWARE\PSADT_Deferrals\$AppKey"

# ============================================================
# PRIMARY: Click-to-Run registry
# ============================================================
try {
    $C2R = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' `
        -ErrorAction Stop

    $installedVersion = [Version]$C2R.VersionToReport

    if ($installedVersion -ge $MinVersion) {
        Write-Output "DETECTED: M365 Apps build $installedVersion meets minimum $MinVersion."
        # Clean up defer registry now that Office is confirmed installed
        Remove-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
        Exit 0
    } else {
        Write-Output "BELOW MINIMUM: Installed $installedVersion | Required $MinVersion. Triggering upgrade."
        Exit 1
    }
} catch {
    Write-Output "C2R registry key not found - Office not installed via Click-to-Run."
}

# ============================================================
# FALLBACK: Uninstall registry
# ============================================================
try {
    $uninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $officeEntry = Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq $RequiredDisplayName } |
        Select-Object -First 1

    if ($officeEntry) {
        try {
            $fallbackVersion = [Version]$officeEntry.DisplayVersion
            if ($fallbackVersion -ge $MinVersion) {
                Write-Output "DETECTED (fallback): $($officeEntry.DisplayName) v$fallbackVersion meets minimum $MinVersion."
                Remove-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
                Exit 0
            } else {
                Write-Output "BELOW MINIMUM (fallback): $fallbackVersion | Required $MinVersion. Triggering upgrade."
                Exit 1
            }
        } catch {
            Write-Output "Could not parse fallback version: $($officeEntry.DisplayVersion)"
        }
    }
} catch {}

# ============================================================
# OFFICE NOT INSTALLED - check defer registry before failing
# ============================================================

if (Test-Path $RegPath) {

    # ---- Check 1: Active DeferUntil window ----
    # Script is sleeping during a snooze - tell Intune "installed" so it stops retrying
    $DeferUntilStr = (Get-ItemProperty -Path $RegPath -Name 'DeferUntil' -ErrorAction SilentlyContinue).DeferUntil
    if ($DeferUntilStr) {
        try {
            $DeferUntil = [DateTime]::Parse($DeferUntilStr)
            if ((Get-Date) -lt $DeferUntil) {
                $minsLeft = [math]::Round(($DeferUntil - (Get-Date)).TotalMinutes)
                Write-Output "DEFER ACTIVE: $minsLeft minutes remaining until $DeferUntil. Returning 0 to hold Intune."
                Exit 0
            } else {
                # DeferUntil expired - clear it so script re-shows prompt
                Remove-ItemProperty -Path $RegPath -Name 'DeferUntil' -ErrorAction SilentlyContinue
                Write-Output "Defer window expired. Clearing DeferUntil."
            }
        } catch {}
    }

    # ---- Check 2: Stale registry from previous session/day ----
    # Device restarted or script ran yesterday - registry exists but script is no longer running
    # Return Exit 0 so Intune doesn't mark as failed on restart
    # Intune will re-evaluate and re-run the install script on next check-in
    $startTimeStr = (Get-ItemProperty -Path $RegPath -Name 'ScriptStartTime' -ErrorAction SilentlyContinue).ScriptStartTime
    if ($startTimeStr) {
        try {
            $startTime   = [DateTime]::Parse($startTimeStr)
            $isNewDay    = $startTime.Date -lt (Get-Date).Date
            $isTooOld    = $startTime -lt (Get-Date).AddHours(-7)

            if ($isNewDay -or $isTooOld) {
                # Stale - clear registry and return Exit 1 so Intune re-runs install fresh
                Write-Output "STALE REGISTRY: From $startTime - clearing for fresh deployment attempt."
                Remove-Item -Path $RegPath -Force -ErrorAction SilentlyContinue
                Exit 1
            } else {
                # Registry is from today and recent - script may still be running or just exited
                # Return Exit 0 to hold Intune off until script has a chance to run
                Write-Output "RECENT REGISTRY: ScriptStartTime $startTime is recent. Holding Intune off."
                Exit 0
            }
        } catch {}
    }
}

# ============================================================
# NOT DETECTED - no defer, no stale registry
# ============================================================
Write-Output "NOT DETECTED: $RequiredDisplayName >= $MinVersion not found. Intune will trigger deployment."
Exit 1
