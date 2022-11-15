<# Loggerhead.ps1
  This module is intended to provide an easy way to write
  consistent logs across all our scripts.  You don't 
  have to specify a log file before getting started.
  So you can create a logger, start writing events to it
  and they will be saved in order, with the timestamp
  preserved, until you specify a file and they can be writen
  to disk.  All events written to 
  This script is documented in the loggerhead.md
  readme file.
#>

<# Example usage:
# You can copy and paste this into your script!  See the readme for more info!
$scriptDirectoryPath =  [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition) 
$scriptRootPath = $scriptDirectoryPath | Split-Path -Parent
. "$scriptRootPath\LoggerHead\loggerhead.ps1"
$logger = [loggerhead]::New()
$logger.writelog("Starting script SomeFancyScript.ps1")
start-sleep 1
$workingdirectory = "$home\Downloads\"
$datestamp = (Get-Date).ToString("yyyy-MM-dd")
$timestamp = (Get-Date).ToString("HH-mm")
$logger.setLogFile($workingDirectory,"SomeFancyScript_Log_$($datestamp)_$($timestamp).log")
$logger.writelog("Doing some work")
start-sleep 3
$logger.writelog("all done!")
Will produce the following file:
$downloads\SomeFancyScript_Log_2021-06-10_09-36.log
    2021/06/10 09:36:51 - Starting script SomeFancyScript.ps1
    2021/06/10 09:36:52 - Doing some work
    2021/06/10 09:36:55 - all done!
#>

class loggerhead 
{
    #Log preloading
    $prelog = [System.Collections.ArrayList]@()# stashing spot for logs before we have a working directory
    $logFilePath = ""
    $logToFile = $false

    <# setLogFile - specify the location on disk where
        log records should be written.  All previously
        recorded log events will be written to the file,
        FIFO.  The 
    #>
    setLogFile([string]$path,[string]$filename){
        <# input validation, making sure we've been 
            given a something
        #>
        if(("" -eq $path) -or ($null -eq $path)){
            return
        }
        if(("" -eq $filename) -or ($null -eq $filename)){
            return
        }

        # Gotta make sure the path exists and filename is valid
        if((test-path $path) -and (test-path -isvalid "$path\$filename")){

            # changes the current target from the array list to a file
            $this.logToFile = $true
            $this.logFilePath = "$path\$filename"

            <# if there are any log events, flush them to disk
                After this, the prelog won't be used.
            #>
            if($this.prelog.count -gt 0){
                foreach($chunkOfWood in $this.prelog){
                    add-content $this.logFilePath -value $chunkOfWood
                }

                # delete all previous log entries from memory
                $this.prelog.clear()
            }
        }
    }

    <# writelog - ingests a new log event. A datetime stamp is 
        prepended to the log message.  If a file location has
        been specified, the event will be written to disk, else
        it is saved in the prelog. 
    #>
    writelog([string]$logRecord){
        $logstamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        if($this.logToFile){
            add-content $this.logFilePath -value "$logstamp - $logRecord"
        }
        else{
            $this.prelog.add("$logstamp - $logRecord")
        }
    }
}
