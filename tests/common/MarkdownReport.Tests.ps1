$modulePath = Join-Path $PSScriptRoot '..\..\common\MarkdownReport.psd1'
Import-Module $modulePath -Force

Describe 'New-MarkdownReport' {
    It 'Generates a report from a result set' {

        $testResults = @{
            "check1" = @{ Status = 'Success'; Message = 'additional info for check1'; ChangedItems = @(); Errors = @() };
            "check2" = @{ Status = 'Skipped'; Message = 'additional info for check2'; ChangedItems = @(); Errors = @() };
            "check3" = @{ Status = 'Failure'; Message = 'additional info for check3'; ChangedItems = @('a'); Errors = @('err') }
        }

        $report = New-MarkdownReport -results $testResults
        $report | Should -BeOfType [System.String]
        $report | Should -Not -BeNullOrEmpty
        $report | Should -Match 'Summary'
        $report | Should -Match 'Success: 1'
        $report | Should -Match 'Skipped: 1'
        $report | Should -Match 'Failure: 1'
    }
    It 'Can handle empty result set' {
        $testResults = @{}

        $report = New-MarkdownReport -results $testResults
        $report | Should -BeOfType [System.String]
        $report | Should -Not -BeNullOrEmpty
    }

    It 'Aborts if the result set is not type of hashtable' {
        $exceptionType = [System.Exception]
        { New-MarkdownReport -results $null } | Should -Throw -Exception $exceptionType
        { New-MarkdownReport -results "" } | Should -Throw -Exception $exceptionType
    }

}