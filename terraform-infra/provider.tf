terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend - the S3 bucket and DynamoDB table created
  # in the terraform-bootstrap stage. State locking via DynamoDB means
  # only one `terraform apply` can run against this state at a time.
  backend "s3" {
    bucket         = "k8s-lab-tfstate-233013921695"
    key            = "main-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "k8s-lab-tflock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
