terraform {
  required_version = "= 1.6.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
    }
}

provider "aws" {
  region                  = "eu-west-1"
  profile                 = "default"
}

provider "aws" {
  region                  = "eu-central-1"
  profile                 = "default"
  alias                   = "eu_central_1"
}

provider "aws" {
  region                  = "eu-west-1"
  profile                 = "work_account"
  alias                   = "rmt_eu_west_1"
}