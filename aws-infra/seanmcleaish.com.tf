
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}


locals {
  seanmcleaish_bucket = var.aws_s3_page["seanmcleaish.com"].bucket_name
  seanmcleaish_domain = var.aws_s3_page["seanmcleaish.com"].domain_name 
  seanmcleaish_zone_id = data.aws_route53_zone.seanmcleaish_zone.zone_id
}

data "aws_route53_zone" "seanmcleaish_zone" {
  name         = "${local.seanmcleaish_domain}."
  private_zone = false
}

resource "aws_route53_record" "root_alias" {
  zone_id = local.seanmcleaish_zone_id
  name    = local.seanmcleaish_domain  
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = local.seanmcleaish_zone_id
  name    = "www.${local.seanmcleaish_domain}"  
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid = "CloudFrontOAItoS3"
    actions = ["s3:GetObject"]
    effect = "Allow"
    resources = ["${module.website.s3_bucket_arn}/*"]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      values = [module.cdn.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }
}

module "website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.3.0"

  acl = "private"
  bucket = "${local.seanmcleaish_bucket}"
  force_destroy = true

  attach_policy = true
  policy = data.aws_iam_policy_document.cloudfront.json

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  providers = {
    aws = aws.us-east-1
  }

  validation_method = "DNS"
  zone_id = "${local.seanmcleaish_zone_id}"


  domain_name = "${local.seanmcleaish_domain}"
  subject_alternative_names = [
    "*.${local.seanmcleaish_domain}",
  ]
}

resource "aws_cloudfront_function" "routing" {
  code    = file("functions/routing.js")
  name    = "routing"
  runtime = "cloudfront-js-1.0"
}

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
  default_root_object = "index.html"

  default_cache_behavior = {
    target_origin_id       = "website_s3"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress = true

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
    error_code = 404
    response_code      = 404
    response_page_path = "/404.html"
  }, {
    error_code = 403
    response_code      = 404
    response_page_path = "/404.html"
  }]
}
