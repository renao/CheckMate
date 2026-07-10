function New-CheckMateRunResult {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Results,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RepoRoot,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ChecksBasePath,

        [AllowNull()]
        [string]$ReportPath
    )

    $summary = Get-ResultsSummary -Results $Results
    $overallStatus = Get-OverallStatus -Results $Results
    $checks = $Results.Keys | Sort-Object | ForEach-Object {
        $checkPath = $_
        $checkResult = $Results[$checkPath]
        $normalizedChangedItems = @(ConvertTo-NormalizedChangedItems -ChangedItems $checkResult.ChangedItems -CheckPath $checkPath)

        [pscustomobject]@{
            CheckPath              = $checkPath
            Status                 = [string]$checkResult.Status
            Message                = [string]$checkResult.Message
            ChangedItems           = @($checkResult.ChangedItems)
            NormalizedChangedItems = $normalizedChangedItems
            Errors                 = @($checkResult.Errors)
            ChangedCount           = @($checkResult.ChangedItems).Count
            ErrorCount             = @($checkResult.Errors).Count
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

function ConvertTo-NormalizedChangedItems {
    param(
        [AllowNull()]
        [object[]]$ChangedItems,

        [Parameter(Mandatory = $true)]
        [string]$CheckPath
    )

    foreach ($item in @($ChangedItems)) {
        ConvertTo-NormalizedChangedItem -ChangedItem $item -CheckPath $CheckPath
    }
}

function ConvertTo-NormalizedChangedItem {
    param(
        [AllowNull()]
        [object]$ChangedItem,

        [Parameter(Mandatory = $true)]
        [string]$CheckPath
    )

    if ($null -eq $ChangedItem) {
        return [pscustomobject]@{
            CheckPath = $CheckPath
            Message   = ''
            Path      = $null
            Line      = $null
            Column    = $null
            Severity  = 'warning'
            Code      = $null
            RawItem   = $null
        }
    }

    if ($ChangedItem -is [string]) {
        return [pscustomobject]@{
            CheckPath = $CheckPath
            Message   = $ChangedItem
            Path      = $null
            Line      = $null
            Column    = $null
            Severity  = 'warning'
            Code      = $null
            RawItem   = $ChangedItem
        }
    }

    $propertyBag = $null

    if ($ChangedItem -is [hashtable]) {
        $propertyBag = $ChangedItem
    }
    else {
        $propertyBag = @{}
        foreach ($property in $ChangedItem.PSObject.Properties) {
            $propertyBag[$property.Name] = $property.Value
        }
    }

    $message = Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Message', 'Text', 'Description', 'Title')
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = $ChangedItem.ToString()
    }

    $path = Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Path', 'File', 'FilePath', 'SourcePath')
    $line = ConvertTo-NullableInt (Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Line', 'LineNumber'))
    $column = ConvertTo-NullableInt (Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Column', 'ColumnNumber'))
    $severity = Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Severity', 'Level')
    if ([string]::IsNullOrWhiteSpace($severity)) {
        $severity = 'warning'
    }
    $code = Get-ChangedItemValue -PropertyBag $propertyBag -PreferredNames @('Code', 'RuleId', 'Id')

    return [pscustomobject]@{
        CheckPath = $CheckPath
        Message   = [string]$message
        Path      = if ([string]::IsNullOrWhiteSpace($path)) { $null } else { [string]$path }
        Line      = $line
        Column    = $column
        Severity  = [string]$severity
        Code      = if ([string]::IsNullOrWhiteSpace($code)) { $null } else { [string]$code }
        RawItem   = $ChangedItem
    }
}

function Get-ChangedItemValue {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$PropertyBag,

        [Parameter(Mandatory = $true)]
        [string[]]$PreferredNames
    )

    foreach ($name in $PreferredNames) {
        if ($PropertyBag.ContainsKey($name)) {
            return $PropertyBag[$name]
        }

        $match = $PropertyBag.Keys | Where-Object { $_ -ieq $name } | Select-Object -First 1
        if ($null -ne $match) {
            return $PropertyBag[$match]
        }
    }

    return $null
}

function ConvertTo-NullableInt {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    $parsedValue = 0
    if ([int]::TryParse([string]$Value, [ref]$parsedValue)) {
        return $parsedValue
    }

    return $null
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