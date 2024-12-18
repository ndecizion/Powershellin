<#
.SYNOPSIS

#>
Class KeepworkTask{
    [String] $taskName
    [TimeSpan] $completionFrequency
    [Boolean] $notesRequired
    [Regex] $noteValidation

    KeepworkTask() { $this.Init($()) }
    KeepworkTask([hashtable]$Properties) {$this.init($Properties)}
    KeepworkTask([string]$TaskName, 
                [TimeSpan]$completionFrequency,
                [Boolean]$notesRequired=$false, 
                [Regex]$noteValidation=$null){
        $this.init(@{
            taskName = $TaskName
            completionFrequency = $completionFrequency
            notesRequired = $notesRequired
            noteValidation = $noteValidation
        })
    }

    [void] init([hashtable]$Properties){
        if($Properties.ContainsKey("taskName")){
            $this.taskName = $properties["taskName"]
        }
        else {
            Throw ("Unable to initialize KeepworkTask with no name. Provided hashtable missing TaskName.")
        }
        if($Properties.ContainsKey("completionFrequency")){
            $this.completionFrequency = $Properties["completionFrequency"]
        }
        else {
            Throw ("Unable to initialize KeepworkTask with no name. Provided hashtable missing completionFrequency.")
        }
        if($Properties.ContainsKey("noteValidation")){
            if($Properties["noteValidation"].GetType() -eq [regex]){
                $this.noteValidation = $Properties["noteValidation"]
            }
            else{
                Throw ("Unable to initialize KeepworkTask with provided noteValidation.  Must be valid regex.")
            }
        }
        else{
            $this.noteValidation = $null
        }
        if($Properties.ContainsKey("notesRequired")){
            $this.notesRequired = $Properties["notesRequired"]
        }
        else{
            $this.notesRequired = $false
        }
    }
    [hashtable] createCompletedTaskEntry([datetime]$time = (get-date)){
        if($this.notesRequired){
            Throw ("Unable to generate completed task entry.  Notes are required, but none were provided.")
        }
        return @{
            taskname = $this.taskName
            completedOn = $time
        }
    }
    [hashtable] createCompletedTaskEntry([string]$notes, [datetime]$time = (get-date)){
        $returnHash = @{}
        $returnHash["taskName"] = $this.taskName
        $returnHash["completionTime"] = $time
        if($null -ne $this.noteValidation){
            if($notes -notmatch $this.noteValidation){
                Throw ("Provided notes do not meet requirements of provided note validation.")
            }
        }
        $returnHash["completionNotes"] = $notes
        return $returnHash
    }
}