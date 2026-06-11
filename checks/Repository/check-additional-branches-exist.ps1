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

$branches = Get-RemoteBranches -repoRoot $RepoRoot
$branches = $branches | Where-Object { $_ -notin $allowed_branches }


if ($branches.Count -eq 0) {
    return @{
        Status = 'Success'
        Message = 'No additional branches found, only main branches exists'
        ChangedItems = @()
        Errors = @()
    }
}

return @{
    Status = 'Failure'
    Message = "Additional branches found: $($branches -join ', ')"
    ChangedItems = @($branches)
    Errors = @()
}