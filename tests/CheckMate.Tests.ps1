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
}
