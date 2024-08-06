#!/bin/bash

# Ensure script exits if a command fails
set -e

# Function to display usage
usage() {
    echo "Usage: $0 --appPath <appPath> --appId <appId> [--credentialFileContent <credentialFileContent>] [--firebaseToken <firebaseToken>] [--groups <groups>] [--releaseNotes <releaseNotes>] [--releaseNotesFile <releaseNotesFile>] [--testers <testers>]"
    exit 1
}

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
  echo "Error: Firebase CLI is not installed. Please install it and try again."
  exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --appPath)
            appPath="$2"
            shift 2
            ;;
        --appId)
            appId="$2"
            shift 2
            ;;
        --credentialFileContent)
            credentialFileContent="$2"
            shift 2
            ;;
        --firebaseToken)
            firebaseToken="$2"
            shift 2
            ;;
        --groups)
            groups="$2"
            shift 2
            ;;
        --releaseNotes)
            releaseNotes="$2"
            shift 2
            ;;
        --releaseNotesFile)
            releaseNotesFile="$2"
            shift 2
            ;;
        --testers)
            testers="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check mandatory parameters
if [ -z "$appPath" ] || [ -z "$appId" ]; then
    usage
fi

# Ensure either credentialFileContent or firebaseToken is provided
if [ -z "$credentialFileContent" ] && [ -z "$firebaseToken" ]; then
    echo "Either 'credentialFileContent' or 'firebaseToken' must be provided."
    exit 1
fi

# Initialize the base command
baseCommand="firebase appdistribution:distribute \"$appPath\" --app \"$appId\""

# Add optional parameters to the command
[ -n "$groups" ] && baseCommand+=" --groups \"$groups\""
[ -n "$releaseNotes" ] && baseCommand+=" --release-notes \"$releaseNotes\""
[ -n "$releaseNotesFile" ] && baseCommand+=" --release-notes-file \"$releaseNotesFile\""
[ -n "$testers" ] && baseCommand+=" --testers \"$testers\""

# Show a warning if firebaseToken is used
if [ -n "$firebaseToken" ]; then
    echo "Warning: Using 'firebaseToken' instead of 'credentialFileContent' is not recommended. This will be deprecated in the future."
    baseCommand+=" --token \"$firebaseToken\""
else
    echo "$credentialFileContent" > ./service_credentials_content.json
    export GOOGLE_APPLICATION_CREDENTIALS="./service_credentials_content.json"
fi

# Execute the command
eval $baseCommand
