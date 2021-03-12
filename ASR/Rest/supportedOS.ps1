# Variables
$SubscriptionId = "" # Enter Subscription Id.
$ResourceGroups= ""
$vault = ""

$supportedOs = armclient.exe get https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroups/providers/Microsoft.RecoveryServices/vaults/$vault/replicationSupportedOperatingSystems?api-version=2018-07-10
$supportedOs = [System.Collections.ArrayList]$supportedOs


$supportedOsList = ($supportedOs | ConvertFrom-Json).properties.supportedOsList.supportedOs

Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font(“Consolas”, 13)
$mainForm.Text = ” Pick Vault”
$mainForm.Font = $font
$mainForm.ForeColor = “White”
$mainForm.BackColor = “CadetBlue”
$mainForm.Width = "800"

#Vault Label
$OsLabel = New-Object System.Windows.Forms.Label
$OsLabel.Text = "OS"
$OsLabel.Location = "15, 45"
$OsLabel.Height = 22
$OsLabel.Width = 90
$mainForm.Controls.Add($OsLabel)


#Vault
$Osname = New-Object System.Windows.Forms.ComboBox
$Osname.Location = "110,42"
$Osname.Width = "500"
$Osname.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
ForEach ($supportedOsL in $supportedOsList){
    [Void] $Osname.Items.Add($supportedOsL.osName)
}
#$Osname.SelectedItem = $supportedOsList[].Items[0]
$mainForm.Controls.Add($Osname)

# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = “15, 130”
$okButton.ForeColor = “Black”
$okButton.BackColor = “White”
$okButton.Text = “OK”
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()


$supportedOsList[$OsName.SelectedIndex] | Out-GridView 
