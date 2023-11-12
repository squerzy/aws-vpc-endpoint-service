terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {

  region = "eu-west-1"

  default_tags {
    tags = {
      "Example" = "VPC-Endpoint-Service"
    }
  }
}
