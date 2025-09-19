param(
    # Repository-Root: Standardwert ist das aktuelle Verzeichnis
    [string]$RepoRoot = ".",

    # Protokolldatei: Standardwert im RepoRoot
    [string]$ReportPath =  "$(get-date -f yyyy-MM-dd-HH-mm-ss)_autoreview-report.md"
)

function Get-ResultValueByStatusCode($statusCode) {
    if ($statusCode -eq 0) {
        return "✔ Success"
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

Write-Host ">>> Repository-Root: $RepoRoot"
Write-Host ">>> Report-Datei   : $reportFile"

# Alle Checks rekursiv einsammeln
Get-ChildItem -Path $checkFolder -Filter *.ps1 -Recurse | ForEach-Object {
    $scriptPath = $_.FullName
    try {
        $simplifiedCheckPath = [System.IO.Path]::GetRelativePath($checkFolder, $scriptPath)
        Write-Host "* Führe Check aus => " $simplifiedCheckPath
        $result = & $scriptPath -RepoRoot $RepoRoot
        $checkSuccess = $LASTEXITCODE        
        $results[$simplifiedCheckPath] = @($checkSuccess, $result)

    } catch {
        Write-Error "Exception bei der Ausführung von $`n$_"
    }
}

$markdown = @("# Prüfprotokoll")

foreach ($check in $results.Keys) {

    $checkResult = $results[$check]
    $status = Get-ResultValueByStatusCode($checkResult[0])
    $results = $checkResult[1]
    $markdown += "`n$check\: $status $results"
}

$markdown -join "`n" | Set-Content -Encoding UTF8 $reportFile
Write-Host $markdown
Write-Host "`nProtokoll gespeichert unter $reportFile"

# Exit-Code für Pipeline =>  vorerst immer erfolgreich
exit 0