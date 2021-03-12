<#
  This is a script used to remove the VM from replication from the different types of replication (VMware/Azure VM/Hyper V)
  It also features as GUI to pick the date and time so as to simplify the usage of it
  It is using the AzureRM Module in case it need to be used in a machine that doesnt have the AZ module
#>

Login-AzureRmAccount

while(!$vault){
$name = Read-Host 'What is your Vault Name?'
$vault = Get-AzureRmRecoveryServicesVault -Name $name
if(!$vault){Write-Host "This Vault doesn't exist"}
}
$cred = Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault
Import-AzureRmRecoveryServicesAsrVaultSettingsFile -Path $cred.FilePath
$fabric = Get-AzureRmRecoveryServicesAsrFabric
Remove-Item -Path $cred.FilePath

TRY{

 for ($i=1;$i -le $fabric.count; $i++){
    if($null -eq $fabric[$i-1].FabricType){$fabric[$i-1].FabricType = "Azure"}
  }

if($fabric.GetType().Name -eq "Object[]"){

$fabric2 = $fabric | Select-Object -Property FriendlyName, FabricType | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
 
for ($i=1;$i -le $fabric.count; $i++){
    if($fabric[$i-1].FriendlyName -eq $fabric2.FriendlyName){$fabricSelection =  $fabric[$i-1]}
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
 
Remove-AzureRmRecoveryServicesAsrReplicationProtectedItem -InputObject $itemSelection -Force

}catch{Write-Host "This CS select has no replicated item associated"}