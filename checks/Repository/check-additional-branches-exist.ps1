 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

Import-Module "$PSScriptRoot\..\..\common\GitChecks.psd1"

$allowed_branches = @(
    'origin/main',
    'origin/master',
    'origin/develop',
    'origin/HEAD -> origin/main',
    'origin/HEAD -> origin/master',
    'origin/HEAD -> origin/develop')

$branches = Get-RemoteBranches
$branches = $branches | Where-Object { $_ -notin $allowed_branches }


if ($branches.Count -eq 0) {
    "No additional branches found, only main branches exists"
    exit 0
}

"Additional branches found: `n
$($branches -join "`n"): `n
consider removing them or adding them to the main branch"
exit 1