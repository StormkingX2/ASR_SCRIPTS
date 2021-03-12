<#
  This is a script used to start the test failover VM replicated
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
Set-Location -Path $initialLocation.Path
Remove-Item -Path $cred.FilePath
$fabric = Get-AzRecoveryServicesAsrFabric

TRY{

 for ($i=1;$i -le $fabric.count; $i++){
    if($null -eq $fabric[$i-1].FabricType){$fabric[$i-1].FabricType = "Azure"}
  }

if($fabric.GetType().Name -eq "Object[]"){

$fabric2 = $fabric | Select-Object -Property FriendlyName, FabricType, SiteIdentifier | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
 
for ($i=1;$i -le $fabric.count; $i++){
    if($fabric[$i-1].SiteIdentifier -eq $fabric2.SiteIdentifier){$fabricSelection =  $fabric[$i-1]}
  }
}else {$fabricSelection =  $fabric}

$container = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $fabricSelection

if($container.GetType().Name -eq "Object[]"){
   
$container2= $container | Select-Object -Property FabricFriendlyName, FabricType | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
for ($i=1;$i -le $container.count; $i++){
    if($container[$i-1].FriendlyName -eq $container2.FriendlyName){$containerSelection =  $container[$i-1]}
  }

  }else{
    $containerSelection= $container
    }

}
Catch{Write-Host "This Vault has no CS associated"}

TRY{
$item = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $containerSelection


if($item.GetType().Name -eq "Object[]"){
   
$item2= $item |  Select-Object -Property FriendlyName, PolicyFriendlyName | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
for ($i=1;$i -le $item.count; $i++){
    if($item[$i-1].FriendlyName -eq $item2.FriendlyName){$itemSelection =  $item[$i-1]}
  }

  }else{
    $itemSelection= $item
  }
 
}catch{Write-Host "This CS select has no replicated item associated"}

$vnet = Get-AzVirtualNetwork


if($vnet.GetType().Name -eq "Object[]"){
   
$vnet2= $vnet |  Select-Object -Property ResourceGroupName , Name| Out-GridView -OutputMode Single -Title "Select the virtualNetwork running"
for ($i=1;$i -le $vnet.count; $i++){
    if($vnet[$i-1].FriendlyName -eq $vnet2.FriendlyName){$vnetSelection =  $vnet[$i-1]}
  }

  }else{
    $vnetSelection= $vnet
  }
 
Start-AzRecoveryServicesAsrTestFailoverJob -AzureVMNetworkId $vnetSelection -Direction PrimaryToRecovery -ReplicationProtectedItem $itemSelection


