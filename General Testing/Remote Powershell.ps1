#Remote Powershell

<# Verify that WinRM is setup and configured locally #>
Test-WSMan

<# basic WinRM configurtaoin with default settings #>
winrm quickconfig

<# Example of WinRM Configuration with more specific settings #>
winrm quickconfig -transport:https

<# Check for WinRM settings #>
<# NOTE: for http, it's expected for this to run when both devices are connected to the same domain
This is considered "trusted" and doesn't required going out to the internet and come back #>
winrm get winrm/config/client
<# Requires to run this as administrator #>
winrm get winrm/config/service
<# Get more configuration information #>
winrm enumerate winrm/config/listener