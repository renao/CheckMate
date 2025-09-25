@{
    RootModule = 'FileChecks.psm1'
    ModuleVersion = '1.0'
    Author = 'renao'
    Description = 'Basic file and directory checks and functions for your repository'
    FunctionsToExport = @('Approve-FileExists', 'Get-FilesByExtension')
}