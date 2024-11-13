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
      managed-by  = "gha"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION_02
  alias  = var.AWS_REGION_02
  default_tags {
    tags = {
      application = "jlv6.com"
      managed-by  = "gha"
    }
  }
}
