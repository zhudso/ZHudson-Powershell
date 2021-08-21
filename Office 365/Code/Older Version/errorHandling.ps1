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