param([Parameter(Mandatory)][string]$RepoRoot)
@{
    Status = 'Failure'
    Message = 'Strukturierte Findings vorhanden'
    ChangedItems = @(
        @{
            Path = 'src\Example.cs'
            Line = 12
            Column = 4
            Code = 'OD001'
            Message = 'Trailing whitespace found.'
        },
        'Legacy string item'
    )
    Errors = @()
}