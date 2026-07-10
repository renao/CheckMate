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

        It "Returns a structured result object in PassThru mode" {
            $fixtureChecksPath = Join-Path $PSScriptRoot 'fixtures\contract-checks'
            $reportPath = Join-Path $TestDrive 'report.md'

            $result = Invoke-CheckMate -RepoRoot $PSScriptRoot -ChecksBasePath $fixtureChecksPath -ReportPath $reportPath -PassThru

            $result.OverallStatus | Should -Be 'Failure'
            $result.ExitCode | Should -Be 1
            $result.ReportPath | Should -Be $reportPath
            $result.Summary.TotalChecks | Should -Be 4
            $result.Summary.SuccessCount | Should -Be 1
            $result.Summary.SkippedCount | Should -Be 1
            $result.Summary.FailureCount | Should -Be 2
            @($result.Checks).Count | Should -Be 4
            @($result.Checks | Where-Object { $_.Status -eq 'Failure' }).Count | Should -Be 2
        }

        It "Can skip markdown report generation in PassThru mode" {
            $fixtureChecksPath = Join-Path $PSScriptRoot 'fixtures\contract-checks'
            $reportPath = Join-Path $TestDrive 'skip-report.md'

            $result = Invoke-CheckMate -RepoRoot $PSScriptRoot -ChecksBasePath $fixtureChecksPath -ReportPath $reportPath -PassThru -SkipReportGeneration

            $result.OverallStatus | Should -Be 'Failure'
            $result.ReportPath | Should -BeNullOrEmpty
            Test-Path $reportPath | Should -BeFalse
        }

        It "Normalizes ChangedItems into structured warning entries in PassThru mode" {
            $fixtureChecksPath = Join-Path $PSScriptRoot 'fixtures\normalized-changed-items'

            $result = Invoke-CheckMate -RepoRoot $PSScriptRoot -ChecksBasePath $fixtureChecksPath -PassThru -SkipReportGeneration

            $result.OverallStatus | Should -Be 'Failure'
            $check = @($result.Checks | Where-Object { $_.CheckPath -eq 'structured-failure-check.ps1' })[0]
            $check.ChangedCount | Should -Be 2
            @($check.NormalizedChangedItems).Count | Should -Be 2

            $firstItem = $check.NormalizedChangedItems[0]
            $firstItem.Path | Should -Be 'src\Example.cs'
            $firstItem.Line | Should -Be 12
            $firstItem.Column | Should -Be 4
            $firstItem.Code | Should -Be 'OD001'
            $firstItem.Message | Should -Be 'Trailing whitespace found.'

            $secondItem = $check.NormalizedChangedItems[1]
            $secondItem.Path | Should -BeNullOrEmpty
            $secondItem.Message | Should -Be 'Legacy string item'
        }
    }
}
