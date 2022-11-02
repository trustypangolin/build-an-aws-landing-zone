#!/bin/bash
### every exit != 0 fails the script
set -e

# Flush the existing Offline Runners
idarray=$( curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUBTOKEN}" \
  https://api.github.com/orgs/${GITORG}/actions/runners \
  | jq '.runners[] | select(.status=="offline") | .id' )

for offline in ${idarray}; do
  curl \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUBTOKEN}" \
    https://api.github.com/orgs/${GITORG}/actions/runners/${offline}
done

# Cleanup previous docker volume
rm -rf /actions-runner
mkdir /actions-runner
cd /actions-runner

# Download the correct arch
arch=$(uname -m)
if [ "$arch" == x86_64* ]; then
    echo "X64 Architecture"
    curl -o /tmp/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    tar xzf /tmp/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
elif [ "$arch" == arm64 ] || [ $arch = aarch64 ]; then
    echo "ARM Architecture"
    curl -o /tmp/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz
    tar xzf /tmp/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz
fi

# Configure a new runer
mycode=$(echo $RANDOM)
./config.sh --unattended \
            --url https://github.com/${GITORG} \
            --name ghr${mycode} \
            --token $(curl -s -X POST -H "Accept: application/vnd.github.v3+json" -H "authorization:token ${GITHUBTOKEN}" https://api.github.com/orgs/${GITORG}/actions/runners/registration-token | jq -r .token)

# Install any missing dependencies for this version
./bin/installdependencies.sh

# When Docker is shutdown, we capture this call and remove the current runner if possible
cleanup() {
    echo "Removing runner..."
    id=$( curl -s \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${GITHUBTOKEN}" \
            https://api.github.com/orgs/${GITORG}/actions/runners | jq --arg mycode "$mycode" '.runners[] | select(.name=="ghr$mycode") | .id' )

    curl \
      -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUBTOKEN}" \
      https://api.github.com/orgs/${GITORG}/actions/runners/${id}

      echo "should have removed ghr${mycode} with id: ${id}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the GitHub runner directly, there is no SystemD in place to do this automatically
./bin/runsvc.sh & wait $!