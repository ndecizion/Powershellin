
import-module ($env:Source + "Powershellin\Mods\Loggerhead.psm1")

for($i = 0; $i -le 100; $i++){
	Update-ProgressBar -Activity "test1" -progressCounter $i -totalCount 100
	start-sleep -Milliseconds 15
}
start-sleep -Milliseconds 15
for($i = 0; $i -le 50; $i++){
	Update-ProgressBar -Activity "test2" -progressCounter $i -totalCount 100
	start-sleep -Milliseconds 15
}
Stop-ProgressBar -Activity "test2"
start-sleep -Milliseconds 15

for($i = 0; $i -le 10; $i++){
	Update-ProgressBar -Activity "test3a" -progressCounter $i -totalCount 10
	for($n=0; $n -le 15; $n++){
		Update-ProgressBar -Activity "test3b" -ProgressCounter $n -TotalCount 15
		start-sleep -Milliseconds 15
	}
}
Stop-ProgressBar -Activity "test3a"
Stop-ProgressBar -Activity "test3b"
start-sleep -Milliseconds 15
for($i = 0; $i -le 50; $i++){
	Update-ProgressBar -Activity "test4" -Status "$($i+4) zebras" -progressCounter $i -totalCount 50
	start-sleep -Milliseconds 15
}