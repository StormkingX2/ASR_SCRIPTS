<#
  This is a powershell scrip to check the speed from the computer to azure.
  It requiers a storage account so we can send a file of 100MB to it and then delete it and take note of the time that it took to transfer so we can calculate the speed in MB/s
  It is using the AZ module
#>

$path = “$env:temp\testfile.txt”
$file = [io.file]::Create($path)
$file.SetLength(100mb)
$file.Close()
$file = Get-Item $path
$BlobName = "testfile.txt"


Login-AzureRmAccount 
$SAN = Read-Host 'What is your Storage Acount Name?'
$RGN = Read-Host 'What is your Resource Group Name?'

Set-AzCurrentStorageAccount -Name $SAN -ResourceGroupName $RGN |Out-Null


$container = Get-AzStorageContainer
$time = Measure-Command {Set-AzureStorageBlobContent -File $file -Container $container[0].Name -Force}

if (Test-Path $file) {
  Remove-Item $file
}

Remove-AzStorageBlob -Blob $BlobName -Container $Container[0].name

$end= 100/($time.TotalSeconds)

Write-Host
Write-Host $end MB/s -ForegroundColor Red -BackgroundColor Black