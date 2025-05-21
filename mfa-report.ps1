# Purpose: Generates a CSV report of users MFA status in Microsoft 365 using Microsoft Graph
# Dependencies: Microsoft.Graph PowerShell module, User.Read.All and UserAuthenticationMethod.Read.All permissions.

# Import required Graph modules
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.SignIns

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All" -NoWelcome

# Initialize output array for report
$report = @()

try {
    # Retrieve all users
    $users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName

    foreach ($user in $users) {
        # Get authentication methods for the user
        $authMethods = Get-MgUserAuthenticationMethod -UserId $user.Id

        # Check for MFA-enabled methods (e.g., phone, authenticator app)
        $mfaEnabled = $false
        foreach ($method in $authMethods) {
            if ($method.AdditionalProperties["@odata.type"] -match "microsoft.graph.(phoneAuthenticationMethod|microsoftAuthenticatorAuthenticationMethod)") {
                $mfaEnabled = $true
                break
            }
        }

        # Create custom object for report
        $report += [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            MFAStatus         = if ($mfaEnabled) { "Enabled" } else { "Disabled" }
        }
    }

    # Define output CSV path with timestamp
    $outputPath = "MFAStatusReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

    # Export report to CSV
    $report | Export-Csv -Path $outputPath -NoTypeInformation

    Write-Host "MFA status report generated successfully at $outputPath"
}
catch {
    # Handle errors gracefully
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    # Disconnect from Graph to clean up session
    Disconnect-MgGraph
}
