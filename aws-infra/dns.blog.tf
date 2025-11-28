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
