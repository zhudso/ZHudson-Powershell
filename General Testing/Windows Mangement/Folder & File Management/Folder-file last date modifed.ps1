Get-ChildItem -Path "C:\Users\zhudson\Documents\WindowsPowerShell" -directory -Recurse | Select-Object FullName,LastWriteTime
    #If we want to filter down to a certain month or year
    #Where-Object  { $_.lastwritetime.month -eq 10 -AND $_.lastwritetime.year -eq 2011 }