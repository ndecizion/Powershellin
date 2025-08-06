import-module ($env:Source + "Powershellin\Mods\Loggerhead.psm1")

Write-LogEvent -message "This is the first test" -Level "warn"

Write-LogEvent -message "This is the second test"
Start-Sleep -Seconds 2
Set-LogVerbosity -level "info"
Write-LogEvent -message "This shouldn't show up on the console" -Level "debug"
Write-LogEvent -message "This is the third test" -Level "info"
Write-LogEvent -message "This is the fourth test" -Level "warn"
Write-LogEvent -message "This is the fifth test" -Level "error"
Set-LogVerbosity -level "debug"
Write-LogEvent -message "This is the sixth test" -Level "debug"
