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

function Format-ChangedItemMarkdown {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$ChangedItem
    )

    if ($null -eq $ChangedItem) {
        return '* (empty changed item)'
    }

    $message = [string]$ChangedItem.Message
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = $ChangedItem.ToString()
    }

    $locationParts = @()
    if (-not [string]::IsNullOrWhiteSpace([string]$ChangedItem.Path)) {
        $location = [string]$ChangedItem.Path
        if ($null -ne $ChangedItem.Line) {
            $location += ":$($ChangedItem.Line)"
            if ($null -ne $ChangedItem.Column) {
                $location += ":$($ChangedItem.Column)"
            }
        }
        $locationParts += $location
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$ChangedItem.Code)) {
        $locationParts += "Code $($ChangedItem.Code)"
    }

    $prefix = if ($locationParts.Count -gt 0) {
        "[$($locationParts -join ' | ')] "
    }
    else {
        ''
    }

    return "* $prefix$message"
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
        $normalizedChangedItems = @($check.NormalizedChangedItems)
        $errors = @($check.Errors)

        $markdown += "`n`n## $icon $($check.CheckPath)"
        $markdown += "`n* Status: $status"
        $markdown += "`n* Message: $message"
        $markdown += "`n* ChangedItems: $($changedItems.Count)"
        $markdown += "`n* Errors: $($errors.Count)"

        if ($changedItems.Count -gt 0) {
            $markdown += "`n* ChangedItems Details:"

            if ($normalizedChangedItems.Count -gt 0) {
                $changedItemsText = $normalizedChangedItems | ForEach-Object { Format-ChangedItemMarkdown -ChangedItem $_ }
            }
            else {
                $changedItemsText = $changedItems | ForEach-Object { "* $($_.ToString())" }
            }

            $markdown += "`n$($changedItemsText -join "`n")"
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
