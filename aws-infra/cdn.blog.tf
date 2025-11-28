module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "4.0.0"

  aliases = ["${local.seanmcleaish_domain}", "*.${local.seanmcleaish_domain}"]

  comment             = "Resume Page"
  enabled             = true
  staging             = false
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_control = true
  default_root_object          = "index.html"

  default_cache_behavior = {
    target_origin_id       = "website_s3"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    use_forwarded_values = false

    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
    response_headers_policy_name = "Managed-SimpleCORS"

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.routing.arn
      }
    }
  }

  origin = {
    website_s3 = {
      domain_name           = module.website.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3"
    }
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response = [{
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
    }, {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }]
}
