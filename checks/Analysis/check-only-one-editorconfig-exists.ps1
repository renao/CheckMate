 # Überprüft ob nur genau eine .editorconfig-Datei im Projekt existiert
 
 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )

$allEditorConfigs = Get-ChildItem -Path $RepoRoot -Recurse -Filter ".editorconfig" -File |
    Where-Object { $_.FullName -notmatch [regex]::Escape("\BuildSupport\") }

if ($allEditorConfigs.Count -eq 1) {
    $editorConfigPath = $allEditorConfigs[0].FullName
    $expectedPath = Join-Path $RepoRoot ".editorconfig"

    if ($editorConfigPath -eq $expectedPath) {
        "Die benötige .editorconfig existiert"
        exit 0
    } else {
        ".editorconfig im falschen Verzeichnis: $editorConfigPath"
        exit 1
    }
} else {
    "Mehrere ($($allEditorConfigs.Count)) .editorconfig Dateien in $RepoRoot gefunden"
    exit 1
}