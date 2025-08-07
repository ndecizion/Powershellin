$LoggingStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$progressBars = @{}
$progressBarCounter = 0
$progressLastPrinted = $LoggingStopwatch.ElapsedMilliseconds
$loggingContexts = @{}
$defaultLoggingContextString = [System.Guid]::NewGuid().ToString()
$levelMap = @{
	"debug" = 1
	"info" = 2
	"warn" = 3
	"error" = 4
}

function New-LoggingContext{
	<#
	.SYNOPSIS
		.
	.OUTPUTS
		.
	#>
	param(
		[string]$contextName
	)
	$newLogContext = @{
		name = $contextName
		stash = [System.Collections.ArrayList]@()
		file = ""
		autosaveInterval = -1
		lastFileWrite = $LoggingStopwatch.ElapsedMilliseconds
		overwrite = $false
		verbosity = $levelMap["warn"]
	}
	return $newLogContext
}

function Get-LoggingContext{
	<#
	.SYNOPSIS
		.
	.OUTPUTS
		.
	#>
	param(
		# Desired logging context to work in. Leave null for the default.
		[string]$Context
	)
	if([string]::IsNullOrEmpty($Context)){
		$Context = $defaultLoggingContextString
	}
	if(-not $loggingContexts.ContainsKey($Context)){
		$loggingContexts.$Context = New-LoggingContext $Context
	}
	return $loggingContexts.$Context
}

function Set-LogFile{
	<#
	.SYNOPSIS
		Configures the log file to be used for a given logging context.
	.OUTPUTS
		none.
	#>
	Param(
		# Folder to save the log file
		[Parameter(Mandatory = $true)]
		[string]$Path,
		# Filename to be used. ".log" will be appended to this, preceded by time/datestamps if specified.
		[Parameter(Mandatory = $true)]
		[string]$Name,
		# Logging context for this file. If null, this will set the default context.
		[string]$Context,
		# Includes a datestamp in the filename using "_yyyyMMdd" format. Defaults true.
		[bool]$includeDatestamp = $true,
		# Includes a datestamp in the filename using "_HHmm" format. Defaults true.
		[bool]$includeTimestamp = $false,
		# Allow overwrite when false, prevent overwrite when true.
		[bool]$overwrite = $false
	)
	if(-not (test-path $path)){
		write-warning "Loggerhead.Set-LogFile: Provided Path Does Not Exist"
	}
	$logFile = $Path
	If($path.remove(0,($path.Length-1)) -ne '\'){$logFile += '\'}
	$logFile += $Name
	if($includeDatestamp){
		$logFile += "_$(get-date -f "yyyyMMdd")"
	}
	if($includeTimestamp){
		$logFile += "_$(get-date -f "HHmm")"
	}
	$logFile += ".log"
	$targetLoggingContext = Get-LoggingContext $Context
	$targetLoggingContext.file = $logFile
	$targetLoggingContext.overwrite = $overwrite
}

function Get-LogFile{
	<#
	.SYNOPSIS
		Returns the explicit name for the logging file. 
	.OUTPUTS
		.
	#>
	Param(
		#w
		[string]$Context
	)
	$activeContext = Get-LoggingContext $Context
	Return $activeContext.file
}

function Write-LogsToFile{
	<#
	.SYNOPSIS
		.
	.OUTPUTS
		.
	#>
	Param(
		#w
		[string]$Context
	)
	$activeContext = Get-LoggingContext $Context
	if($activeContext.overwrite){
		$activeContext.stash | Out-File -FilePath $activeContext.file -Append
	}
	else {
		$activeContext.stash | Out-File -FilePath $activeContext.file
	}
}

function Set-AutosaveInterval{
	<#
	.SYNOPSIS
		Sets a threshold for the provided context which will force a write to disk if exceeded.
		If set to a negative value autosaves will be disabled. Defaults to -1.
	.OUTPUTS
		none
	#>
	Param(
		# Sets the autosave time threshold for the provided context.
		[int]$millisecondInterval,
		# Desired context for the interval. Defaults to the default context.
		[string]$Context
	)
	$activeContext = Get-LoggingContext $Context
	$activeContext.autosaveInterval = $millisecondInterval
}

function Set-LogVerbosity{
	Param(
		# Desired logging threshold for console messages
		[Parameter(Mandatory = $true)]
		[ValidateSet("debug","info","warn","error")]
		[string]$Level,
		# Desired context for this setting. Defaults to the default context.
		[string]$context
	)
	$activeContext = Get-LoggingContext $context
	$activeContext.verbosity = $levelMap.$Level
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
		[string]$Level = "info",
		# Logging context for this message. Default context is used if none is provided.
		[string]$Context = ""
	)
	$activeContext = Get-LoggingContext $Context
	$datestamp = (Get-Date).toString("yyyy-MM-dd|HHmm")
	$runtime = [Math]::Floor($LoggingStopwatch.elapsed.totalSeconds)
	$runtime = '{0:d5}' -f [int]$runtime
	$reportedLevel = $Level.Substring(0,1).ToUpper()
	$printMessage = "$($datestamp)|$($reportedLevel)|rt$($runtime)|$($Message.replace("|","\|"))"
	$activeContext.stash.Add($printMessage) | Out-Null
	$numLevel = $levelMap.$Level
	if("error" -eq $Level){
		Write-Error -Message $printMessage
	}
	elseif("warn" -eq $Level){
		Write-Warning -Message $printMessage
	}
	elseif($numLevel -ge $activeContext.verbosity){
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
	if($script:progressBars.ContainsKey($Activity)){
		$bar = $script:progressBars.$Activity
		Write-Progress -id $bar.id -Activity $Activity -Status "Stopped" -Completed
		$script:progressBars.Remove($Activity)
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
	if($script:progressBars.ContainsKey($Activity)){
		$activeProgressBar = $script:progressBars.$Activity
		$activeProgressBar.Status = $Status
		$activeProgressBar.ProgressCounter = $ProgressCounter
		$activeProgressBar.TotalCount = $TotalCount
	}
	else{
		$newProgressBar = @{
			Activity=$Activity
			Status=$Status
			id=$script:progressBarCounter
			ProgressCounter=$progressCounter
			TotalCount=$TotalCount
		}
		$script:progressBars.$Activity = $newProgressBar
		$script:progressBarCounter++
		$script:progressLastPrinted = 0
	}
	if($script:LoggingStopwatch.elapsed.totalmilliseconds - $script:progressLastPrinted -ge 500){
		$script:progressLastPrinted = $script:LoggingStopwatch.elapsed.totalmilliseconds
		$toRemove = @()
		foreach($bar in $script:progressBars.Values){
			[string]$currentStatus = ""
			if("" -eq $bar.Status){
				$currentStatus = "Item $($bar.ProgressCounter) of $($bar.TotalCount)"
			}
			else{
				$currentStatus = $bar.Status
			}
			$percentComplete = ($bar.ProgressCounter/$bar.TotalCount*100)
			if($bar.ProgressCounter -eq $bar.TotalCount){
				Write-Progress -id $bar.id -Activity $bar.Activity -Status $currentStatus -PercentComplete $percentComplete -Completed
				$toRemove += $bar.Activity
			}
			else{
				Write-Progress -id $bar.id -Activity $bar.Activity -Status $currentStatus -PercentComplete $percentComplete
			}
		}
		foreach($active in $toRemove){
			$script:progressBars.Remove($active)
		}
	}
}

Export-ModuleMember -Function Set-LogFile
Export-ModuleMember -Function Get-LogFile
Export-ModuleMember -Function Set-LogVerbosity
Export-ModuleMember -Function Write-LogsToFile
Export-ModuleMember -Function Write-LogEvent
Export-ModuleMember -Function Stop-ProgressBar
Export-ModuleMember -Function Update-ProgressBar
