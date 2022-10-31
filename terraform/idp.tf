# GitLab OIDC Connections
data "tls_certificate" "gitlab" {
  for_each = { for k in ["gitlab"] : k => k if var.github_idp }
  url      = var.gitlab_url
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  for_each        = { for k in ["gitlab"] : k => k if var.gitlab_idp }
  url             = var.gitlab_url
  client_id_list  = [var.gitlab_aud]
  thumbprint_list = [data.tls_certificate.gitlab["gitlab"].certificates.0.sha1_fingerprint]
}

# GitHub OIDC Connections
data "tls_certificate" "github" {
  for_each = { for k in ["github"] : k => k if var.github_idp }
  url      = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  for_each       = { for k in ["github"] : k => k if var.github_idp }
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.github["github"].certificates.0.sha1_fingerprint
  ]
}

# Bitbucket OIDC Connections
data "tls_certificate" "bitbucket" {
  for_each = { for k in ["bitbucket"] : k => k if var.bitbucket_idp }
  url      = format("https://api.bitbucket.org/2.0/workspaces/%s/pipelines-config/identity/oidc", var.bitbucket_workspace)
}

resource "aws_iam_openid_connect_provider" "bitbucket" {
  for_each = { for k in ["bitbucket"] : k => k if var.bitbucket_idp }
  url = format(
    "https://api.bitbucket.org/2.0/workspaces/%s/pipelines-config/identity/oidc",
    var.bitbucket_workspace
  )
  client_id_list = [format(
    "ari:cloud:bitbucket::workspace/%s",
    var.bitbucket_workspaceuuid
  )]
  thumbprint_list = [
    data.tls_certificate.bitbucket["bitbucket"].certificates.0.sha1_fingerprint,
  ]
}
