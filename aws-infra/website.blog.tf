locals {
  seanmcleaish_bucket  = var.aws_s3_page["seanmcleaish.com"].bucket_name
  seanmcleaish_domain  = var.aws_s3_page["seanmcleaish.com"].domain_name
  seanmcleaish_zone_id = data.aws_route53_zone.seanmcleaish_zone.zone_id
}

module "website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.3.0"

  acl           = "private"
  bucket        = local.seanmcleaish_bucket
  force_destroy = true

  attach_policy = true
  policy        = data.aws_iam_policy_document.cloudfront.json

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
}

resource "aws_cloudfront_function" "routing" {
  code    = file("functions/routing.js")
  name    = "routing"
  runtime = "cloudfront-js-1.0"
}

