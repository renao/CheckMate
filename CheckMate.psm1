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

        try
        {
            $simplifiedCheckPath = [System.IO.Path]::GetRelativePath($checkFolder, $scriptPath)
            $result = & $scriptPath -RepoRoot $workingDirectory
            $checkSuccess = $LASTEXITCODE
            $results[$simplifiedCheckPath] = @($checkSuccess, $result)
        }
        catch
        {
            Write-Error "Exception while running `n$_"
            $results[$simplifiedCheckPath] = @(1, "Threw Exception: $_")
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

    $allSuccess = $results.Values | ForEach-Object { $_[0] } | Where-Object { $_ -ne 0 }

    if ($allSuccess.Count -eq 0) {
        return 0
    } else {
        return 1
    }
}