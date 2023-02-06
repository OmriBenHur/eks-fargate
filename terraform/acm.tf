resource "aws_route53_zone" "fargate-zone" {
  name = var.domain-name
}

resource "aws_acm_certificate" "fargate-certificate" {
  domain_name       = var.domain-name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "fargate-app-dns" {
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.fargate-certificate.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.fargate-certificate.domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.fargate-certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.fargate-zone.zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "hello_cert_validate" {
  certificate_arn = aws_acm_certificate.fargate-certificate.arn
  validation_record_fqdns = [aws_route53_record.fargate-app-dns.fqdn]
}