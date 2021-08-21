$configurationType = Read-Host "
Which would you like to do?
-----------------------------------------
1. Add Members to an existing group
2. Remove Members from an exisiting group
3. Add a new Distribution Group
4. Remove a Distribution Group
-----------------------------------------
Number"

if ($configurationType -eq "1") {
    <# Write-Host -ForegroundColor Yellow "Pulling all distribution groups.." #>
        <# Get-DistributionGroup | select DisplayName,PrimarySmtpAddress #>
    $distroGroup = Read-Host "Which group do we want to be added to?"
        <# Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Checking for Distribution Group.." #>
        <# Old get-distributgroup placement. #>
    Write-Host "Who wants to be added to $distroGroup. "
        $requestersMailbox = Read-Host
        $requestersMailbox -split ","
            <# Get-Mailbox $RequestersMailbox | Select-Object DisplayName,PrimarySMTPAddress,RecipientType #>

        if ($requestersMailbox) {
            foreach ($requestersMailbox in $requestersMailbox) {
               Write-Host $requestersMailbox
                Write-Host -ForegroundColor Green "Completed."
                break
            }
        break }
        else {Write-Host -ForegroundColor -Red "Invalid Input"}
    }