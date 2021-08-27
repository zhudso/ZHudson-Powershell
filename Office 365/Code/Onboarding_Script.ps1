
<# Office 365 License Management 
https://docs.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell?view=o365-worldwide #>

Write-host "Connecting to Azure Ad.."
<# Bypass PSGallery Warning Message #>
Install-Module -Name AzureAD -Repository PSGallery -Force
<# Connect to Azure AD with previously stored credentials. #>
Connect-AzureAD -Credential $UserCredential
<# Now connected to Azure AD. #>
Read-Host "We're now past the Connect-AzureAD Phase!"