Connect-MgGraph

# Task 1: Retrieve and display organization contact details
Get-MgOrganization | Select-Object DisplayName, City, State, Country, PostalCode, BusinessPhones

# Task 2: Retrieve and display organization assigned plans 
Get-MgOrganization | Select-Object -expand AssignedPlans 

# Task 3 : List application registrations in the tenant
Get-MgApplication | Select-Object DisplayName, Appid, SignInAudience 

# Task 4: List service principals in the tenant 
Get-MgServicePrincipal | Select-Object id, AppDisplayName | Where-Object { $_.AppDisplayName -like "*sharepoint*"}