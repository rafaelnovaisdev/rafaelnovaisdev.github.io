terraform {
  required_version = "~> 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Use remote state storage in S3 and enable state locking with DynamoDB
  backend "s3" {
    bucket         = "your-terraform-state-bucket" # Change this to your actual state bucket
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS Region where the resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for your site. Must be globally unique."
  type        = string
  default     = "rafaelnovaisdev-prod"
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state."
  type        = string
  default     = "your-terraform-state-bucket"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
  default     = "terraform-locks"
}

# Terraform State Bucket (Ensure it exists before applying this config)
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table for Terraform Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Check if the site bucket already exists
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

# Create a new site bucket only if it doesn’t exist
resource "aws_s3_bucket" "site_bucket" {
  count  = data.aws_s3_bucket.existing_bucket.id != "" ? 0 : 1
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true  # Ensures Terraform never deletes it
  }
}

# Use the existing bucket or the newly created one
resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = coalesce(
    try(aws_s3_bucket.site_bucket[0].id, ""),
    data.aws_s3_bucket.existing_bucket.id
  )

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = coalesce(
    try(aws_s3_bucket.site_bucket[0].id, ""),
    data.aws_s3_bucket.existing_bucket.id
  )

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "site_bucket_acl" {
  bucket = coalesce(
    try(aws_s3_bucket.site_bucket[0].id, ""),
    data.aws_s3_bucket.existing_bucket.id
  )
  acl = "public-read"
}

# 🟢 Public Read Policy for the Website Bucket
resource "aws_s3_bucket_policy" "site_policy" {
  bucket = coalesce(
    try(aws_s3_bucket.site_bucket[0].id, ""),
    data.aws_s3_bucket.existing_bucket.id
  )
  policy = data.aws_iam_policy_document.site_bucket_policy.json
}

data "aws_iam_policy_document" "site_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Output the bucket name and website URL
output "bucket_name" {
  value = var.bucket_name
}

output "website_url" {
  description = "The URL of the website hosted in S3."
  value       = "http://${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
}
