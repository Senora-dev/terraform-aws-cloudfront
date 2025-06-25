# AWS CloudFront Terraform Module

This Terraform module creates an AWS CloudFront distribution with highly customizable configuration options. The module is designed to be flexible and reusable across different use cases and organizations.

## Features

- Supports both S3 and custom origins
- Configurable cache behaviors with support for ordered cache behaviors
- Flexible SSL/TLS certificate configuration
- Geographic restrictions support
- Custom error responses
- Web Application Firewall (WAF) integration
- IPv6 support
- Comprehensive tagging support

## Usage

### Basic Example with S3 Origin

```hcl
module "cloudfront" {
  source = "Senora-dev/cloudfront/aws"

  enabled             = true
  is_ipv6_enabled    = true
  distribution_comment = "My CloudFront Distribution"
  price_class        = "PriceClass_100"
  
  origins = [{
    domain_name = "my-bucket.s3.amazonaws.com"
    origin_id   = "my-s3-origin"
    s3_origin_config = {
      origin_access_identity = "origin-access-identity/cloudfront/XXXXX"
    }
  }]

  default_cache_behavior = {
    target_origin_id    = "my-s3-origin"
    allowed_methods     = ["GET", "HEAD"]
    cached_methods      = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Example with Custom Origin and Multiple Cache Behaviors

```hcl
module "cloudfront" {
  source = "path/to/module"

  enabled             = true
  is_ipv6_enabled    = true
  distribution_comment = "My Custom Origin Distribution"
  
  origins = [{
    domain_name = "api.example.com"
    origin_id   = "my-custom-origin"
    custom_origin_config = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }]

  default_cache_behavior = {
    target_origin_id       = "my-custom-origin"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values = {
      query_string = true
      headers      = ["Authorization"]
      cookies = {
        forward = "all"
      }
    }
  }

  ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "my-custom-origin"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = "https-only"
      forwarded_values = {
        query_string = true
        headers      = ["Origin"]
        cookies = {
          forward = "none"
        }
      }
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:XXXXXXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

## Requirements

- AWS Provider >= 4.0
- Terraform >= 1.0

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled | Whether the distribution is enabled | `bool` | `true` | no |
| is_ipv6_enabled | Whether IPv6 is enabled for the distribution | `bool` | `true` | no |
| distribution_comment | Comment for the distribution | `string` | `null` | no |
| price_class | Price class for the distribution | `string` | `"PriceClass_100"` | no |
| aliases | Extra CNAMEs for the distribution | `list(string)` | `[]` | no |
| default_root_object | Default root object | `string` | `null` | no |
| origins | List of origins for the distribution | `list(object)` | n/a | yes |
| default_cache_behavior | Default cache behavior configuration | `object` | n/a | yes |
| ordered_cache_behaviors | List of ordered cache behaviors | `list(object)` | `[]` | no |
| geo_restrictions | Geographic restriction configuration | `object` | `null` | no |
| viewer_certificate | SSL/TLS certificate configuration | `object` | See variables.tf | no |
| custom_error_responses | Custom error response configuration | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| distribution_id | The identifier for the distribution |
| distribution_arn | The ARN for the distribution |
| distribution_domain_name | The domain name of the distribution |
| distribution_hosted_zone_id | The CloudFront Route 53 zone ID |
| distribution_status | The current status of the distribution |
| distribution_last_modified_time | The date and time the distribution was last modified |
| distribution_in_progress_validation_batches | The number of invalidation batches currently in progress |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT Licensed. See LICENSE for full details.

## Maintainers

This module is maintained by [Senora.dev](https://senora.dev). 