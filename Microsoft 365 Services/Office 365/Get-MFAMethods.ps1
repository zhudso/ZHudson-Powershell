function Get-MFAMethods {
    $methodTypes = Get-MFAStatus -IsLicensed | Where-Object {$null -ne $_.MFAType} | Select-Object -ExpandProperty MFAType
    foreach ($method in $methodTypes) {
        switch ($method) {
            PhoneAppOTP {
                [int]$PhoneAppOTP++ > $null
            }
            PhoneAppNotification {
                [int]$PhoneAppNotification++ > $null
            }
            OneWaySMS {
                [int]$OneWaySMS++ > $null
            }
        }
    }
Write-Host "PhoneAppOTP: " $PhoneAppOTP; Write-Host "PhoneApplicationNotification: "$PhoneAppNotification; Write-Host "Text Message: " $OneWaySMS
}