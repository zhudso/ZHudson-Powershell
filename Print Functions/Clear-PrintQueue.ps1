<#
.SYNOPSIS
        Clears stuck print jobs on a windows server or workstation.
    .DESCRIPTION
        Clear-PrintQueue will start by executing another function (Test-Admin). Clear-PrintQueue cannot perform any actions without running as administrator and (Test-Admin) will notify if you powershell is running as a non-administrator.
        After clearing (Test-Admin), Clear-PrintQueue will stop the print spooler service & clear any files under: C:\Windows\System32\spool\PRINTERS\. If there is no files under: C:\Windows\System32\spool\PRINTERS\ and the print service has started, then print queue provides a success message.
        If no success message, then it'll report the Print Spooler status and what files are still under the directory: C:\Windows\System32\spool\PRINTERS\
    .EXAMPLE
        On a Print Server or a stand alone workstation that may have host the printer. Run Powershell as Admin and enter: Clear-PrintQueue
    .NOTES
        FunctionName    : Clear-PrintQueue
        Created by      : Zach Hudson
        Date Coded      : 08/21/2021
        Modified by     : Zach Hudson
        Date Modified   : 4/1/2022
#>


function Clear-PrintQueue {
    begin {
        function Test-Admin {
            param(
                [switch]$Elevated
                )
            $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
            $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        }
            if ((Test-Admin) -eq $false)  {
                Write-Warning "Powershell is not running as Administrator. Please close this window and run powershell as Administrator."
            }
    }
    process {
        if ((Test-Admin) -eq $true) {
            try {
                <#Stop print spooler service, clear print queue and start print spooler. #>
                Stop-Service -Name Spooler
                Remove-Item C:\Windows\System32\spool\PRINTERS\*.*
                Start-Service -Name Spooler
                $SpoolerStatus = Get-Service -Name Spooler | Select-Object -ExpandProperty Status
                $SpoolFiles = Get-ChildItem C:\Windows\System32\spool\PRINTERS
                #$SpoolServers = Get-ChildItem C:\Windows\System32\spool\SERVERS\
                    if ($SpoolerStatus -eq "Running" -and $SpoolFiles.Count -eq 0) {
                        Write-Host -ForegroundColor Cyan "`nPrint jobs now cleared`n"
                        <# Good command to check printers jobs through cli
                        Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors #>
                    }
            }
            catch {
                Write-Warning "`nFailed to clear print queue. Please ensure that Printer Spooler service is running & files under directory: C:\Windows\System32\spool\PRINTERS\ is empty."
                $SpoolerStatus = Get-Service -Name Spooler; $SpoolerStatus
                $SpoolFiles = Get-ChildItem C:\Windows\System32\spool\PRINTERS; Write-Host  "`nNumber of files under C:\Windows\System32\spool\PRINTERS\:" $SpoolFiles.Count
            }
        }
    }
}