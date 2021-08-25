function Reset-O365Password {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $pipeValue,
        [Parameter(Mandatory=$false)]
        [switch]$PasswordAge,
        [Parameter()]
        [Alias("Identity","UPN")]
        $UPN
    )

#Checking if MsolService Module is installed.
Write-Host -foregroundcolor Yellow "Checking for required Office 365 modules.."

#Backup Execution Policy
$previousEP = Get-ExecutionPolicy
#Set Execution Policy to allow install of modules.
Set-ExecutionPolicy RemoteSigned

$MsolModule = Get-InstalledModule -Name MSOnline -ErrorAction SilentlyContinue
    # If Module is not installed, sliently install Module.
    if ($null -eq $MsolModule) {
        try {
            Write-Host -ForegroundColor Cyan "Installing Msolservice Module.. "
            #Silenty Install Module.
            Install-Module MSOnline -Force
        }
            catch {
                $error[0]
            }
    }
#Checking if Azure AD Module is installed.
$AzureADModule = Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue
    # If Module is not installed, sliently install Module.
    if ($null -eq $AzureADModule) {
        try {
            Write-Host -ForegroundColor Cyan "Installing AzureAD Module.. "
            #Silenty Install Module.
            Install-Module AzureAD -Force
        }
        catch {
            $error[0]
        }
    }

#Return to previous Execution Policy
Set-ExecutionPolicy $previousEP

#Connect to MsolService
Write-Host "Connecting to MsolService"
    Connect-MsolService
#Connect to Microsoft Azure AD
Write-Host "Connecting to Azure-AD"
    Connect-AzureAD

    #If the function switch statement "-PasswordAge is used"
    if ($PasswordAge.IsPresent) {
        #Check for accounts that have "Password never expires"
        Write-Host "Checking for any users that have 'Password Never Expires'.."
        Get-MsolUser | Where-Object {($_.Islicensed -eq $true) -and ($_.PasswordNeverExpires -eq $true)} | Select-Object Displayname,PasswordNeverExpires
    }

#Find users that are licensed and passwords has NOT been changed within the last 11 days.
Write-Host "Checking for any users that have not changed their password in the last 11 days.."
    $pwdResetUsers = Get-MsolUser | Where-Object {($_.Islicensed -eq $true) -and ($_.LastPasswordChangeTimestamp -lt (Get-Date).AddDays(-11))}
#Go through each user who's password hasn't been updated in the last 11 days to force password change at next logon.
    $i = 0
    foreach ($user in $pwdResetUsers) {
        Write-Progress -Activity 'Processing Pwd Reset Flags & Removing Access Tokens..' -Status "Scanned: $i of $($pwdResetUsers.Count)"
        #Flag account for password reset at next logon.
        Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true
        #Revoke Access Token
        Get-AzureADUser -SearchString $user.UserPrincipalName | Revoke-AzureADUserAllRefreshToken
        $i++
        start-sleep -Milliseconds 150
    }
Write-Host -foregroundcolor Yellow "Users that were effected"
$pwdResetUsers | Select-Object UserPrincipalName, DisplayName, LastPasswordChangeTimestamp, PasswordNeverExpires

<# Write-Host -ForegroundColor Yellow "Checking for any Refresh Tokens that weren't deleted.."
Get-AzureADUser -SearchString $user | Select-Object *refresh* #>
    
Write-Host -ForegroundColor Cyan "Script completed, instruct users to close their browser and navigate to https://www.office.com to update their passwords."
Write-host "Refresh Tokens are kept for 5 hours by default. If any were output above, then run command: Get-AzureADUser -SearchString 'USERS EMAIL ADDRESS' | Revoke-AzureADUserAllRefreshToken (Do this for each user listed)"
}