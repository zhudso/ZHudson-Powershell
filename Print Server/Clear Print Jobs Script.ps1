<# Open Powershell as Administrator with UAC prompt. #>
param([switch]$Elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

<# Script to stop print spooler service, clear print queue and start print spooler. #>
Stop-Service -Name Spooler
Remove-Item C:\Windows\System32\spool\PRINTERS\*.*
Remove-Item C:\Windows\System32\spool\SERVERS\*.*
Start-Service -Name Spooler
$SpoolerStatus = Get-Service -Name Spooler | Select-Object -ExpandProperty Status
$SpoolFiles = Get-ChildItem C:\Windows\System32\spool\PRINTERS
$SpoolServers = Get-ChildItem C:\Windows\System32\spool\SERVERS\
if ($SpoolerStatus -eq "Running" -and $SpoolFiles.Count -eq 0) {
    Write-Host -ForegroundColor Green -NoNewline "Print jobs now cleared"
}
else {
    Write-Warning "Error, please check print service & remove any files in the print queue C:\Windows\System32\spool\PRINTERS\ & C:\Windows\System32\spool\SERVERS\"
    Get-Service -Name Spooler
    Write-Output "C:\Windows\System32\spool\PRINTERS\"
    $SpoolFiles | measure | select @{expression={$_.Count};Label="CurrentJobs"}
    Write-Output "C:\Windows\System32\spool\SERVERS\"
    $SpoolServers | measure | select @{expression={$_.Count};Label="CurrentJobs"}
    <# Good command to check printers jobs through cli
    Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors #>
}