# Define the registry key path
$regPath = "HKLM:\Software\Policies\Microsoft\FVE"

# Check if the registry key exists
if (Test-Path $regPath) {
    # Attempt to remove the registry key, including any subkeys
    try {
        Remove-Item -Path $regPath -Recurse -Force
        Write-Output "Successfully deleted: $regPath"
    } catch {
        Write-Error "Failed to delete $regPath. Error: $_"
    }
} else {
    Write-Output "Registry key does not exist: $regPath"
}
