resource "aws_kms_key" "this" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-aws-monorepo-poc"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-aws-monorepo-poc-staging"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  required_version = "1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-state-aws-monorepo-poc"
  #   key            = "global/s3/staging.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks-aws-monorepo-poc-staging"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = "us-east-1"
}

