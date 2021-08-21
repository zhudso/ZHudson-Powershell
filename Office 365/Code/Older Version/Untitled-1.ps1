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
#Possibly include a progress bar? https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress?view=powershell-7

<# Open Powershell as Administrator #>
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
    }

<# Set the executionPolicy to Unrestrited while the script is running, It'll switch back to what was configured previously after the session ends. #>
Set-ExecutionPolicy Unrestricted -Scope Process
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

<# Re-Run credential prompt if unsuccessful login. #>
do {$userConfirmation = Read-Host -Prompt "Successful Login? (Y/N)"

if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
    $userConfirmation = $null
    break
    }
else {
    Write-Host "Check that Credentials are valid and or not expired"
    $userConfirmation = $null
    $UserCredential = $null
    $UserCredential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    }
}
while ($userConfirmation -eq $null)

<# Welcome Message #>
$number = Read-Host "
Welcome to my EAC Powershell Script: Written by Zach Hudson

You can cancel the script at any time with Ctrl C

Configuration
---------------------------
1. Full Access
2. Send As
3. Send on Behalf
4. Email Forwarding
5. Distribution Groups
6. Calendars
7. Public Folders
8. Public Folders Mailbox
---------------------------
Number"

$OldPref = $global:ErrorActionPreference
$global:ErrorActionPreference = 'Stop'

Switch ($number) {
    1 {
        do {
        $number = "FullAccess"
        Write-Host "Which recipient do we need Full Access " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or Firstname Lastname)"
            $userMailbox = Read-Host
            $OldPref = $global:ErrorActionPreference
            $global:ErrorActionPreference = 'Continue'
            $getUserMailbox = Get-Recipient $userMailbox
        Write-Host "Who needs this Full Access permission applied " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or Firstname Lastname)"
            $requestersMailbox = Read-Host
            $getRequestersMailbox = Get-Recipient $requestersMailbox
        $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                #Add-MailboxPermission -Identity "$userMailbox" -User "$requestersMailbox" -AccessRights $number
            break
        } else {
            Write-Host "Unfortunately Exchange was unable to find the mailbox. Check that provided user information is correct or is not deleted."
        }
}
        while ($true)        
    }
    
    2 {  
        do {
            $number = "SendAs"
            Write-Host "Which recipient do we need Send As " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or Firstname Lastname)"
                $userMailbox = Read-Host
                $getUserMailbox = Get-Recipient $userMailbox
                Write-Host $getUserMailbox
            Write-Host "Who needs this Send As permission applied " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or Firstname Lastname)"
                $requestersMailbox = Read-Host
                $getRequestersMailbox = Get-Recipient $requestersMailbox
                Write-Host $getRequestersMailbox
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                #Add-RecipientPermission $mailbox -AccessRights $number -Trustee "$requestersMailbox"
            break
        }
        else {
            Write-Host "Unfortunately Exchange was unable to find the mailbox. Check that provided user information is correct or is not deleted."
        }
}
        while ($true)
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
        Write-Output """$number"" Is an incorrect input. Please choose again"
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
    $global:ErrorActionPreference = $OldPref
    #Remove-PSSession $Session
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
