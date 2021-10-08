<# Ask if we need to copy #>
$copy = Read-Host "Copy an exisiting user? (Y/N) "
<# If coping a user. #>
if ($copy -eq "Yes" -or $copy -eq "Y") {
    $copiedUser = Read-Host "User to copy from: "
    $copiedOU = (((Get-ADUser -identity $copiedUser -Properties CanonicalName | select-object -expandproperty DistinguishedName) -split",") | Select-Object -Skip 1) -join ','
    $copiedMemberships = Get-ADPrincipalGroupMembership $copiedUser | Select-Object -ExpandProperty Name
}

function importCSV {
    Write-Output "Select new user's CSV file."
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $myFile = "%USERPROFILE%\"
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = Split-Path $myFile -Parent 
    $OpenFileDialog.ShowDialog() | Out-Null
    $Attachment = $OpenFileDialog.filename
    <# Coverted to global to use in forreach newUser function #>
    $script:ConvertedAttachment = Import-Csv -Path $Attachment
}
function newUser {
    foreach ($user in $script:ConvertedAttachment) {
        try{
            <# Map user variables #>
            $splat = @{
                name                    = $user.displayName
                accountpassword         = read-host "Password: " -AsSecureString
                givenname               = $user.givenname
                surname                 = $user.Surname
                Samaccountname          = $user.username
                userprincipalname       = $user.emailaddress
                department              = $user.department 
                Title                   = $user.jobtitle 
                displayname             = $user.displayname 
                emailaddress            = $user.emailaddress
                path                    = $copiedOU
                Enabled                 = $true
                verbose                 = $true
            }
            <# Create new user with mapped variables #>
            New-aduser @splat -ErrorAction Stop

            <# Add Group Memberships from copied user. #>
                foreach ($membership in $copiedMemberships) {
                    try {
                        Add-ADGroupMember -Identity $membership -Members $user.username
                    }
                    catch [System.Management.Automation.CmdletInvocationException] {
                        <# Catch "Already apart of "domain users" error" #>
                    }
                }
        } <# End of Try block #>
        catch {
            Write-Warning $error[0]
        }
        Write-Warning "To add SMTP address run command: Set-aduser -identity 'USERNAME' -Add @{ProxyAddresses='SMTP:EMAIL ADDRESS'}"
    } <# End of foreach #>
} <# End of function #>

importCSV
newUser