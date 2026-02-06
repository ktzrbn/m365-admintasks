$regPath = "HKLM:\Software\Policies\Microsoft\FVE"
if (Test-Path $regPath) {
    Remove-Item -Path $regPath -Recurse -Force
}
