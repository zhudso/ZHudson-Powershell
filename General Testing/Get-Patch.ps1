function Get-Patch {
    param (
        $Hotfix
    )
    begin {
        
    }
    process {
        $Updates = Get-Hotfix
    }
    end {
        if ($Updates -notcontains $Hotfix) {
            Get-Hotfix -Id $Hotfix
        }
        else {
            Write-Warning "$Hotfix is currently not installed."
        }
    }
}
