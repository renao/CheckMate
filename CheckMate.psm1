function Invoke-CheckMate {
    <#
    .SYNOPSIS
    This is CheckMate. He will run everything inside a checks folder.

    .DESCRIPTION
    CheckMate is intended to run automated checks for a software projects repository. Its also meant to be easily extended by just adding PowerShell scripts to its checks/-folder. 

    .PARAMETER RepoRoot
    The root folder to run the checks from.

    .PARAMETER ReportPath
    (optional) Specifies the output path for the report - will be generated inside the repoPath otherwise.

    .PARAMETER ChecksBasePath
    (optional) Specifies the base path for the checks - will be resolved relative to this script if not absolute.

    .EXAMPLE
    Run only the checks from the `checks/Sanity` directory on the `./MySolution/MyProject` path and generate a `ChecksResult.md` file with the results:
    Invoke-CheckMate -RepoRoot "./MySolution/ProjectDirectory" -ReportPath "CheckResults.md" -ChecksBasePath "checks/Sanity"
    #>

    param(
        # Root directory to run the checks for
        [string]$RepoRoot = ".",

        # Base directory for the checks to run (relative to this script)
        [string]$ChecksBasePath = "checks",

        # name of the report file to be created

        [string]$ReportPath = "$(get-date -f yyyy-MM-dd-HH-mm-ss)_autoreview-report.md"

    )

    $workingDirectory = Resolve-RepoRoot -RepoRoot $RepoRoot

    if ($null -eq $workingDirectory) {
        throw "RepoRoot is not valid or does not exist: $RepoRoot"
    }

    $checkFolder = Resolve-ChecksPath $ChecksBasePath

    if ($null -eq $checkFolder) {

        throw "Checks Directory is not valid or does not exist: $ChecksBasePath"

    }

    $results = @{}

    # Alle Checks rekursiv einsammeln
    Get-ChildItem -Path $checkFolder -Filter *.ps1 -Recurse | ForEach-Object {
        $scriptPath = $_.FullName
        $simplifiedCheckPath = [System.IO.Path]::GetRelativePath($checkFolder, $scriptPath)

        try
        {
            $result = & $scriptPath -RepoRoot $workingDirectory
            $results[$simplifiedCheckPath] = Resolve-CheckResult -RawOutput $result -CheckPath $simplifiedCheckPath
        }
        catch
        {
            $results[$simplifiedCheckPath] = New-FailureResultFromException -ExceptionRecord $_ -CheckPath $simplifiedCheckPath
        }

    }

    Import-Module "$PSScriptRoot/common/MarkdownReport.psd1"

    $markdownReport = New-MarkdownReport -results $results

    $reportFile = if ([System.IO.Path]::IsPathRooted($ReportPath)) {
        $ReportPath
    }
    else {
        Join-Path $workingDirectory $ReportPath
    }

    Set-Content -Value $markdownReport -Encoding UTF8 $reportFile

    return Get-OverallResult $results
}

function Resolve-CheckResult {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$RawOutput,

        [Parameter(Mandatory = $true)]
        [string]$CheckPath
    )

    $resultHash = $null

    if ($RawOutput -is [System.Collections.IEnumerable] -and -not ($RawOutput -is [string])) {
        $allOutput = @($RawOutput)
        if ($allOutput.Count -gt 0) {
            $resultHash = $allOutput | Where-Object { $_ -is [hashtable] } | Select-Object -Last 1
        }
    }
    elseif ($RawOutput -is [hashtable]) {
        $resultHash = $RawOutput
    }

    if ($null -eq $resultHash) {
        return New-ContractFailureResult -CheckPath $CheckPath -Reason "The check did not return a hashtable as its last hashtable output object."
    }

    $requiredFields = @('Status', 'Message', 'ChangedItems', 'Errors')
    $missingFields = $requiredFields | Where-Object { -not $resultHash.ContainsKey($_) }

    if ($missingFields.Count -gt 0) {
        return New-ContractFailureResult -CheckPath $CheckPath -Reason "Missing required field(s): $($missingFields -join ', ')"
    }

    $allowedStatuses = @('Success', 'Failure', 'Skipped')
    if ($resultHash.Status -notin $allowedStatuses) {
        return New-ContractFailureResult -CheckPath $CheckPath -Reason "Invalid Status value '$($resultHash.Status)'. Allowed: Success, Failure, Skipped."
    }

    return @{
        Status       = [string]$resultHash.Status
        Message      = [string]$resultHash.Message
        ChangedItems = @($resultHash.ChangedItems)
        Errors       = @($resultHash.Errors)
    }
}

function New-ContractFailureResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CheckPath,

        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    return @{
        Status       = 'Failure'
        Message      = "Contract violation in '$CheckPath': $Reason"
        ChangedItems = @()
        Errors       = @()
    }
}

function New-FailureResultFromException {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ExceptionRecord,

        [Parameter(Mandatory = $true)]
        [string]$CheckPath
    )

    return @{
        Status       = 'Failure'
        Message      = "Exception while running '$CheckPath': $($ExceptionRecord.Exception.Message)"
        ChangedItems = @()
        Errors       = @($ExceptionRecord.Exception)
    }
}

function Resolve-RepoRoot {
    param(
        [string] $repoRoot
    )

    $resolvedPath = Resolve-Path $repoRoot -ErrorAction SilentlyContinue
    if (
        (-not $resolvedPath) -or
        (-not $(Test-Path -Path $resolvedPath -PathType Container)))
    {
        return $null
    }

    return $resolvedPath.Path
}

function Resolve-ChecksPath {
    param(
        [string] $checksPath
    )

    $resolvedPath = $checksPath

    if (-not [System.IO.Path]::IsPathRooted($checksPath)) {
        $resolvedPath = Join-Path $PSScriptRoot $checksPath
    }

    if (
        (-not $resolvedPath) -or
        (-not $(Test-Path -Path $resolvedPath -PathType Container)))
    {
        return $null
    }
    return $resolvedPath
}

function Get-OverallResult {
    param (
        [Hashtable] $results
    )

    $failedChecks = $results.Values | Where-Object { $_.Status -eq 'Failure' }

    if ($failedChecks.Count -eq 0) {
        return 0
    } else {
        return 1
    }
}