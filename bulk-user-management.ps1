# Purpose: Creates or updates M365 users in bulk from a CSV file, assigning licenses and properties
# Dependencies: Microsoft.Graph PowerShell module, User.ReadWrite.All and Directory.ReadWrite.All permissions.
# CSV Format: DisplayName,UserPrincipalName,Password,LicenseSkuId,Department,UsageLocation (e.g., US)

# Import required Graph modules
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome

# Specify path to input CSV
$csvPath = "Users.csv"

try {
    # Import CSV file
    $users = Import-Csv -Path $csvPath

    foreach ($user in $users) {
        Write-Host "Processing user: $($user.UserPrincipalName)"

        # Check if user already exists
        $existingUser = Get-MgUser -Filter "userPrincipalName eq '$($user.UserPrincipalName)'" -ErrorAction SilentlyContinue

        if ($existingUser) {
            # Update existing user
            Update-MgUser -UserId $existingUser.Id -Department $user.Department -UsageLocation $user.UsageLocation
            Write-Host "Updated user: $($user.UserPrincipalName)"
        } else {
            # Create new user
            $passwordProfile = @{
                Password = $user.Password
                ForceChangePasswordNextSignIn = $true
            }
            New-MgUser -DisplayName $user.DisplayName `
                       -UserPrincipalName $user.UserPrincipalName `
                       -PasswordProfile $passwordProfile `
                       -AccountEnabled $true `
                       -Department $user.Department `
                       -UsageLocation $user.UsageLocation
            Write-Host "Created user: $($user.UserPrincipalName)"
        }

        # Assign license if specified
        if ($user.LicenseSkuId) {
            $license = @{ SkuId = $user.LicenseSkuId }
            Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses @($license) -RemoveLicenses @()
            Write-Host "Assigned license $($user.LicenseSkuId) to $($user.UserPrincipalName)"
        }
    }

    Write-Host "Bulk user management completed successfully."
}
catch {
    # Handle errors gracefully
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    # Disconnect from Graph to clean up session
    Disconnect-MgGraph
}
