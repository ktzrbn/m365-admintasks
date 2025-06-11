# Exercise 1. Understand how to establish a connection to Microsoft Graph using PowerShell.
Connect-MgGraph

# Connect using previously consented permissions
# Exercise 2: Learn how to retrieve information from Microsoft Graph using PowerShell.
Get-MgUser

# Exercise 3: Search for delegated permissions related to sharepoint sites
Find-MgGraphPermission sites -PermissionType Delegated

# Exercise 4: Learn how to grant additional permissions to the Microsoft Graph connection
Connect-Graph -Scopes "User.Read", "User.ReadWrite.All", "Mail.ReadWrite", `
    "Directory.Read.All", "Chat.ReadWrite", "People.Read", `
    "Group.Read.All", "Tasks.ReadWrite", 
    "Sites.Manage.All"

# Exercise 5: Understand token persistence and how to disconnect forget access tokens
Disconnect-MgGraph

# Exercise 6: Learn how to access detailed documentation using the Get-Help command
Get-Help Find-MgGraphPermission -Online