

Write-Host $scriptPath
Describe 'Checks: README.md existence' {
    It 'README exists | Returns Success result hashtable' {
        $scriptPath = Join-Path $PSScriptRoot '..\..\..\..\checks\Base\README.md\check-existence.ps1'
        $readmePath = Join-Path $PSScriptRoot "..\..\..\..\"
        $result = & $scriptPath -RepoRoot $readmePath

        $result | Should -BeOfType [hashtable]
        $result.Status | Should -Be 'Success'
        $result.Message | Should -Be 'README.md exists'
        $result.ContainsKey('ChangedItems') | Should -BeTrue
        $result.ContainsKey('Errors') | Should -BeTrue
        @($result.ChangedItems).Count | Should -Be 0
        @($result.Errors).Count | Should -Be 0
    }

    It 'README missing | Returns Failure result hashtable' {
        $scriptPath = Join-Path $PSScriptRoot '..\..\..\..\checks\Base\README.md\check-existence.ps1'
        $result = & $scriptPath -RepoRoot $PSScriptRoot

        $result | Should -BeOfType [hashtable]
        $result.Status | Should -Be 'Failure'
        $result.Message | Should -Be 'README.md missing - add a meaningful README.md file'
        $result.ChangedItems | Should -Contain 'README.md'
        @($result.Errors).Count | Should -Be 0
    }
}