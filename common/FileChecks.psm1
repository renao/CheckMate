function RepositoryContainsFile($filePath) {
    return Test-Path $filePath
}