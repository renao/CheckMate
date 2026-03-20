@{
    RootModule = 'GitChecks.psm1'
    ModuleVersion = '0.3'
    GUID = '5ee9e5f1-ee55-444c-8afe-018ba5194bcf'
    Author = 'renao'
    Description = 'Basic git checks and functions for your repository'
    FunctionsToExport = @(
        'Approve-FileIsYoungerThan',
        'Get-LastFileCommitDate',
        'Get-RemoteBranches')
}