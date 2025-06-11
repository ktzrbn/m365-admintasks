#Task 1: Module Discovery 
Find-module Microsoft.Graph* | Select-Object Name

#Task 2: License Management
Get-Command -Module Microsoft.Graph* *license*

#Task 3: Application Registration 
Get-Command -Module Microsoft.Graph *application* 

#Task 4: Teams Administration 
Get-Command -Module Microsoft.Graph* *Team*

