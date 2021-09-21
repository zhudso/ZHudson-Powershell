function Check-Updates {
    param (
        # Specify a file path to the update file.
        [Parameter(Mandatory,Position=1)]
        [ValidateScript({test-path $_})]
        $FilePath
    )
    begin {
        $FileContents = Get-Content $FilePath
        $InstalledUpdates = Get-HotFix
    }
    process {
        foreach ($update in $FileContents) {
        write-output $InstalledUpdates | Where-Object {$_.HotFixID -eq $update} | Select-Object Description,HotFixID,InstalledBy,InstalledOn | Sort-Object -Property InstalledOn -Descending
    }
}
}
<# function Remove-Updates {
    param (
    [Parameter(Mandatory,Position=1)]
    [ValidateScript({Get-HotFix $_})]
    $Update
    )
    begin {

    }
} #>