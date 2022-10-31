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

variable "gitlab_role" {
  type    = bool
  default = false
}

variable "gitlab_field" {
  type    = string
  default = "sub"
}

variable "gitlab_match" {
  type    = string
  default = null
}

# GitHub OIDC variables
variable "github_idp" {
  type    = bool
  default = false
}

variable "github_role" {
  type    = bool
  default = false
}

variable "github_match" {
  type    = string
  default = null
}

variable "github_field" {
  type    = string
  default = "sub"
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

variable "bitbucket_role" {
  type    = bool
  default = false
}

# Customise Entry Roles
variable "bootstrap_prefix" {
  type        = string
  description = "To match customer naming polices, we create a Landing Zone prefix for state, role, dynamodb resources. Typically foundation,bedrock,landingzone etc"
  default     = "foundation"
}

variable "oidc_role" {
  type        = string
  description = "Entry role suffix appended to bootstrap_prefix. This needs to match the OpenID initial Role"
  default     = "oidc"
}
