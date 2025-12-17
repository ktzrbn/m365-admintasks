# find and rename a printer (only renames on local comp, not network

Get-Printer | Where-Object { $_.Name -eq "Adobe PDF2" } | Rename-Printer -NewName "Adobe PDF"