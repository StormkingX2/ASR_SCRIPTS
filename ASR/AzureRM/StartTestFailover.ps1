Login-AzureRmAccount

while($vault -eq $null){
$name = Read-Host 'What is your Vault Name?'
$vault = Get-AzureRmRecoveryServicesVault -Name $name
if($vault -eq $null){Write-Host "Not a Vaild Vault"}
}
$cred = Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault
Import-AzureRmRecoveryServicesAsrVaultSettingsFile -Path $cred.FilePath
$fabric = Get-AzureRmRecoveryServicesAsrFabric
Remove-Item -Path $cred.FilePath

TRY{

 for ($i=1;$i -le $fabric.count; $i++){
    if($fabric[$i-1].FabricType -eq $null){$fabric[$i-1].FabricType = "Azure"}
  }

if($fabric.GetType().Name -eq "Object[]"){

$fabric2 = $fabric | Select-Object -Property FriendlyName, FabricType, SiteIdentifier | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
 
for ($i=1;$i -le $fabric.count; $i++){
    if($fabric[$i-1].SiteIdentifier -eq $fabric2.SiteIdentifier){$fabricSelection =  $fabric[$i-1]}
  }
}else {$fabricSelection =  $fabric}

$container = Get-AzureRmRecoveryServicesAsrProtectionContainer -Fabric $fabricSelection

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
$item = Get-AzureRmRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $containerSelection


if($item.GetType().Name -eq "Object[]"){
   
$item2= $item |  Select-Object -Property FriendlyName, PolicyFriendlyName | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
for ($i=1;$i -le $item.count; $i++){
    if($item[$i-1].FriendlyName -eq $item2.FriendlyName){$itemSelection =  $item[$i-1]}
  }

  }else{
    $itemSelection= $item
  }
 
Start-AzureRmRecoveryServicesAsrTestFailoverJob -AzureVMNetworkId $vnetSelection.Id -Direction PrimaryToRecovery -ReplicationProtectedItem $itemSelection

}catch{Write-Host "This CS select has no replicated item associated"}

$vnet = Get-AzureRmVirtualNetwork


if($vnet.GetType().Name -eq "Object[]"){
   
$vnet2= $vnet |  Select-Object -Property ResourceGroupName , Name| Out-GridView -OutputMode Single -Title "Select the virtualNetwork running"
for ($i=1;$i -le $vnet.count; $i++){
    if($vnet[$i-1].FriendlyName -eq $vnet2.FriendlyName){$vnetSelection =  $vnet[$i-1]}
  }

  }else{
    $vnetSelection= $vnet
  }
 
Start-AzureRmRecoveryServicesAsrTestFailoverJob -AzureVMNetworkId $vnet -Direction PrimaryToRecovery -ReplicationProtectedItem $itemSelection


