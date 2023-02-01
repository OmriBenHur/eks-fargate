
# using terraform cloud to run these configuration files.
# aws access key and secret key are saved as env variables in the tf cloud workspace. so no declaration in code is needed
terraform {
  cloud {
    organization = "omribenhur"

    workspaces {
      name = "eks-fargate-application"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider conf. enter the region you're operating in
provider "aws" {
  region = "us-west-2"
}