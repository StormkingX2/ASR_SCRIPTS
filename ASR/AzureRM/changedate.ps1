<#
  This is a script used to change the date of when the backup is run for the policy of affecting azureVM
  It also features as GUI to pick the date and time so as to simplify the usage of it
  It is using the azurerm module
#>

Login-AzureRmAccount

$vaults = Get-AzureRmRecoveryServicesVault

$Initaltime = [datetime]"00:00"
$timetoadd = $Initaltime
$timetable = @()
$timetable +=$timetoadd
$time2 = $timetoadd | Get-Date -Format HH:mm
while($time2 -ne "23:30"){
$timetoadd = $timetoadd.AddMinutes(30)
$timetable += $timetoadd
$time2 = $timetoadd | Get-Date -Format HH:mm
}

Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font(“Consolas”, 13)
$mainForm.Text = ” Pick Time Frame”
$mainForm.Font = $font
$mainForm.ForeColor = “White”
$mainForm.BackColor = “CadetBlue”
$mainForm.Width = 300
$mainForm.Height = 200


# MinTimePicker Label
$minTimePickerLabel = New-Object System.Windows.Forms.Label
$minTimePickerLabel.Text = “Time”
$minTimePickerLabel.Location = “15, 45”
$minTimePickerLabel.Height = 22
$minTimePickerLabel.Width = 90
$mainForm.Controls.Add($minTimePickerLabel)

#Vault Label
$VaultLabel = New-Object System.Windows.Forms.Label
$VaultLabel.Text = "Vault"
$VaultLabel.Location = "15, 80"
$VaultLabel.Height = 22
$VaultLabel.Width = 90
$mainForm.Controls.Add($VaultLabel)


# MinTimePicker
$minTimePicker = New-Object System.Windows.Forms.ComboBox
$minTimePicker.Location = “110, 42”
$minTimePicker.Width = “150”
$minTimePicker.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
ForEach ($time in $timetable){
    [Void] $minTimePicker.Items.Add(($time | Get-date -Format HH:mm))
}
$minTimePicker.SelectedItem = $minTimePicker.Items[0]
$mainForm.Controls.Add($minTimePicker)

#Vault
$Vaultname = New-Object System.Windows.Forms.ComboBox
$Vaultname.Location = "110,77"
$Vaultname.Width = "150"
$vaultname.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
ForEach ($Item in $vaults){
    [Void] $Vaultname.Items.Add($Item.Name)
}
$Vaultname.SelectedItem = $Vaultname.Items[0]
$mainForm.Controls.Add($Vaultname)

# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = “15, 130”
$okButton.ForeColor = “Black”
$okButton.BackColor = “White”
$okButton.Text = “OK”
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()

$time = $minTimePicker.SelectedItem


$vaultSelection = Get-AzureRmRecoveryServicesVault -Name $Vaultname.SelectedItem.ToString()

Set-AzureRmRecoveryServicesVaultContext -Vault $vaultSelection


$backupPolicies = Get-AzureRmRecoveryServicesBackupProtectionPolicy -WarningAction Ignore

  foreach($backupPolicy in $backupPolicies)
{
$ScheduleRunTimes = (Get-Date -Date $time).ToUniversalTime()

     $schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"

    $ScheduleRunDays = $schPol.ScheduleRunDays

    $schPol.ScheduleRunTimes.Clear()
    $schPol.ScheduleRunTimes.Add($ScheduleRunTimes)
    $schPol.ScheduleRunDays = $ScheduleRunDays
             
     Set-AzureRmRecoveryServicesBackupProtectionPolicy -Policy $backupPolicy -SchedulePolicy $SchPol 
  } 
