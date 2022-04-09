<#
.SYNOPSIS
        Takes pipeline or written input and appends to a file.
    .DESCRIPTION
        This function will take mutiple or single pipleline inputs and or written input and appends to a folder/file path that you (optionally) can define.
        -PipeLine Value: (optional) Takes one or more values stored from the Pipeline and stores it to a file.
        -Message: (optional) Creates a message you define
            You can write multiple messages at once with , (Get-Help Write-Notes -Examples) for more information.
        -FolderPath: (optional) Default folder path: $env:userprofile\desktop
        -FileName: (optional) Default file name: Offboarding Notes.txt
    .EXAMPLE
        Pipeline Example: Get-WmiObject -Class Win32_Processor -ComputerName $env:COMPUTERNAME | Write-Notes -FileName CPUInfo -FilePath $env:userprofile\Desktop\
        Written  Example: Write-Notes -Message "$env:COMPUTERNAME system information", "Home Drive: $env:HOMEDRIVE", "Logon Server: $env:LOGONSERVER" -FilePath $env:USERPROFILE\Desktop -FileName "$env:COMPUTERNAME Information"
    .NOTES
        FunctionName    : Write-Notes
        Created by      : Zach Hudson
        Date Coded      : 03/11/2021
        Modified by     : Zach Hudson
        Date Modified   : 04/07/2022
#>
function Write-Notes{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)] $pipeValue,
        [Parameter()] $Message,
        [Parameter()] $FolderPath = "$env:USERPROFILE\Desktop\User Offboarding Notes",
        [Parameter()] $FileName = "$($User.Name) - Notes"
    )
    begin {
        <# Create the folder structure for storing notes "actions taken to offboard the user" and a backup of the security groups. #>
            $fullPath = Join-Path -Path $FolderPath -ChildPath $($User.Name)
            $testPath = Test-Path -Path $fullPath
            $FolderPath = $fullPath
                if ($testPath) {
                    <#Do nothing, continue through script#>
                }
                else {
                    $FolderPath = New-Item -ItemType Directory -Path $fullPath
                }
        }
    process {
        <# Take each item in the pipeline and write it out to a file. #>
        foreach ($pValue in $pipeValue) {
            $pValue | Out-File "$FolderPath\$FileName.txt" -Append
        }
    }
    end {
        <# Take the -message parameter and append the message to the file. #>
        $Message | Out-File "$FolderPath\$FileName.txt" -Append
    }
}
function Backup-User {
    <# Show Original Object Location #>
    $ObjectLocation = Get-ADUser -identity $User -Properties CanonicalName | select-object -ExpandProperty CanonicalName
    Write-Notes -Message "Original Object location: $ObjectLocation"
    $UserEmailAddress = Get-ADUser -id $User -Properties * | Select-Object -ExpandProperty UserPrincipalName
    Write-Notes -Message "Users Email Address: $UserEmailAddress"
    <# Backup the current groups to the desktop in a .txt file #>
    Get-ADPrincipalGroupMembership -Identity $User | Select-Object -ExpandProperty Name | Write-Notes -FileName "Group Memberships"
    Write-Notes -Message "Saved copy of Active Directory Groups to $env:USERPROFILE\Desktop\User Offboarding Notes"
}
function Set-Password {
    <# Generates a new 14 character password. 14-character password with the complexity of 5 then add a random number at the end. #>
    Add-Type -AssemblyName System.Web
    $NewPassword = [System.Web.Security.Membership]::GeneratePassword(14,5)
    $NewPassword += Get-Random -Maximum 10
    Write-Notes -Message "Changed user password to: $NewPassword"
    Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
}
function Move-User {
    $currentOU = Get-ADUser -identity $user -Properties CanonicalName | select-object -expandproperty DistinguishedName
    $disabledOU = Get-ADOrganizationalUnit -Filter 'Name -like "* - Mailbox Retention"'
    try {
        Move-ADObject -Identity "$currentOU" -TargetPath "$disabledOU"
        Write-Notes -Message "Moved $User to $disabledOU"
    }
    catch {
        Write-Warning "Unable to move user account. There are multiple or no OU's found on the search condition of 'Mailbox Retention'. Please manually move the user to a Disabled Users OU"
    }
}

function Remove-DistributionGroups {
    $ADGroups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object {$_.Name -ne "Domain Users"} | Select-Object -ExpandProperty Name
    try {
        foreach ($ADG in $ADGroups) {
            Remove-ADPrincipalGroupMembership -Identity $User -MemberOf "$ADG" -ErrorAction Stop -Confirm:$false
        }
        Write-Notes -Message "Removed Active Directory groups."
    }
    catch {
        Write-Warning "Error possibly due to the fact that the group was re-named at one point and the name and pre-windows 2000 name are no longer the same. (will require manual removal or correction of the names 'making them the same')"
        Write-Output $Error[0]
      }
    }

function Hide-GAL {
        if ($User.msExchHideFromAddressLists -ne "TRUE") {
            try {
            Set-ADUser -Identity $User.samAccountName -Replace @{msExchHideFromAddressLists="TRUE"}
                if ($User.msExchHideFromAddressLists -eq "TRUE") {
                    Write-Notes -Message "Hid $User from global address lists in AD"
                }
            }
                catch {
                    #nothing
                }
        }
}
function Start-Dirsync {
    $ADSyncService = Get-Service -Name "Microsoft Azure AD Sync" -ErrorAction SilentlyContinue
    if ($ADSyncService.Status -eq "Running") {
        Start-AdSyncSyncCycle -Policytype Delta
        Write-Notes -Message "Ran Dirsync Command."
    }
}

function Disable-ADUser {
    [CmdletBinding()]
    param (
        [Parameter()] $FolderPath,
        [Parameter()] $User
        )
        $allUsers = Import-Csv -Path $FolderPath
        #$FilePath = "C:\Users\aldridgeadmin\Desktop\User Offboarding Notes\newCSVFile.csv"
        Write-Host "Found "$allUsers.count" users."
                foreach($account in $allUsers) {
                        $User = Get-ADUser -filter * -Properties * | Where-Object {$_.Mail -eq $account.TalentPathEmail}
                            If ($User) {
                                try {
                                Write-Notes -Message "Logged into server: $env:COMPUTERNAME"
                                Backup-User
                                Set-ADUser $User -Enabled $false; Write-Notes -Message "Disabled $User"
                                Set-Password
                                Move-User
                                Remove-DistributionGroups
                                $todaysDate = Get-Date
                                Set-ADUser -identity $User -description "Disabled on $todaysDate"
                                Hide-GAL
                                Start-Dirsync
                                Write-Host -ForegroundColor Green "$($User.Name) success"
                                }
                                catch {
                                    write-host "Error on user $($User.Name)"
                                    write-error -message $error[0]
                                }
                            }
                            else {
                                Write-Host -ForegroundColor Red "$($account.TalentPathEmail) not found."
                            }
                }
}