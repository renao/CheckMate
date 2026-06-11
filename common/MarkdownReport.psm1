function _Get-ResultValueByStatus($status) {
    switch ($status) {
        'Success' { return '✅' }
        'Skipped' { return '⏭️' }
        default { return '❌' }
    }
}

function New-MarkdownReport {
    <#
    .SYNOPSIS
    Creates a new markdown report.

    .DESCRIPTION
    Creates a markdown report from a result set.

    .PARAMETER results
    A Hashtable in the form of [Name of the check] => [Status, Message, ChangedItems, Errors]

    .EXAMPLE
    New-MarkdownReport -results $checkResults
    
    #>
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true)]
        [Hashtable] $results
    )

    $markdown = "# CheckMate Report`n"
    $runChecks = $results.Keys | Sort-Object

    $statusCounts = @{
        Success = 0
        Failure = 0
        Skipped = 0
    }

    foreach ($check in $runChecks) {

        $checkResult = $results[$check]
        $status = [string]$checkResult.Status
        $icon = _Get-ResultValueByStatus -status $status
        $message = [string]$checkResult.Message
        $changedItems = @($checkResult.ChangedItems)
        $errors = @($checkResult.Errors)

        if ($statusCounts.ContainsKey($status)) {
            $statusCounts[$status] = $statusCounts[$status] + 1
        }

        $markdown += "`n`n## $icon $check"
        $markdown += "`n* Status: $status"
        $markdown += "`n* Message: $message"
        $markdown += "`n* ChangedItems: $($changedItems.Count)"
        $markdown += "`n* Errors: $($errors.Count)"

        if ($changedItems.Count -gt 0) {
            $changedItemsText = ($changedItems | ForEach-Object { $_.ToString() }) -join " | "
            $markdown += "`n* ChangedItems Details: $changedItemsText"
        }

        if ($errors.Count -gt 0) {
            $errorText = ($errors | ForEach-Object {
                if ($_ -is [System.Exception]) { $_.Message }
                else { $_.ToString() }
            }) -join " | "
            $markdown += "`n* Error Details: $errorText"
        }
    }

    $markdown += "`n`n## Summary"
    $markdown += "`n* Success: $($statusCounts.Success)"
    $markdown += "`n* Failure: $($statusCounts.Failure)"
    $markdown += "`n* Skipped: $($statusCounts.Skipped)"

    return $markdown -join "`n"
}
