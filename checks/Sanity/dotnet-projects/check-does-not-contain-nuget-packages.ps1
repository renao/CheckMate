 param (
        [Parameter(Mandatory=$true)]
        [string]$RepoRoot
        )


Import-Module "$PSScriptRoot\..\..\..\common\FileChecks.psd1"

$NuGetPackages = Get-FilesByExtension -rootPath $RepoRoot -fileExtension "nupkg"

if ($NuGetPackages.Length -ne 0)
{
    # NuGet Packages found.
    $packagesList = $NuGetPackages -join "`n"
    "Found NuGet packages. Please check:`n $packagesList"
    exit 1
}

# Everything's fine, nothing found.
"No NuGet-Packages found."
exit 0