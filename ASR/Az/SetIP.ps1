<#
  This is a script used to set the IP the VM replicated will use on azure
  It will work with the different types of replication (VMware/Azure VM/Hyper V)
  It also features as GUI to pick the date and time so as to simplify the usage of it
  It is using the Az Module
#>

Connect-AzAccount

while($null -eq $vault){
$name = Read-Host 'What is your Vault Name?'
$vault = Get-AzRecoveryServicesVault -Name $name
if($null -eq $vault){Write-Host "Not a Vaild Vault"}
}
$dnaname = "ASR-Script"
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname $dnaname
$certificate =[System.Convert]::ToBase64String($cert.RawData)
$cred = Get-AzRecoveryServicesVaultSettingsFile -Certificate $certificate -Vault $vault
Import-AzRecoveryServicesAsrVaultSettingsFile -Path $cred.FilePath

$initialLocation = Get-Location
Set-Location Cert:\LocalMachine\My
$certs = Get-ChildItem

for($i=1;$i -le $certs.count; $i++){
    if (($certs[$i-1].Subject).Split("=")[1] -eq $dnaname){   
        $certs[$i-1] | Remove-Item
    }
}
Remove-Item -Path $cred.FilePath
Set-Location -Path $initialLocation.Path

$fabric = Get-AzRecoveryServicesAsrFabric
$IP = Read-Host 'What is the IP to be set?'

Try
{
    if($fabric.GetType().Name -eq "Object[]"){
        $menu = @{}
        for ($i=1;$i -le $fabric.count; $i++) 
        { Write-Host "$i. $($fabric[$i-1].FriendlyName)"
        $menu.Add($i,($fabric[$i-1].FriendlyName)) }

    [int]$ans = Read-Host 'Select CS'
    $fabricSelection = $fabric[$ans-1]

    }else{
       
        $fabricSelection = $fabric

    }

    $container = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $fabricSelection
}
Catch{Write-Host "This Vault has no CS associated"}

Try
{
    if($container.GetType().Name -eq "Object[]"){
    $menu = @{}
    for ($i=1;$i -le $container.count; $i++) 
    { Write-Host "$i. $($container[$i-1].FriendlyName)"
    $menu.Add($i,($container[$i-1].FriendlyName)) }

    [int]$ans = Read-Host 'Select CS'
    $containerSelection= $container[$ans-1]
    }else{
    $containerSelection= $container
    }

$item = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $containerSelection
}Catch{Write-Host "This Vault has no CS associated"}

Set-AzRecoveryServicesAsrReplicationProtectedItem -ReplicationProtectedItem $item -RecoveryNicStaticIPAddress $IP -RecoveryNetworkId $item.NicDetailsList.RecoveryVMNetworkId -RecoveryNicSubnetName $item.NicDetailsList.RecoveryVMSubnetName -PrimaryNic $item.NicDetailsList.NicId