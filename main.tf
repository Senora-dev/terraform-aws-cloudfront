#--- CloudFront Distribution ---#
resource "aws_cloudfront_distribution" "distribution" {
  enabled             = var.enabled
  is_ipv6_enabled    = var.is_ipv6_enabled
  comment            = var.distribution_comment
  price_class        = var.price_class
  aliases            = var.aliases
  default_root_object = var.default_root_object
  retain_on_delete   = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id         = var.web_acl_id

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name              = origin.value.domain_name
      origin_id               = origin.value.origin_id
      origin_path             = lookup(origin.value, "origin_path", null)
      connection_attempts     = lookup(origin.value, "connection_attempts", 3)
      connection_timeout      = lookup(origin.value, "connection_timeout", 10)

      dynamic "s3_origin_config" {
        for_each = lookup(origin.value, "s3_origin_config", null) != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin_config", null) != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 60)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 60)
        }
      }

      dynamic "custom_header" {
        for_each = coalesce(lookup(origin.value, "custom_headers", []), [])
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = [var.default_cache_behavior]
    content {
      target_origin_id       = default_cache_behavior.value.target_origin_id
      viewer_protocol_policy = default_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = default_cache_behavior.value.allowed_methods
      cached_methods         = default_cache_behavior.value.cached_methods
      compress              = lookup(default_cache_behavior.value, "compress", true)
      field_level_encryption_id = lookup(default_cache_behavior.value, "field_level_encryption_id", null)

      cache_policy_id          = lookup(default_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id = lookup(default_cache_behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(default_cache_behavior.value, "response_headers_policy_id", null)

      dynamic "forwarded_values" {
        for_each = lookup(default_cache_behavior.value, "forwarded_values", null) != null ? [default_cache_behavior.value.forwarded_values] : []
        content {
          query_string = forwarded_values.value.query_string
          headers      = lookup(forwarded_values.value, "headers", [])

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = lookup(forwarded_values.value.cookies, "whitelisted_names", null)
          }
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress              = lookup(ordered_cache_behavior.value, "compress", true)

      cache_policy_id          = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)

      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "forwarded_values", null) != null ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string = forwarded_values.value.query_string
          headers      = lookup(forwarded_values.value, "headers", [])

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = lookup(forwarded_values.value.cookies, "whitelisted_names", null)
          }
        }
      }
    }
  }

  #--- Geo Restrictions ---#
  dynamic "restrictions" {
    for_each = [1]
    content {
      geo_restriction {
        restriction_type = try(var.geo_restrictions.restriction_type, "none")
        locations        = try(var.geo_restrictions.locations, [])
      }
    }
  }

  #--- SSL/TLS Configuration ---#
  viewer_certificate {
    acm_certificate_arn            = lookup(var.viewer_certificate, "acm_certificate_arn", null)
    cloudfront_default_certificate = lookup(var.viewer_certificate, "cloudfront_default_certificate", null)
    iam_certificate_id            = lookup(var.viewer_certificate, "iam_certificate_id", null)
    minimum_protocol_version      = lookup(var.viewer_certificate, "minimum_protocol_version", "TLSv1.2_2021")
    ssl_support_method           = lookup(var.viewer_certificate, "ssl_support_method", "sni-only")
  }

  #--- Custom Error Responses ---#
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code        = lookup(custom_error_response.value, "response_code", null)
      response_page_path   = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  tags = var.tags
} 