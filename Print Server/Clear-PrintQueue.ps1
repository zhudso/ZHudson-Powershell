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
                Write-Warning "Powershell not running as Administrator. Please close this window and run powershell as Administrator."
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
                        Write-Host -ForegroundColor Cyan -NoNewline "Print jobs now cleared"
                        <# Good command to check printers jobs through cli
                        Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors #>
                    }
            }
            catch {

            }
    }
}
}