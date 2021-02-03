variable "public_bucket_domain_name" {}
variable "lambda_edge_bucket_domain_name" {}
variable "origin_id" {}
variable "project_prefix" {}
variable "edge_lambda_html_qualified_arn" {}
variable "acm_arn"  {}
variable "domain_website" {}
variable "route53_zone_id" {}

// variable "edge_lambda_qualified_arn" {}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "test origin identity"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${var.public_bucket_domain_name}"
    origin_id   = "${var.origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "A comment"
  default_root_object = "index.html"

  # store logs in the lamdba edge bucket 
  logging_config {
    include_cookies = true
    bucket          = "${var.lambda_edge_bucket_domain_name}"
    prefix          = "${var.project_prefix}"
  }

  
  aliases = ["azuka.ga"]

  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  ordered_cache_behavior {
    path_pattern     = "/api*"
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = true
      headers      = ["Origin"] # can add custome headers here if need to forward
      cookies {
        forward = "all"
      }

      // also query_string_cache_keys for controlling query string caching
    }

    min_ttl                = 0
    default_ttl            = 600
    max_ttl                = 1200
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = "${var.edge_lambda_html_qualified_arn}"
      include_body = true
    }
  }



  # edge locations are different prices, PriceClass_All give you everything
  # see https://aws.amazon.com/cloudfront/pricing/

  # price_class = "PriceClass_All" # all regions
  # price_class = "PriceClass_200" # All but Austroalia and South America
  price_class = "PriceClass_100" # Just EU and US/Canada

  # restrictions {
  #   geo_restriction {
  #     restriction_type = "whitelist"
  #     locations        = ["US", "CA", "GB", "DE"]
  #   }
  # }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
      acm_certificate_arn =  "${var.acm_arn}"
      ssl_support_method  = "sni-only"

  }


  tags = {
    Environment = "production"
  }
/*
  viewer_certificate {
    cloudfront_default_certificate = true
  }
*/
}



# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "example" {
  name    = "${var.domain_website}"                                      # aws_api_gateway_domain_name.example.domain_name
  type    = "A"
  zone_id = "${var.route53_zone_id}"

  alias  {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"    # aws_api_gateway_domain_name.example.regional_domain_name
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"    # aws_api_gateway_domain_name.example.regional_zone_id
  }
}




output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "edge_lambda_cloud_url" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}/api"
}

# to invalidate
# aws cloudfront create-invalidation --distribution-id $CDN_DISTRIBUTION_ID --paths "/*"
