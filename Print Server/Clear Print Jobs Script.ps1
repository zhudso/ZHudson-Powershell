#---------------------------- New Code but still has the same issues as the old code ----------------------------
#Problem trying to solve is have powershell open as admin and then run the "process" block code. Currently it's failing because it's still thinking it's not evalated.

<# If script is executed in a non-administrator powershell window.
Open Powershell as Administrator with UAC prompt. #>

function Clear-PrintQueue2 {
    begin {
        function Test-Admin {
            param(
                [switch]$Elevated
                )
            $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
            $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        }
            if ((Test-Admin) -eq $false)  {
                invoke-command -scriptblock {start-job -name AdminPS  -scriptblock {Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))}}
                wait-job -name AdminPS
            }
    }
    process {
        Write-host "hitting process block"
        start-sleep -Milliseconds 150
        Test-Admin
        if ((Test-Admin) -eq $true) {
            Write-host "hitting process if statement"
            try {
                Write-host "hitting process try statement"
                <# Script to stop print spooler service, clear print queue and start print spooler. #>
                Stop-Service -Name Spooler
                Remove-Item C:\Windows\System32\spool\PRINTERS\*.*
                Remove-Item C:\Windows\System32\spool\SERVERS\*.*
                Start-Service -Name Spooler
                $SpoolerStatus = Get-Service -Name Spooler | Select-Object -ExpandProperty Status
                $SpoolFiles = Get-ChildItem C:\Windows\System32\spool\PRINTERS
                #$SpoolServers = Get-ChildItem C:\Windows\System32\spool\SERVERS\
                    if ($SpoolerStatus -eq "Running" -and $SpoolFiles.Count -eq 0) {
                        Write-Host -ForegroundColor Cyan -NoNewline "Print jobs now cleared"
                    }
            }
            catch {

            }
    }
}
}


#---------------------------- Old Code ----------------------------

<# If script is executed in a non-administrator powershell window.
Open Powershell as Administrator with UAC prompt. #>
function Test-Admin {
    param(
        [switch]$Elevated
        )
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($Elevated) {
        #session is already as an Administrator
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

function Clear-PrintQueue {
    if ((Test-Admin) -eq $true) {
        try {
            <# Script to stop print spooler service, clear print queue and start print spooler. #>
            Stop-Service -Name Spooler
            Remove-Item C:\Windows\System32\spool\PRINTERS\*.*
            Remove-Item C:\Windows\System32\spool\SERVERS\*.*
            Start-Service -Name Spooler
            $SpoolerStatus = Get-Service -Name Spooler | Select-Object -ExpandProperty Status
            $SpoolFiles = Get-ChildItem C:\Windows\System32\spool\PRINTERS
            $SpoolServers = Get-ChildItem C:\Windows\System32\spool\SERVERS\
                if ($SpoolerStatus -eq "Running" -and $SpoolFiles.Count -eq 0 -and $SpoolServers.Count -eq 0) {
                    Write-Host -ForegroundColor Cyan -NoNewline "Print jobs now cleared"
                }
        }
        catch {
            Write-Warning "Error, please check print service & remove any files in the print queue C:\Windows\System32\spool\PRINTERS\ & C:\Windows\System32\spool\SERVERS\"
            Get-Service -Name Spooler
            Write-Output "C:\Windows\System32\spool\PRINTERS\"
            $SpoolFiles | Measure-Object | Select-Object @{expression={$_.Count};Label="CurrentJobs"}
            Write-Output "C:\Windows\System32\spool\SERVERS\"
            $SpoolServers | Measure-Object | Select-Object @{expression={$_.Count};Label="CurrentJobs"}
            <# Good command to check printers jobs through cli
            Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors #>
        }

    }
    
}