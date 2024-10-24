terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      application = "jlv6.com"
      environment = "staging"
      managed-by  = "gha"
    }
  }
}
