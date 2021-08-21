$accessRights = Read-Host "Which Number"

Switch ($accessRights) {
    1 {
        Write-Host "Which recipient do we need Full Access " -NoNewline; Write-Host -ForegroundColor Red "From " -NoNewline; Write-Host "(username@domain.com or Firstname Lastname)"
        $userMailbox = Read-Host
        Write-Host "Who needs this Full Access permission applied " -NoNewline; Write-Host -ForegroundColor Red "To " -NoNewline; Write-Host "their mailbox (username@domain.com or Firstname Lastname)"
        $requestersMailbox = Read-Host

    $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
        do {
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                #Add-MailboxPermission -Identity "$mailbox" -User "$requestersMailbox" -AccessRights FullAccess
            break
        }
        else {
            $message = "Unfortunately Exchange was unable to find the mailbox. Check that provided user information is correct or is not deleted."
            $runUsernameCheck
        }
}
        while ($true)
    }
    Default {
        Write-Output """$accessRights"" Is an incorrect input. Please choose again"
        $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
        Invoke-Expression -Command $scriptToRun
        break
    }

}

Write-Host $accessRights