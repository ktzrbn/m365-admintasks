# --------------------------------------
# 1. Managing Site Collections
# --------------------------------------

# Connect to SharePoint Online Admin Center
# Purpose: Establishes a connection to the SharePoint Online admin center to perform tenant-level operations.
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com

# Create a New Site Collection
# Purpose: Creates a modern team site with specified URL, owner, storage quota, and template (STS#3 = Modern Team Site).
New-SPOSite -Url https://<tenant>.sharepoint.com/sites/NewSite `
            -Owner admin@tenant.com `
            -StorageQuota 1000 `
            -Title "New Site Collection" `
            -Template STS#3

# List All Site Collections
# Purpose: Retrieves a list of all site collections with their URL, title, and storage quota for auditing or management.
Get-SPOSite | Select-Object Url, Title, StorageQuota

# --------------------------------------
# 2. User and Permissions Management
# --------------------------------------

# Connect to a Specific SharePoint Site (PnP PowerShell)
# Purpose: Connects to a specific site for site-level operations using PnP PowerShell.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive

# Add User to a Site Group
# Purpose: Adds a user to the site's Members group to grant edit permissions.
Add-PnPUserToGroup -LoginName "user@tenant.com" -Identity "MySite Members"

# Export Permissions Report
# Purpose: Generates a report of all users and their roles (permissions) for a specific site for auditing.
Get-PnPWeb -Includes RoleAssignments | Select-Object -ExpandProperty RoleAssignments | ForEach-Object {
    $_.Member.LoginName + ": " + $_.RoleDefinitionBindings.Name
}

# --------------------------------------
# 3. Managing Lists and Libraries
# --------------------------------------

# Create a Document Library
# Purpose: Creates a new document library named "Project Documents" with versioning enabled.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive
New-PnPList -Title "Project Documents" -Template DocumentLibrary -EnableVersioning $true

# Bulk Upload Files to a Document Library
# Purpose: Uploads all files from a local folder to the "Shared Documents" library.
$files = Get-ChildItem -Path "C:\LocalFolder"
foreach ($file in $files) {
    Add-PnPFile -Path $file.FullName -Folder "Shared Documents"
}

# --------------------------------------
# 4. Automating Content Management
# --------------------------------------

# Update List Items
# Purpose: Bulk-updates the "Status" field to "Completed" for all items in a Tasks list.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive
$items = Get-PnPListItem -List "Tasks"
foreach ($item in $items) {
    Set-PnPListItem -List "Tasks" -Identity $item.Id -Values @{ "Status" = "Completed" }
}

# Delete Old Files
# Purpose: Deletes files in "Shared Documents" created before January 1, 2023, to free up storage.
$files = Get-PnPListItem -List "Shared Documents" `
         -Query "<View><Query><Where><Leq><FieldRef Name='Created' /><Value Type='DateTime'>2023-01-01</Value></Leq></Where></Query></View>"
foreach ($file in $files) {
    Remove-PnPListItem -List "Shared Documents" -Identity $file.Id -Force
}

# --------------------------------------
# 5. Configuring Site Settings
# --------------------------------------

# Enable a Site Feature
# Purpose: Activates the publishing feature (f41cc668-37e5-4743-b4a8-74d1db3fd8a4) for a site.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive
Enable-PnPFeature -Identity "f41cc668-37e5-4743-b4a8-74d1db3fd8a4"

# Set External Sharing Settings
# Purpose: Enables external sharing (guests and authenticated users) for a site collection.
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com
Set-SPOSite -Identity https://<tenant>.sharepoint.com/sites/MySite -SharingCapability ExternalUserAndGuestSharing

# --------------------------------------
# 6. Monitoring and Reporting
# --------------------------------------

# Generate Storage Usage Report
# Purpose: Exports a CSV file with storage usage details for all site collections.
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com
Get-SPOSite | Select-Object Url, StorageUsageCurrent, StorageQuota | Export-Csv -Path "StorageReport.csv" -NoTypeInformation

# Audit User Activity
# Purpose: Exports audit logs for SharePoint file operations in the last 30 days (requires Microsoft 365 audit log permissions).
Connect-MgGraph -Scopes "AuditLog.Read.All"
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) -RecordType SharePointFileOperation |
Export-Csv -Path "AuditLog.csv" -NoTypeInformation

# --------------------------------------
# 7. Migration and Backup
# --------------------------------------

# Export a List to CSV
# Purpose: Exports the "Title" and "Status" fields of a Tasks list to a CSV file for backup or migration.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive
$items = Get-PnPListItem -List "Tasks"
$items | Select-Object @{Name="Title";Expression={$_.FieldValues["Title"]}}, @{Name="Status";Expression={$_.FieldValues["Status"]}} |
Export-Csv -Path "TasksExport.csv" -NoTypeInformation

# Copy a Site Structure
# Purpose: Exports a site’s structure (lists, libraries, settings) to an XML template and applies it to another site.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/SourceSite -Interactive
Get-PnPSiteTemplate -Out "SiteTemplate.xml"
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/TargetSite -Interactive
Invoke-PnPSiteTemplate -Path "SiteTemplate.xml"

# --------------------------------------
# 8. Troubleshooting and Maintenance
# --------------------------------------

# Check Site Health
# Purpose: Runs a health check on a site to identify issues like broken links or missing templates.
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com
Test-SPOSite -Identity https://<tenant>.sharepoint.com/sites/MySite

# Clear Recycle Bin
# Purpose: Empties the site’s recycle bin to free up storage.
Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive
Clear-PnPRecycleBinItem -All -Force

# --------------------------------------
# Example with Error Handling
# --------------------------------------

# Purpose: Demonstrates basic error handling for connecting to a site to avoid script crashes.
try {
    Connect-PnPOnline -Url https://<tenant>.sharepoint.com/sites/MySite -Interactive -ErrorAction Stop
    Write-Host "Connected successfully"
} catch {
    Write-Host "Error: $_"
}

# --------------------------------------
# End of Script
# --------------------------------------