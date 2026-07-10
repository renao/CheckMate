@{
    RootModule = 'CheckMateResult.psm1'
    ModuleVersion = '0.2'
    GUID = '8f220e4f-e1b5-4cf1-a57e-c120608f08f2'
    Author = 'renao'
    Description = 'Creates structured CheckMate result objects and summaries'
    FunctionsToExport = @('New-CheckMateRunResult', 'Get-ResultsSummary', 'Get-OverallStatus')
}