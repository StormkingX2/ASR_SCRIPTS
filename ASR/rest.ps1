#test Script to understand how rest works in microsoft azure for azure site recovery

# Variables
$TenantId = "" # Enter Tenant Id.
$ClientId = "" # Enter Client Id.
$ClientSecret = "" # Enter Client Secret.
$Resource = "https://management.core.windows.net/"
$SubscriptionId = "" # Enter Subscription Id.
$ResourceGroups= ""
$vault = ""


$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"


$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

Write-Host "Print Token" -ForegroundColor Green
Write-Output $Token

# Get Azure Replication VM

$ResourceGroupApiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroups/providers/Microsoft.RecoveryServices/vaults/$vault/replicationSupportedOperatingSystems?api-version=2018-07-10"


$Headers = @{}

$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")

$ResourceGroups = Invoke-RestMethod -Method Get -Uri $ResourceGroupApiUri -Headers $Headers

$OS = (($ResourceGroups.properties).supportedOsList).supportedOS

$OS | Select-Object osName -ExpandProperty osversions | Out-GridView 