terraform {
  required_providers {
    archive = {}
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
}
provider archive {}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      application = "jlv6.com"
      environment = "production"
      managed-by  = "gha"
    }
  }
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
  default_tags {
    tags = {
      application = "jlv6.com"
      environment = "production"
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
