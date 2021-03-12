Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font(“Consolas”, 13)
$mainForm.Text = ” Pick Time Frame”
$mainForm.Font = $font
$mainForm.ForeColor = “White”
$mainForm.BackColor = “DarkOliveGreen”
$mainForm.Width = 300
$mainForm.Height = 200

# DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = “date”
$datePickerLabel.Location = “15, 10”
$datePickerLabel.Height = 22
$datePickerLabel.Width = 90
$mainForm.Controls.Add($datePickerLabel)

# MinTimePicker Label
$minTimePickerLabel = New-Object System.Windows.Forms.Label
$minTimePickerLabel.Text = “min-time”
$minTimePickerLabel.Location = “15, 45”
$minTimePickerLabel.Height = 22
$minTimePickerLabel.Width = 90
$mainForm.Controls.Add($minTimePickerLabel)

# DatePicker
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = “110, 7”
$datePicker.Width = “150”
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = “dd/MM/yyyy”
$mainForm.Controls.Add($datePicker)

# MinTimePicker
$minTimePicker = New-Object System.Windows.Forms.DateTimePicker
$minTimePicker.Location = “110, 42”
$minTimePicker.Width = “150”
$minTimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$minTimePicker.CustomFormat = “HH:mm:ss”
$minTimePicker.ShowUpDown = $TRUE
$mainForm.Controls.Add($minTimePicker)

# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = “15, 130”
$okButton.ForeColor = “Black”
$okButton.BackColor = “White”
$okButton.Text = “OK”
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)


[void] $mainForm.ShowDialog()