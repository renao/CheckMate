function _Get-ResultValueByStatus($status) {
    switch ($status) {
        'Success' { return '✅' }
        'Skipped' { return '⏭️' }
        default { return '❌' }
    }
}

function ConvertTo-CheckMateRunResult {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$InputObject
    )

    if ($InputObject -is [hashtable]) {
        Import-Module "$PSScriptRoot/CheckMateResult.psd1" -Force
        return New-CheckMateRunResult -Results $InputObject -RepoRoot '' -ChecksBasePath '' -ReportPath $null
    }

    if ($null -ne $InputObject.PSObject.Properties['Checks'] -and $null -ne $InputObject.PSObject.Properties['Summary']) {
        return $InputObject
    }

    throw 'Unsupported input for New-MarkdownReport. Provide either the raw results hashtable or a structured CheckMate result object.'
}

function New-MarkdownReport {
    <#
    .SYNOPSIS
    Creates a new markdown report.

    .DESCRIPTION
    Creates a markdown report from a result set.

    .PARAMETER InputObject
    Either a Hashtable in the form of [Name of the check] => [Status, Message,
    ChangedItems, Errors] or a structured CheckMate result object.

    .EXAMPLE
    New-MarkdownReport -InputObject $checkResults
    
    #>
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [object] $InputObject
    )

    $checkMateResult = ConvertTo-CheckMateRunResult -InputObject $InputObject
    $markdown = "# CheckMate Report`n"
    foreach ($check in @($checkMateResult.Checks)) {
        $status = [string]$check.Status
        $icon = _Get-ResultValueByStatus -status $status
        $message = [string]$check.Message
        $changedItems = @($check.ChangedItems)
        $errors = @($check.Errors)

        $markdown += "`n`n## $icon $($check.CheckPath)"
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

    $summary = $checkMateResult.Summary
    $markdown += "`n`n## Summary"
    $markdown += "`n* Success: $($summary.SuccessCount)"
    $markdown += "`n* Failure: $($summary.FailureCount)"
    $markdown += "`n* Skipped: $($summary.SkippedCount)"
    $markdown += "`n* ChangedItems: $($summary.ChangedItemCount)"
    $markdown += "`n* Errors: $($summary.ErrorCount)"

    return $markdown -join "`n"
}
