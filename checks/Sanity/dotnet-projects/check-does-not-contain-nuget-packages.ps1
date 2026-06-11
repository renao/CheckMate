 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )


Import-Module "$PSScriptRoot\..\..\..\common\FileChecks.psd1"

$NuGetPackages = Get-FilesByExtension -rootPath $RepoRoot -fileExtension "nupkg"

if ($NuGetPackages.Length -ne 0)
{
    return @{
        Status = 'Failure'
        Message = 'Found NuGet packages inside this repository. Reference them in your projects and remove the package files from the repository.'
        ChangedItems = @($NuGetPackages)
        Errors = @()
    }
}

return @{
    Status = 'Success'
    Message = 'No NuGet-Packages found.'
    ChangedItems = @()
    Errors = @()
}
