#Script to get every update done by each machine and output a CSV with the name of the machine the hotfixID and the date of installation

Invoke-Command -ComputerName (Get-ADComputer -Filter *).Name {Get-HotFix} -ErrorAction SilentlyContinue | Select-Object PSComputername, HotfixID, InstalledOn | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File 'C:\tempCSV\Update.csv'