Import-Module Microsoft.Graph.Users
Connect-MgGraph 
# this function creates a new user
function New-User { 
    param (
        $params
    )

    $newUser = New-MgUser -BodyParameter $params
    return $newUser
}

# Function to update an existing user
function Update-User { 
    param (
        [string]$UserID,
        [string]$DisplayName, 
        [string]$GivenName,
        [string]$Surname
    )

    Update-MgUser -UserId -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname
}

# Function to delete a user

function Remove-User {
    param( 
        [string]$UserId
    )

    Remove-MgUser -UserId $UserId
}

# Example Usage

$params = @{
    accountEnabled = $true
    displayName = "Isaac Newton"
    mailNickname = "IsaacN"
    userPrincipalName = "IsaacN@katzirindustries.onmicrosoft.com"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $true
        password = "P@ssw0rd1234"
    }
}

# Call function to create a user
$newUser = New-User $params

# Get the ID of the newly created user

$userId = $newUser.ID

#update the user
Update-User -UserID $userId -DisplayName "Isaac Newton Updated" -GivenName "Isaac Updated" -Surname "Newton Updated"

# Delete the user
Remove-User -UserId $userId 


Get-MgContext