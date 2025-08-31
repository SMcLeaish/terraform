provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_route53_zone" "mcleaish_zone" {
  name = "mcleaish.com"
}

resource "aws_route53_zone" "seanmcleaish_zone" {
  name = "seanmcleaish.com"
}

resource "aws_route53domains_registered_domain" "mcleaish_domain" {
  domain_name = "mcleaish.com"

  dynamic "name_server" {
    for_each = aws_route53_zone.mcleaish_zone.name_servers
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53domains_registered_domain" "seanmcleaish_domain" {
  domain_name = "seanmcleaish.com"

  dynamic "name_server" {
    for_each = aws_route53_zone.seanmcleaish_zone.name_servers
    content {
      name = name_server.value
    }
  }
}

resource "aws_acm_certificate" "mcleaish_cert" {
  provider          = aws.us_east_1
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

  tags = {
    Name = "mcleaish-cert"
  }
}


resource "aws_route53_record" "mcleaish_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mcleaish_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
      zone_id = contains(["seanmcleaish.com", "*.seanmcleaish.com"], dvo.domain_name) ? aws_route53_zone.seanmcleaish_zone.zone_id : aws_route53_zone.mcleaish_zone.zone_id
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
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.mcleaish_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.mcleaish_cert_validation : record.fqdn]
}


resource "aws_route53_record" "api_record" {
  zone_id = aws_route53_zone.seanmcleaish_zone.zone_id
  name    = "api.seanmcleaish.com"
  type    = "A"
  ttl     = 300
  records = ["152.117.99.115"]
}
