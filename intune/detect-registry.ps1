$regPath = "HKLM:\Software\Policies\Microsoft\FVE"
if (Test-Path $regPath) {
    exit 0
} else {
    exit 1
}
