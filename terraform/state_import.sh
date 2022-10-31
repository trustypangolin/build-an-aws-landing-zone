#!/bin/bash

# We don't store this state in S3, because it is a bootstrap
ACCOUNTID=$1
BITBUCKETWORKSPACE=$2

if [ -z ${ACCOUNTID} ]; 
then 
  echo "Account ID is unset, exiting"; 
  exit 1
else 
  echo "var is set to '$ACCOUNTID'"; 
fi

terraform import 'aws_iam_role.foundation_oidc' foundation-oidc
terraform import 'aws_iam_openid_connect_provider.github["github"]' arn:aws:iam::${ACCOUNTID}:oidc-provider/token.actions.githubusercontent.com
terraform import 'aws_iam_openid_connect_provider.gitlab["gitlab"]' arn:aws:iam::${ACCOUNTID}:oidc-provider/gitlab.com

if [ -z ${BITBUCKETWORKSPACE} ]; then 
  echo "Skipping Bitbucket Import"; 
else 
  terraform import 'aws_iam_openid_connect_provider.bitbucket["bitbucket"]' "arn:aws:iam::${ACCOUNTID}:oidc-provider/api.bitbucket.org/2.0/workspaces/${BITBUCKETWORKSPACE}/pipelines-config/identity/oidc";
fi

