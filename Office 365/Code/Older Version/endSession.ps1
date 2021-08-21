differentName.ps1

$scriptSession = Read-Host -Prompt "Would you like to end the session? (Y/N)"

if ($scriptSession -eq "Yes" -or "Y") {
    #Remove-PSSession $Session
    Write-Host "Session is now ended"
    }
elseif ($scriptSession -eq "No" -or "N") {
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