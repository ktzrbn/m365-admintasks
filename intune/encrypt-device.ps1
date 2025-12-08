$regPath = "HKLM:\Software\Policies\Microsoft\FVE"

if (Test-Path $regPath) {
	try {
	    Remove-Item -Path $regPath -Recurse -Force
	    Write-Output "Successfully deleted $regPath"
	} catch { 
	    Write-Error "Failed to delete $regPath with error $_"
} else { 
	Write-Output "Registry key does not exist on this device" 
}

Start-Sleep -Seconds 3600

$bitlocker = Get-BitLockerVolume -MountPoint 'C:'

if ($bitlocker.ProtectionStatus -ne 'On') {
	manage-bde -on C: -RecoveryPassword
}