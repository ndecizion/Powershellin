$LoggingStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$progressBars = [System.Collections.ArrayList]@()
$progressLastPrinted = $LoggingStopwatch.ElapsedMilliseconds
$loggingStash = [System.Collections.ArrayList]@()
$loggingFile = ""
$verbosityNumeric = 3
$levelMap = @{
	"debug" = 1
	"info" = 2
	"warn" = 3
	"error" = 4
}
function Set-LogFile{
	<#
	.SYNOPSIS
		.
	.OUTPUTS
		.
	#>
	Param()
}
function Get-LogFile{
	<#
	.SYNOPSIS
		Returns the explicit name for the logging file. 
	.OUTPUTS
		.
	#>
	Param()
	Return $loggingFile
}
function Write-LogsToFile{
	<#
	.SYNOPSIS
		.
	.OUTPUTS
		.
	#>
	Param()
}

function Set-LogVerbosity{
	Param(
		#Desired logging threshold for console messages
		[Parameter(Mandatory = $true)]
		[ValidateSet("debug","info","warn","error")]
		[string]$Level
	)
	write-host "Setting verbosity to $($levelMap.$Level)"
	$script:verbosityNumeric = $levelMap.$Level
}

function Write-LogEvent{
	<#
	.SYNOPSIS
		All messages are captured to a temporary stash. Messages above verbosity
		threshold are written to console.  Stash is written to disk every 60
		seconds or on demand. 
	.OUTPUTS
		Console messages
		Log files
	#>
	param(
		# Message to be captured.
		[Parameter(Mandatory = $true)]
		[string]$Message,
		# Log level for the message, from "debug","info","warn","error". Defaults to info.
		[ValidateSet("debug","info","warn","error")]
		[string]$Level = "info"
	)
	$datestamp = (Get-Date).toString("yyyy-MM-dd_HH:mm")
	$runtime = [Math]::Floor($LoggingStopwatch.elapsed.totalSeconds)
	$runtime = '{0:d5}' -f [int]$runtime
	$reportedLevel = $Level.replace("u","").replace("rr","r")
	$printMessage = "$($datestamp)_$($reportedLevel)_rt$($runtime):$($Message)"
	$loggingStash.add($printMessage) | Out-Null
	$numLevel = $levelMap.$Level
	if("error" -eq $Level){
		Write-Error -Message $printMessage
	}
	elseif("warn" -eq $Level){
		Write-Warning -Message $printMessage
	}
	elseif($numLevel -ge $verbosityNumeric){
		Write-Host $printMessage
	}
}

function Stop-ProgressBar{
	<#
	.SYNOPSIS
		A wrapper for the write-progress function which allows you to dismiss
		progress bars when all records haven't been processed.

	.OUTPUTS
		Renders progress on the screen. You get nothing else and you'll like it.
	#>
	param(
		# Unique identifier that designates a progress bar.
		[Parameter(Mandatory = $true)]
		[string]$Activity
	)
	$activeBar = $progressBars | where-object {$_.Activity -eq $Activity}
	if($null -ne $activeBar){
		Write-Progress -Activity $Activity -PercentComplete 100 -Completed
		$progressBars.Remove($activeBar)
	}
}

function Update-ProgressBar{
	<#
	.SYNOPSIS
		A wrapper for the write-progress function which only updates if 500ms
		have passed since the last time the progress bar was updated. Supports
		multiple progress bars by changing the Activity parameter.

	.DESCRIPTION
		This is a wrapper for the write-progress function which limits frequent
		updates to improve performance. Multiple progress bars can be rendered
		by using different Activity strings.
		
		If the function is called with the ProgressCounter equal to the 
		TotalCount, it will automatically call the Stop-ProgressBar function.  
		If the progress bar needs to be terminatd early, call Stop-Progress
		to dismiss it.

	.OUTPUTS
		Renders progress on the screen. You get nothing else and you'll like it.
	#>
	[OutputType([psobject])]
	param(
		# Unique identifier that designates a progress bar.
		[Parameter(Mandatory = $true)]
		[string]$Activity,
		
		# Number for current record being processed.
		[Parameter(Mandatory = $true)]
		[int]$ProgressCounter,
		
		# Total count of records 
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]$TotalCount,
		
		# Optional status message that will be displayed above the progress.
		# If this isn't provided, it defaults to 
		#	"Item $ProgressCounter of $TotalCount"
		[Parameter(Mandatory = $false)]
		[string]$Status = ""
	)
	$activeProgressBar = $progressBars | where-object {$_.Activity -eq $Activity}
	if($null -eq $activeProgressBar){
		$newProgressBar = @{
			Activity=$Activity
			Status=$Status
			ProgressCounter=$progressCounter
			TotalCount=$TotalCount
		}
		$progressBars.add($newProgressBar)
	}
	else{
		$activeProgressBar.Status = $Status
		$activeProgressBar.ProgressCounter = $ProgressCounter
		$activeProgressBar.TotalCount = $TotalCount
	}
	if($LoggingStopwatch.elapsed.totalmilliseconds - $progressLastPrinted -ge 5000){
		$progressLastPrinted = $LoggingStopwatch.elapsed.totalmilliseconds
		for($i = 0; $i -lt $progressBars.count; $i++){
			$currentStatus = "Item $($progressBars[$i].ProgressCounter) of $($progressBars[$i].TotalCount)"
			if("" -ne $progressBars[$i].Status){
				$currentStatus = $progressBars[$i].Status
			}
			Write-Progress -id $i -Activity ($progressBars[$i].Activity) -Status $currentStatus -PercentComplete ($ProgressBars[$i].ProgressCounter/$ProgressBars[$i].TotalCount*100)
		}
	}
	if($ProgressCounter -eq $TotalCount){
		Stop-ProgressBar -Activity $Activity
	}
}

Export-ModuleMember -Function Set-LogFile
Export-ModuleMember -Function Get-LogFile
Export-ModuleMember -Function Set-LogVerbosity
Export-ModuleMember -Function Write-LogsToFile
Export-ModuleMember -Function Write-LogEvent
Export-ModuleMember -Function Stop-ProgressBar
Export-ModuleMember -Function Update-ProgressBar
