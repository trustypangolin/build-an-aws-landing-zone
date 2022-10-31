# OIDC Role
resource "aws_iam_role" "foundation_oidc" {
  name                 = format("%s-%s", var.bootstrap_prefix, var.oidc_role)
  assume_role_policy   = data.aws_iam_policy_document.trust_oidc.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "trust_oidc" {
  # Is the OIDC Source GitHub? If so, add the GitHub IdP as the trust source
  dynamic "statement" {
    for_each = var.github_role ? [1] : []
    content {
      sid     = "AllowGitHub"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = var.github_idp ? [aws_iam_openid_connect_provider.github["github"].arn] : [format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", data.aws_caller_identity.current.account_id)]
      }
      condition {
        test     = "StringLike"
        variable = var.github_idp ? format("%s:%s", aws_iam_openid_connect_provider.github["github"].url, var.github_field) : "token.actions.githubusercontent.com:sub"
        values   = [var.github_match]
      }
    }
  }

  # Is the OIDC Source GitLab? If so, add the GitLab IdP as the trust source
  dynamic "statement" {
    for_each = var.gitlab_role ? [1] : []
    content {
      sid     = "AllowGitLab"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type = "Federated"
        identifiers = var.gitlab_idp ? [
          aws_iam_openid_connect_provider.gitlab["gitlab"].arn
          ] : [
          format(
            "arn:aws:iam::%s:oidc-provider/%s",
            data.aws_caller_identity.current.account_id,
            var.gitlab_url
          )
        ]
      }
      condition {
        test     = "StringLike"
        variable = var.gitlab_idp ? format("%s:%s", aws_iam_openid_connect_provider.gitlab["gitlab"].url, var.gitlab_field) : format("%s:sub", var.gitlab_url)
        values   = [var.gitlab_match]
      }
    }
  }

  # Is the OIDC Source Bitbucket? If so, add the Bitbucket IdP as the trust source
  dynamic "statement" {
    for_each = var.bitbucket_role ? [1] : []
    content {
      sid     = "AllowBitbucket"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type = "Federated"
        identifiers = var.bitbucket_idp ? [
          aws_iam_openid_connect_provider.bitbucket["bitbucket"].arn
          ] : [
          format(
            "arn:aws:iam::%s:oidc-provider/api.bitbucket.org/2.0/workspaces/%s/pipelines-config/identity/oidc",
            data.aws_caller_identity.current.account_id,
            var.bitbucket_workspace
          )
        ]
      }
      condition {
        test = "StringLike"
        variable = format(
          "arn:aws:iam::%s:oidc-provider/api.bitbucket.org/2.0/workspaces/%s/pipelines-config/identity/oidc:aud",
          data.aws_caller_identity.current.account_id,
          var.bitbucket_workspace
        )
        values = [format("ari:cloud:bitbucket::workspace/%s", var.bitbucket_workspaceuuid)]
      }
    }
  }
}
