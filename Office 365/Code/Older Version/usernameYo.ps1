$OldPref = $global:ErrorActionPreference
$global:ErrorActionPreference = 'Stop'
$getUsername1 = Read-Host -prompt "Whats your username"

Do {
try {    
    $checkUsername = whoami -ErrorAction Stop
    }   
catch {
    Write-Warning -Message "Could not find a user with the username: $getUsername1. Please check the spelling and try again."
    # Loop de loop (Restart)
    $getUsername1 = $null
    }   
}
while ($getUsername -eq $null)
$global:ErrorActionPreference = $OldPref


<# $message = "Whats the username in question"

Do
{
    # Get a username from the user
    $getUsername = Read-Host -prompt $message

    Try
    {
        # Check if it's in AD
        $checkUsername = Get-ADUser -Identity $getUsername -ErrorAction Stop
        Write-Host "Successful entry!!"
    }
    Catch
    {
        # Couldn't be found
        Write-Warning -Message "Could not find a user with the username: $getUsername. Please check the spelling and try again."

        # Loop de loop (Restart)
        $getUsername = $null
    }
}
While ($getUsername -eq $null) #>