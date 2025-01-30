terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }
}

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
