 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$RepoRoot/common/GitChecks.psm1"

$thresholdMonths = 12
$readmePath = "$RepoRoot/CheckMate.ps1"

$ageCheckResult = Approve-FileIsYoungerThan -filePath $readmePath -cutOffDay (Get-Date).AddMonths(-$thresholdMonths)

switch ($ageCheckResult) {
    0 {
        "Datei wurde in den letzten $thresholdMonths Monaten aktualisert."
        exit 0
    }
    1 {
        $lastCommitDate = (Get-LastFileCommit -filePath $readmePath)
        "Datei ist veraltet. Letzter Commit am $lastCommitDate"
        exit 1
    }
    $null {
        "Konnte $readmePath nicht finden"
        exit 1
    }
}