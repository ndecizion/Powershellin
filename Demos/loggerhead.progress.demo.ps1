
import-module ($env:Source + "Powershellin\Mods\Loggerhead.psm1")
$inLoopSleepTime = 10
$oneTotal = 100
for($i = 0; $i -le $oneTotal; $i++){
	Update-ProgressBar -Activity "test1" -progressCounter $i -totalCount $oneTotal
	start-sleep -Milliseconds $inLoopSleepTime
}
start-sleep -Milliseconds 500
$twoTotal = 50
for($i = 0; $i -le $twoTotal; $i++){
	Update-ProgressBar -Activity "test2" -progressCounter $i -totalCount ($twoTotal*2)
	start-sleep -Milliseconds $inLoopSleepTime
}
Stop-ProgressBar -Activity "test2"
start-sleep -Milliseconds 500

$threeATotal = 15
$threeBTotal = 60
for($i = 0; $i -le $threeATotal; $i++){
	Update-ProgressBar -Activity "test3a" -progressCounter $i -totalCount $threeATotal
	for($n=0; $n -le $threeBTotal; $n++){
		Update-ProgressBar -Activity "test3b" -ProgressCounter $n -TotalCount $threeBTotal
		start-sleep -Milliseconds $inLoopSleepTime
	}
}
Stop-ProgressBar -Activity "test3a"
Stop-ProgressBar -Activity "test3b"
start-sleep -Milliseconds 500
$fourTotal = 50
for($i = 0; $i -le $fourTotal; $i++){
	Update-ProgressBar -Activity "test4" -Status "$($i+4) zebras" -progressCounter $i -totalCount $fourTotal
	start-sleep -Milliseconds $inLoopSleepTime
}