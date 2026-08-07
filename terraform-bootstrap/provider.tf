terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This bootstrap stage intentionally uses LOCAL state.
  # It creates the S3 bucket + DynamoDB table that every OTHER
  # stage of this project will use as its remote backend.
  # Do not point this stage at a remote backend - that would be
  # a chicken-and-egg problem (the backend resources don't exist yet).
}

provider "aws" {
  region = var.aws_region
}
