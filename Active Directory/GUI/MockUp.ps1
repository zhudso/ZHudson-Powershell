
#---------------------------------------------------------[Pre Reqs]---------------------------------------------------------
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName PresentationCore,PresentationFramework

#---------------------------------------------------------[GUI]---------------------------------------------------------
$basicForm = New-Object System.Windows.Forms.Form
$basicForm.Height = 600
$basicForm.Width = 600


$copyUserButton                     = New-Object System.Windows.Forms.RadioButton
$copyUserButton.text                = "Yes"
$copyUserButton.AutoSize            = $true
$copyUserButton.width               = 150
$copyUserButton.height              = 50
$copyUserButton.location            = New-Object System.Drawing.Point(200,5)
$copyUserButton.Font                = 'Microsoft Sans Serif,10'

$nocopyUserButton                     = New-Object System.Windows.Forms.RadioButton
$nocopyUserButton.text                = "No"
$nocopyUserButton.AutoSize            = $true
$nocopyUserButton.width               = 150
$nocopyUserButton.height              = 50
$nocopyUserButton.location            = New-Object System.Drawing.Point(300,5)
$nocopyUserButton.Font                = 'Microsoft Sans Serif,10'

$copyUserTxtBox               = New-Object System.Windows.Forms.TextBox
$copyUserTxtBox.Location      = '200,25'
$copyUserTxtBox.Size          = '150,25'

$givenName                     = New-Object system.Windows.Forms.Label
$givenName.text                = "First Name"
$givenName.AutoSize            = $true
$givenName.width               = 150
$givenName.height              = 50
$givenName.location            = New-Object System.Drawing.Point(20,5)
$givenName.Font                = 'Microsoft Sans Serif,10'

$givenNameTxtBox               = New-Object System.Windows.Forms.TextBox
$givenNameTxtBox.Location      = '23,25'
$givenNameTxtBox.Size          = '150,25'

$surName                     = New-Object system.Windows.Forms.Label
$surName.text                = "Last Name"
$surName.AutoSize            = $true
$surName.width               = 150
$surName.height              = 50
$surName.location            = New-Object System.Drawing.Point(20,60)
$surName.Font                = 'Microsoft Sans Serif,10'

$surNameTxtBox               = New-Object System.Windows.Forms.TextBox
$surNameTxtBox.Location      = '23,80'
$surNameTxtBox.Size          = '150,25'

$Username                     = New-Object system.Windows.Forms.Label
$Username.text                = "Username"
$Username.AutoSize            = $true
$Username.width               = 150
$Username.height              = 50
$Username.location            = New-Object System.Drawing.Point(20,115)
$Username.Font                = 'Microsoft Sans Serif,10'

$usernameTxtBox               = New-Object System.Windows.Forms.TextBox
$usernameTxtBox.Location      = '23,135'
$usernameTxtBox.Size          = '150,23'

$Password                     = New-Object System.Windows.Forms.Label
$Password.text                = "Password"
$Password.AutoSize            = $true
$Password.width               = 150
$Password.height              = 50
$Password.location            = New-Object System.Drawing.Point(20,170)
$Password.Font                = 'Microsoft Sans Serif,10'

$passwordTxtBox               = New-Object System.Windows.Forms.MaskedTextBox
$passwordTxtBox.PasswordChar  = "*"
$passwordTxtBox.Location      = '23,190'
$passwordTxtBox.Size          = '150,23'

$Email                     = New-Object system.Windows.Forms.Label
$Email.text                = "Email"
$Email.AutoSize            = $true
$Email.width               = 150
$Email.height              = 50
$Email.location            = New-Object System.Drawing.Point(20,225)
$Email.Font                = 'Microsoft Sans Serif,10'

$emailTxtBox               = New-Object System.Windows.Forms.TextBox
$emailTxtBox.Location      = '23,245'
$emailTxtBox.Size          = '150,23'

$submitButton                 = New-Object System.Windows.Forms.Button
$submitButton.Text            = 'Submit'
$submitButton.Width           = 147
$submitButton.Height          = 32
$submitButton.Location        = New-Object System.Drawing.Point(20,500)
$submitButton.Anchor          = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

<# confirmation warning panel #>
$buttonType                   = [System.Windows.MessageBoxButton]::YesNo
$messageIcon                  = [System.Windows.MessageBoxImage]::Warning
$messageBody                  = "Confirm Submission?"
$messageTitle                 = "Confirm Submission"

$basicForm.controls.AddRange(@($copyUserButton, $nocopyUserButton, $copyUserTxtBox, $givenName, $givenNameTxtBox, $surName, $surNameTxtBox, $Username, $usernameTxtBox, $Password, $passwordTxtBox, $Email, $emailTxtBox, $submitButton))

#---------------------------------------------------------[Functions]---------------------------------------------------------

function newUser {
    $splat = @{
        name              = $user.displayName
        accountpassword   = $securePW
        givenname         = $givenNameTxtBox.Text
        surname           = $surNameTxtBox.Text
        Samaccountname    = $usernameTxtBox.Text
        userprincipalname = $emailTxtBox.Text
        department        = $user.department 
        Title             = $user.jobtitle 
        displayname       = $givenNameTxtBox.Text + " " + $surNameTxtBox.Text
        emailaddress      = $emailTxtBox.Text
        path              = $global:copiedOU
        Enabled           = $true
        verbose           = $true
    }
        Write-Host @splat
        #New-ADUser @splat -ErrorAction Stop
            #foreach ($membership in $copiedMemberships) {
                #try {
                    #Add-ADGroupMember -Identity $membership -Members $usernameTxtBox.Text
                #}
                #catch [System.Management.Automation.CmdletInvocationException] {
                    <# Catch "Already apart of "domain users" error" #>
                #}
            #} <# End of foreach block #>
}<# End of new user function #>

function copyUser {
        $copiedUser = $copyUserTxtBox.Text
        $global:copiedOU = (((Get-ADUser -identity $copiedUser -Properties CanonicalName | select-object -expandproperty DistinguishedName) -split",") | Select-Object -Skip 1) -join ','
        $copiedMemberships = Get-ADPrincipalGroupMembership $copiedUser | Select-Object -ExpandProperty Name
        
} <# End of copyUser function #>
#---------------------------------------------------------[Scripts]---------------------------------------------------------

$submitButton.Add_Click({
    $confirmationWindow = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    if ($confirmationWindow -eq "Yes" -and $copyUserButton.Checked) {
        copyUser
        $securePW = $passwordTxtBox.Text | ConvertTo-SecureString -AsPlainText -Force
        newUser
    } 
    elseif ($confirmationWindow -eq "Yes") {
        $securePW = $passwordTxtBox.Text | ConvertTo-SecureString -AsPlainText -Force
        newUser
    }
    else {
        <# Do nothing, allows user to correct information #>
    }
})
$basicForm.ShowDialog()