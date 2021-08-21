#Saving File Test

$randomName = ipconfig
$answer = Read-Host -Prompt "Would you like to save to a file? (Y/N)"

if ($answer -eq "Y" -or $answer -eq "Yes" ){
    Write-Host "Saving File "$psScriptRoot"\ipconfig"
    [System.IO.Path]::GetRandomFileName()
    #$exportCSV = $psScriptRoot+".\ipconfig"
}
elseif ($answer -eq "N" -or $answer -eq "No") {
    Write-Host "Printing to console.."
    $randomName
    break
}