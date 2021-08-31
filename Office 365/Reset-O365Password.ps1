#Investigate how to take in pipeline users.

function Reset-O365Password {
    [CmdletBinding()]
    param (
        #Take user(s) through the Pipeline
        [Parameter(ValueFromPipeline=$true)]
        $pipeValue,
        #Find users who's password is set to never expire
        [Parameter(Mandatory=$false)]
        [switch]$NoExpiration,
        # Finds user passwords that have been not recently changed within a certain time frame.
        [Parameter(Mandatory=$false)]
        $OlderThan,
        # Finds user passwords that have been recently changed within a certain time frame.
        [Parameter(Mandatory=$false)]
        $NewerThan,
        # Parameter help description
        [Alias('UPN')]
        [Parameter()]
        $UserPrincipalName
    )

#Are we already connected to MsolService & Azure AD?
$MsolServiceSession = Get-MsolDomain -ErrorAction SilentlyContinue
$AzureADServiceSession = Get-AzureADTenantDetail -ErrorAction SilentlyContinue
#Checking if MsolService & AzureAD Module is installed.
$MsolModule = Get-InstalledModule -Name MSOnline -ErrorAction SilentlyContinue
$AzureADModule = Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue

#Checking for MsolService
try {
    if ($null -ne $MsolServiceSession) {
        break
    }
    elseif ($null -eq $MsolModule) {
            # Module is not installed, sliently install
            try {
                #Backup Execution Policy
                $previousEP = Get-ExecutionPolicy
                #Set Execution Policy to allow install of modules.
                Set-ExecutionPolicy RemoteSigned
                #Installing Module
                Write-Host -ForegroundColor Cyan "Installing Msolservice Module.. "
                #Silenty Install Module.
                Install-Module -Name MSOnline -Force
                #Restore Execution Policy
                Set-ExecutionPolicy $previousEP
                Write-host -ForegroundColor Cyan "Module now installed and now connecting to MsolService"
                Connect-MsolService
            }
                catch {
                    $error[0]
                }
        }
    else {
        # Module is already installed, creating new active session.
        Write-host -ForegroundColor Cyan "Connecting to MsolService.."
        Connect-MsolService
    }
}   
    catch {
        $error[0]
}

#Checking for Azure AD
try {
    if ($null -ne $AzureADServiceSession) {
        break
    }
    elseif ($null -eq $AzureADModule) {
            # Module is not installed, sliently install
            try {
                #Backup Execution Policy
                $previousEP = Get-ExecutionPolicy
                #Set Execution Policy to allow install of modules.
                Set-ExecutionPolicy RemoteSigned
                #Installing Module
                Write-Host -ForegroundColor Cyan "Installing AzureAD Module.. "
                #Silenty Install Module.
                Install-Module -Name AzureAD -Force
                #Restore Execution Policy
                Set-ExecutionPolicy $previousEP
                Write-host -ForegroundColor Cyan "Module now installed and now connecting to AzureAD"
                Connect-AzureAD
            }
                catch {
                    $error[0]
                }
        }
    else {
        # Module is already installed, creating new active session.
        Write-host -ForegroundColor Cyan "Connecting to MsolService.."
        Connect-MsolService
    }
}   
    catch {
        $error[0]
}

#If the -NoExpiration switch is provided
#NOTE: Add an export to csv funtion here
if ($NoExpiration) {
    #Check for accounts that have "Password never expires"
    Write-Host "Checking for any users that are licensed and have 'Password Never Expires'.."
    Get-MsolUser -All | Where-Object {($_.Islicensed -eq $true) -and ($_.PasswordNeverExpires -eq $true)} | Select-Object Displayname,PasswordNeverExpires
}

#If the -OlderThan switch is provided
if ($OlderThan -or $NewerThan) {
    #If a Date was a string (Example: 8/12/2021), then covert that into a number of Days.
    If ($OlderThan -is [string]) {
        $OlderThanDate = $OlderThan
        $Today         = Get-Date
        $TotalDays     = New-TimeSpan -Start $OlderThanDate -End $Today
        $OlderThan     = $TotalDays.Days
    }
    If ($NewerThan -is [string]) {
        $NewerThanDate = $NewerThan
        $Today         = Get-Date
        $TotalDays     = New-TimeSpan -Start $NewerThanDate -End $Today
        $NewerThan     = $TotalDays.Days
    }
    if ($OlderThan -and $null -eq $UserPrincipalName) {
        Write-Host -ForegroundColor Yellow "Checking for any users that have not changed their password in the last $OlderThan days.."
        $pwdResetUsers = Get-MsolUser -All | Where-Object {($_.Islicensed -eq $true) -and ($_.LastPasswordChangeTimestamp -lt (Get-Date).AddDays(-$OlderThan))}
    }
    elseif ($NewerThan -and $null -eq $UserPrincipalName) {
        Write-Host -ForegroundColor Yellow "Checking for any users that have changed their password in the last $NewerThan days.."
        $pwdResetUsers = Get-MsolUser -All | Where-Object {($_.Islicensed -eq $true) -and ($_.LastPasswordChangeTimestamp -gt (Get-Date).AddDays($NewerThan))}
    }
}

#Go through each user who's password needs to be updated & force password change at next logon.
    $i = 0
    foreach ($user in $pwdResetUsers) {
        Write-Progress -Activity 'Processing Pwd Reset Flags & Removing Access Tokens..' -Status "Scanned: $i of $($pwdResetUsers.Count)"
        #Flag account for password reset at next logon.
        Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true
        #Revoke Access Token
        Get-AzureADUser -SearchString $user.UserPrincipalName | Revoke-AzureADUserAllRefreshToken
        start-sleep -Milliseconds 150
        $i++
    }
Write-Host -foregroundcolor Yellow "Users that were effected"
$pwdResetUsers | Select-Object UserPrincipalName, DisplayName, LastPasswordChangeTimestamp, PasswordNeverExpires

<# Write-Host -ForegroundColor Yellow "Checking for any Refresh Tokens that weren't deleted.."
Get-AzureADUser -SearchString $user | Select-Object *refresh* #>
    
Write-Host -ForegroundColor Cyan "Script completed, instruct users to close their browser and navigate to https://www.office.com to update their passwords."
Write-host "Refresh Tokens are kept for 5 hours by default. If any were output above, then run command: Get-AzureADUser -SearchString 'USERS EMAIL ADDRESS' | Revoke-AzureADUserAllRefreshToken (Do this for each user listed)"
}
