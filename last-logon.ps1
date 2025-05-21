# Generates a CSV of all users' last sign-in times in Microsoft 365 using Microsoft Graph
# Dependencies: Microsoft.Graph PowerShell module, User.Read.All and Directory.Read.All permissions.

# Import required Graph modules
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome

# Initialize output array for report
$report = @()

try {
    # Retrieve all users with sign-in activity
    $users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, SignInActivity

    foreach ($user in $users) {
        # Extract last sign-in date, if available
        $lastSignIn = $user.SignInActivity.LastSignInDateTime
        if ($lastSignIn) {
            $lastSignIn = [datetime]$lastSignIn
            $daysSinceSignIn = (Get-Date) - $lastSignIn
        } else {
            $lastSignIn = "Never"
            $daysSinceSignIn = "N/A"
        }

        # Create custom object for report
        $report += [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            LastSignIn        = $lastSignIn
            DaysSinceSignIn   = if ($daysSinceSignIn -eq "N/A") { "N/A" } else { $daysSinceSignIn.Days }
        }
    }

    # Define output CSV path with timestamp
    $outputPath = "UserLastLogonReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

    # Export report to CSV
    $report | Export-Csv -Path $outputPath -NoTypeInformation

    Write-Host "Report generated successfully at $outputPath"
}
catch {
    # Handle errors gracefully
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    # Disconnect from Graph to clean up session
    Disconnect-MgGraph
}
