 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$PSScriptRoot\..\..\..\common\GitChecks.psd1"

$thresholdMonths = 12
$readmeName = "README.md"
$readmePath =  "$RepoRoot/$readmeName"

$ageCheckResult = Approve-FileIsYoungerThan -filePath $readmePath -repoRoot $RepoRoot -cutOffDay (Get-Date).AddMonths(-$thresholdMonths)

switch ($ageCheckResult) {
    0 {
        return @{
            Status = 'Success'
            Message = "$readmeName was modified in the last $thresholdMonths months."
            ChangedItems = @()
            Errors = @()
        }
    }

    1 {
        $lastCommitDate = (Get-LastFileCommitDate -filePath $readmePath -repoRoot $RepoRoot)
        return @{
            Status = 'Failure'
            Message = "$readmeName seems outdated. Consider updating the file - last commit: $lastCommitDate"
            ChangedItems = @($readmeName)
            Errors = @()
        }
    }

    20 {
        return @{
            Status = 'Failure'
            Message = "$readmeName is missing in the git repository"
            ChangedItems = @($readmeName)
            Errors = @()
        }
    }

    $null {
        return @{
            Status = 'Failure'
            Message = "$readmeName not found"
            ChangedItems = @($readmeName)
            Errors = @()
        }
    }
}
