@{
    RootModule = 'GitChecks.psm1'
    ModuleVersion = '1.0'
    Author = 'renao'
    Description = 'Basic git checks and functions for your repository'
    FunctionsToExport = @('Approve-FileIsYoungerThan', 'Get-LastFileCommitDate')
}