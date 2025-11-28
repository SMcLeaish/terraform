module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  providers = {
    aws = aws.us-east-1
  }

  validation_method = "DNS"
  zone_id           = local.seanmcleaish_zone_id


  domain_name = local.seanmcleaish_domain
  subject_alternative_names = [
    "*.${local.seanmcleaish_domain}",
  ]
}
