# Script:	Get-Remote-LocalAdmins.ps1
# Purpose:  This script can detect the members of a remote machine's local Admins group
# Author:   Paperclips
# Email:	pwd9000@hotmail.co.uk
# Date:     Nov 2011
# Comments: 
# Notes:    
#			

function Get-LocalAdmin {
param ($computer) 
 
$admins = wmi win32_groupuser –computer $computer  
$admins = $admins | ? {$_.groupcomponent –like '*"Administrators"'} 
 
$admins |% { 
$_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul 
$matches[1].trim('"') + “\” + $matches[2].trim('"') 
}
}
#Usage: get-localadmin "Server FQDN"