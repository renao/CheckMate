 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$PSScriptRoot\..\..\..\common\FileChecks.psd1"

$readmeName = "README.md"
$readmePath =  "$RepoRoot/$readmeName"
$readmeExists = Approve-FileExists($readmePath)

if ($readmeExists) {
    return @{
        Status = 'Success'
        Message = "$readmeName exists"
        ChangedItems = @()
        Errors = @()
    }
}

return @{
    Status = 'Failure'
    Message = "$readmeName missing - add a meaningful $readmeName file"
    ChangedItems = @($readmeName)
    Errors = @()
}
