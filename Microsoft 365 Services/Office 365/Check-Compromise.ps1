<# To do list:
    Suspicious activity, such as missing or deleted emails.
    Other users might receive emails from the compromised account without the corresponding email existing in the Sent Items folder of the sender.
    The presence of inbox rules that weren't created by the intended user or the administrator. These rules may automatically forward emails to unknown addresses or move them to the Notes, Junk Email, or RSS Subscriptions folders.
    The user's display name might be changed in the Global Address List.
    The user's mailbox is blocked from sending email.
    The Sent or Deleted Items folders in Microsoft Outlook or Outlook on the web (formerly known as Outlook Web App) contain common hacked-account messages, such as "I'm stuck in London, send money."
    Unusual profile changes, such as the name, the telephone number, or the postal code were updated.
    Unusual credential changes, such as multiple password changes are required.
    Mail forwarding was recently added.
    An unusual signature was recently added, such as a fake banking signature or a prescription drug signature.
 #>

#Required Office 365 Modules.
    Connect-ExchangeOnline
    Connect-IPPSSession
    Connect-AzureAD
    Connect-MsolService

function Connect-O365Services {

#Are we already connected to MsolService & Azure AD?
    $MsolServiceSession = Get-MsolDomain -ErrorAction SilentlyContinue
#Checking if MsolService & AzureAD Module is installed.
    $MsolModule = Get-InstalledModule -Name MSOnline -ErrorAction SilentlyContinue
    $AzureADModule = Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue
}
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
        Connect-AzureAD -AccountId $globalAdmin
    }
}   
    catch {
        $error[0]
}

#Connecting to Online Microsoft Services.
    Write-Host -ForegroundColor Yellow "
    ------------------------------------------------------------------------------------------------------------------------------------------------------------
    | Check-Compromise function will log into (Microsoft Azure AD, Azure-AD, Exchange Online & Security Admin Center)                                           |
    |   For more information, use Get-Help Check-Compromise                                                                                                     |
    | To help automatically sign into these services, you'll be asked to enter a global admin email, followed by entering your MFA credentials for Office 365.  |
    ------------------------------------------------------------------------------------------------------------------------------------------------------------"
    $globalAdminAcct = Read-Host "Global Admin Email Address"
    if ($globalAdminAcct) {
        Write-Host -ForegroundColor Cyan "Signing into Online Microsoft services."
        try {
            #Microsoft Azure Active Directory
            Write-Host -ForegroundColor Cyan "`nConnecting to Office 365 services..`n"
                Connect-MsolService
            #Azure Active Directory
            Write-Host -ForegroundColor Cyan "`nConnecting to Azure AD..`n"
                Connect-AzureAD -AccountId $globalAdminAcct
            #Exchange Online
            Write-Host -ForegroundColor Cyan "`nConnecting to Exchange Online..`n"
                Connect-ExchangeOnline -UserPrincipalName $globalAdminAcct
            #Security & Compliance Center
            Write-Host -ForegroundColor Cyan "`nConnecting to Protection.Office.com..`n"
                Connect-IPPSSession -UserPrincipalName $globalAdminAcct
        }
        catch {
            $error[0]
        }
    }

    #disconnecting from the services:
        #Disconnect-ExchangeOnline -confirm:$false
        #Disconnect-AzAccount
        #Disconnect-AzureAD
     
#Disconnect-ExchangeOnline -confirm:$false
#Check if MFA is enabled (https://docs.microsoft.com/en-us/powershell/module/msonline/get-msoluserbystrongauthentication?view=azureadps-1.0)
    Get-MsolUserByStrongAuthentication

#If CA Policy, further investigate here (https://practical365.com/using-powershell-to-manage-conditional-access-ca-policies/)
    Get-AzureADMSConditionalAccessPolicy
#further confirm the excepted locations of MFA here
    Get-AzureADMSNamedLocationPolicy

#Check if user account is flagged for being compromised.
Get-AzureADUser -ObjectId $User | select-object IsCompromised

#Get user account's email that is blocked (https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/removing-user-from-restricted-users-portal-after-spam?view=o365-worldwide)
    Get-BlockedSenderAddress

#Get Azure Sign in Logs: (https://docs.microsoft.com/en-us/powershell/module/azuread/get-azureadauditsigninlogs?view=azureadps-2.0-preview)
    Get-AzureADAuditSignInLogs

#Generate a temp password that can be easily provided over the phone (https://www.dinopass.com/api)
    Invoke-RestMethod http://www.dinopass.com/password/simple

#Set user password (https://docs.microsoft.com/en-us/powershell/module/azuread/set-azureaduserpassword?view=azureadps-2.0)
#will need to get the users object ID.
    Set-AzureADUserPassword -ForceChangePasswordNextLogin $true
    Get-AzureADUser -SearchString $user.UserPrincipalName | Revoke-AzureADUserAllRefreshToken

function Test-User {
    param (
        [CmdletBinding]
        # Parameter help description
        [Parameter()]
        [ValidateScript({Get-AzureADUser -ObjectId $_})]
        [string]$CompUser
    )
            $CompUser1 = Get-AzureADUser -ObjectId $CompUser
            $CompUser1.Objectid
    }