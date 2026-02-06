# Get all users and their sign-in activity
$Users = Get-MgUser -All -Property "DisplayName","UserPrincipalName","SignInActivity"

# Filter for inactive users (Last sign-in older than 30 days)
$30DaysAgo = (Get-Date).AddDays(-30)
$InactiveUsers = $Users | Where-Object { 
    $_.SignInActivity.LastSignInDateTime -lt $30DaysAgo -and $_.SignInActivity.LastSignInDateTime -ne $null 
}

# Output a "Professional" table
$InactiveUsers | Select-Object DisplayName, UserPrincipalName, `
    @{Name="LastSignIn"; Expression={$_.SignInActivity.LastSignInDateTime}} | Format-Table