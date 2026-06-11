$modulePath = Join-Path $PSScriptRoot '..\..\common\GitChecks.psd1'
Import-Module $modulePath -Force

Describe 'Approve-FileIsYoungerThan' {
    It 'Returns 0 if files last commit is younger than a certain day' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        $expectedAtFilePath = Join-Path $repoRoot 'README.md'
        $cutOffDay = (Get-Date).AddYears(-20)
        Approve-FileIsYoungerThan -filePath $expectedAtFilePath -repoRoot $repoRoot -cutOffDay $cutOffDay | Should -Be 0
    }
    It 'Returns 1 if a file is older than a certain day' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        $expectedAtFilePath = Join-Path $repoRoot 'README.md'
        $cutOffDay = (Get-Date).AddYears(2)
        Approve-FileIsYoungerThan -filePath $expectedAtFilePath -repoRoot $repoRoot -cutOffDay $cutOffDay | Should -Be 1
    }

    It 'Returns 20 if a file has no commit' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        $shouldNotExist = Join-Path $PSScriptRoot 'funny-non-existant-filename.md'
        $cutOffDay = Get-Date
        Approve-FileIsYoungerThan -filePath $shouldNotExist -repoRoot $repoRoot -cutOffDay $cutOffDay | Should -Be 20
    }
}

Describe 'Get-LastFileCommitDate' {
    It 'Returns DateTime if file was committed to git' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        $readmeFilePath = Join-Path $repoRoot 'README.md'
        Get-LastFileCommitDate -filePath $readmeFilePath -repoRoot $repoRoot | Should -BeOfType [System.DateTime]
    }

    It 'Returns $null is not a part of the git repository' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        $shouldNotExist = Join-Path $PSScriptRoot 'funny-non-existant-filename.md'
        Get-LastFileCommitDate -filePath $shouldNotExist -repoRoot $repoRoot | Should -Be $null
    }
}

Describe 'Get-RemoteBranches' {
    It 'Returns a list of remote branches' {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
        Get-RemoteBranches -repoRoot $repoRoot | Should -Not -BeNullOrEmpty
        Get-RemoteBranches -repoRoot $repoRoot | Should -Contain 'origin/main'
    }
}