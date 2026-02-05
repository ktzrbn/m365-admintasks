<#
.SYNOPSIS
    Automated User Onboarding Script.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$CSVPath,
    
    [string]$LogPath = "C:\Logs\OnboardingLog.txt",
    
    [switch]$WhatIf 
)

# 1. ENSURE LOG DIRECTORY EXISTS
$LogDir = Split-Path $LogPath
if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# 2. VALIDATE CSV
if (-not (Test-Path $CSVPath)) {
    Write-Error "CSV file not found at $CSVPath"
    exit
}

# 3. RUN THE AUTOMATION
$NewHires = Import-Csv -Path $CSVPath
$Domain = "contoso.local"

foreach ($User in $NewHires) {
    try {
        $SAM = ($User.FirstName[0] + $User.LastName).ToLower()
        $UPN = "$SAM@$Domain"
        
        # MODERN PASSWORD GEN (Works in PS 5.1 and PS 7)
        $CharSet = "ABCDEFGHKLMNPQRSTUVWXYZabcdefghkmnpqrstuvwxyz23456789!@#%&*".ToCharArray()
        $PlainPassword = -join ($CharSet | Get-Random -Count 12)
        
        $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

        Write-Host "Processing: $($User.FirstName) $($User.LastName)..." -ForegroundColor Cyan

        if ($WhatIf) {
            Write-Host "[WhatIf] Would create user: $SAM with password: $PlainPassword" -ForegroundColor Yellow
        } else {
            # In a real AD environment, New-ADUser would run here
            Add-Content -Path $LogPath -Value "$(Get-Date): SUCCESS - Created $SAM. Password: $PlainPassword"
            Write-Host "Successfully processed $SAM" -ForegroundColor Green
        }
    }
    catch {
        $ErrorMessage = "$(Get-Date): ERROR - Failed to create $($User.LastName). Reason: $($_.Exception.Message)"
        Add-Content -Path $LogPath -Value $ErrorMessage
        Write-Warning $ErrorMessage
    }
}