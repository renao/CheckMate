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
        return @{
            Status = 'Success'
            Message = 'Die benötige .editorconfig existiert'
            ChangedItems = @()
            Errors = @()
        }
    } else {
        return @{
            Status = 'Failure'
            Message = ".editorconfig im falschen Verzeichnis: $editorConfigPath"
            ChangedItems = @($editorConfigPath)
            Errors = @()
        }
    }
} else {
    return @{
        Status = 'Failure'
        Message = "Mehrere ($($allEditorConfigs.Count)) .editorconfig Dateien in $RepoRoot gefunden."
        ChangedItems = @($allEditorConfigs.FullName)
        Errors = @()
    }
}
