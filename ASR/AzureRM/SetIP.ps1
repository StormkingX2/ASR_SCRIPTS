<#
  This is a script used to set the IP the VM replicated will use on azure
  It will work with the different types of replication (VMware/Azure VM/Hyper V)
  It also features as GUI to pick the date and time so as to simplify the usage of it
  It is using the AzureRM Module in case it need to be used in a machine that doesnt have the AZ module
#>

Login-AzureRmAccount
$name = Read-Host 'What is your Vault Name?'
$vault = Get-AzureRmRecoveryServicesVault -Name $name
$cred = Get-AzureRmRecoveryServicesVaultSettingsFile -Vault $vault
Import-AzureRmRecoveryServicesAsrVaultSettingsFile -Path $cred.FilePath
$fabric = Get-AzureRmRecoveryServicesAsrFabric
$IP = Read-Host 'What is the IP to be set?'
Remove-Item -Path $cred.FilePath

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

    $container = Get-AzureRmRecoveryServicesAsrProtectionContainer -Fabric $fabricSelection
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

$item = Get-AzureRmRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $containerSelection
}Catch{Write-Host "This Vault has no CS associated"}

Set-AzureRmRecoveryServicesAsrReplicationProtectedItem -ReplicationProtectedItem $item -RecoveryNicStaticIPAddress $IP -RecoveryNetworkId $item.NicDetailsList.RecoveryVMNetworkId -RecoveryNicSubnetName $item.NicDetailsList.RecoveryVMSubnetName -PrimaryNic $item.NicDetailsList.NicId