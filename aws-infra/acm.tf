resource "aws_acm_certificate" "mcleaish_cert" {
  domain_name       = "mcleaish.com"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.mcleaish.com",
    "seanmcleaish.com",
    "*.seanmcleaish.com",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "mcleaish_zone" {
  name         = "mcleaish.com."
  private_zone = false
}

data "aws_route53_zone" "seanmcleaish_zone" {
  name         = "seanmcleaish.com."
  private_zone = false
}

resource "aws_route53_record" "mcleaish_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mcleaish_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
      zone_id = dvo.domain_name == "seanmcleaish.com" || dvo.domain_name == "*.seanmcleaish.com" ? data.aws_route53_zone.seanmcleaish_zone.zone_id : data.aws_route53_zone.mcleaish_zone.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "mcleaish_cert_validation" {
  certificate_arn         = aws_acm_certificate.mcleaish_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.mcleaish_cert_validation : record.fqdn]
}
