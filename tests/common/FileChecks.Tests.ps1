$modulePath = Join-Path $PSScriptRoot '..\..\common\FileChecks.psd1'
Import-Module $modulePath -Force

Describe 'Approve-FileExists' {
    It 'Returns $true if a file exists' {
        $expectedAtFilePath = Join-Path $PSScriptRoot 'FileChecksTests/filechecks.testfile'
        Approve-FileExists -filePath $expectedAtFilePath| Should -Be $true
    }
    It 'Returns $false if a file does not exist' {
        $notExpectedThere = Join-Path $PSScriptRoot 'FileChecksTests/no.testfile'
        Approve-FileExists -filePath $notExpectedThere | Should -Be $false
    }
}

Describe 'Get-FilesByExtension' {
    It 'Returns all files and nested files in a certain directory with a named extension' -Skip {
        $testfilesRoot = Join-Path $PSScriptRoot 'FileChecksTests'
        $testfiles = Get-FilesByExtension -rootPath $testfilesRoot -fileExtension "testfile"
        $testfiles.Count | Should -Be 3
    }
}