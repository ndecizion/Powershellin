
#Outlook attachment dump
$outlook = New-Object -ComObject Outlook.Application
$mapi = $outlook.GetNamespace("MAPI")
# this wil grab your personal inbox.
$inbox = $mapi.GetDefaultFolder(6)
$filepath = "$HOME\Downloads\Attachments"
foreach($mailItem in $inbox.Items){
    #$SendName = $_.SenderName
    foreach($attachment in $mailItem.attachments){
        Write-Host $attachment.filename
        $name = $attachment.filename
        <#If( -Not (Test-Path -Path "$filepath\$name")) {
            $attachment.saveasfile((Join-Path $filepath "$name"))
        }#>
    }
}
