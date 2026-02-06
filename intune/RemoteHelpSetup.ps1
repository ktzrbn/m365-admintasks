$installerPath = "$env:TEMP\RemoteHelpSetup.exe"
Invoke-WebRequest -Uri "https://aka.ms/downloadremotehelp" -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait
Remove-Item $installerPath