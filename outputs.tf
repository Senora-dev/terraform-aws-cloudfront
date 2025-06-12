output "distribution_id" {
  description = "The identifier for the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}

output "distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.arn
}

output "distribution_domain_name" {
  description = "The domain name corresponding to the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to"
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "distribution_status" {
  description = "The current status of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.status
}

output "distribution_last_modified_time" {
  description = "The date and time the distribution was last modified"
  value       = aws_cloudfront_distribution.distribution.last_modified_time
}

output "distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress"
  value       = aws_cloudfront_distribution.distribution.in_progress_validation_batches
} 