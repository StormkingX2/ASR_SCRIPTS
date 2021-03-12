<#
        This is demo code to setup the Azure site recovery configuration server unatended, it was used by me so i can set up a test lab while doing tasks.
        As such it uses a non secure password for the MySQL database and should not be used in production
#>

md C:\ASRAuto
Set-Location -Path C:\ASRAuto
$uri= "https://aka.ms/unifiedinstaller_ne"
$destination = "ASRUnifiedSetup.exe"



$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -uri $uri -outfile $destination
$progressPreference = 'Continue'

Add-Type -AssemblyName System.Web
$root = [system.web.security.membership]::GeneratePassword(10,2)
$root = $root -replace "[\W!@#$%]", "#"
$root = $root + (Get-Random -Minimum 0 -Maximum 9)

$user = [system.web.security.membership]::GeneratePassword(10,2)
$user = $user -replace "[\W!@#$%]", "$"
$user = $user + (Get-Random -Minimum 0 -Maximum 9)


Set-Content C:\ASRAuto\MySQLCreds.txt '[MySQLCredentials]'
Add-Content C:\ASRAuto\MySQLCreds.txt  -Value "`MySQLRootPassword = ` `"$root`""
Add-Content C:\ASRAuto\MySQLCreds.txt -Value "`MySQLUserPassword = ` `"$user`""

cmd /c .\ASRUnifiedSetup.exe /q /x:C:\ASRAuto\Setup
Set-Location -Path C:\ASRAuto\Setup

Login-AzureRmAccount

$vaults = Get-AzureRMRecoveryServicesVault

Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font("Consolas", 13)
$mainForm.Text = "Pick Vault"
$mainForm.Font = $font
$mainForm.ForeColor = "White"
$mainForm.BackColor = "CadetBlue"
$mainForm.Width = 300
$mainForm.Height = 200

#Vault Label
$VaultLabel = New-Object System.Windows.Forms.Label
$VaultLabel.Text = "Vault"
$VaultLabel.Location = "15, 45"
$VaultLabel.Height = 22
$VaultLabel.Width = 90
$mainForm.Controls.Add($VaultLabel)


#Vault
$Vaultname = New-Object System.Windows.Forms.ComboBox
$Vaultname.Location = "110,42"
$Vaultname.Width = "150"
$vaultname.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
ForEach ($Item in $vaults){
    [Void] $Vaultname.Items.Add($Item.Name)
}
$Vaultname.SelectedItem = $Vaultname.Items[0]
$mainForm.Controls.Add($Vaultname)

# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = "15, 130"
$okButton.ForeColor = "Black"
$okButton.BackColor = "White"
$okButton.Text = "OK"
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()

$vault = Get-AzureRMRecoveryServicesVault -Name $Vaultname.SelectedItem.ToString()
$cred = Get-AzureRMRecoveryServicesVaultSettingsFile -Vault $vault

$initialLocation = Get-Location
Set-Location Cert:\LocalMachine\My
$certs = Get-ChildItem

for($i=1;$i -le $certs.count; $i++){
    if (($certs[$i-1].Subject).Split("=")[1] -eq $dnaname){   
        $certs[$i-1] | Remove-Item
    }
}
Set-Location -Path $initialLocation.Path

C:\ASRAuto\Setup\UNIFIEDSETUP.EXE /AcceptThirdpartyEULA /ServerMode CS /InstallLocation "C:\Program Files (x86)\Microsoft Azure Site Recovery" /MySQLCredsFilePath "C:\ASRAuto\MySQLCreds.txt" /VaultCredsFilePath, $cred.FilePath /EnvType NonVMWare /SkipSpaceCheck

Remove-Item -Path $cred.FilePath

New-SmbShare -Name ASRAgent -Path C:\ProgramData\ASR\home\svsystems\pushinstallsvc\repository
New-SmbShare -Name ASRPass -Path "C:\ProgramData\Microsoft Azure Site Recovery\private"