 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$PSScriptRoot\..\..\..\common\GitChecks.psd1"

$thresholdMonths = 12
$readmeName = "README.md"
$readmePath =  "$RepoRoot/$readmeName"

$ageCheckResult = Approve-FileIsYoungerThan -filePath $readmePath -cutOffDay (Get-Date).AddMonths(-$thresholdMonths)

switch ($ageCheckResult) {
    0 {
        "$readmeName was modified in the last $thresholdMonths months."
        exit 0
    }

    1 {
        $lastCommitDate = (Get-LastFileCommitDate -filePath $readmePath)
        "$readmeName is outdated - last commit: $lastCommitDate"
        exit 1
    }

    20 {
        "$readmeName is missing in the git repository"
        exit 1
    }

    $null {
        "$readmeName not found"
        exit 1
    }
}