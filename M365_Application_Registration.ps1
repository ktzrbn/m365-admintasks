function Connect-ToAzureADandCreateApp {
    param (
        [string]$appName = "M365AdministrationUsingPowerShellApp",
        [string]$permissionID
    )

    # Step 1: Connect to Azure AD w/ required scopes
    Connect-MgGraph -Scopes "Application.Read.All", "Application.ReadWrite.All", "User.Read.All"

    # Step 2: Create an application with the given app name 
    $app = New-MgApplication -DisplayName $appName
    $appObjectId = $app.Id

    # Step 3: Create client secret
    $passwordCred = @{
        displayName = $appName
        endDateTime = (Get-Date).AddMonths(12)
    }
    $clientSecret = Add-MgApplicationPassword -ApplicationId $appObjectId -PasswordCredential $passwordCred

    # Step 4: Grant permissions
    $permissionParams = @{
        RequiredResourceAccess = @(
            @{
                ResourceAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
                ResourceAccess = @(
                    @{
                        Id = $permissionID
                        Type = "Role"
                    }
                )
            }
        )
    }
    Update-MgApplication -ApplicationId $appObjectId -BodyParameter $permissionParams

    # Get tenant ID
    $tenantID = (Get-MgOrganization).Id

    # Return details
    return @{
        ClientId = $app.AppId
        TenantId = $tenantID
        ClientSecret = $clientSecret.SecretText
    }
}

# Example usage:
$permissionId = "656f6061-f9fe-4807-9708-6a2e0934df76"
$appDetails = Connect-ToAzureADandCreateApp -appName "M365AdministrationUsingPowerShellApp" -permissionID $permissionId
Write-Output "ClientId: $($appDetails.ClientId)"
Write-Output "TenantId: $($appDetails.TenantId)"
Write-Output "ClientSecret: $($appDetails.ClientSecret)"