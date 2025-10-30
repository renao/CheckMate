<#
    .SYNOPSIS
    This is CheckMate. He will run everything you give him inside a "checks/" folder.

    .DESCRIPTION
    CheckMate is intended to run automated checks for a software projects repository. Its also meant to be easily extended by just adding PowerShell scripts to its checks/-folder.

    .PARAMETER RepoRoot
    The root folder to run the checks from.

    .PARAMETER ReportPath
    (optional) Specifies the output path for the report - will be generated inside the repoPath otherwise.

    .EXAMPLE
    ./CheckMate.ps1 -RepoRoot "." -ReportPath "CheckResults.md"
    
    #>

param(
    # Repository-Root: Standardwert ist das aktuelle Verzeichnis
    [string]$RepoRoot = ".",

    # Protokolldatei: Standardwert im RepoRoot
    [string]$ReportPath =  "$(get-date -f yyyy-MM-dd-HH-mm-ss)_autoreview-report.md"
)

Import-Module "$PSScriptRoot/common/MarkdownReport.psd1"

# Absolute Pfade berechnen
$RepoRoot   = (Resolve-Path $RepoRoot).Path
$checkFolder = Join-Path $PSScriptRoot "checks"
$reportFile  = if ([System.IO.Path]::IsPathRooted($ReportPath)) {
    $ReportPath
} else {
    Join-Path $RepoRoot $ReportPath
}

$results = @{}

Write-Host ">>> Repository Root: $RepoRoot"
Write-Host ">>> Report file being generated: $reportFile"

# Alle Checks rekursiv einsammeln
Get-ChildItem -Path $checkFolder -Filter *.ps1 -Recurse | ForEach-Object {
    $scriptPath = $_.FullName

    try
    {
        $simplifiedCheckPath = [System.IO.Path]::GetRelativePath($checkFolder, $scriptPath)
        Write-Host "Executing => " $simplifiedCheckPath
        $result = & $scriptPath -RepoRoot $RepoRoot
        $checkSuccess = $LASTEXITCODE
        $results[$simplifiedCheckPath] = @($checkSuccess, $result)
    }
    catch
    {
        Write-Error "Exception while running `n$_"
        $results[$scriptPath] = @(1, "Threw Exception: $_")
    }
}

$markdownReport = New-MarkdownReport -results $results

Write-Host "`n$markdownReport"

Set-Content -Value $markdownReport -Encoding UTF8 $reportFile 
Write-Host "`n See report file: $reportFile"

exit 0