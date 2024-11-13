terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us_east_1"
  default_tags {
    tags = {
      application = "jlv6.com"
      managed-by  = "gha"
    }
  }
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
  default_tags {
    tags = {
      application = "jlv6.com"
      managed-by  = "gha"
    }
  }
}
