#!/bin/bash
##############################################################################################################################
# Script to set or update secrets into a GitHub repo environment
##############################################################################################################################

# owner/repo
REPO="yyyyyyyyyyyy/xxxxxxxxxxxx"

# Check if arguments were provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 environment secrets_file (ex: dev, tst) (ex: secrets.txt)"
    exit 1
fi

# Check if exists the export variable
if [ -z "$GITHUB_TOKEN" ]; then
    echo "The export variable is not configured"
    exit 1
fi

# ENV
ENVIRONMENT_NAME=$1

# NAME OF THE VARIABLES FILE
SECRETS_FILE=$2

# GitHub CLI Authentication
gh auth login --with-token "$GITHUB_TOKEN"

# Function to set the new secrets
set_github_secret_env() {
  local secret_name="$1"
  local secret_value="$2"
  echo "Setting environment secret: $secret_name for: $REPO in env: $ENVIRONMENT_NAME"
  gh secret set "$secret_name" --env "$ENVIRONMENT_NAME" --body "$secret_value"
}

# Check if the repo has that environment, if yes, update or add secrets
response=$(curl -H "Authorization: token $GITHUB_TOKEN" -s "https://api.github.com/repos/$REPO/environments")

# Putting the new variables envs
if echo "$response" | grep -q "\"name\": \"$ENVIRONMENT_NAME\""; then
    # Check if the file exists
    if [ -f "$SECRETS_FILE" ]; then
        while IFS='=' read -r secret_name secret_value; do
            set_github_secret_env "$secret_name" "$secret_value"
            echo "==========================================================================================================="
        done < "$SECRETS_FILE"
    else
        echo "$SECRETS_FILE doesnt exist"
        exit 1
    fi
else
    echo "$ENVIRONMENT_NAME doesnt exist. Please create before executing this script"
    exit 1
fi