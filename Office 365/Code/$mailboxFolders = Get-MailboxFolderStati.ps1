$mailboxFolders = Get-MailboxFolderStatistics -Identity 2017TSBRI-1AdminAssistant@tri-stargroup.com | Select-Object itemsinfolder
$mailboxFolders | foreach-Object {
    $mailboxFolders -as [int]
    $totalMailboxFolders = $mailboxFolders + $mailboxFolders
}
Write-Host $totalMailboxFolders