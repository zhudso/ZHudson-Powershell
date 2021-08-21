$SourceFile = “C:\Temp\File.txt”
$DestinationFile = $psScriptRoot+".\mailboxPermissions.ps1"

If (Test-Path $DestinationFile) {
$i = 0
While (Test-Path $DestinationFile) {
$i += 1
$DestinationFile = “C:\Temp\NonexistentDirectory\File$i.txt”
}
} Else {
New-Item -ItemType File -Path $DestinationFile -Force
}

Copy-Item -Path $SourceFile -Destination $DestinationFile -Force



$scriptToRun = $psScriptRoot+".\mailboxPermissions.ps1"
Invoke-Expression -Command $scriptToRun
break