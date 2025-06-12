terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # CloudFront requires ACM certificates to be in us-east-1
}

# Random string for unique names
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for static content
resource "aws_s3_bucket" "static" {
  bucket = "static-content-${random_string.random.result}"
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront OAI for S3
resource "aws_cloudfront_origin_access_identity" "static" {
  comment = "OAI for static content bucket"
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAI"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.static.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static.arn}/*"
      }
    ]
  })
}

# Example API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "example-api-${random_string.random.result}"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "api" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.api
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

# ACM Certificate (optional - uncomment if you want to use HTTPS with a custom domain)
/*
resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  subject_alternative_names = ["*.example.com"]

  lifecycle {
    create_before_destroy = true
  }
}
*/

# CloudFront Distribution with multiple origins and behaviors
module "cloudfront" {
  source = "../../"

  enabled             = true
  is_ipv6_enabled    = true
  distribution_comment = "Complete Example Distribution"
  price_class        = "PriceClass_100"
  
  # Multiple origins
  origins = [
    {
      domain_name = aws_s3_bucket.static.bucket_regional_domain_name
      origin_id   = "static_content"
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.static.cloudfront_access_identity_path
      }
      custom_headers = []
    },
    {
      domain_name = replace(aws_api_gateway_stage.api.invoke_url, "/^https?://([^/]*).*/", "$1")
      origin_id   = "api_gateway"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_headers = []
    }
  ]

  # Default cache behavior for static content
  default_cache_behavior = {
    target_origin_id       = "static_content"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress              = true
    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  # Ordered cache behaviors
  ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "api_gateway"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      forwarded_values = {
        query_string = true
        headers      = ["Authorization", "Origin"]
        cookies = {
          forward = "all"
        }
      }
    }
  ]

  # Custom error responses
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  # Geographic restrictions (optional)
  geo_restrictions = {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB", "DE"]
  }

  # SSL Certificate configuration (using CloudFront default certificate)
  viewer_certificate = {
    cloudfront_default_certificate = true
    # Uncomment below and comment above to use custom certificate
    /*
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    */
  }

  tags = {
    Environment = "test"
    Project     = "platform-resources"
    Example     = "complete"
  }
}

# Outputs
output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.static.id
}

output "api_gateway_url" {
  description = "The URL of the API Gateway stage"
  value       = aws_api_gateway_stage.api.invoke_url
} 