#!/bin/bash

set -e # Exit with nonzero exit code if anything fails

if git diff-tree --no-commit-id --name-only -r HEAD; then
    echo 'kps code changed, creating release'

    git pull --tags
    # Save some useful information
    REPO=`git config remote.origin.url`
    SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
    OLD_VERSION=`git describe --tags $(git rev-list --tags --max-count=1) | awk -F'[.]' '/^v/ {print $1"."$2"."$3}' | cut -c 2-`
    NEW_VERSION=`git describe --tags $(git rev-list --tags --max-count=1) | awk -F'[.]' '/^v/ {print $1"."$2"."$3+1}' | cut -c 2-`
    SHA256=`shasum -a 256 kps | cut -c -64`

    # Set config
    git config --global user.email "rcruzper@gmail.com"
    git config --global user.name "Travis CI"

    # Create git tag
    GIT_TAG=`git describe --tags $(git rev-list --tags --max-count=1) | awk -F'[.]' '/^v/ {print $1"."$2"."$3+1}'`
    git tag $GIT_TAG -a -m "Generated tag from TravisCI build $TRAVIS_BUILD_NUMBER"

    # Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
    ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
    ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
    ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
    ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
    openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
    chmod 600 deploy_key
    eval `ssh-agent -s`
    ssh-add deploy_key

    # Now that we're all set up, we can push.
    git push $SSH_REPO --tags

    body="{
        \"request\": {
            \"version\":\"master\",
            \"config\": {
                \"env\": {
                    \"old_version\":\"$OLD_VERSION\",
                    \"formula\":\"kps\",
                    \"new_version\":\"$NEW_VERSION\",
                    \"sha256\":\"$SHA256\"
                }
            }
        }
    }"

    echo "travis_api_token: $TRAVIS_API_TOKEN"
    TEST=$TRAVIS_API_TOKEN
    echo "test: $TEST"
    curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -H "Travis-API-Version: 3" \
      -H "Authorization: token $TEST" \
      -d "$body" \
      https://api.travis-ci.org/repo/rcruzper%2Fhomebrew-tools/requests
else
    echo 'kps code does not changed'
    exit 1
fi