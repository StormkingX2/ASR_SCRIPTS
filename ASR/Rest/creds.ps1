
#Demo code to understand how to get the vault creds for azure site recovery

# Variables
$SubscriptionId = "" # Enter Subscription Id.
$ResourceGroup= ""
$vault = ""
$sitename = ""


$SubscriptionId = ((ARMClient.exe get https://management.azure.com/subscriptions?api-version=2016-06-01) | ConvertFrom-Json).value

$ResourceGroup = ((ARMClient.exe get "https://management.azure.com/subscriptions/$SubscriptionId/ResourceGroups?api-version=2016-06-01") | ConvertFrom-Json).value
 
$vault = ((ARMClient.exe get "https://management.azure.com/subscriptions/$SubscriptionId/ResourceGroups/$ResourceGroup/providers/Microsoft.RecoveryServices/vaults?api-version=2016-06-01") | ConvertFrom-Json).value

#$cred = (armclient.exe get "https://main.recoveryservices.ext.azure.com/api/subscriptions/$SubscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.RecoveryServices/vaults/$vault/downloadVaultCreds?credstype=siterecovery&authType=AAD&siteFriendlyName=$sitename") | ConvertFrom-Json

$cred= armclient.exe get "https://main.recoveryservices.ext.azure.com/api/subscriptions/$SubscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.RecoveryServices/vaults/$vault/downloadVaultCreds?credstype=siterecovery&authType=AAD"
$cred | Out-String | Out-File "C:\$vault.vaultCredentials"
