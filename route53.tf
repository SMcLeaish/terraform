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
