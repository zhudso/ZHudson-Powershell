function Get-Patch {
    param (
        $Hotfix,
        $Path
    )
    $providedKBs = Get-Content -Path $Path
    $currentlyInstalled = Get-HotFix
    foreach ($kb in $providedKBs) {
            try {
                if ($currentlyInstalled -match $kb) {
                    $foundKB = Get-HotFix -Id $kb
                    write-host -ForegroundColor Green "Installed:" $foundKB.HotFixID "-" $foundKB.Description "-" $foundKB.InstalledOn
                }
                else {
                    $missingKBs++
                    $allMissingKBs += $kb
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
        $userInput = Read-Host "(Y/N)"
            switch ($userInput) {
                "y" {
                    $updateModule = Get-Module PSWindowsUpdate
                     if ($updateModule) {
                         #loading bar doesn't work. 
                        foreach ($kb in $allMissingKBs) {
                            for ($kb -le $allMissingKBs; $kbCount++) {
                            Write-Progress -Activity "Installing $kb.." -Status "$kb% Complete" -PercentComplete $kb
                            Start-Sleep -Milliseconds 250
                            Get-WindowsUpdate -Install -KBArticleID $kb
                            }
                        }
                     } else {
                        Write-Host -ForegroundColor Green "Installing PSWindowsUpdate module.."
                        #Backup Execution Policy
                        $previousEP = Get-ExecutionPolicy
                        #Set Execution Policy to allow install of modules.
                        Set-ExecutionPolicy RemoteSigned
                        #Installing Module
                        Install-Module PSWindowsUpdate
                        Set-ExecutionPolicy $previousEP
                            foreach ($kb in $allMissingKBs) {
                                for ($kb -le $allMissingKBs; $kbCount++) {
                                Write-Progress -Activity "Installing $kb.." -Status "$kb% Complete" -PercentComplete $kb
                                Start-Sleep -Milliseconds 250
                                Get-WindowsUpdate -Install -KBArticleID $kb
                                }
                            }
                     }
                }
                Default {
                    Write-Host -ForegroundColor Red "Unexpected input."
                }
            }
    }
}