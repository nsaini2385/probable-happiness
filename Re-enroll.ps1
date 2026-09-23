$Global:ErrorActionPreference = 'Stop'
Write-Host "Stopping Intune Service" -ForegroundColor Yellow
Get-Service *intune* | Stop-Service
Write-Host "Check if device is AAD Joined" -ForegroundColor Yellow
$DSREGCMD = dsregcmd /status
$AADJoinCheck = $null
$AADJoinCheck = $DSREGCMD | Select-String -Pattern 'AzureAdJoined : YES'
if ($null -eq $AADJoinCheck) {
	Write-Host "Device is not AAD Joined!!! Stopping!" -ForegroundColor Red
	Break
} else {
	Write-Host "Device is AAD Joined - OK" -ForegroundColor Green
}
Write-Host "Searching for enrollment ID"
$Tasks = Get-ScheduledTask | Where-Object { $psitem.TaskPath -like "\Microsoft\Windows\EnterpriseMgmt\*" }
$EnrollId = $Tasks[0].TaskPath.Split('\\')[-2]
if ($EnrollID -match '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') {
	Write-Host "Found EnrollID - $EnrollID" -ForegroundColor Green
} else {
	Write-Host "Error parsing EnrollID. Stopping" -ForegroundColor Red
	Break
}
Write-Host "Removing scheduledTasks" -ForegroundColor Yellow
Try {
	$Tasks | ForEach-Object { Unregister-ScheduledTask -InputObject $psitem -Verbose -Confirm:$false }
} catch {
	Throw $_.Exception.Message
}
Write-Host "Done" -ForegroundColor Green
Write-Host "Trying to remove tasks folder" -ForegroundColor Yellow
$TaskFolder = Test-Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID"
try {
	if ($TaskFolder) {
		Remove-Item -Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID" -Force -Verbose 
	}
} catch {
	Throw $_.Exception.Message
}
Write-Host "Removing registry keys" -ForegroundColor Yellow
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID -Recurse -Force -Verbose 
}
$EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID
if ($EnrollmentReg) {
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID -Recurse -Force -Verbose 
}
##### Run this if Remove-Item -Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID" -Force -Verbose FAILED
<#
$EnrollmentReg = Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\EnterpriseMgmt\$EnrollID"
if ($EnrollmentReg) {
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\EnterpriseMgmt\$EnrollID" -Recurse -Force -Verbose 
}
#>
Write-Host "Checking for Intune MDM cert" -ForegroundColor Yellow
$Certs = $null
$Certs = Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { $psitem.issuer -like '*Intune*' }
if ($null -ne $Certs) {
	$(Get-Item ($Certs).PSPath) | Remove-Item -Force -Verbose 
	Write-Host "Removed" -ForegroundColor Green
} else {
	Write-Host "Not found" -ForegroundColor Yellow
}
Write-Host "Downloading psexec" -ForegroundColor Yellow
Invoke-RestMethod -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile $env:TEMP\PSTools.zip
Write-Host "Expanding psexec" -ForegroundColor Yellow
Expand-Archive -Path $env:TEMP\PSTools.zip -DestinationPath $env:TEMP\PSTools -Force
Write-Host "Starting psexec with AutoEnrollMDM" -ForegroundColor Yellow
$Process = Start-Process -FilePath $env:TEMP\PSTools\psexec.exe -ArgumentList "-i -s -accepteula cmd  /c `"deviceenroller.exe /c /AutoEnrollMDM`"" -Wait -NoNewWindow -PassThru
if ($process.ExitCode -eq 0) {
	Write-Host "Started AutoEnrollMDM" -ForegroundColor Green

} else {
	Write-Host "Exit code 1. Please verify manually" -ForegroundColor Red
}
if ((Get-Service *intune*).Status -ne 'Running') {
	Get-Service *intune* | Start-Service
}
# SIG # Begin signature block
# MIIFrQYJKoZIhvcNAQcCoIIFnjCCBZoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfHWAUnxDVsGlFQc4xiUvHQ1d
# bUegggM/MIIDOzCCAiOgAwIBAgIQTsp720aeRJ1EQldN2wd3DzANBgkqhkiG9w0B
# AQsFADAjMSEwHwYDVQQDDBhFQk9TIElOVFVORSBDT0RFIFNJR05JTkcwHhcNMjUx
# MDIyMDI0NDM3WhcNMjYxMDIyMDMwNDM3WjAjMSEwHwYDVQQDDBhFQk9TIElOVFVO
# RSBDT0RFIFNJR05JTkcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCh
# jnjWGMs9l5MFMfqPosXQH1v67Eg/zc/PHD1+ZZS3iUuuC/TTyyXaUyjmSpQiVH9F
# 1fyYMFxs1EAJfizw1wVj0X+7WNkDrFVuCrGR01pFNjpQ/zrrykqWNuPpGJaIl2Sk
# 2gs/0/x0fMlz/4d8lt6Q3uTRf/KtjdDqDUJ9vhbMiL5KhqNB2bOWoILwlakYEVG1
# c0VV6swXeue+e1/T3u+TGjkatapKucLD2VtGKMosC2yOvjvr8+pd2mgDRAvjRcZu
# 5G1n4evKWXqGqig6yUtEdyCL/Auc3liLHUXQMJiIr+Dv+x0ez04HGffq+Fzb+JpR
# d9BVrcG3p7+NIxdR1Un9AgMBAAGjazBpMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUE
# DDAKBggrBgEFBQcDAzAjBgNVHREEHDAaghhFQk9TIElOVFVORSBDT0RFIFNJR05J
# TkcwHQYDVR0OBBYEFB1pKwZkK2cumE0qoxN6C8GDsVWuMA0GCSqGSIb3DQEBCwUA
# A4IBAQCFvgNlMG+hiiOsySwtcI6kl/Db84Q5cAVGssWSrnO01ai2o0JasW081WOX
# iizdyg7qm0jEoj9IgeU1YpSnJxY5zNX+SV9ajZVpWvYfFOSdhzK+Cn9x3h7ZnBWF
# Bbg1jnbUDgoIKO7PIFCcamUl5KuLVhN66w3v2NdZUtgT7eIOlmm66LxCR4Mu6bBy
# O4S9vnEV8n28Tz6uj01g/wDwSC5IbVpvR9v2+rIr+5Ed0Qv1JZ+tUQaBTrqr9sE1
# kW7cw3ZV4KWjcsqEOOK/5XOXvg1+gAmL+F1lHdMogzhLYZtQCV50XBF13sHETu+8
# mb6Dat9efmEvg8A1CA+xdBDpxuQzMYIB2DCCAdQCAQEwNzAjMSEwHwYDVQQDDBhF
# Qk9TIElOVFVORSBDT0RFIFNJR05JTkcCEE7Ke9tGnkSdREJXTdsHdw8wCQYFKw4D
# AhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZI
# hvcNAQkEMRYEFK1h1tOSEqq22CkvYXRC0t6xhdvMMA0GCSqGSIb3DQEBAQUABIIB
# ABAoc9wCH9iShx7bjIw02wD7QwjykuVfr1V916YbzHyLQhXOJ3N1wjnZk3E8NktC
# VFjK6kB7uzNXAn6RP3cYDIOjhLwQwSXzk1Bst0Uwcaip/xBGa6nrxOLzBJqI0JSX
# AAOTICkte+HCuAkLoVP70WaT13mcOPJUZ+fnWS449o/onqgSNFeFTWPx/fbkPF3m
# G0hW7VSRHnZim+/616+fdOKXN1cGod3O/sGSQWURINkirC7YTb6sPlR4LT0l5WmJ
# dukMNecD67sJ6M6AjDB2BnV7tbhhDTY7csmrsiKu+e4FiG2ZuhA0Yo0EEq7ullw7
# 7pudwthDkr1Myylh67UhEJ0=
# SIG # End signature block
