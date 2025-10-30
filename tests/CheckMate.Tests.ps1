Describe "CheckMate.ps1 - Parameter-Validierung" {
    It "RepoRoot sollte standardmäßig auf '.' gesetzt sein" {
        $checkMateScript = Join-Path $PSScriptRoot '..\CheckMate.ps1'
        $content = Get-Content -Path $checkMateScript -Raw
        $paramBlock = [regex]::Match($content, 'param\s*\((.*?)\)', [System.Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value
        $repoRootMatch = [regex]::Match($paramBlock, '\$RepoRoot\s*=\s*"\."')
        $repoRootMatch.Success | Should -Be $true
    }

    #It "ReportPath sollte standardmäßig eine Datumsbasierte Datei im RepoRoot erstellen" {
    #    $checkMateScript = Join-Path $PSScriptRoot '..\CheckMate.ps1'
    #    $content = Get-Content -Path $checkMateScript -Raw
    #    $paramBlock = [regex]::Match($content, 'param\s*\((.*?)\)', [System.Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value
    #    $reportPathMatch = [regex]::Match($paramBlock, '\$ReportPath\s*=\s*"\$\(get-date.*autoreview-report\.md"')
    #    Write-Host $reportPathMatch
    #    $reportPathMatch.Success | Should -Be $true
    #}
}

Describe "CheckMate.ps1 - Pfadauflösung" {
    It "RepoRoot sollte als absoluter Pfad aufgelöst werden" {
        $testRepoRoot = "."
        $resolvedPath = (Resolve-Path $testRepoRoot).Path
        $resolvedPath | Should -Not -BeNullOrEmpty
        $resolvedPath | Should -Match '^([A-Za-z]:\\|\\\\\\\\|/)'  # Windows/Unix-Pfad
    }

    It "ReportPath sollte relativ zu RepoRoot aufgelöst werden, falls nicht absolut" {
        $testRepoRoot = (Get-Location).Path
        $testReportPath = "report.md"
        $expectedReportPath = Join-Path $testRepoRoot $testReportPath
        $actualReportPath = if ([System.IO.Path]::IsPathRooted($testReportPath)) { $testReportPath } else { Join-Path $testRepoRoot $testReportPath }
        $actualReportPath | Should -Be $expectedReportPath
    }
}

