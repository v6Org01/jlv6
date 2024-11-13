terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
}

provider "aws" {
  alias  = var.AWS_REGION_01
  region = var.AWS_REGION_01
  default_tags {
    tags = {
      application = "jlv6.com"
      environment = "staging"
      managed-by  = "gha"
    }
  }
}

provider "aws" {
  alias  = var.AWS_REGION_02
  region = var.AWS_REGION_02
  default_tags {
    tags = {
      application = "jlv6.com"
      environment = "staging"
      managed-by  = "gha"
    }
  }
}

data "terraform_remote_state" "shared" {
  backend = "remote"
  config = {
    organization = var.TF_ORG
    workspaces = {
      name = var.TF_WORKSPACE_SHARED
    }
  }
}
