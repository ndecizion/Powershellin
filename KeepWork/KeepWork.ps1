<#
.SYNOPSIS
    A collection of tools for tracking completion of recurring tasks and production of artifacts.
.DESCRIPTION
    Provides tools for tracking recurring task completion & production of work artifacts.
.PARAMETER NewTaskName
#>
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$NewTaskName,
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$ExpectedCompletionFrequency,
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]$ExpectedDayOfCompletion
)

$inventoryDefinitionFile = "$home\OneDrive - Premise Health\Documents\Keepwork\config\inventory.json"
$tasksDefinitionFile = "$home\OneDrive - Premise Health\Documents\Keepwork\config\tasks.json"

$inventory = $null
$tasks = $null
if(test-path $inventoryDefinitionFile){
    $inventory = [inventoryObject](Get-Content $inventoryDefinitionFile | Out-String | ConvertFrom-Json)
}
if(test-path $tasksDefinitionFile){
    $tasks = (Get-Content $tasksDefinitionFile | Out-String | ConvertFrom-Json)
}

