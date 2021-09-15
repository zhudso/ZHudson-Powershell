
function Disable-ADUser {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position=0)]
        [ValidateScript({Get-ADUser -id $_ -Properties *})]
        [string]$User
        )
        try {
            Write-Notes -Message "Logged into server: $env:COMPUTERNAME"
            Backup-User
            Set-ADUser $User -Enabled $false
            Write-Notes -Message "Disabled $User"
            Set-Password
            Move-User
            Remove-DistributionGroups
            Hide-GAL
            Start-Dirsync
            Write-Host "Successfully offboarded user."
        }
        catch {
            Write-Output "Hit the Disable-User try catch block"
            Write-Warning $Error[0]
        }
}

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
        Date Modified   : 03/13/2021
#>
function Write-Notes{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $pipeValue,
        [Parameter()]
        $Message,
        [Parameter()]
        $FilePath = "$env:USERPROFILE\Desktop",
        [Parameter()]
        $FileName = "$User.DisplayName Offboarding Notes"
    )
    begin {
        <# Process each value and get them ready as 1 unit for the process block.
        If no begin block, they'll be processed as single items. #>
    }
    process {
        <# Take each item in the pipeline and write it out to a file. #>
        foreach ($pValue in $pipeValue) {
            $pValue | Out-File "$FilePath\$FileName.txt" -Append
        }
    }
    end {
        <# Take the -message parameter and append the message to the file. #>
        $Message | Out-File "$FilePath\$FileName.txt" -Append
    }
}
function Backup-User {
    <# Show Original Object Location #>
    $ObjectLocation = Get-ADUser -identity $User -Properties CanonicalName | select-object -ExpandProperty CanonicalName
    Write-Notes -Message "Original Object location: $ObjectLocation"
    $UserEmailAddress = Get-ADUser -id $User -Properties * | Select-Object -ExpandProperty UserPrincipalName
    Write-Notes -Message "Users Email Address: $UserEmailAddress"
    <# Backup the current groups to the desktop in a .txt file #>
    Get-ADPrincipalGroupMembership -Identity $User | Select-Object -ExpandProperty Name | Write-Notes -FileName "$User ADGroups.txt"
    Write-Notes -Message "Saved copy of Active Directory Groups $env:userprofile\desktop\$User ADGroups.txt"
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
            try {
                if ($null -eq $User1.msExchHideFromAddressLists) {
                    Set-ADUser -Identity $User1 -Replace @{msExchHideFromAddressLists="TRUE"}
                    #Write-Notes -Message "Hid $User from global address lists in AD"
                    Write-Notes -Message $User.DisplayName "is now hidden from GAL"
                }
            }
            catch {
                #nothing
            }
        }
function Start-Dirsync {
    $ADSyncService = Get-Service -Name "Microsoft Azure AD Sync" -ErrorAction SilentlyContinue
    if ($ADSyncService.Status -eq "Running") {
        Start-AdSyncSyncCycle -Policytype Delta
        Write-Notes -Message "Ran Dirsync Command."
    }
}