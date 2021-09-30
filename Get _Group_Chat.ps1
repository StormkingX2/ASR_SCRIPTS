<#File to back a group chat, needs an azure ad app with delegated permission of Chat.Read and Chat.ReadBasic, also needs the user consented permisions on the following url

 http://login.microsoft.com/{tennant_id}/adminconsent?client_id={client_id}
 
#>


$clientId = "client_id"
$tennantName = "tennant_id"
$clientSecret = "app_secret"
$resource = "https://graph.microsoft.com/"
$Username = "email_adress"
$Password = 'password'
$UsernameID = "user_id"
$GroupName = Read-Host 'What is your Group Conversation Name?'


$ReqTokenBody = @{
    Grant_Type    = "Password"
    client_Id     = $clientID
    Client_Secret = $clientSecret
    Username      = $Username
    Password      = $Password
    Scope         = "Chat.Read Chat.ReadBasic"
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($tennantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
 
$apiUrl = "https://graph.microsoft.com/v1.0/users/$($UsernameID)/chats"

$ChatList = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get).value

foreach($Chat in $ChatList){
    If($chat.topic -eq $PGroupName){
        $chatID = $chat.id
    }
}

$apiUrl = "https://graph.microsoft.com/v1.0/users/$($UsernameID)/chats/$($chatID)/messages"
$MessageList = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get).value
$FinalList = $null
foreach($Message in $MessageList){
    If(!$Message.deletedDateTime -and !$Message.attachments){
    $tmpMessage = $Message.CreatedDateTime + " : " + $Message.from.user.DisplayName + " - "+ $Message.body.content

    $FinalList = $FinalList + $tmpMessage +"`n`r" +"`n`r"
    }elseif($Message.attachments){

        $AttachmentList = $Message.attachments
        $tmpAttachment = $null
        foreach($Attachment in $AttachmentList){
            $tmpAttachment = $tmpAttachment +"`n`r" +$Attachment.contentUrl + " ; "
        }

        $tmpMessage = $Message.CreatedDateTime + " : " + $Message.from.user.DisplayName + " - "+ $Message.body.content.Split("<")[0] + " Anexo(s) em : " + $tmpAttachment
        $FinalList = $FinalList + $tmpMessage +"`n`r" +"`n`r"
    }
}

$FinalList | Out-File -FilePath .\$($GroupName).txt -NoClobber
