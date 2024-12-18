<#
.SYNOPSIS
    Testing for the KeepWorkTask class.
.DESCRIPTION
    Because we're testing a class, this pester script needs to be run in a new terminal each time
    changes are made to KeepworkTask.ps1.  This is due to classes not being loaded in memory based
    on file timestamps, but based on class name or filename updates.  Pretty dumb stuff.
.EXAMPLE
$KeepworkTaskPesterScriptPath = "c:\users\adam.twitty\Git\KeepWork\KeepWorkTask_pester.ps1"
$KeepworkTaskPesterParameters = @{scriptPath = "c:\users\adam.twitty\Git\KeepWork\"}
$KeepworkTaskPesterContainer = New-PesterContainer -path $KeepworkTaskPesterScriptPath -Data $KeepworkTaskPesterParameters
Invoke-Pester -Container $KeepworkTaskPesterContainer
#>
param(
    [ValidateNotNull()]
    [String]
    $scriptPath
)
Describe 'KeepworkTask'{
    BeforeAll{
        Test-Path $scriptPath
        . "$scriptPath\KeepworkTask.ps1"
    }
    It "should throw an error when initialized with no name"{
        
        {[KeepworkTask]::new(@{})} | Should -Throw -ExpectedMessage "Unable to initialize KeepworkTask with no name. Provided hashtable missing TaskName."
    }
    It "should theow an exception when initialized with no completion frequency"{
        {[KeepworkTask]::new(@{taskName="TestTask1"})} | Should -Throw -ExpectedMessage "Unable to initialize KeepworkTask with no name. Provided hashtable missing completionFrequency."
    }
    It "should retain a name and time interval"{
        $span = New-TimeSpan -Days 14
        $testTask = [KeepworkTask]::new(@{taskName="TestTask1";completionFrequency=$span})
        $testTask.TaskName | Should -Be "TestTask1"
        $testTask.completionFrequency.days | Should -Be 14
    }
}