Import-Module .\common\FileChecks.psm1

$readmeExists = RepositoryContainsFile("README.md")

if ($readmeExists) {
    "README.md vorhanden"
    exit 0
}
"README.md fehlt"
exit 1