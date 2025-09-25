function Get-FilesByExtension {
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory=$true)]
        [string] $rootPath,
        [Parameter(Mandatory=$true)]
        [string] $fileExtension
    )
    $files = Get-ChildItem -Path $rootPath -Recurse -Filter "*.$fileExtension" -File > $null
    return $files
}

function Approve-FileExists {
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )
     return Test-Path $filePath
}
