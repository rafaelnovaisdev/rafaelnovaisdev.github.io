terraform {
  backend "s3" {
    bucket         = "rafaelnovaisdev-prod-state-bucket"  # The S3 bucket created in bootstrap
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "rafaelnovaisdev-prod-state-dynamodb-table" 
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS Region where the bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for your site. Must be globally unique."
  type        = string
  default     = "rafaelnovaisdev-prod"
}

# Check if the bucket already exists in AWS
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

# Create the S3 Website Bucket (Only If It Does Not Exist)
resource "aws_s3_bucket" "site_bucket" {
  count  = data.aws_s3_bucket.existing_bucket.id != "" ? 0 : 1
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

# Configure the S3 Bucket for Static Website Hosting
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

# Public Access Block (Ensures Public Read is Allowed)
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

# Set the ACL to Public-Read
resource "aws_s3_bucket_acl" "site_bucket_acl" {
  bucket = coalesce(
    try(aws_s3_bucket.site_bucket[0].id, ""),
    data.aws_s3_bucket.existing_bucket.id
  )
  acl = "public-read"
}

# Public Read Policy for the Website Bucket
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

# Output the website URL
output "website_url" {
  description = "The URL of the website hosted in S3."
  value       = "http://${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
}
