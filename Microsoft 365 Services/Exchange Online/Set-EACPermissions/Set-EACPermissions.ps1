
<# -------------- START OF SCRIPT -------------- #>

<# Checking for Active Session, if False, then start a new one and loop until successful sign in. #>
if ($activeSession -eq "True") {
    $number = $null
    $userMailbox = $null
    $requestersMailbox = $null
} else {
    <# Open Powershell as Administrator #>
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

    <# Connect to EAC. #>
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $Session -AllowClobber

    <# Confirm successful login. #>
    do {$sessionURL = $session | select ComputerName | Select-String outlook.office365.com
        $sessionState = $session | select State | Select-String Opened
    if ($sessionState -match "@{State=Opened}" -and $sessionURL -match "@{ComputerName=outlook.office365.com}") {
        $activeSession = "True"
        <# Clear screen #>
        cls
        break }
    else {

    <# Re-run logon block for another sign in attempt #>
    Write-Host -ForegroundColor Yellow "Check that Credentials are valid and or not expired"
    $successfulLogon = $null
    $UserCredential = $null
    $UserCredential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $Session
    }
    }
while ($successfulLogon -eq $null)
    }

<# Welcome Message #>
$number = Read-Host "
You can cancel the script at any time with Ctrl C Twice

Configuration Options
---------------------------
1. Full Access
2. Send As
3. Send on Behalf
4. Email Forwarding
5. Distribution Groups
6. Converting to a Shared Mailbox
---------------------------
Number"

Switch ($number) {
    1 { <# Full Access #>
        do {
        $number = "Full Access"

        <# Requesting if we need to add or remove permissions. #>
        $configurationType = Read-Host "Add or Remove Access? (Add/Remove)"

            <# ADD: Gathering user account information.. #>
            if ($configurationType -eq "Add" -or $configurationType -eq "Adding" ){
            Write-Host "Which recipient do we want Full Access " -NoNewline; Write-Host -ForegroundColor Red "From "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            Write-Host "Who wants this Full Access permission applied " -NoNewline; Write-Host -ForegroundColor Red "To "
                $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            
            <# Checking that both users are valid #>
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"

            <# Applying the "Add/Adding" configuration #>
                if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                    Write-Host -ForegroundColor Yellow "Adding mailbox access.."
                        Add-MailboxPermission -Identity $userMailbox -User $requestersMailbox -AccessRights FullAccess
                            Write-Host -ForegroundColor Green "Please allow Microsoft 12 - 24 hrs & Outlook to be restarted before $requestersMailbox see's $userMailbox mailbox in Outlook"
                break
                }
            }
            <# REMOVE: Gathering user account information.. #>
            elseif ($configurationType -eq "Remove" -or $configurationType -eq "Removing" ){
            Write-Host "Which mailbox do we already have Full Access " -NoNewline; Write-Host -ForegroundColor Red "To "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            Write-Host "Who wants this Full Access permission removed " -NoNewline; Write-Host -ForegroundColor Red "From "
                $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Checking that previous permissions were configured to remove. #>
            Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "MESSAGE: Pulling previous access.. if nothing comes back then there are currently no mailbox permissions to remove"
                Get-MailboxPermission -Identity $userMailbox -User $requestersMailbox | Select-Object AccessRights

            <# Confirming that both users are valid and previous access is actually configured. #>
             $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users and confirm previous access? (Y/N)"
 
            <# Removing permission #>
                if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                    Write-Host -ForegroundColor Yellow "Removing Mailbox Access.."
                        Remove-MailboxPermission -Identity $userMailbox -User $requestersMailbox -AccessRights FullAccess -Confirm:$false
                            Write-Host -ForegroundColor Green "Completed"
                break
                }
            }
        else {Write-Host -ForegroundColor Red "Invalid Input."}
        }
        while ($true)     
    }
    2 {  <# Send As #>
        do {
        $number = "SendAs"

        <# Requesting if we need to add or remove permissions. #>
        $configurationType = Read-Host "Add or Remove Access? (Add/Remove)"

            <# ADD: Gathering user account information.. #>
            if ($configurationType -eq "Add" -or $configurationType -eq "Adding") {
            Write-Host "Which recipient do we want Send As " -NoNewline; Write-Host -ForegroundColor Red "From "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            Write-Host "Who wants this Send As permission applied " -NoNewline; Write-Host -ForegroundColor Red "To "
                $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Checking that both users are valid #>    
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"

            <# Applying the "Add/Adding" configuration #>
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                Write-Host -ForegroundColor Yellow "Granting Send As permissions.."
                    Add-RecipientPermission -Identity $userMailbox -AccessRights $number -Trustee "$requestersMailbox" -Confirm:$false
            break
                }
            }
            <# REMOVE: Gathering user account information.. #>
            elseif ($configurationType -eq "Remove" -or $configurationType -eq "Removing") {
            Write-Host "Which mailbox do we already have Send As " -NoNewline; Write-Host -ForegroundColor Red "To "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            Write-Host "Who wants this Send As permission removed " -NoNewline; Write-Host -ForegroundColor Red "From "
                $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Pulling previous access rights.. #>
            Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling previous access.. if nothing comes back then there are currently no mailbox permissions to remove"
                Get-RecipientPermission -Identity $userMailbox -Trustee $requestersMailbox

            <# Confirming that both users are valid and previous access is actually configured. #>
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users and confirm previous access? (Y/N)"

            <# Removing Permission #>
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                Write-Host -NoNewline; Write-Host -ForegroundColor Yellow  "Removing Send As permissions.."
                    Remove-RecipientPermission $userMailbox -AccessRights $number -Trustee "$requestersMailbox" -Confirm:$false
                        Write-Host -ForegroundColor Green "Completed."
            break
            }          
            } 
            {Write-Host "Invalid Input."}
        }
        while ($true)
    }
    3 { <# Send on Behalf #>
        do {
            $number = "Send on Behalf"

            <# Requesting if we need to add or remove permissions. #>
            $configurationType = Read-Host "Add or Remove Access? (Add/Remove)"

            <# ADD: Gathering user account information.. #>
            if ($configurationType -eq "Add" -or $configurationType -eq "Adding") {
            Write-Host "Which recipient do we want Send on Behalf " -NoNewline; Write-Host -ForegroundColor Red "From "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType            
            Write-Host "Who want this Send on Behalf permission applied " -NoNewline; Write-Host -ForegroundColor Red "To "
                $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Checking that both users are valid #>   
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"

            <# Applying the "Add/Adding" configuration #>
                if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                    Write-Host "Granting Send on Behalf permissions.."
                        Set-Mailbox -Identity $userMailbox -GrantSendOnBehalfTo @{Add=$requestersMailbox}
                    Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling new permissions"
                        Get-Mailbox -Identity $userMailbox | Format-List DisplayName,GrantSendOnBehalfTo
                break
                }
            }
            <# REMOVE: Gathering user account information.. #>
            elseif ($configurationType -eq "Remove" -or $configurationType -eq "Removing") {
                Write-Host "Which mailbox do we already have Send on Behalf " -NoNewline; Write-Host -ForegroundColor Red "To "
                    $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                        Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
                Write-Host "Who wants this Send on Behalf permission removed " -NoNewline; Write-Host -ForegroundColor Red "From "
                    $requestersMailbox = Read-Host "Email, Username or Firstname Lastname "
                        Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
        
                <# Pulling previous access rights.. #>
                Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling previous access.. if nothing comes back then there are currently no mailbox permissions to remove"
                    Get-Mailbox -Identity $userMailbox | Select-Object DisplayName, GrantSendonBehalfTo | fl
        
                <# Confirming that both users are valid and previous access is actually configured. #>
                    $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users and confirm previous access? (Y/N)"
        
                <# Removing Permission #>
                    if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                        Write-Host -NoNewline; Write-Host -ForegroundColor Yellow  "Removing Send on Behalf permissions.."
                            Set-Mailbox -Identity $userMailbox -GrantSendOnBehalfTo @{Remove=$requestersMailbox}
                        Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling new permissions"
                            Get-Mailbox -Identity $userMailbox | Format-List DisplayName, GrantSendOnBehalfTo
                    break
                    }
            }
            else {Write-Host "Invalid Input."}
    } while ($true)
    }
    4 { <# Email Forwarding #>
        do {
            $number = "Email Forwarding"

            <# Requesting if we need to add or remove permissions. #>
            $configurationType = Read-Host "Add or Remove Access? (Add/Remove)"
            
            <# ADD: Gathering user account information.. #>
            if ($configurationType -eq "Add" -or $configurationType -eq "Adding") {
            Write-Host "Which mailbox do we want to receive emails " -NoNewline; Write-Host -ForegroundColor Red "From "
                $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                    Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType        
            Write-Host "Who wants $userMailbox emails. " -NoNewline; Write-Host -ForegroundColor Red "Must be an Email (EG: user@domain.com)"
                Write-Host -ForegroundColor Yellow "Email: " -NoNewline; $requestersMailbox = Read-Host
                    Get-Mailbox $requestersMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType
            $userConfirmation = Read-Host -Prompt "Was Exchange able to locate the both users? (Y/N)"
                if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                    Set-Mailbox -Identity "$userMailbox" -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "$requestersMailbox"
                    Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling new changes.."
                        Get-Mailbox -Identity "$userMailbox" | select DisplayName, ForwardingSMTPAddress, DeliverToMailboxAndForward
                    break
                }
            }    
            <# REMOVE: Gathering user account information.. #>
            elseif ($configurationType -eq "Remove" -or $configurationType -eq "Removing") {
                Write-Host "Which mailbox do we want to stop receiving emails " -NoNewline; Write-Host -ForegroundColor Red "From "
                    $userMailbox = Read-Host "Email, Username or Firstname Lastname "
                        Get-Mailbox $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Pulling previous access rights.. #>
            Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "MESSAGE: Pulling previous access.. Please confirm if user is listed"
                Get-Mailbox -Identity $userMailbox | Select ForwardingSMTPAddress,DeliverToMailboxAndForward

            <# Confirming that both users are valid and previous access is actually configured. #>
            Write-Host -ForegroundColor Yellow "Was Exchange able to locate the user and show email forwarding is configured? (Y/N)" -NoNewline; $userConfirmation = Read-Host

            <# Removing the fowarding rule from mailbox #>
            if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                Write-Host -NoNewline; Write-Host -ForegroundColor Yellow  "Removing Forwarding permissions.."
                    Set-Mailbox -Identity $userMailbox -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $null
                Write-Host -NoNewline; Write-Host -ForegroundColor Green  "Completed."
                    Get-Mailbox -Identity $userMailbox | select DisplayName, DeliverToMailboxAndForward, ForwardingSMTPAddress
            break}
            }
            else {Write-Host "Invalid Input."}
    } while ($true) 
    }
    5 { <# Distribution Grous #>
        do {
            $configurationType = Read-Host "
Which would you like to do?
-----------------------------------------
1. Add Members to an existing group
2. Remove Members from an exisiting group
3. Add a new Distribution Group
4. Remove a Distribution Group
-----------------------------------------
Number"

            <# Add Members to an existing group #>
            if ($configurationType -eq "1") {
                Write-Host -ForegroundColor Yellow "Pulling all distribution groups.."
                    Get-DistributionGroup | select Name,PrimarySmtpAddress
                        $distroGroup = Read-Host "Which group do we want to be added to?"
                Write-Host `n -ForegroundColor Green "You can add multiple users with , between each user."
                Write-Host -ForegroundColor Yellow "Username or Email: " -nonewline; $requestersMailbox = Read-Host

                <# Find each user with , and remove spacing#>
                $requestersMailbox | ForEach-Object {
                    $RequestersMailbox = $requestersMailbox.Replace(" ", "") -split ","

                    <# Loop through each user that is divied by , #>    
                        foreach ($requestersMailbox in $RequestersMailbox) {
                            try {Add-DistributionGroupMember -id $distroGroup -Member $requestersMailbox -ea Continue}
                                catch {
                                    Write-Host -ForegroundColor Red "$requestersMailbox failed, user may already be added or invalid Username or Email"
                                    break
                                finally {
                                    Write-Host -ForegroundColor Green "Processed: " -NoNewline; $requestersMailbox
                                }
                                }
                        }   <# foreach end #>
                    Write-Host -ForegroundColor Yellow "Current users in $distroGroup"
                    Get-DistributionGroupMember -id $distroGroup | Select-Object Name,PrimarySMTPAddress
               break }  <# ForEach-Object End #>
            }   <# If Add Members to group End #>
            
            <# Remove Members from an exisiting group #>
            elseif ($configurationType -eq "2") {
                Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Pulling a list of distribution groups.."
                    Get-DistributionGroup | select Name
                        $distroGroup = Read-Host "Which group do we want to be removed from?"
                        
                Write-Host -NoNewline; Write-Host -ForegroundColor Yellow "Current list of users in $distroGroup"
                    Get-DistributionGroupMember -id $distroGroup | select Name
                    
                Write-Host `n -ForegroundColor Green "You can remove multiple users with , between each user."    
                $requestersMailbox = Read-Host "Who wants to be removed from $distroGroup. "
                $requestersMailbox | ForEach-Object {
                $RequestersMailbox = $requestersMailbox.Replace(" ", "") -split ","
                    
                <# Loop through each user that is divied by , #>
                foreach ($requestersMailbox in $RequestersMailbox) {
                    try {Remove-DistributionGroupMember -id $distroGroup -Member $requestersMailbox -Confirm:$false -ea Continue}
                        catch {
                            Write-Host -ForegroundColor Red "$requestersMailbox failed, user may already be added or invalid Username or Email"
                            break
                        }
                    Write-Host -ForegroundColor Green "Processed: " -NoNewline; $requestersMailbox       
                } <# foreach end #>
                Write-Host -ForegroundColor Yellow "Current users in $distroGroup"
                Get-DistributionGroupMember -id $distroGroup | Select-Object Name,PrimarySMTPAddress
                break }
            }
            <# Add a new Distribution Group #>
            elseif ($configurationType -eq "3") {

                <# Required Input Questions #>
                $distroGroup = Read-Host "What would you like the name of the group to be?"
                $distroGroupEmail = Read-Host "What would you like the email address to be for this group?"
                Write-Host "Creating $distroGroup.."
                    New-DistributionGroup -Name $distroGroup -PrimarySmtpAddress $distroGroupEmail -Type Distribution | Select-Object Name,PrimarySMTPAddress,RequireSenderAuthenticationEnabled

                Write-Host -ForegroundColor Yellow "MESSAGE: Would you like this $distroGroup to receive emails from External Senders? (Y/N): " -NoNewline; $userConfirmation = Read-Host
                    <# Disallowing/Allowing External Emails to be received#>
                        if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                            Set-DistributionGroup -id $distroGroup -RequireSenderAuthenticationEnabled $False
                            }
                        elseif ($userConfirmation -eq "No" -or $userConfirmation -eq "N") {
                            break <# This is set by default #>
                        }
                        else {Write-Host -ForegroundColor Red "Invalid Input"}

                Write-Host -ForegroundColor Yellow "Add users to this new distribution group? (Y/N) " -NoNewline; $addingUsers = Read-Host
                <# Adding users to the new group #>
                if ($addingUsers -eq "Y" -or $addingUsers -eq "Yes") {
                    Write-Host -ForegroundColor Green "You can add multiple users with , between each user."
                    Write-Host -ForegroundColor Yellow "Username or Email: " -nonewline; $requestersMailbox = Read-Host
                    <# Loop through each user #>
                    $requestersMailbox | ForEach-Object {
                        $RequestersMailbox = $requestersMailbox.Replace(" ", "") -split ","
                        foreach ($requestersMailbox in $RequestersMailbox) {
                            try {Add-DistributionGroupMember -id $distroGroup -Member $requestersMailbox -Confirm:$false -ea Continue}
                                catch {
                                    Write-Host -ForegroundColor Red "$requestersMailbox failed, user may already be added or invalid Username or Email"
                                    break
                                }
                            Write-Host -ForegroundColor Green "Processed: " -NoNewline; $requestersMailbox   
                        } <# foreach end #>
                    }<# ForEach-Object end #>
                Write-Host -ForegroundColor Yellow "Providing distribution group members.."
                Get-DistributionGroupMember -id $distroGroup | Select-Object Name,PrimarySMTPAddress 
                break
                }<# if statement end #>
                elseif ($addingUsers -eq "N" -or $addingUsers -eq "No") {
                    Write-Host "No users will be added."
                    break
                }
                else {
                    Write-Host "We've hit the else statement"
                    break
                }
            }
            <# Remove a Distribution Group #>
            elseif ($configurationType -eq "4") {
                Write-Host -ForegroundColor Yellow "Pulling a list of current Distribution Groups.."
                Get-DistributionGroup | select Name,PrimarySMTPAddress
                Write-Host -ForegroundColor Yellow "What is the name/email of the group that we want to remove? " -NoNewLine; $distroGroup = Read-Host
                Get-DistributionGroup -id $distroGroup | select Name,PrimarySmtpAddress -ErrorAction Continue

            Write-Host -ForegroundColor Yellow "Are you sure you want to remove this group and it's members? (Y/N): " -NoNewline; $userConfirmation = Read-Host 
                if ($userConfirmation -eq "Yes" -or $userConfirmation -eq "Y") {
                    Write-Host -nonewline; Write-Host -ForegroundColor Yellow "Removing $distroGroup and its members.."
                        Remove-DistributionGroup -id $distroGroup -Confirm:$false -ea Continue
                    break
                }
            else {Write-Host -ForegroundColor Red "Invalid Input"}          
            }
    } while ($true)
    } 
    6 { <# Shared Mailbox #>
        do {
            <# Gathering user account information.. #>
            Write-Host -ForegroundColor Yellow "Which mailbox do we want to convert to shared? " -NoNewLine; $userMailbox = Read-Host
                Get-Mailbox -id $userMailbox | Select-Object Name,PrimarySMTPAddress,RecipientType

            <# Convermation that the mailbox is found #>
            Write-Host -ForegroundColor Yellow "Was Exchange able to locate the user account? (Y/N): " -NoNewLine; $userConfirmation = Read-Host

            <# Coverting to Sharedmailbox.. #>
            if ($userConfirmation -eq "Y" -or $userConfirmation -eq "Yes") {
                Write-Host -ForegroundColor Yellow "Configuring to sharedmailbox.."
                    Set-Mailbox -id $userMailbox -Type Shared
                Write-Host -ForegroundColor Green "Completed, waiting for new changes to reflect.."
                <# Setting 10 Sec Timer to reflect the new changes #>
                $delay = 10
                while ($delay -ge 0) {
                    Write-Host "Seconds Remaining: $($delay)"
                    start-sleep 1
                    $delay -= 1
                }
                    Get-Mailbox -Id $userMailbox | Select Name,Isshared
                break
            if ($userConfirmation -eq "No" -or $userConfirmation -eq "N") {
                break
            }

            } else {Write-Host -ForegroundColor Red "Invalid Input."}
        } while($true)

    }
    7 {  <# On-boarding #>
        <# $scriptToOpen = $psScriptRoot+"\Onboarding_Script.ps1"
        Invoke-Expression -Command $scriptToOpen #>
    exit
    }
    8 { <# Off-boarding #>
        <# $scriptToOpen = $psScriptRoot+"\Offboarding_Script.ps1"
        Invoke-Expression -Command $scriptToOpen #>
    exit
    }
    Default {      
    }
}

<# End Session or keep alive #>
do {
    Write-Host -ForegroundColor Yellow "Would you like to end this session? (Y/N)"
    $scriptSession = Read-Host "Input"

if ($scriptSession -eq "Yes" -or $scriptSession -eq "Y") {
    Remove-PSSession $Session
        break
    }
elseif ($scriptSession -eq "No" -or $scriptSession -eq "N") {
    cls
    $successfulLogon = "Yes"
    $scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
        Invoke-Expression -Command $scriptToRun
    break
    }
else {Write-Host "Answer was unclear, type LOUDER"}
} while ($true)
