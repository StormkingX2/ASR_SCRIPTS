$path = “$env:temp\testfile.txt”
$file = [io.file]::Create($path)
$file.SetLength(100mb)
$file.Close()
$file = Get-Item $path
$BlobName = "testfile.txt"


Login-AzureRmAccount 
$SAN = Read-Host 'What is your Storage Acount Name?'
$RGN = Read-Host 'What is your Resource Group Name?'

Set-AzureRmCurrentStorageAccount -Name $SAN -ResourceGroupName $RGN |Out-Null


$container = Get-AzureStorageContainer
$time = Measure-Command {Set-AzureStorageBlobContent -File $file -Container $container[0].Name -Force}

if (Test-Path $file) {
  Remove-Item $file
}

Remove-AzureStorageBlob -Blob $BlobName -Container $Container[0].name

$end= 100/($time.TotalSeconds)

Write-Host
Write-Host $end MB/s -ForegroundColor Red -BackgroundColor Black