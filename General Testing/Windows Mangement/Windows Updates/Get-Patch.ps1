function Get-Patch {
    param (
        $Hotfix,
        $Path
    )
    $providedKBs = Get-Content -Path $Path
    foreach ($kb in $providedKBs) {
            try {
                $currentlyInstalled = Get-HotFix
                if ($currentlyInstalled -match $kb) {
                    $foundKB = Get-HotFix -Id $kb
                    write-host -ForegroundColor Green "Installed:" $foundKB.HotFixID "-" $foundKB.Description "-" $foundKB.InstalledOn
                }
                else {
                    $missingKBs++
                    Write-Host -ForegroundColor Red "Missing:" $kb 
                }
            }
            catch {
                Write-Warning "catch statement error"
            }
    }
    if ($missingKBs) {
        Write-Warning "$env:computername is missing $missingKBs out of the $($providedKBs.count) provided updates"
        Write-Information -MessageData "Would you like to get and install the missing KB's? (Get-WindowsUpdate)" -Tags "Instructions" -InformationAction Continue
    }
}