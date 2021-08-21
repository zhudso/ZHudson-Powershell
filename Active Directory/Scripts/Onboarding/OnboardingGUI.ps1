
#---------------------------------------------------------[Pre Reqs]---------------------------------------------------------
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName PresentationCore,PresentationFramework

#---------------------------------------------------------[GUI]---------------------------------------------------------
$basicForm = New-Object System.Windows.Forms.Form
$basicForm.Height = 600
$basicForm.Width = 300

$givenName                    = New-Object system.Windows.Forms.Label
$givenName.text               = "First Name *"
$givenName.AutoSize           = $true
$givenName.width              = 150
$givenName.height             = 50
$givenName.location           = New-Object System.Drawing.Point(23,5)
$givenName.Font               = 'Microsoft Sans Serif,10'

$givenNameTxtBox              = New-Object System.Windows.Forms.TextBox
$givenNameTxtBox.Location     = '23,25'
$givenNameTxtBox.Size         = '150,25'

$surName                      = New-Object system.Windows.Forms.Label
$surName.text                 = "Last Name *"
$surName.AutoSize             = $true
$surName.width                = 150
$surName.height               = 50
$surName.location             = New-Object System.Drawing.Point(23,60)
$surName.Font                 = 'Microsoft Sans Serif,10'

$surNameTxtBox                = New-Object System.Windows.Forms.TextBox
$surNameTxtBox.Location       = '23,80'
$surNameTxtBox.Size           = '150,25'

$Username                     = New-Object system.Windows.Forms.Label
$Username.text                = "Username *"
$Username.AutoSize            = $true
$Username.width               = 150
$Username.height              = 50
$Username.location            = New-Object System.Drawing.Point(23,115)
$Username.Font                = 'Microsoft Sans Serif,10'

$usernameTxtBox               = New-Object System.Windows.Forms.TextBox
$usernameTxtBox.Location      = '23,135'
$usernameTxtBox.Size          = '150,23'

$Password                     = New-Object System.Windows.Forms.Label
$Password.text                = "Password *"
$Password.AutoSize            = $true
$Password.width               = 150
$Password.height              = 50
$Password.location            = New-Object System.Drawing.Point(23,170)
$Password.Font                = 'Microsoft Sans Serif,10'

$passwordTxtBox               = New-Object System.Windows.Forms.MaskedTextBox
$passwordTxtBox.PasswordChar  = "*"
$passwordTxtBox.Location      = '23,190'
$passwordTxtBox.Size          = '150,23'

$Email                        = New-Object system.Windows.Forms.Label
$Email.text                   = "Email *"
$Email.AutoSize               = $true
$Email.width                  = 150
$Email.height                 = 50
$Email.location               = New-Object System.Drawing.Point(23,225)
$Email.Font                   = 'Microsoft Sans Serif,10'

$emailTxtBox                  = New-Object System.Windows.Forms.TextBox
$emailTxtBox.Location         = '23,245'
$emailTxtBox.Size             = '150,23'

$jobTitle                     = New-Object system.Windows.Forms.Label
$jobTitle.text                = "Job Title"
$jobTitle.AutoSize            = $true
$jobTitle.width               = 150
$jobTitle.height              = 50
$jobTitle.location            = New-Object System.Drawing.Point(23,280)
$jobTitle.Font                = 'Microsoft Sans Serif,10'

$jobTitleTxtBox               = New-Object System.Windows.Forms.TextBox
$jobTitleTxtBox.Location      = '23,300'
$jobTitleTxtBox.Size          = '150,25'

$department                   = New-Object system.Windows.Forms.Label
$department.text              = "Department"
$department.AutoSize          = $true
$department.width             = 150
$department.height            = 50
$department.location          = New-Object System.Drawing.Point(23,330)
$department.Font              = 'Microsoft Sans Serif,10'

$departmentTxtBox             = New-Object System.Windows.Forms.TextBox
$departmentTxtBox.Location    = '23,350'
$departmentTxtBox.Size        = '150,25'

$copyUser                     = New-Object System.Windows.Forms.Label
$copyUser.Text                = "Copy User?"
$copyUser.AutoSize            = $true
$copyUser.Width               = 150
$copyUser.Height              = 50
$copyUser.Location            = '23,385'
$copyUser.Font                = 'Microsoft Sans Serif,10'

$copyUserButton               = New-Object System.Windows.Forms.RadioButton
$copyUserButton.text          = "Yes"
$copyUserButton.AutoSize      = $true
$copyUserButton.width         = 150
$copyUserButton.height        = 50
$copyUserButton.location      = New-Object System.Drawing.Point(100,383)
$copyUserButton.Font          = 'Microsoft Sans Serif,10'

$nocopyUserButton             = New-Object System.Windows.Forms.RadioButton
$nocopyUserButton.text        = "No"
$nocopyUserButton.AutoSize    = $true
$nocopyUserButton.width       = 150
$nocopyUserButton.height      = 50
$nocopyUserButton.location    = New-Object System.Drawing.Point(150,383)
$nocopyUserButton.Font        = 'Microsoft Sans Serif,10'

$userToCopy                   = New-Object system.Windows.Forms.Label
$userToCopy.text              = "Their Username"
$userToCopy.AutoSize          = $true
$userToCopy.width             = 150
$userToCopy.height            = 50
$userToCopy.location          = New-Object System.Drawing.Point(23,415)
$userToCopy.Font              = 'Microsoft Sans Serif,10'

$copyUserTxtBox               = New-Object System.Windows.Forms.TextBox
$copyUserTxtBox.Location      = '23,440'
$copyUserTxtBox.Size          = '150,25'

$submitButton                 = New-Object System.Windows.Forms.Button
$submitButton.Text            = 'Submit'
$submitButton.Width           = 147
$submitButton.Height          = 32
$submitButton.Location        = New-Object System.Drawing.Point(23,500)
$submitButton.Anchor          = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left


<# confirmation dialog box #>
$buttonType                   = [System.Windows.MessageBoxButton]::YesNo
$messageIcon                  = [System.Windows.MessageBoxImage]::Information
$messageBody                  = "Confirm Submission?"
$messageTitle                 = "Confirm"

<# successful dialog box. #>
$successConfBody             = "Successful user creation"
$successConfTitle            = "User Creation"

<# failed dialog box. #>
$failedConfBody               = "Failed to create user"
$failedConfTitle              = "User Creation"

$basicForm.controls.AddRange(@($givenName, $givenNameTxtBox, $surName, $surNameTxtBox, $Username, $usernameTxtBox, $Password, $passwordTxtBox, $Email, $emailTxtBox ,$jobTitle, $jobTitleTxtBox, $department, $departmentTxtBox, $copyUser, $copyUserButton, $nocopyUserButton, $userToCopy, $copyUserTxtBox, $submitButton))

#---------------------------------------------------------[Functions]---------------------------------------------------------

function copyUser {
        $copiedUser = $copyUserTxtBox.Text
        $global:copiedOU = (((Get-ADUser -identity $copiedUser -Properties CanonicalName | select-object -expandproperty DistinguishedName) -split",") | Select-Object -Skip 1) -join ','
        $global:copiedMemberships = Get-ADPrincipalGroupMembership $copiedUser | Select-Object -ExpandProperty Name
}

function newUser {
    $splat = @{
        name              = $givenNameTxtBox.Text + " " + $surNameTxtBox.Text
        accountpassword   = $securePW
        givenname         = $givenNameTxtBox.Text
        surname           = $surNameTxtBox.Text
        Samaccountname    = $usernameTxtBox.Text
        userprincipalname = $emailTxtBox.Text
        department        = $departmentTxtBox.Text
        Title             = $jobTitleTxtBox.Text 
        displayname       = $givenNameTxtBox.Text + " " + $surNameTxtBox.Text
        emailaddress      = $emailTxtBox.Text
        path              = $global:copiedOU
        Enabled           = $true
        verbose           = $true
    }
        New-ADUser @splat -ErrorAction Stop
        foreach ($membership in $global:copiedMemberships) {
        try {
            Add-ADGroupMember -Identity $membership -Members $usernameTxtBox.Text
        }
        catch [System.Management.Automation.CmdletInvocationException] {
                    <# Catch "Already apart of "domain users" error" #>
            }
        } <# End of foreach block #>
}
#---------------------------------------------------------[Scripts]---------------------------------------------------------

$submitButton.Add_Click({
    $confirmationWindow = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    if ($confirmationWindow -eq "Yes" -and $copyUserButton.Checked) {
        try {
            copyUser
            $securePW = $passwordTxtBox.Text | ConvertTo-SecureString -AsPlainText -Force
            newUser -ErrorAction Stop
            [System.Windows.MessageBox]::Show($successConfBody, $successConfTitle)
            $basicForm.Close()
        }
        catch {
            [System.Windows.MessageBox]::Show($failedConfBody, $failedConfTitle)
            Write-Warning $Error[0]
        }
        
    }
    elseif ($confirmationWindow -eq "Yes") {
        try {
            $securePW = $passwordTxtBox.Text | ConvertTo-SecureString -AsPlainText -Force
            newUser
        }
        catch {
            Write-Output "Failed to create new user"
            Write-Warning $Error[0]
        }
    }
    else {
        <# Do nothing, allows user to correct information #>
    }
})
$basicForm.ShowDialog()