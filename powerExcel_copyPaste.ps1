
$objExcel = New-Object -ComObject Excel.Application
#region Helper Functions
<######################
## Convert-ColNumToAlpha Helper function 
##
## This takes an integer column number and converts it to the Excel column format
######################>
function Convert-ColNumToAlpha([int]$excelColumnNumber)
{
    # keep from erroring on negative numbers
    if($excelColumnNumber -le 0)
    {
        return $null
    }

    $a1Value = $null
    while($excelColumnNumber -gt 0)
    {
        #will be 0 for input numbers less than 26
        $multiplier = [math]::floor([decimal]($excelColumnNumber / 26))

        #will be 0 if input is evenly divisible by 26, like 52
        $modulo = $excelColumnNumber % 26
        if($modulo -eq 0)
        {
            $multiplier--
            $modulo = 26
        }

        #convert the current modulus to a letter, and add the previous letters after it.
        $a1Value = ([char]($modulo + 64)) + $a1Value

        #start again with the multiplier
        $excelColumnNumber = $multiplier
    }
    #return our compiled letters
    return $a1Value
}
#endregion Helper Functions
$destWorkbook = $objExcel.Workbooks.Open($destinationPath)
$WorkBook = $objExcel.Workbooks.Open($sourceFile.FullName)

#should be able to do .Sheets[0] or [1] if there's only one sheet in the template
$sourceSheet = $WorkBook.Sheets | where {$_.Name -match $sourceSheetName}
$destSheet = $destWorkbook.sheets | where {$_.Name -eq $destSheetName}

# identify source data ranges
$srcLastRow = $sourceSheet.UsedRange.rows.Count
$srcLastColumn = $sourceSheet.UsedRange.Columns.count
$srcLastColAlpha = Convert-ColNumToAlpha $srcLastColumn
    
# get the source range
$srcRange = $sourceSheet.Range("A$($sourceHeaderRow+1):$srcLastColAlpha$srcLastRow")

$destHeaderRow = 1 
# match the appropriate cell based on header name
$anchorCell = $destSheet.Rows[$destHeaderRow].Find($sourceSheet.Cells($sourceHeaderRow,1).value2)

# identify the last row with data.  
$dstLastUsedRow = $destSheet.UsedRange.rows.Count
        
# because the template has formulas on the first row they appear to be used when they aren't. 
if($dstLastUsedRow -eq ($destHeaderRow + 1))
{
    $dstLastUsedRow--
}
# identify target range based on the information above
$dstCellTopLeft = Convert-ColNumToAlpha $anchorCell.Column
$dstCellTopLeft += $dstLastUsedRow + 1
$dstCellBotRight = Convert-ColNumToAlpha($anchorCell.Column + $srcLastColumn)
$dstCellBotRight += $dstLastUsedRow + $srcLastRow - $sourceHeaderRow

#Paste the data from the other spreadsheet
$destRange = $destSheet.Range($dstCellTopLeft + ":" + $dstCellBotRight)
        
# Copy and paste the data.
$srcRange.Copy() | Out-Null
$destSheet.Paste($destRange)| Out-Null