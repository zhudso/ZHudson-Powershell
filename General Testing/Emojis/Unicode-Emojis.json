function Convert-UnicodeToString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $UnicodeChars
    )
    
    $UnicodeChars = $UnicodeChars -replace 'U\+', '';

    $UnicodeArray = @();
    foreach ($UnicodeChar in $UnicodeChars.Split(' ')) {
        $Int = [System.Convert]::ToInt32($UnicodeChar, 16);
        $UnicodeArray += [System.Char]::ConvertFromUtf32($Int);
    }

    $UnicodeArray -join [String]::Empty;
}

function Get-Emoji {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'GRINNING FACE'
        )]
        [string[]] $Name
    )
    
    $EmojiList = Get-Content -Raw -Path $PSScriptRoot\Unicode-Emojis.json | ConvertFrom-Json;
    
    foreach ($Item in $Name) {
        Convert-UnicodeToString -UnicodeChars ($EmojiList.Where({ $PSItem.Name -eq $Item; })).Code;
    }
}

New-Alias -Name emoji -Value Get-Emoji -Description 'Retrieves a Unicode emoji';