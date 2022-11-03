#!/bin/bash

pkgyum=$(command -v yum)
pkgapt=$(command -v apt-get)

if [[ ! -z $pkgyum ]] 2>/dev/null; then
  echo "found yum base"
  sopt="" # RHEL based Images uses a different version of OpenSSL
fi

if [[ ! -z $pkgapt ]] 2>/dev/null; then
  echo "found apt base"
  sopt="-pbkdf2" # Ubuntu Images uses a different version of OpenSSL
fi

# Detect a GitLab CI/CD variable and set the OIDC token
if [[ ! -z $CI_JOB_JWT_V2 ]] 2>/dev/null; then
  echo "found gitlab token"
  jwt_token=$CI_JOB_JWT_V2
  session_name="GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
fi

# Detect a Bitbucket CI/CD variable and set the OIDC token
if [[ ! -z $BITBUCKET_STEP_OIDC_TOKEN ]] 2>/dev/null; then
  echo "found bitbucket token"
  jwt_token=$BITBUCKET_STEP_OIDC_TOKEN
  session_name="BitBucketRunner"
fi

# Detect a GitHub CI/CD variable and exit safely. Authentication is a GitHub Action normally
if [[ ! -z $ACTIONS_ID_TOKEN_REQUEST_TOKEN ]] 2>/dev/null; then
  echo "found GitHub token"
  jwt_token=$(curl -sLS "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" -H "User-Agent: actions/oidc-client" -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" | jq -r '.value' )
  session_name="GitHubRunner"
  echo "This should be running under the GitHub Actions, but I will request the jwt token anyhow"
fi

# Assume the Role that trusts the OIDC IdP using Web Identity
STS=($(aws sts assume-role-with-web-identity                          \
--role-arn arn:aws:iam::${AWS_ROOT_ACCOUNT}:role/${role_name}         \
--role-session-name "${session_name}"                                 \
--web-identity-token $jwt_token                                       \
--duration-seconds 3600                                               \
--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'      \
--output text))
export AWS_ACCESS_KEY_ID="${STS[0]}"      
export AWS_SECRET_ACCESS_KEY="${STS[1]}"  
export AWS_SESSION_TOKEN="${STS[2]}"      

echo "AWS_REGION=$AWS_REGION"           > credentials.env
echo "AWS_ACCESS_KEY_ID=${STS[0]}"     >> credentials.env
echo "AWS_SECRET_ACCESS_KEY=${STS[1]}" >> credentials.env
echo "AWS_SESSION_TOKEN=${STS[2]}"     >> credentials.env

# Bitbucket/GitHub/GitLab sharing of credentials through the repo securely
openssl enc -aes-256-cbc $sopt -base64 -k $ENCKEY -in credentials.env -out securecreds.enc