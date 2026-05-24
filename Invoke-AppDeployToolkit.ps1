<#
.SYNOPSIS
    PSAppDeployToolkit v4 - Microsoft Office 365 x64 Deployment
.DESCRIPTION
    Installs, Uninstalls, or Repairs Microsoft Office 365 x64.
    Converted from v3 Deploy-Application.ps1 to v4 format.
    - Uses Show-ADTInstallationWelcome with DeferRunInterval to silently
      absorb Intune re-check-ins within the defer window (fixes 10-min reprompt).
    - No longer requires ServiceUI.exe; Invoke-AppDeployToolkit.exe handles
      user session detection natively in v4.1+.
.PARAMETER DeploymentType
    Install | Uninstall | Repair  (default: Install)
.PARAMETER DeployMode
    Interactive | Silent | NonInteractive  (default: Interactive)
.PARAMETER AllowRebootPassThru
    Pass exit code 3010 back to the calling process.
.PARAMETER TerminalServerMode
    Enable user-install mode for RDS / Citrix hosts.
.PARAMETER DisableLogging
    Suppress log file output.
.NOTES
    Author  : kundv1 (v3 original) - converted to v4
    Version : 4.0.0
    Date    : 10/04/2024
    PSADT   : 4.1.x required
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [string]$DeploymentType = 'Install',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [string]$DeployMode = 'Interactive',

    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging
)


##*=============================================
##* IMPORT PSADT v4 MODULE
##*=============================================
try {
    $adtModule = Join-Path -Path $PSScriptRoot -ChildPath 'PSAppDeployToolkit\PSAppDeployToolkit.psd1'
    if (-not (Test-Path -LiteralPath $adtModule)) {
        throw "PSAppDeployToolkit module not found at: $adtModule"
    }
    Import-Module -Name $adtModule -Force

    # Load custom scripts
    . (Join-Path -Path $PSScriptRoot -ChildPath 'Show-DeferralPrompt.ps1')
    . (Join-Path -Path $PSScriptRoot -ChildPath 'Show-ProgressWindow.ps1')
}
catch {
    Write-Error "Failed to import PSAppDeployToolkit module: $_"
    exit 60008
}


##*=============================================
##* INSTALL SCRIPTBLOCK
##*=============================================
$Install = {

    ##*------------------------------------------
    ##* PRE-INSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Pre-Installation'

    # Custom time-based deferral prompt
    $deferResult = Show-DeferralPrompt `
        -AppName      'Microsoft Office 365' `
        -MaxDeferCount 4 `
        -SnoozeDuration 60 `
        -CloseApps    @('WINWORD','EXCEL','OUTLOOK','POWERPNT','ONENOTE','WINPROJ','VISIO','TEAMS','GROOVE')

    # -1 = active defer window found, exit silently so Intune sees detection.ps1 return 0
    if ($deferResult -eq -1) { Close-ADTSession; exit 0 }

    ##*------------------------------------------
    ##* INSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Installation'

    # Retrieve session object so DirFiles is available
    $adtSession = Get-ADTSession

    # Show custom progress window (no black box, no Software Center branding)
    Show-ProgressWindow `
        -StatusMessage 'Microsoft Office 365 Installation in Progress... This may take up to 25 minutes to complete.'

    Write-ADTLogEntry -Message 'Starting Office removal and upgrade process...' -Source 'Install'

    # Key paths
    $SetupExe  = Join-Path -Path $adtSession.DirFiles -ChildPath 'setup.exe'
    $dirFiles  = $adtSession.DirFiles
    $PF86      = ${env:ProgramFiles(x86)}
    $PF64      = $env:ProgramFiles
    $MsiConfig = Join-Path -Path $dirFiles -ChildPath 'O2016\remove2016.xml'

    # Helper: run ODT /configure with a named XML from Files\
    # -WindowStyle Hidden suppresses the black console window from setup.exe
    function Invoke-OfficeConfig {
        param([string]$XmlName)
        $XmlPath = Join-Path -Path $dirFiles -ChildPath $XmlName
        if (Test-Path -Path $XmlPath) {
            Write-ADTLogEntry -Message "Running ODT config: $XmlName" -Source 'Invoke-OfficeConfig'
            Start-ADTProcess -FilePath $SetupExe -ArgumentList "/configure `"$XmlPath`"" -WindowStyle Hidden
        }
        else {
            Write-ADTLogEntry -Message "XML not found, skipping: $XmlName" -Severity 2 -Source 'Invoke-OfficeConfig'
        }
    }

    # 1. Remove Visio Standard - check both x86 and x64 C2R paths
    if (Test-Path "$PF86\Microsoft Office\root\Office16\Visio.exe") {
        Write-ADTLogEntry -Message 'Visio detected (x86) - removing...' -Source 'Install'
        Invoke-OfficeConfig 'RemoveVisioStd.xml'
    }
    if (Test-Path "$PF64\Microsoft Office\root\Office16\Visio.exe") {
        Write-ADTLogEntry -Message 'Visio detected (x64) - removing...' -Source 'Install'
        Invoke-OfficeConfig 'RemoveVisioStd.xml'
    }

    # 2. Remove Project Standard - check both x86 and x64 C2R paths
    if (Test-Path "$PF86\Microsoft Office\root\Office16\WinProj.exe") {
        Write-ADTLogEntry -Message 'WinProj detected (x86) - removing...' -Source 'Install'
        Invoke-OfficeConfig 'Uninstall-ProjStdXVolume.xml'
    }
    if (Test-Path "$PF64\Microsoft Office\root\Office16\WinProj.exe") {
        Write-ADTLogEntry -Message 'WinProj detected (x64) - removing...' -Source 'Install'
        Invoke-OfficeConfig 'Uninstall-ProjStdXVolume.xml'
    }

    # 3. Remove legacy Office 2016 MSI - check both x86 and x64 Setup Controller paths
    $MsiSetup86 = 'C:\Program Files (x86)\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe'
    $MsiSetup64 = 'C:\Program Files\Common Files\Microsoft Shared\OFFICE16\Office Setup Controller\setup.exe'

    if (Test-Path -Path $MsiSetup86) {
        Write-ADTLogEntry -Message 'Legacy Office 2016 MSI detected (x86) - removing...' -Source 'Install'
        Start-ADTProcess -FilePath $MsiSetup86 -ArgumentList "/uninstall PROPLUS /config `"$MsiConfig`"" -WindowStyle Hidden
    }
    if (Test-Path -Path $MsiSetup64) {
        Write-ADTLogEntry -Message 'Legacy Office 2016 MSI detected (x64) - removing...' -Source 'Install'
        Start-ADTProcess -FilePath $MsiSetup64 -ArgumentList "/uninstall PROPLUS /config `"$MsiConfig`"" -WindowStyle Hidden
    }

    # 4. Additional C2R cleanup passes (x86 C2R paths)
    if (Test-Path "$PF86\Microsoft Office\root\Office16\winproj.exe") {
        Invoke-OfficeConfig 'removeprj.xml'
    }
    if (Test-Path "$PF86\Microsoft Office\root\Office16\Visio.exe") {
        Invoke-OfficeConfig 'RemoveVisioStd2021.xml'
    }
    if (Test-Path "$PF86\Microsoft Office\root\Office16\outlook.exe") {
        Invoke-OfficeConfig 'remove.xml'
    }

    # 5. Deploy Office 365
    Write-ADTLogEntry -Message 'Initiating Office 365 deployment...' -Source 'Install'
    Invoke-OfficeConfig 'Configuration.xml'

    ##*------------------------------------------
    ##* POST-INSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Post-Installation'

    # Close the custom progress window
    Close-ProgressWindow
}


##*=============================================
##* UNINSTALL SCRIPTBLOCK
##*=============================================
$Uninstall = {

    ##*------------------------------------------
    ##* PRE-UNINSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Pre-Uninstallation'

    $closeAppsAll = @(
        'officeclicktorun', 'ose', 'osppsvc', 'sppsvc', 'msoia',
        'excel', 'groove', 'onenote', 'infopath', 'outlook', 'mspub',
        'powerpnt', 'winword', 'winproj', 'visio', 'iexplore',
        'lync', 'communicator', 'teams', 'ONENOTEM', 'msaccess'
    )

    Show-ADTInstallationWelcome `
        -CloseProcesses $closeAppsAll `
        -AllowDefer `
        -DeferTimes 3 `
        -DeferRunInterval 60 `
        -PersistPrompt

    ##*------------------------------------------
    ##* UNINSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Uninstallation'

    Show-ADTInstallationProgress `
        -StatusMessage 'Uninstalling Microsoft Office 365. This may take some time. Please wait...'

    Start-ADTProcess `
        -FilePath      (Join-Path -Path (Get-ADTSession).DirFiles -ChildPath 'UnInstall.bat') `
        -WindowStyle   Hidden

    ##*------------------------------------------
    ##* POST-UNINSTALLATION
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Post-Uninstallation'
}


##*=============================================
##* REPAIR SCRIPTBLOCK
##*=============================================
$Repair = {

    ##*------------------------------------------
    ##* PRE-REPAIR
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Pre-Repair'

    $closeAppsAll = @(
        'officeclicktorun', 'ose', 'osppsvc', 'sppsvc', 'msoia',
        'excel', 'groove', 'onenote', 'infopath', 'outlook', 'mspub',
        'powerpnt', 'winword', 'winproj', 'visio', 'iexplore',
        'lync', 'communicator', 'teams', 'ONENOTEM', 'msaccess'
    )

    Show-ADTInstallationWelcome `
        -CloseProcesses $closeAppsAll `
        -AllowDefer `
        -DeferTimes 3 `
        -DeferRunInterval 60 `
        -PersistPrompt

    ##*------------------------------------------
    ##* REPAIR
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Repair'

    Show-ADTInstallationProgress `
        -StatusMessage 'Repairing Microsoft Office 365. This may take some time. Please wait...'

    Start-ADTProcess `
        -FilePath      (Join-Path -Path (Get-ADTSession).DirFiles -ChildPath 'Install.bat') `
        -WindowStyle   Hidden

    ##*------------------------------------------
    ##* POST-REPAIR
    ##*------------------------------------------
    (Get-ADTSession).InstallPhase = 'Post-Repair'
}


##*=============================================
##* OPEN SESSION AND RUN
##*=============================================
try {
    $sessionParams = @{
        SessionState           = $ExecutionContext.SessionState
        AppVendor              = 'Microsoft'
        AppName                = 'Office 365'
        AppVersion             = '365'
        AppArch                = 'x64'
        AppLang                = 'EN'
        AppRevision            = '003'
        AppScriptVersion       = '4.0.0'
        AppScriptDate          = '10/04/2024'
        AppScriptAuthor        = 'kundv1'
        DeploymentType         = $DeploymentType
        DeployMode             = $DeployMode
        SuppressRebootPassThru = $AllowRebootPassThru
        TerminalServerMode     = $TerminalServerMode
        DisableLogging         = $DisableLogging
    }

    Open-ADTSession @sessionParams

    switch ($DeploymentType) {
        'Install'   { & $Install   }
        'Uninstall' { & $Uninstall }
        'Repair'    { & $Repair    }
    }
}
catch {
    Write-ADTLogEntry -Message "Unhandled error: $_" -Severity 3 -Source 'Invoke-AppDeployToolkit'
    Show-ADTDialogBox -Title 'Installation Error' -Text $_.ToString() -Icon Stop -ErrorAction SilentlyContinue
    Close-ProgressWindow
    exit 60001
}
finally {
    Close-ADTSession
}