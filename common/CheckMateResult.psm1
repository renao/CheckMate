function New-CheckMateRunResult {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Results,

        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,

        [Parameter(Mandatory = $true)]
        [string]$ChecksBasePath,

        [AllowNull()]
        [string]$ReportPath
    )

    $summary = Get-ResultsSummary -Results $Results
    $overallStatus = Get-OverallStatus -Results $Results
    $checks = $Results.Keys | Sort-Object | ForEach-Object {
        $checkPath = $_
        $checkResult = $Results[$checkPath]

        [pscustomobject]@{
            CheckPath    = $checkPath
            Status       = [string]$checkResult.Status
            Message      = [string]$checkResult.Message
            ChangedItems = @($checkResult.ChangedItems)
            Errors       = @($checkResult.Errors)
            ChangedCount = @($checkResult.ChangedItems).Count
            ErrorCount   = @($checkResult.Errors).Count
        }
    }

    return [pscustomobject]@{
        RepoRoot       = $RepoRoot
        ChecksBasePath = $ChecksBasePath
        ReportPath     = $ReportPath
        OverallStatus  = $overallStatus
        ExitCode       = if ($overallStatus -eq 'Failure') { 1 } else { 0 }
        Summary        = $summary
        Checks         = @($checks)
    }
}

function Get-ResultsSummary {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Results
    )

    $successCount = @($Results.Values | Where-Object { $_.Status -eq 'Success' }).Count
    $failureCount = @($Results.Values | Where-Object { $_.Status -eq 'Failure' }).Count
    $skippedCount = @($Results.Values | Where-Object { $_.Status -eq 'Skipped' }).Count
    $changedItemCount = @($Results.Values | ForEach-Object { @($_.ChangedItems).Count } | Measure-Object -Sum).Sum
    $errorCount = @($Results.Values | ForEach-Object { @($_.Errors).Count } | Measure-Object -Sum).Sum

    if ($null -eq $changedItemCount) {
        $changedItemCount = 0
    }

    if ($null -eq $errorCount) {
        $errorCount = 0
    }

    return [pscustomobject]@{
        TotalChecks      = $Results.Count
        SuccessCount     = $successCount
        FailureCount     = $failureCount
        SkippedCount     = $skippedCount
        ChangedItemCount = $changedItemCount
        ErrorCount       = $errorCount
    }
}

function Get-OverallStatus {
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Results
    )

    $failedChecks = $Results.Values | Where-Object { $_.Status -eq 'Failure' }

    if ($failedChecks.Count -eq 0) {
        return 'Success'
    }

    return 'Failure'
}

Export-ModuleMember -Function @('New-CheckMateRunResult', 'Get-ResultsSummary', 'Get-OverallStatus')