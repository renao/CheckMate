function Get-ResultValueByStatusCode($statusCode) {
    if ($statusCode -eq 0) {
        return "✅"
    } else {
        return "❌"
    }
}

function New-MarkdownReport {
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true)]
        [Hashtable] $results
    )

    $markdown = "# CheckMate Report`n"
    $runChecks = $results.Keys | Sort-Object

    foreach ($check in $runChecks) {

        $checkResult = $results[$check]
        $status = Get-ResultValueByStatusCode -statusCode $checkResult[0]
        $checkInfos = $checkResult[1]
        $markdown += "`n* $status | $checkInfos ($check)"
    }

    return $markdown -join "`n"
}
