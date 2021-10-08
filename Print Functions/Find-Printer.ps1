<#
  .SYNOPSIS
    Finds a certain printer based off of IP, WSD Port or DisplayName.
    This will automatically display ALL printers that match the provided parameters.

  .DESCRIPTION
    Helps you find printer(s) details by searching with the (Printer's Displayname, Labeled Driver Name or IP Address)

  .PARAMETER InputPath
  -Port (Alias is "IP","WSD")
    Specify a Port address to search
  -Name
    Specify a Name to search. this will perform a "wildcard" search in both the Printer's displayname and or Driver Displayname. 

  .PARAMETER OutputPath
  Once a printer is found, it'll output (IP Address, WSD Port, Printer's Displayname or Labeled Driver Name)

  .INPUTS
  You cannot pipe items into this function. Specify -IP or -Name

  .OUTPUTS
  Will provide Name, DriverName, IP / Port, Shared, JobCount
    Example: 
        Name       : Brother HL-4570CDW series Printer
        DriverName : Brother Color Type3 Class Driver
        Portname   : WSD-16ed43e6-f0ec-4b93-bd1b-eee07ad04017
        Shared     : False
        JobCount   : 0

  .EXAMPLE
  Find-Printer -IP 192.168.110.243

        Name       : Brother Color Leg Type1 Class Driver
        DriverName : Brother Color Leg Type1 Class Driver
        Portname   : 192.168.110.243
        Shared     : False
        JobCount   : 0

  .EXAMPLE
  Find-Printer -IP WSD-16ed43e6-f0ec-4b93-bd1b-eee07ad04017

        Name       : Brother HL-4570CDW series Printer
        DriverName : Brother Color Type3 Class Driver
        Portname   : WSD-16ed43e6-f0ec-4b93-bd1b-eee07ad04017
        Shared     : False
        JobCount   : 0

  .EXAMPLE
  Find-Printer -name brother

        Name       : Brother HL-4570CDW series Printer
        DriverName : Brother Color Type3 Class Driver
        IP / Port  : WSD-16ed43e6-f0ec-4b93-bd1b-eee07ad04017
        Shared     : False
        JobCount   : 0
#>

function Find-Printer{
  [CmdletBinding()]
  param (
      [Parameter(Position=0)]
      [alias("IP","WSD")]
      $Port,
      [Parameter(Position=1)]
      $Name
  )
  if ($Port) {
      Get-Printer | Where-Object {$_.Portname -eq $Port} | Select-Object Name,DriverName,Portname,Shared,ShareName,JobCount | Format-List
  }
  if ($Name) {
      Get-Printer | Where-Object {($_.Name -match $Name) -or ($_.DriverName -match $Name)} | Select-Object Name,DriverName,@{N='Port'; E={$_.Portname}},Shared,ShareName,JobCount | Format-List
  }
  else { 
      Get-Printer | Select-Object Name,DriverName,@{N='Port'; E={$_.Portname}},Shared,ShareName,JobCount | Format-List
  }
}