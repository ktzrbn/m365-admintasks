# BitLocker Detection Script for Intune
# This script checks if BitLocker needs remediation

$regPath = "HKLM:\Software\Policies\Microsoft\FVE"
$needsRemediation = $false
$issues = @()

# Priority 1: Check BitLocker status first
try {
    $bitlocker = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
    
    if ($bitlocker.ProtectionStatus -eq 'On') {
        # BitLocker is enabled - check if recovery key exists
        $recoveryKey = $bitlocker.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
        if ($recoveryKey) {
            # All good - BitLocker enabled with recovery key
            Write-Output "Compliant: BitLocker enabled with recovery key"
            exit 0
        } else {
            $needsRemediation = $true
            $issues += "BitLocker enabled but no recovery key found"
        }
    } else {
        # BitLocker not enabled - check if blocking registry key is preventing it
        $needsRemediation = $true
        $issues += "BitLocker not enabled"
        
        if (Test-Path $regPath) {
            $issues += "Blocking registry key exists (must be removed first)"
        }
    }
    
} catch {
    $needsRemediation = $true
    $issues += "BitLocker not available or error: $($_.Exception.Message)"
    
    # Still check registry if BitLocker check failed
    if (Test-Path $regPath) {
        $issues += "Blocking registry key exists"
    }
}

# Output results
if ($needsRemediation) {
    Write-Output "Remediation needed: $($issues -join ', ')"
    exit 1  # Exit 1 = needs remediation
} else {
    Write-Output "Compliant: BitLocker enabled with recovery key"
    exit 0  # Exit 0 = compliant, no remediation needed
}
