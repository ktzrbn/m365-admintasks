$regPath = "HKLM:\Software\Policies\Microsoft\FVE"

if (Test-Path $regPath) {
	try {
	    Remove-Item -Path $regPath -Recurse -Force
	    Write-Output "Successfully deleted $regPath"
	} catch { 
	    Write-Error "Failed to delete $regPath with error $($_.Exception.Message)"
	}
} else { 
	Write-Output "Registry key does not exist on this device" 
}

# Start-Sleep -Seconds 3600

try {
	$bitlocker = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
	
	if ($bitlocker.ProtectionStatus -ne 'On') {
		Write-Output "BitLocker is not enabled. Enabling now..."
		Enable-BitLocker -MountPoint 'C:' -EncryptionMethod XtsAes256 -RecoveryPasswordProtector -SkipHardwareTest -ErrorAction Stop
		Write-Output "BitLocker encryption started successfully"
		
		# Wait for key protector to be created
		Start-Sleep -Seconds 5
		
		# Backup recovery key to Azure AD
		$recoveryProtector = (Get-BitLockerVolume -MountPoint 'C:').KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
		if ($recoveryProtector) {
			BackupToAAD-BitLockerKeyProtector -MountPoint 'C:' -KeyProtectorId $recoveryProtector.KeyProtectorId
			Write-Output "Recovery key backed up to Azure AD successfully"
		} else {
			Write-Warning "No recovery key protector found to backup"
		}
	} else {
		Write-Output "BitLocker is already enabled"
	}
	
	# Final status summary
	$finalStatus = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
	$recoveryKey = $finalStatus.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
	Write-Output "SUMMARY - BitLocker Status: $($finalStatus.ProtectionStatus) | Encryption: $($finalStatus.VolumeStatus) | Recovery Key Present: $($null -ne $recoveryKey)"
	
} catch {
	Write-Error "Failed to enable BitLocker: $($_.Exception.Message)"
	exit 1
}