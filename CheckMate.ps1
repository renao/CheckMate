param(
    # Repository-Root: Standardwert ist das aktuelle Verzeichnis
    [string]$RepoRoot = ".",

    # Protokolldatei: Standardwert im RepoRoot
    [string]$ReportPath =  "$(get-date -f yyyy-MM-dd-HH-mm-ss)_autoreview-report.md"
)

function Get-ResultValueByStatusCode($statusCode) {
    if ($statusCode -eq 0) {
        return "✅ Success"
    } else {
        return "❌ Failed"
    }
}

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
        $results[$scriptPath] = @(Get-ResultValueByStatusCode(20), "Threw Exception: $_")
    }
}

$runChecks = $results.Keys | Sort-Object

foreach ($check in $runChecks) {

    $checkResult = $results[$check]
    $status = Get-ResultValueByStatusCode($checkResult[0])
    $checkInfos = $checkResult[1]
    $markdown += "`n$check\: $status $checkInfos"
}

$markdown -join "`n" # | Set-Content -Encoding UTF8 $reportFile
# Write-Host $markdown
# Write-Host "`nProtokoll gespeichert unter $reportFile"

# Exit-Code für Pipeline =>  vorerst immer erfolgreich
exit 0