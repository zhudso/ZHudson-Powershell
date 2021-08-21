$userConfirmation = do {

    Read-Host -Prompt "Are there any errors on screen? (Y/N)"

if ($userConfirmation -eq "No" -or $userConfirmation -eq "N") {
    Write-Host "Lets proceed.."
    break
    }
else {
    Write-Host "Unfortunately Exchange was unable to find the mailbox. Please check & re-enter emails"
    $userConfirmation = Read-Host -Prompt "Are there any errors on screen? (Y/N)"
    }
}
while ($true)


#------------------------------------------------------------------------
#Previous configuration
#------------------------------------------------------------------------

$runUsernameCheck =  Do 
{
Try
{
    <# !!!!!!!! NEED TO CHANGE TO EAC !!!!!!!! Check if it's in AD #>
    $checkMailbox = Get-ADUser -Identity $getMailbox -ErrorAction Stop
    Write-Host "Found "$getMailbox"!"
    $checkRequestersMailbox = Get-ADUser -Identity $getRequestersMailbox -ErrorAction Stop
    Write-Host "Found "$getRequestersMailbox"!"
}
Catch
{
    # Warning Message
    Write-Warning -Message "Could not find a user with the username: $getMailbox. Please check the spelling and try again."

    # Loop de loop (Restart)
    $getUsername = $null
}
}
While ($getUsername -eq $null)