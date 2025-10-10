function Get-FilesByExtension {
    <#
    .SYNOPSIS
    Gets all files with the $fileExtension in the $rootPath

    .DESCRIPTION
    Gets all files recursively with the $fileExtension from the $rootPath.

    .PARAMETER rootPath
    The root path to start.

    .PARAMETER fileExtension
    The file extension to search for.

    .EXAMPLE
    Get-FilesByExtension -rootPath "C:\example" -fileExtension "txt"

    #>
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory=$true)]
        [string] $rootPath,
        [Parameter(Mandatory=$true)]
        [string] $fileExtension
    )
    $files = @(Get-ChildItem -Path $rootPath -Recurse -Filter "*.$fileExtension" -File) > $null
    return $files
}

function Approve-FileExists {
    <#
    .SYNOPSIS
    Approves that a file exists.

    .DESCRIPTION
    Approves that the file at $filePath exists.

    .PARAMETER filePath
    The file to look for.

    .EXAMPLE
    Approve-FileExists -filePath "README.md"

    #>
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )
     return Test-Path $filePath
}
