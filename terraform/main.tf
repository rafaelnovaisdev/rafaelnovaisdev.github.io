terraform {
  required_version = "~> 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

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

# Create the S3 bucket without an inline website block.
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "site_bucket" {
  #depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket = aws_s3_bucket.site_bucket.id
  acl    = "public-read"
}

# Configure the bucket for website hosting using a separate resource.
resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Set up public access settings to allow website access.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Create a bucket policy to allow public read access.
resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.site_bucket_policy.json
}

data "aws_iam_policy_document" "site_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Output the website URL.
output "website_url" {
  description = "The URL of the website hosted in S3."
  value       = "http://${aws_s3_bucket.site_bucket.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}
