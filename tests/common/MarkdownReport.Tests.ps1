$modulePath = Join-Path $PSScriptRoot '..\..\common\MarkdownReport.psd1'
Import-Module $modulePath -Force

Describe 'New-MarkdownReport' {
    It 'Generates a report from a result set' {

        $testResults = @{
            "check1" = @(0, "additional info for check1");
            "check2" = @(0, "additional info for check2");
            "check3" = @(0, "additional info for check3")
        }

        $report = New-MarkdownReport -results $testResults
        $report | Should -BeOfType [System.String]
        $report | Should -Not -BeNullOrEmpty
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