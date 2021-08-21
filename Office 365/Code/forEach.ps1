try {
     
    # Exchange cmdlets do not pay attention to the -ErrorAction parameter,
    # but they do pay attention to $ErrorActionPreference.
    # Capture the old $ErrorActionPreference first as we should set it back once done.
    $ErrorActionPreferenceOld = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
     
    $Mailbox = Get-Mailbox -Identity $Identity
 
    # Double check that we have actually obtained an Mailbox.
    if ($Mailbox) {
        $MailboxFound = $true
    } else {
        $MailboxFound = $false
    } #end else
  
} catch [System.Management.Automation.RemoteException] {
  
    # We may need this message for later.    
    $MailboxError = $_.Exception.Message
    $MailboxErrorRegex = "^The operation couldn't be performed because object '.*' couldn't be found on '.*'\.$"
 
    if ($MailboxError -match $MailboxErrorRegex) {
        # We can handle a mailbox not found, so no need to throw.
        $MailboxFound = $false
    } else {
        # We don't (yet) know how to handle this error, so rethrow for the user to see.
        throw
    } #end else
  
} finally {
 
    # Set $ErrorActionPreference back to its previous value.
    $ErrorActionPreference = $ErrorActionPreferenceOld
 
} #end finally