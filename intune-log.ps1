# Verbose diagnostic script for Intune Management Extension troubleshooting
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

Write-Verbose "Starting IME diagnostic script..."

# Check service status
try {
    $service = Get-Service -Name "IntuneManagementExtension" -ErrorAction Stop
    $serviceStatus = $service.Status
    Write-Verbose "Service 'IntuneManagementExtension' status: $serviceStatus"
} catch {
    $serviceStatus = "Not Found or Error: $($_.Exception.Message)"
    Write-Verbose "Service check failed: $serviceStatus"
}

# Check log file existence and content
$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log"
Write-Verbose "Checking log file: $logPath"

if (Test-Path $logPath) {
    Write-Verbose "Log file found. Reading last 50 lines..."
    $logContent = Get-Content -Path $logPath -Tail 50 -ErrorAction SilentlyContinue | Out-String
} else {
    $logContent = "Log file not found at $logPath"
    Write-Verbose $logContent
}

# Get current user profile and system info
$currentUser = $env:USERNAME
$userProfile = $env:USERPROFILE
$computerName = $env:COMPUTERNAME
$scriptContext = if ($env:USERNAME -eq "SYSTEM") { "System Context" } else { "User Context ($currentUser)" }

# Create comprehensive report
$output = @"
=== INTUNE MANAGEMENT EXTENSION DIAGNOSTIC REPORT ===
Generated: $(Get-Date)
Device: $computerName
Script Context: $scriptContext
User Profile: $userProfile

SERVICE STATUS:
IntuneManagementExtension: $serviceStatus

AGENT EXECUTOR LOG (Last 50 lines):
$logContent

=== END REPORT ===
"@

# Save to multiple accessible locations
$output | Out-File -FilePath "$env:USERPROFILE\Desktop\IME_Diagnostic_Report.txt" -Encoding UTF8
Write-Verbose "Report saved to Desktop: $env:USERPROFILE\Desktop\IME_Diagnostic_Report.txt"

# Also save to C:\Temp for system access
$tempPath = "C:\Temp\IME_Diagnostic_Report.txt"
New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
$output | Out-File -FilePath $tempPath -Encoding UTF8
Write-Verbose "Report also saved to: $tempPath"

Write-Verbose "Diagnostic Script completed successfully."
