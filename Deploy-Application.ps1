<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Repair','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $true,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
    [string]$accountName = 'TAC'
	[string]$appVendor = 'TAC'
	[string]$appName = 'WSDOM'
	[string]$appVersion = '10.0'
    [string]$projectName = 'WSDOM'
	[string]$buildNumber = 'B1'
    [string]$OSVersion = ',,'
    [string]$AppType = 'Script'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '00/00/0000'
	[string]$appScriptAuthor = 'Vikram KV'
	[string]$KeyPath = ''
	[string]$KeyFile = ''
	[string]$LogPath = ''
	[string]$LogFile = ''
	[string]$detectionMethod = "HKEY_LOCAL_MACHINE\Software\IBM\Ocelot Packages\" + $appName + "_" + $appversion
    
    ##*===============================================
    ## IBM Standards Variable Initialization
    ##*===============================================
	$SystemPath = $Env:Windir + '\system32\'
	$KeyPath = $Env:ProgramData + '\Tagfiles\'
	$KeyFile = $appname + ' ' + $appversion 
	$KeyFile = $KeyFile -replace ' ','_'
	$KeyFile = $KeyFile -replace '\.','_'
	$KeyFile = $KeyFile + '.tag'
    $SummaryLogFile = "$Env:Windir\Logs\Software\$appname $appversion\Summary_$appname $appversion.log"

	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.7.0'
	[string]$deployAppScriptDate = '02/13/2018'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE TEST
	##*===============================================
		
	If ($deploymentType -ieq 'Install') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close apps if required, allow up to 3 deferrals, additional commands are supported
		#RUNNING_APPS
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress 
        
        ##Creates folders in case they don't exist on target computer
        New-Folder -Path $KeyPath
		
		## CUSTOM ACTION SECTION BELOW
        Write-Log -Message "Beginning Custom Action Execution" -Source 'Pre-Installation' -LogType 'Legacy'
        "Pre-Installation - Start Executing tasks" | Out-File $SummaryLogFile -Force -Append
        #PRECA1
		"Pre-Installation - Done Executing tasks" | Out-File $SummaryLogFile -Append
		
		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'

		$msg = "Installing " + $appName + " " + $appversion + ". Please wait..."
	  	Show-InstallationProgress -StatusMessage $msg   
     
        ## <Perform Installation tasks here>
        Write-Log -Message "Beginning Installation Step" -Source 'Installation' -LogType 'Legacy'
        "Installation - Start Executing tasks" | Out-File $SummaryLogFile -Append
        "Execute-Process -Path $envSystem32Directory\cmd.exe -Parameters /c `$dirfiles\WSDoM Package V10.0\v10.0x64x86Office\01-WORKSAFE-PROD-INSTALL-CM94-Client-v10.0.cmd` -WindowStyle 'Hidden'" | Out-File $SummaryLogFile -Append
Execute-Process -Path "$envSystem32Directory\cmd.exe" -Parameters "/c `"$dirfiles\WSDoM Package V10.0\v10.0x64x86Office\01-WORKSAFE-PROD-INSTALL-CM94-Client-v10.0.cmd`"" -WindowStyle 'Hidden'
#ICA1
        "Installation - Done Executing tasks" | Out-File $SummaryLogFile -Append
		
		
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## Create Tagfile if good return code
		if ($mainExitCode -ne 0 -And $mainExitCode -ne 1707 -And $mainExitCode -ne 3010 -And $mainExitCode -ne 1641 -And $mainExitCode -ne 1618) {
			Write-Log -Message "Keyfile $Tagfile not Created" -Source 'Post-Installation' -LogType 'Legacy'		
		} else {
			"" | out-file -FilePath ($KeyPath + $Keyfile) 
            Write-Log -Message "Installation Succeeded" -Source 'Installation' -LogType 'Legacy'
			Write-Log -Message "Tagfile $Keyfile Created" -Source 'Post-Installation' -LogType 'Legacy'	
            
            ##Setting detection method for SCCM
            Set-RegistryKey -Key $detectionMethod -Name 'Installed' -Value '1' -Type 'DWord'		
		}

		## CUSTOM ACTIONS SECTION BELOW
        Write-Log -Message "Beginning Custom Actions Execution" -Source 'Post-Installation' -LogType 'Legacy'
        "Post-Installation - Start Executing tasks" | Out-File $SummaryLogFile -Append
        "Execute-Process -Path $envSystem32Directory\wscript.exe -Parameters `$dirfiles\WSDoM Package V10.0\v10.0x64x86Office\WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs` -WindowStyle 'Hidden'" | Out-File $SummaryLogFile -Append
Execute-Process -Path "$envSystem32Directory\wscript.exe" -Parameters "`"$dirfiles\WSDoM Package V10.0\v10.0x64x86Office\WSDoM\CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs`"" -WindowStyle 'Hidden'
#POSTCA1
        "Post-Installation - Done Executing tasks" | Out-File $SummaryLogFile -Append
        
		## Display a message at the end of the install
		##If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Repair')
	{
        ##*===============================================
		##* REPAIR 
		##*===============================================
		[string]$installPhase = 'Repair'

		$msg = "Repairing " + $appName + " " + $appversion + ". Please wait..."
	  	Show-InstallationProgress -StatusMessage $msg   
     
        ## <Perform Installation tasks here>
        Write-Log -Message "Beginning Repair Step" -Source 'Repair' -LogType 'Legacy'
        "Repair - Start Executing tasks" | Out-File $SummaryLogFile -Append
        #REPCA1
        "Repair - Done Executing tasks" | Out-File $SummaryLogFile -Append
    }
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
        ##Creates folders in case they don't exist on target computer
        New-Folder -Path $KeyPath

		## CUSTOM ACTION SECTION BELOW
        Write-Log -Message "Beginning Custom Action Execution" -Source 'Pre-Uninstllation' -LogType 'Legacy'
        "Pre-Uninstallation - Start Executing tasks" | Out-File $SummaryLogFile -Append
        #PREUCA1
		"Pre-Uninstallation - Done Executing tasks" | Out-File $SummaryLogFile -Append
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
		Write-Log -Message "Beginning Uninstallation Step" -Source 'Uninstallation' -LogType 'Legacy'
        "Uninstallation - Start Executing tasks" | Out-File $SummaryLogFile -Append
		#UCA1
		"Uninstallation - Done Executing tasks" | Out-File $SummaryLogFile -Append

		# <Perform Uninstallation tasks here>

          Execute-MSI -Action 'Uninstall' -Path '{4E6086CA-B627-4AFA-A41C-8F86363832C7}'

          Execute-MSI -Action 'Uninstall' -Path '{CEA78427-2FFF-4C38-B6F0-A108724C7421}'
		
		
		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## CUSTOM ACTION SECTION BELOW
        Write-Log -Message "Beginning Custom Action Execution" -Source 'Post-Uninstallation' -LogType 'Legacy'       
        "Post-Uninstallation - Start Executing tasks" | Out-File $SummaryLogFile -Append
		#POSTUCA1
        "Post-Uninstallation - Done Executing tasks" | Out-File $SummaryLogFile -Append
		Remove-RegistryKey -Key $detectionMethod
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}