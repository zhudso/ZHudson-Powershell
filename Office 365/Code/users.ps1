            <# Add Members to an existing group #>
            if ($configurationType -eq "1") {
                Write-Host -ForegroundColor Yellow "Pulling all distribution groups.."
                    Get-DistributionGroup | select DisplayName,PrimarySmtpAddress
                        $distroGroup = Read-Host "Which group do we want to be added to?"
                Write-Host -ForegroundColor Green `n "You can add multiple users with , between each user."
                Write-Host "Who wants to be added to $distroGroup. Must be " -NoNewline; Write-Host -ForegroundColor Yellow "Username or Email: " -nonewline; $requestersMailbox = Read-Host
                    $requestersMailbox | ForEach-Object {
                        $RequestersMailbox = $requestersMailbox.Replace(" ", "") -split ","

                do {
                    if ($requestersMailbox) {
                        <# Loop through each user that is divied by , #>
                        foreach ($requestersMailbox in $RequestersMailbox) {
                            try { Add-DistributionGroupMember -id $distroGroup -Member $requestersMailbox -ErrorAction}
                                catch {
                                    Write-Host -ForegroundColor Red "$requestersMailbox failed, user may already be added or invalid Username or Email"
                                    break
                                }
                            Write-Host -ForegroundColor Green "Completed $requestersMailbox"        
                        }
                    Write-Host "Pulling list of current users in $distroGroup"
                    Get-DistributionGroupMember -id $distroGroup | Select-Object DisplayName,PrimarySMTPAddress
                    }
                    else {Write-Host -ForegroundColor Green "Where " -NoNewline; write-host -ForegroundColor Cyan "are " -NoNewline; Write-Host -ForegroundColor Magenta "we?"}
                } until ($RequestersMailbox -eq $null)
            }
            }