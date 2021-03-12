$ipCs = Read-Host "Input CS ip"

md C:\ASR

$cred = Get-Credential
$networkCred = $cred.GetNetworkCredential()
$user = $networkCred.UserName.ToString()

net use \\$ipCs\ASRAgent $networkCred.Password /USER:$user
Copy-Item -Path \\$ipCs\ASRAgent\Microsoft-ASR_UA_*.exe -Destination C:\ASR\MobilityServiceInstaller.exe


net use \\$ipCs\ASRPass $networkCred.Password /USER:$user
Copy-Item -Path \\$ipCs\ASRPass\connection.passphrase -Destination C:\ASR\pass.txt

Set-Location -Path C:\ASR

ren Microsoft-ASR_UA*Windows*release.exe MobilityServiceInstaller.exe
.\MobilityServiceInstaller.exe /q /x:C:\Temp\Extracted
Set-Location -Path C:\Temp\Extracted



Set-Location -Path "C:\Program Files (x86)\Microsoft Azure Site Recovery\agent"
.\UnifiedAgentConfigurator.exe  /CSEndPoint $ipCs /PassphraseFilePath C:\ASR\pass.txt
