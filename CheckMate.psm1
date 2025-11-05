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
    (optional) Specifies the output path for the report - will be generated inside the repoPath otherwise.

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
        [string]$ReportPath =  "$(get-date -f yyyy-MM-dd-HH-mm-ss)_autoreview-report.md"
    )
   
    $workingDirectory = Resolve-RepoRoot -RepoRoot $RepoRoot

    if ($null -eq $workingDirectory) {
        throw "RepoRoot is not valid or does not exist: $RepoRoot"
    }
    
    $checkFolder = Join-Path $PSScriptRoot $ChecksBasePath
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
            $results[$scriptPath] = @(1, "Threw Exception: $_")

            return 1
        }
    }

    Import-Module "$PSScriptRoot/common/MarkdownReport.psd1"
    $markdownReport = New-MarkdownReport -results $results

    Write-Output "`n$markdownReport"


    $reportFile  = if ([System.IO.Path]::IsPathRooted($ReportPath)) {
        $ReportPath
    } else {
        Join-Path $workingDirectory $ReportPath
    }

    Set-Content -Value $markdownReport -Encoding UTF8 $reportFile 
    Write-Output "`n See report file: $reportFile"

    return 0
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