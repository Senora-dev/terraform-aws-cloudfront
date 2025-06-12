variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "distribution_comment" {
  description = "Comment to describe the CloudFront distribution"
  type        = string
  default     = null
}

variable "price_class" {
  description = "Price class for this distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Object that you want CloudFront to return when an end user requests the root URL"
  type        = string
  default     = null
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource"
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Whether to wait for the distribution deployment to complete"
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "ID of the AWS WAF web ACL that is associated with the distribution"
  type        = string
  default     = null
}

variable "origins" {
  description = "List of origins for the distribution"
  type = list(object({
    domain_name         = string
    origin_id          = string
    origin_path        = optional(string)
    connection_attempts = optional(number)
    connection_timeout  = optional(number)
    s3_origin_config   = optional(object({
      origin_access_identity = string
    }))
    custom_origin_config = optional(object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    }))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })))
  }))
}

variable "default_cache_behavior" {
  description = "Default cache behavior for this distribution"
  type = object({
    target_origin_id           = string
    viewer_protocol_policy     = string
    allowed_methods           = list(string)
    cached_methods            = list(string)
    compress                  = optional(bool)
    field_level_encryption_id = optional(string)
    cache_policy_id           = optional(string)
    origin_request_policy_id  = optional(string)
    response_headers_policy_id = optional(string)
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string))
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string))
      })
    }))
  })
}

variable "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors for this distribution"
  type = list(object({
    path_pattern             = string
    target_origin_id        = string
    viewer_protocol_policy  = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    compress               = optional(bool)
    cache_policy_id        = optional(string)
    origin_request_policy_id = optional(string)
    response_headers_policy_id = optional(string)
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string))
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string))
      })
    }))
  }))
  default = []
}

variable "geo_restrictions" {
  description = "Geographic restriction configuration for the distribution"
  type = object({
    restriction_type = string
    locations        = list(string)
  })
  default = null
}

variable "viewer_certificate" {
  description = "SSL/TLS certificate configuration for the distribution"
  type = object({
    acm_certificate_arn            = optional(string)
    cloudfront_default_certificate = optional(bool)
    iam_certificate_id            = optional(string)
    minimum_protocol_version      = optional(string)
    ssl_support_method           = optional(string)
  })
  default = {
    cloudfront_default_certificate = true
  }
}

variable "custom_error_responses" {
  description = "List of custom error responses"
  type = list(object({
    error_code            = number
    response_code        = optional(number)
    response_page_path   = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Tags to assign to the distribution"
  type        = map(string)
  default     = {}
} 