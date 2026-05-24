$AppKey = "Microsoft_Office365_x64_EN_003"
$RegPath = "HKLM:\SOFTWARE\PSADT_Deferrals\$AppKey"

# 1. Check if Office 365 is actually installed on the system
$OfficeInstalled = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
                   Where-Object { $_.DisplayName -like "*Microsoft 365 Apps for enterprise*" -or $_.DisplayName -like "*Office 365*" }

if ($OfficeInstalled) {
    Write-Output "Office 365 is installed. Detection passed."
    Exit 0
}

# 2. Office is missing. Check if a 1-hour deferral is active
if (Test-Path $RegPath) {
    $DeferUntilStr = (Get-ItemProperty -Path $RegPath -Name "DeferUntil" -ErrorAction SilentlyContinue).DeferUntil
    if ($DeferUntilStr) {
        $DeferUntil = [DateTime]::Parse($DeferUntilStr)
        $CurrentTime = Get-Date

        # If still within the 1-hour window, return 0 (Success) to fool Intune into sleeping
        if ($CurrentTime -lt $DeferUntil) {
            Write-Output "User deferred deployment. Deferral active until $DeferUntil. Exiting with 0 to prevent 20-minute re-prompt."
            Exit 0
        }
    }
}

# 3. Office is missing AND no active deferral exists (or it expired). Intune will run the installation.
Write-Output "Office is missing and deferral window has expired. Initiating deployment."
Exit 1
