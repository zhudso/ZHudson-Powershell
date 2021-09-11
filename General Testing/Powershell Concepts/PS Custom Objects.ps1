<# $myObject = [PSCustomObject]@{
    Name     = 'Kevin'
    Language = 'PowerShell'
    State    = 'Texas'
} #>

$PrintSpool = Get-Service -Name Spooler
$LocalAdmins = Get-LocalGroupMember -Group "Administrators" | Select-Object -First 1

$customObject = [PSCustomObject]@{
    Name = $PrintSpool.Name
    Status = $PrintSpool.Status
    User = $LocalAdmins
}