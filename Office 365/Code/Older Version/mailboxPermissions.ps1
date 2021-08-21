#Future Updates.
#-----------------------
#Open Powerhsell as Administrator - Completed.
#Connect to EAC with new authenctation built in the script.
#Provided numbered choices to the user to enter to prevent misspellings. -Completed.
#Add other functions, like email forwarding and auto reply
#Change if, elseif, else to switch statements. - Completed.
#Distribution Group stuff
#Keep the session open to run multiple commands and then end the session
#Retrieve information (What does this user have access to)
#Offboarding steps
#Pause the script to make sure that there isn't an error, prompt the user for yes or no -Completed.
#Call another file to open On-boarding or Off-boarding script.
#Provide default file save location ($exportCSV = $psScriptRoot+".\mailboxPermissions.ps1")

#Open Powershell as Administrator
#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    #Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
    #}

#documentation links:
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7
#https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell?view=exchange-ps

#Set-ExecutionPolicy Unrestricted -Scope Process
#$UserCredential = Get-Credential
#Connect-ExchangeOnline -Credential $UserCredential

$userConfirmation = Read-Host -Prompt "Successful Login? (Y/N)"
do {

if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
    break
    }
else {
    Write-Host "Check that Credentials are valid and not expired"
    $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
    Invoke-Expression -Command $scriptToRun
    }
}
while ($true)


$accessRights = Read-Host "Welcome to my EAC Powershell Script: Written by Zach Hudson
You can cancel the script at any time with Ctrl C

Configuring
-------------------
1. Full Access
2. Send As
3. Send on Behalf
4. Onboarding
-------------------
Number"


Write-Host "Which recipient do we need this permission " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or 'Firstname Lastname')"
$mailbox = Read-Host
Write-Host "Who needs this permission " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or 'Firstname Lastname')"
$requestersMailbox = Read-Host 

#validate provided information is correct.
Write-Host "Checking for correct inputs.."
#Get-Recipient -Identity $mailbox

$userConfirmation = Read-Host -Prompt "Are there any errors? (Y/N)"
do {

if ($userConfirmation -eq "No" -or $userConfirmation -eq "N") {
    Write-Host "Lets proceed.."
    break
    }
else {
    Write-Host "Unfortunately Exchange was unable to find the mailbox. Please check & re-enter emails"
    $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
    Invoke-Expression -Command $scriptToRun
    }
}
while ($true)

#Testing stored variables in IF statement

Switch ($accessRights) {
    1 {
        Write-Output "Successful Input for FullAccess.. Now configuring"
        #Add-MailboxPermission -Identity $mailbox -User $requestersMailbox -AccessRights $accessRights
    }
    2 {
        Write-Output "Successful Input for Send As.. Now configuring"
        #Add-MailboxPermission -Identity $mailbox -User $requestersMailbox -AccessRights $accessRights
    }

    3 {
        Write-Output "Successful Input for SendonBehalf.. Now configuring"
        #Set-Mailbox -Identity $mailbox -GrantSendOnBehalfTo @{Add=$requestersMailbox}
    }
    4 {
        $scriptToOpen = $psScriptRoot+"\Onboarding_Script.ps1"
        Invoke-Expression -Command $scriptToOpen
        exit
    } 

    Default {
        Write-Output """$accessRights"" Is an incorrect input. Please choose again"
        $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
        Invoke-Expression -Command $scriptToRun
        break
    }

}

Write-Host ""$requestersMailbox" is now configured!"
Write-Host "Giving EAC time to reflect the new permission.."

#Setting Timer for EAC to reflect new changes
$delay = 5
while ($delay -ge 0)
{
  Write-Host "Seconds Remaining: $($delay)"
  start-sleep 1
  $delay -= 1
}

Write-Host "Checking our work.. "
#$getMailboxpermissions = Get-MailboxPermission -Identity $mailbox -User $requestersMailbox
#Write-Output ($getMailboxpermissions)

$scriptSession = Read-Host -Prompt "Would you like to end the session? (Y/N)"

if ($scriptSession -eq "Yes" -or $scriptSession -eq "Y") {
    Remove-PSSession $Session
    Write-Host "Session is now ended"
    }
elseif ($scriptSession -eq "No" -or $scriptSession -eq "N") {
    Write-Output "We have work to do! Go AGANE!"
    $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
    Invoke-Expression -Command $scriptToRun
    break
    }
else {
    Write-Host "Answer was unclear, type LOUDER"
    $scriptSession = Read-Host -Prompt "Would you like to end the session? (Y/N)"
    $scriptSession
}