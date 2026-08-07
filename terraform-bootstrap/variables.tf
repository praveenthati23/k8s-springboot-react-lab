variable "aws_region" {
  description = "AWS region for all lab resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID, used to make the S3 bucket name globally unique"
  type        = string
  default     = "233013921695"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket that will hold Terraform state for later stages"
  type        = string
  default     = "k8s-lab-tfstate-233013921695"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "k8s-lab-tflock"
}
