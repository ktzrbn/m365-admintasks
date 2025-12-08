# BitLocker Detection Script for Intune
# This script checks if BitLocker needs remediation

$regPath = "HKLM:\Software\Policies\Microsoft\FVE"
$needsRemediation = $false
$issues = @()

# Check if blocking registry key exists
if (Test-Path $regPath) {
    $needsRemediation = $true
    $issues += "Blocking registry key exists"
}

# Check BitLocker status
try {
    $bitlocker = Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop
    
    if ($bitlocker.ProtectionStatus -ne 'On') {
        $needsRemediation = $true
        $issues += "BitLocker not enabled"
    }
    
    # Check if recovery key exists
    $recoveryKey = $bitlocker.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
    if (-not $recoveryKey -and $bitlocker.ProtectionStatus -eq 'On') {
        $needsRemediation = $true
        $issues += "No recovery key found"
    }
    
} catch {
    $needsRemediation = $true
    $issues += "BitLocker not available or error: $($_.Exception.Message)"
}

# Output results
if ($needsRemediation) {
    Write-Output "Remediation needed: $($issues -join ', ')"
    exit 1  # Exit 1 = needs remediation
} else {
    Write-Output "Compliant: BitLocker enabled with recovery key"
    exit 0  # Exit 0 = compliant, no remediation needed
}
