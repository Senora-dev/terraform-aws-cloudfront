# Complete CloudFront Module Example

This example demonstrates a comprehensive setup of the CloudFront module, showcasing multiple features and integration options.

## Features

- Multiple origins (S3 and API Gateway)
- WAF integration with AWS managed rules
- Geographic restrictions
- Custom SSL certificate support (commented out by default)
- Multiple cache behaviors with different settings
- Custom error responses
- Comprehensive tagging

## Architecture

The example creates the following architecture:

1. **Static Content Delivery**:
   - S3 bucket with secure settings
   - CloudFront OAI for S3 access
   - Default cache behavior for static content

2. **API Integration**:
   - API Gateway with mock endpoint
   - Custom origin configuration
   - Path-based routing for API endpoints

3. **Security**:
   - WAF Web ACL with AWS managed rules
   - Geographic restrictions
   - SSL/TLS configuration options
   - Secure bucket policies

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources anymore.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| random | >= 3.0 |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_domain_name | The domain name of the CloudFront distribution |
| cloudfront_id | The ID of the CloudFront distribution |
| s3_bucket_name | The name of the S3 bucket |
| api_gateway_url | The URL of the API Gateway stage |

## Notes

### Custom Domain Setup

To use a custom domain:

1. Uncomment the ACM certificate resource
2. Update the domain name in the certificate resource
3. Update the viewer certificate configuration in the CloudFront module
4. Set up DNS records in Route 53 or your DNS provider

### WAF Configuration

The example includes a basic WAF configuration with AWS managed rules. In production:

- Add custom rules based on your security requirements
- Configure rate limiting
- Add IP-based rules
- Enable logging

### Geographic Restrictions

The example includes geographic restrictions to whitelist specific countries. Modify the locations list based on your requirements:

```hcl
geo_restrictions = {
  restriction_type = "whitelist"
  locations        = ["US", "CA", "GB", "DE"]
}
``` 