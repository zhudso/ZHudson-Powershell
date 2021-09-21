Add-Type -AssemblyName PresentationCore,PresentationFramework
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
If ($timer.Elapsed.TotalSeconds -lt 10) {
    $dialogbox = [System.Windows.MessageBox]::Show('Start work programs?','Work Programs','YesNoCancel','Information')
        if ($dialogbox -eq "Yes") {
            Write-Host "Yes!"
        }
            elseif ($dialogbox -eq "No") {
                Write-Host "Nope.."
        }
            else {
                Write-Host "Canceling..."
        }
    ## Wait a specific interval
    <# Start-Sleep -Seconds 1 #>
  
    ## Check the time
    $totalSecs =  [math]::Round($timer.Elapsed.TotalSeconds,0)
    Write-Verbose -Message "Still waiting for action  to complete after [$totalSecs] seconds..."
}