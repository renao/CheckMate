function Approve-FileIsYoungerThan {
    <#
    .SYNOPSIS
    Approves that a file is not older than the given $cutOffDay.

    .DESCRIPTION
    Approves that a file is not older than the given $cutOffDay.

    .PARAMETER filePath
    The file to approve.

    .EXAMPLE
    Approve-FileIsYoungerThan -filePath "README.md"

    #>
    [OutputType([System.Int16])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$filePath,
        [Parameter(Mandatory=$true)]
        [DateTime]$cutOffDay
    )
    $fileCommittedAt = Get-LastFileCommitDate -filePath $filePath

    if ($null -eq $fileCommittedAt) {
        # Not able to find or fetch file information from git/current branch.
        return 20
    }

    if ($fileCommittedAt -le $cutOffDay) {
        # File is older than allowed.
        return 1
    }
    # Everything seems okay.
    return 0
}

function Get-LastFileCommitDate {
    <#
    .SYNOPSIS
    Gets the date from the last commit of a file.

    .DESCRIPTION
    Returns a DateTime object for the last commit of the file or $null if the file does not exist in the repository.

    .PARAMETER filePath
    The file to examine

    .EXAMPLE
    Get-LastFileCommitDate -filePath "README.md"
    
    #>
    [OutputType([System.DateTime])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$filePath
    ),

    $gitDateString = git log -1 --format="%ci" -- $filePath
    if ([string]::IsNullOrWhiteSpace(($gitDateString))) {
        return $null
    }
    return [DateTime]::ParseExact($gitDateString.Substring(0, 19), "yyyy-MM-dd HH:mm:ss", $null)
}