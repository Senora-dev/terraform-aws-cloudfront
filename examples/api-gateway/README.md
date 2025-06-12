# API Gateway with CloudFront Example

This example demonstrates how to use the CloudFront module to create a distribution for an API Gateway endpoint.

## Features

- Creates an API Gateway REST API with a mock integration
- Sets up CloudFront with API Gateway as a custom origin
- Configures advanced cache behaviors
- Demonstrates header and cookie forwarding
- Shows path-based routing with ordered cache behaviors

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

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_domain_name | The domain name of the CloudFront distribution |
| api_gateway_url | The URL of the API Gateway stage |

## Notes

- The example uses a mock integration in API Gateway. In a real-world scenario, you would integrate with your actual backend services.
- The CloudFront distribution is configured to forward the Authorization header, which is important for authenticated API calls.
- The example includes a public endpoint under `/api/public/*` with different caching settings. 