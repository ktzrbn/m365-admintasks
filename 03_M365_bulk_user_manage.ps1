Import-Module Microsoft.Graph.Users

Connect-MgGraph
# Function to create a new user
function New-User { 
    param (
        $params
    )

    $newUser = New-MgUser -BodyParameter $params
    return $newUser
}

# Function to update an existing user
function Update-User { 
    param(
        [string]$UserId,
        [string]$DisplayName, 
        [string]$GivenName,
        [string]$Surname
    )

    Update-MgUser -UserId $UserId -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname
}

function Remove-User {
    param( 
        [string]$UserId
    )

    Remove-MgUser -UserId $UserId
}

$securePassword = "TempPassword123!"

# Example usage
$userData = Import-Csv -Path "./newuserslist.csv"

foreach ($userRow in $UserData) {
    $params = @{
        accountEnabled = $true
        displayName = $userRow.DisplayName
        mailNickname = $userRow.MailNickname
        userPrincipalName = $userRow.UserPrincipalName
        passwordProfile = @{
            forceChangePasswordNextSignIn = $true
            password = $securePassword
        }
    }

    # Call function to create a user
    $newUser = New-User -params $params
    Write-Output "User created: $($newUser.DisplayName)"
}