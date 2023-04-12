# Adding required types to create windows forms and show GUI alerts
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Setting up the Window/Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Password Reset"
$form.Width = 525
$form.Height = 120
$form.AutoSize = $true

# Setting up the users Label
$usersLabel = New-Object System.Windows.Forms.Label
$usersLabel.Text = "AD Users: "
$usersLabel.Location = New-Object System.Drawing.Point(10,10)
$usersLabel.AutoSize = $true

# User list ComboBox
$userList = New-Object System.Windows.Forms.ComboBox
$userList.Width = 300
$userList.Location = New-Object System.Drawing.Point(70,10)

# Populating user list with AD users
$users = Get-ADUser -Filter "enabled -eq 'true'" -Properties SamAccountName | Sort-Object -Property SamAccountName
foreach($user in $users)
{
    $userList.Items.Add($user.SamAccountName)
}

# Password Label
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Text = "Password: "
$passwordLabel.Location = New-Object System.Drawing.Point(10,40)

# Password to reset to TextBox
$userPassword = New-Object System.Windows.Forms.TextBox
$userPassword.Width = 300
$userPassword.Location = New-Object System.Drawing.Point(70,40)

# Reset Password Button
$resetPasswordButton = New-Object System.Windows.Forms.Button
$resetPasswordButton.Location = New-Object System.Drawing.Point(375, 40)
$resetPasswordButton.Size = New-Object System.Drawing.Size(120,23)
$resetPasswordButton.Text = "Reset"
$resetPasswordButton.Add_Click(
    {
        # Checking if values were entered in the username and password fields
        if(($userList.SelectedItem.Length -gt 0) -And ($userPassword.Text.Length -gt 0))
        {
            # Getting the user to confirm the account is correct
            $user = Get-ADUser -Identity $userList.SelectedItem
            $answer = [System.Windows.MessageBox]::Show("Do you want to reset the password for this user?: "+$user.UserPrincipalName, "Confirmation", "YesNo", "Warning")
            if($answer -eq "Yes")
            {
                try 
                {
                    # Getting list of domain controllers to reset the password on
                    $DCs = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=domain,DC=com"
                    $pass = ConvertTo-SecureString $userPassword.Text -AsPlainText -Force
                
                    # Active Directory Web Services must be enabled on the DCs for the below to run
                    # Resetting the password and unlocking the account on all found domain controllers
                    foreach($DC in $DCs)
                    {
                        Set-ADAccountPassword -Identity $user.SamAccountName -NewPassword $pass -Server $DC.Name
                        Unlock-ADAccount -Identity $user.SamAccountName -Server $DC.Name
                    }

                    [void][System.Windows.MessageBox]::Show("Password has been reset", "Completed", "OK", "Information")
                }
                catch 
                {
                    [void][System.Windows.MessageBox]::Show("Error resetting password", "Error", "OK", "Error")
                }
            }
        }
    }
)

# Adding the items and making the window visible
$form.Controls.Add($usersLabel)
$form.Controls.Add($userList)
$form.Controls.Add($userPassword)
$form.Controls.Add($passwordLabel)
$form.Controls.Add($resetPasswordButton)
$form.ShowDialog()