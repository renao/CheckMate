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
    "Found NuGet packages inside this repository:`n
    $packagesList `n `n
    Reference them in your projects and remove the package file from the repository"
    exit 1
}

# Everything's fine, nothing found.
"No NuGet-Packages found."
exit 0
