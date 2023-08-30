#Script that goes to the AD and get the OS registered and export the name of the machine and OS to a CSV

Get-ADComputer -Filter * -Properties OperatingSystem | Select-Object name, OperatingSystem |  Export-Csv -Path 'C:\tempCSV\OS.csv' -NoTypeInformation