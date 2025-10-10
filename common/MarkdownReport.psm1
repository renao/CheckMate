function _Get-ResultValueByStatusCode($statusCode) {

    if ($statusCode -eq 0) {
        return "✅"
    } else {
        return "❌"
    }
}

function New-MarkdownReport {
    <#
    .SYNOPSIS
    Creates a new markdown report.

    .DESCRIPTION
    Creates a markdown report from a result set.

    .PARAMETER results
    A Hashtable in the form of [Name of the check] => [StatusCode (0/1), additional infos]

    .EXAMPLE
    New-MarkdownReport -results $checkResults
    
    #>
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true)]
        [Hashtable] $results
    )

    $markdown = "# CheckMate Report`n"
    $runChecks = $results.Keys | Sort-Object

    foreach ($check in $runChecks) {

        $checkResult = $results[$check]
        $status = _Get-ResultValueByStatusCode -statusCode $checkResult[0]
        $checkInfos = $checkResult[1]
        $markdown += "`n* $status | $checkInfos ($check)"
    }

    return $markdown -join "`n"
}
