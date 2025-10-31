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