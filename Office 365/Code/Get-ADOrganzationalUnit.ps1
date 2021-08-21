do {
    $OUpath = 'OU=HudsonComputers,DC=hudson,DC=test,DC=com'
        if (object in $OUpath) {
        $OUgroup = Get-ADOrganizationalUnit -filter * -SearchBase $OUpath | Select-Object Name | Out-String
        $computer = Get-ADComputer -Filter * -SearchBase $OUpath | Select-object Name | Out-String
        write-host "OU: $OUgroup"
        Write-Host "Computer: $computer"
            else {
                Write-Host "RIP, here's an else statement"
            }
        }    
    } while($true)