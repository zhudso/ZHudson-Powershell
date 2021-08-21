#Future Updates.
#-----------------------
#Create an AD Test environment: https://azure.microsoft.com/en-us/free/?ref=portal
#Open Powerhsell as Administrator - Completed.
#Connect to EAC with new authenctation built in the script.
#Provided numbered choices to the user to enter to prevent misspellings. -Completed.
#Add other functions, like email forwarding and auto reply
#Change if, elseif, else to switch statements. - Completed.
#Distribution Group stuff
#Keep the session open to run multiple commands and then end the session -Completed
#Retrieve information (What does this user have access to)
#Offboarding steps
#Pause the script to make sure that there isn't an error, prompt the user for yes or no -Completed.
#Call another file to open On-boarding or Off-boarding script.
#Provide default file save location that creates a unique file name ($exportCSV = $psScriptRoot+"\mailboxPermissions.ps1")
#compromised accounts, checking for inbox rules, email forwarding. 

#Open Powershell as Administrator
#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    #Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
    #}

#Set the executionPolicy to Unrestrited while the script is running, It'll switch back to what was configured previously after the session ends.
#Set-ExecutionPolicy Unrestricted -Scope Process
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session

#Need to investigate further into EAC error handleing. From what I've found it's a nightmare..
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

Switch ($accessRights) {
    1 {
        Write-Host "Which recipient do we need Full Access " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or Firstname Lastname)"
            $mailbox = Read-Host
        Write-Host "Who needs this Full Access permission applied " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or Firstname Lastname)"
            $requestersMailbox = Read-Host
        #ADD Get-recipient -identity $mailbox
        #ADD Get-recipient -identity $requestersMailbox    

## Not sure if this will work in EAC but it's worth investigating further: https://stackoverflow.com/questions/32594757/restart-the-currently-running-script   
## Need to investigate further into EAC error handleing. From what I've found it's a nightmare..
    $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
        do {
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                #Add-MailboxPermission -Identity "$mailbox" -User "$requestersMailbox" -AccessRights FullAccess
            break
        }
        else {
            Write-Host "Unfortunately Exchange was unable to find the mailbox. Check that provided user information is correct or is not deleted."
            $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
            Invoke-Expression -Command $scriptToRun
        }
}
        while ($true)
        
    }
    2 {
        Write-Host "Which recipient do we need Send As " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or Firstname Lastname)"
            $mailbox = Read-Host
        Write-Host "Who needs this Send As permission applied " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or Firstname Lastname)"
            $requestersMailbox = Read-Host
        #ADD Get-recipient -identity $mailbox
        #ADD Get-recipient -identity $requestersMailbox

## Need to investigate further into EAC error handleing. From what I've found it's a nightmare..    
    $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
        do {
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                #Add-RecipientPermission $mailbox -AccessRights SendAs -Trustee "$requestersMailbox"
            break
        }
        else {
            Write-Host "Unfortunately Exchange was unable to find the mailbox. Check that provided user information is correct or is not deleted."
            $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
            Invoke-Expression -Command $scriptToRun
        }
}
        while ($true)
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

#validate provided information is correct.
#Write-Host "Checking for correct inputs.."
#Get-Recipient -Identity $mailbox

#$userConfirmation = Read-Host -Prompt "Are there any errors? (Y/N)"
#do {

#if ($userConfirmation -eq "No" -or $userConfirmation -eq "N") {
<#     Write-Host "Lets proceed.."
    break
    }
else {
    Write-Host "Unfortunately Exchange was unable to find the mailbox. Please check & re-enter emails"
    $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
    Invoke-Expression -Command $scriptToRun
    }
}
while ($true)
 #>

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
    Remove-PSSession -ComputerName outlook.office365.com
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