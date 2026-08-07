# -----------------------------------------------------------------------
# S3 bucket to hold Terraform state for all later stages of this project
# -----------------------------------------------------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  # Lab convenience: allows `terraform destroy` on this bucket even if
  # it still has (versioned) objects in it when we tear everything down.
  force_destroy = true

  tags = {
    Project = "k8s-lab"
    Purpose = "terraform-state"
  }
}

# Versioning protects against accidental state corruption/loss -
# every state write becomes a new object version instead of overwriting.
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest. Terraform state can contain sensitive values
# (e.g. DB passwords if we ever put them in resources), so this matters
# even for a lab.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access - state bucket must never be public.
resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------
# DynamoDB table for Terraform state locking (prevents two people/
# processes from running `terraform apply` against the same state
# at the same time and corrupting it)
# -----------------------------------------------------------------------
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST" # no fixed cost - pay only per request, effectively free for a lab
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "k8s-lab"
    Purpose = "terraform-state-locking"
  }
}
