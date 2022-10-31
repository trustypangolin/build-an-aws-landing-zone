terraform {
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.base_region
  default_tags {
    tags = {
      Environment = "Landing Zone"
    }
  }
}

data "aws_caller_identity" "current" {}
