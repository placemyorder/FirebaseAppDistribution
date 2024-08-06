param(
    [parameter(Mandatory=$true)]
    [string]$appPath,
    [parameter(Mandatory=$true)]
    [string]$appId,
    [string]$credentialFileContent = '',
    [string]$firebaseToken = '',
    [string]$groups = '',
    [string]$releaseNotes = '',
    [string]$releaseNotesFile = '',
    [string]$testers = ''
)

# Ensure either credentialFileContent or firebaseToken is provided
if ([string]::IsNullOrEmpty($credentialFileContent) -and [string]::IsNullOrEmpty($firebaseToken)) {
    throw "Either 'credentialFileContent' or 'firebaseToken' must be provided."
}

# Initialize the base command
$baseCommand = "firebase appdistribution:distribute $appPath --app $appId"

# Add optional parameters to the command
if (-not [string]::IsNullOrEmpty($groups)) {
    $baseCommand += " --groups `$groups`"
}
if (-not [string]::IsNullOrEmpty($releaseNotes)) {
    $baseCommand += " --release-notes `$releaseNotes`"
}
if (-not [string]::IsNullOrEmpty($releaseNotesFile)) {
    $baseCommand += " --release-notes-file `$releaseNotesFile`"
}
if (-not [string]::IsNullOrEmpty($testers)) {
    $baseCommand += " --testers `$testers`"
}

# Show a warning if firebaseToken is used
if (-not [string]::IsNullOrEmpty($firebaseToken)) {
    Write-Warning "Using 'firebaseToken' instead of 'credentialFileContent' is not recommended. This will be deprecated in the future."
    $baseCommand += " --token $firebaseToken"
    Invoke-Expression $baseCommand
} else {
    $credentialFileContent | Out-File -FilePath "./service_credentials_content.json" -Force
    $env:GOOGLE_APPLICATION_CREDENTIALS="service_credentials_content.json"
    Invoke-Expression $baseCommand
}