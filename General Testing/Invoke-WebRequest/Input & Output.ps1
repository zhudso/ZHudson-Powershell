<# Get the reddit board of powershell in Json format #>
$webResults = Invoke-WebRequest -Uri https://www.reddit.com/r/PowerShell.json
<# Store the Content of of the web results. 
This variable name is a little misleading since there also child object $webResults.RawContent #>
$rawJSON = $webResults.Content
<# Convert our Json data into a powershell object. #>
$objData = $rawJSON | ConvertFrom-Json
<# Creating a "shortcut" of the actual post information. #>
$posts = $objData.data.children.data
<# Pull the top posts Title and their "UpVotes aka Score" and sort by descending #>
$posts | Select-Object Title,Score | Sort-Object Score -Descending