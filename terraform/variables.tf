# Optional Variables - These are retrieved from terraform.tfvars
variable "base_region" {
  type        = string
  description = "AWS region to operate in. Defaults to ap-southeast-2 (Sydney)."
  default     = "ap-southeast-2"
}

# GitLab OIDC variables
variable "gitlab_idp" {
  type    = bool
  default = false
}

variable "gitlab_url" {
  type    = string
  default = "https://gitlab.com"
}

variable "gitlab_aud" {
  type    = string
  default = "https://gitlab.com"
}

# GitHub OIDC variables
variable "github_idp" {
  type    = bool
  default = false
}

# BitBucket OIDC variables
variable "bitbucket_idp" {
  type    = bool
  default = false
}

variable "bitbucket_workspace" {
  type    = string
  default = null
}

variable "bitbucket_workspaceuuid" {
  type    = string
  default = null
}
