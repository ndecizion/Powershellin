import-module ($env:Source + "Powershellin\Mods\Loggerhead.psm1")

Write-LogEvent -message "This is the first test" -Level "warn"

Write-LogEvent -message "This is the second test"
Start-Sleep -Seconds 2
Set-LogVerbosity -level "info"
Write-LogEvent -message "This shouldn't show up on the console" -Level "debug"
Set-LogFile -context "debug" -path ($env:workingDir + "loggerhead\")  -name "debugContextTest" -overwrite $true
Set-LogVerbosity -context "debug" -level "info"
Write-LogEvent -message "This is the third test" -Level "info"
Write-LogEvent -message "This is a copy of the third test" -Level "debug" -context "debug"
Write-LogEvent -message "This is the fourth test" -Level "warn"
Write-LogEvent -message "This is a copy of the fourth test" -Level "debug" -context "debug"
Write-LogEvent -message "This is the fifth test" -Level "error"
Write-LogEvent -message "This is a copy of the fifth test" -Level "debug" -context "debug"

Set-LogVerbosity -level "debug"
Write-LogEvent -message "This is the sixth test" -Level "debug"
Write-LogEvent -message "This is a copy of the sixth test" -Level "debug" -context "debug"

Set-Logfile -path ($env:workingDir + "loggerhead\")  -name "defaultContextTest"
Write-LogsToFile
Write-LogsToFile -context "debug"

$latestContextFile = get-childitem ($env:workingDir + "loggerhead\") | Where-Object {$_.name -like "DefaultContextTest*"} | select-object -last 1
write-host "found latest context log: $($latestContextFile.Fullname)"
get-content $latestContextFile.FullName | write-host
$latestDebugFile = get-childitem ($env:workingDir + "loggerhead\") | Where-Object {$_.name -like "debugContextTest*"} | select-object -last 1
write-host "found latest context log: $($latestDebugFile.Fullname)"
get-content $latestDebugFile.FullName | write-host
