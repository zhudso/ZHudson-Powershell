function Reset-O365Password {
    [CmdletBinding()]
    param (
        # Select a single user with their UPN
        [Alias('UPN')]
        [Parameter(Position=0)]
        $UserPrincipalName,
        # Finds user passwords that have been not recently changed within a certain time frame.
        [Parameter()]
        $OlderThan,        
        #Find users who's password is set to never expire
        [Parameter()]
        [switch]$NoExpiration
    )

#Are we already connected to MsolService & Azure AD?
    $MsolServiceSession = Get-MsolDomain -ErrorAction SilentlyContinue
#Checking if MsolService & AzureAD Module is installed.
    $MsolModule = Get-InstalledModule -Name MSOnline -ErrorAction SilentlyContinue
    $AzureADModule = Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue

#Checking for MsolService
try {
    if ($MsolServiceSession) {
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

#Have to do ErrorActionPreference swaps for Azure If Statement command due to Microsoft reasons: https://github.com/Azure/azure-docs-powershell-azuread/issues/155
$ErrorActionBackup = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
$AzureADServiceSession = Get-AzureADTenantDetail -ErrorAction SilentlyContinue
$ErrorActionPreference = $ErrorActionBackup

#Checking for Azure AD
try {
    if ($AzureADServiceSession) {
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
        $globalAdmin = Read-Host -Prompt "Global Admin Email"
        Write-host -ForegroundColor Cyan "Connecting to AzureAD as $globalAdmin.."
        Connect-AzureAD -AccountId $globalAdmin
    }
}   
    catch {
        $error[0]
}

#If the -NoExpiration switch is provided
if ($NoExpiration) {
    #Check for accounts that have "Password never expires"
    Write-Host "Checking for any users that are licensed and have 'Password Never Expires'.."
    #$neverExpireUsers = Get-MsolUser -All | Where-Object {($_.Islicensed -eq $true) -and ($_.PasswordNeverExpires -eq $true)} | Select-Object Displayname,$UserPrincipalName,PasswordNeverExpires
    Write-Host $neverExpireUsers.Count "users were found."; $neverExpireUsers
}

#If the -OlderThan switch is provided
if ($OlderThan) {
    #If a Date was a string (Example: 8/12/2021), then covert that into a number of Days.
    if ($OlderThan -is [string]) {
        $OlderThanDate = $OlderThan
        $Today         = Get-Date
        $TotalDays     = New-TimeSpan -Start $OlderThanDate -End $Today
        $OlderThan     = $TotalDays.Days
    }
    try {
        if ($OlderThan -and $null -eq $UserPrincipalName) {
            Write-Host -ForegroundColor Yellow "Checking for any users that have not changed their password in the last $OlderThan days.."
            $pwdResetUsers = Get-MsolUser -All | Where-Object {($_.Islicensed -eq $true) -and ($_.LastPasswordChangeTimestamp -lt (Get-Date).AddDays(-$OlderThan))}
                #Go through all users who's password needs to be updated & force password change at next logon.
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
            Write-Host -ForegroundColor Cyan "Script completed, instruct users to close their browser and navigate to https://www.office.com or simply sign out and back in to update their passwords."
            }
    } 
    catch {
        $error[0]
    }
}
    if ($UserPrincipalName) {
        try {
        #Flag account for password reset at next logon.
        Write-Host -ForegroundColor Yellow Write-host "Setting $UserPrincipalName for a password reset and deleting Azure AD token.."
        #Difference between -ForceChangePasswordOnly (automatically sets a random password & tells the acount to reset at next logon) & -ForceChangePassword: Removes the previous's command action of setting a random password)
        Get-MsolUser -UserPrincipalName $UserPrincipalName.UserPrincipalName | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true
        #Revoke Access Token
        Get-AzureADUser -SearchString $UserPrincipalName.UserPrincipalName | Revoke-AzureADUserAllRefreshToken
    } catch {
        $error[0]
    }
    Write-Host -ForegroundColor Cyan "Script completed, instruct $UserPrincipalName to close their browser and navigate to https://www.office.com or simply sign out and back in to update their password."
}
}