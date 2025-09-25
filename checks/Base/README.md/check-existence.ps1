 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$PSScriptRoot\..\..\..\common\FileChecks.psd1"

$readmeName = "README.md"
$readmePath =  "$RepoRoot/$readmeName"
$readmeExists = Approve-FileExists($readmePath)

if ($readmeExists) {
    "$readmeName exists"
    exit 0
}

"$readmeName missing"
exit 1