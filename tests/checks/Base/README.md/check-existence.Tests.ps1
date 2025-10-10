

Write-Host $scriptPath
Describe 'Checks: README.md existence' {
    It 'README exists | Returns EXITCODE 0 and info message' {
        $scriptPath = Join-Path $PSScriptRoot '..\..\..\..\checks\Base\README.md\check-existence.ps1'
        $readmePath = Join-Path $PSScriptRoot "..\..\..\..\"
        $result = & $scriptPath -RepoRoot $readmePath

        $LASTEXITCODE | Should -Be 0
        $result | Should -Be "README.md exists"
    }

    It 'README missing | Returns EXITCODE 1 and info message' {
        $scriptPath = Join-Path $PSScriptRoot '..\..\..\..\checks\Base\README.md\check-existence.ps1'
        $result = & $scriptPath -RepoRoot $PSScriptRoot

        $LASTEXITCODE | Should -Be 1
        $result | Should -Be "README.md missing"
    }
}