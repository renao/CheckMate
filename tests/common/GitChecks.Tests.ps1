$modulePath = Join-Path $PSScriptRoot '..\..\common\GitChecks.psd1'
Import-Module $modulePath -Force

    # 'Approve-FileIsYoungerThan'
    # 'Get-LastFileCommitDate'

Describe 'Approve-FileIsYoungerThan' {
    It 'Returns 0 if files last commit is younger than a certain day' {
        $expectedAtFilePath = Join-Path $PSScriptRoot '../../README.md'
        $cutOffDay = (Get-Date).AddYears(-20)
        Approve-FileIsYoungerThan -filePath $expectedAtFilePath -cutOffDay $cutOffDay | Should -Be 0
    }
    It 'Returns 1 if a file is older than a certain day' {
        $expectedAtFilePath = Join-Path $PSScriptRoot '../../README.md'
        $cutOffDay = Get-Date
        Approve-FileIsYoungerThan -filePath $expectedAtFilePath -cutOffDay $cutOffDay | Should -Be 1
    }

    It 'Returns 20 if a file has no commit' {
        $shouldNotExist = Join-Path $PSScriptRoot 'funny-non-existant-filename.md'
        $cutOffDay = Get-Date
        Approve-FileIsYoungerThan -filePath $shouldNotExist -cutOffDay $cutOffDay | Should -Be 20
    }
}

Describe 'Get-LastFileCommitDate' {
    It 'Returns DateTime if file was committed to git' {
        $readmeFilePath = Join-Path $PSScriptRoot '../../README.md'
        Get-LastFileCommitDate -filePath $readmeFilePath | Should -BeOfType [System.DateTime]
    }

    It 'Returns $null is not a part of the git repository' {
        $shouldNotExist = Join-Path $PSScriptRoot 'funny-non-existant-filename.md'
        Get-LastFileCommitDate -filePath $shouldNotExist | Should -Be $null
    }
}