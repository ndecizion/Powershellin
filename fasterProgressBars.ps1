<#This code helps improve code processing time. processtime of the entire code
is lengthed by using prgress counter but adding in a stopwatch helps counteract
that#>

#set up Stopwatch and progress counter variables
$progresscounter = 0
$sw = [System.Diagnostics.Stopwatch]::StartNew()

#as you proceed with code and need to increment the counter use the following
$progresscounter ++


<#run the stopwatch while displaying the progress counter. replace $collection with the array being processed for count to be geneterated
code waits 500 milliseconds between progress display and then displays the current progress counter at that time versus each change in the counter#>
if($sw.Elapsed.TotalMilliseconds -ge 500)
{
    Write-Progress -Activity "What is occuring" -Status "Item: $progresscounter of $($collection.Count)" -PercentComplete ($progresscounter/$collection.Count*100)
    $sw.Reset()
    $sw.Start()
}   
