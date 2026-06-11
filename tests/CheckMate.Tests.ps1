BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\CheckMate.psd1'
    Import-Module $modulePath -Force
}

Describe "Invoke-CheckMate" {
    Context "Validating parameters" {
        It "Exits FAILED when repository path does not exist" {
            { Invoke-CheckMate -RepoRoot "C:\nonexistant" } | Should -Throw
        }
    }

    Context "Status contract behavior" {
        It "Returns failed overall result when at least one check fails and continues on throwing checks" {
            $fixtureChecksPath = Join-Path $PSScriptRoot 'fixtures\contract-checks'
            $reportPath = Join-Path $TestDrive 'report.md'

            $overallResult = Invoke-CheckMate -RepoRoot $PSScriptRoot -ChecksBasePath $fixtureChecksPath -ReportPath $reportPath

            $overallResult | Should -Be 1
            Test-Path $reportPath | Should -BeTrue

            $reportContent = Get-Content -Path $reportPath -Raw
            $reportContent | Should -Match 'Status: Success'
            $reportContent | Should -Match 'Status: Skipped'
            $reportContent | Should -Match 'Status: Failure'
            $reportContent | Should -Match 'Exception while running'
            $reportContent | Should -Match 'Summary'
            $reportContent | Should -Match 'Success: 1'
            $reportContent | Should -Match 'Skipped: 1'
            $reportContent | Should -Match 'Failure: 2'
        }
    }
}
