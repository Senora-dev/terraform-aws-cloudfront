# S3 Static Website with CloudFront Example

This example demonstrates how to use the CloudFront module to create a distribution for serving static content from an S3 bucket.

## Features

- Creates an S3 bucket with secure settings
- Sets up CloudFront Origin Access Identity (OAI)
- Configures bucket policy to allow access only from CloudFront
- Sets up CloudFront distribution with S3 origin
- Includes custom error responses for Single Page Application (SPA) support

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
| s3_bucket_name | The name of the S3 bucket | 