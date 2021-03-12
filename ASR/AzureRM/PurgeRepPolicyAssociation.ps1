Login-AzureRmAccount

$name = Read-Host 'What is your Vault Name?'
$vault = Get-AzureRmRecoveryServicesVault -Name $name
$cred = Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault
Import-AzureRmRecoveryServicesAsrVaultSettingsFile -Path $cred.FilePath
$fabric = Get-AzureRmRecoveryServicesAsrFabric
Remove-Item -Path $cred.FilePath

TRY{

 for ($i=1;$i -le $fabric.count; $i++){
    if($fabric[$i-1].FabricType -eq $null){$fabric[$i-1].FabricType = "Azure"}
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


}Catch{Write-Host "This Vault has no CS associated"}



TRY{
$mapping = Get-AzureRmRecoveryServicesAsrProtectionContainerMapping -ProtectionContainer $containerSelection


if($mapping.GetType().Name -eq "Object[]"){
   
$mapping2= $mapping |  Select-Object -Property PolicyFriendlyName, SourceFabricFriendlyName | Out-GridView -OutputMode Single -Title "Select the source location where your virtual machines are running"
for ($i=1;$i -le $item.count; $i++){
    if($mapping[$i-1].PolicyFriendlyName -eq $mapping2.PolicyFriendlyName){$mappingSelection =  $mapping[$i-1]}}
  }else{
    $mappingSelection= $maping
  }
 
$mappingSelection

#Remove-AzureRmRecoveryServicesAsrProtectionContainerMapping -InputObject $mappingSelection -Force
}Catch{Write-Host "This CS has no Replication Policies associated"}
